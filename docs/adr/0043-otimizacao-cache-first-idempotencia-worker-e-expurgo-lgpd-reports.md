# ADR 0043: Otimização Cache-First na Navegação Litúrgica, Idempotência Parcial do Worker Cloud Run, Expurgo LGPD em Reports de IA e Fluidez de Inicialização

- **Status:** Aceito
- **Data:** 2026-10-13
- **Autores:** Arquitetura pwE

## Contexto e Problema

Durante a correlação dos logs de teste manual em dispositivo físico (`SM-A346M`, `v0.9.96+122`) com a telemetria real de produção no **Google Cloud Platform** (`Cloud Logging`, `Cloud Run`) e **Firebase** (`Cloud Firestore`, `Crashlytics`) do projeto `<REDACTED_GCP_PROJECT_ID>`, foram diagnosticados quatro gargalos operacionais e de conformidade:

1. **Bypass do Cache-First na Seleção de Datas (`DailyDashboardPage._selectDate`):** O seletor de datas do calendário disparava `LoadDailyLiturgyEvent(..., forceRefresh: true)` a cada mudança de dia, ignorando a caixa local do Hive (`cached_daily_liturgy_box`) e gerando leituras desnecessárias no Cloud Firestore mesmo para datas já cacheadas segundos antes.
2. **Desperdício de Tokens LLM e Falso Alerta Crítico no Worker Cloud Run (`scripts/daily_liturgy_worker.dart`):** Quando a geração de imagem no `gemini-3.1-flash-image` atingia o limite do Free Tier (`HTTP 429 RESOURCE_EXHAUSTED`, `limit: 0`), os documentos eram gravados no Firestore com `theologicalStatus: "verified"`, `nihilObstat: true` e textos/gotas completos, porém com `sacredIconUrl: ""`. Nas execuções subsequentes, `_isDocumentVerified` tratava tais documentos como inválidos, descartando e regenerando todo o texto teológico via Gemini e disparando falsos alertas críticos (`0 de 7 dias futuros garantidos`) no `Buffer Health Monitor`.
3. **Resíduo de `uid` na Coleção `ai_content_reports` Após Exclusão de Conta (LGPD Art. 18 / GDPR Art. 17):** O fluxo `AuthRemoteDataSourceImpl._purgeUserDataFromFirestore` expurgava `users/{uid}`, `sessions`, `session_embeddings`, `security/key_vault` e `profiles/{uid}`, mas não removia denúncias de conteúdo de IA em `ai_content_reports` associadas ao `uid` excluído, e as regras `firestore.rules` bloqueavam `read`/`delete` pelo próprio titular.
4. **Concorrência de Inicialização na Main Thread (`AuthMigrationListener`):** O disparo imediato de `LectioMigrationService.runMigration()` no evento `Authenticated` carregava os `30.522 tokens` do `vocab.txt` (`BertTokenManager`) simultaneamente à renderização do primeiro quadro do `DailyDashboardPage`.

## Decisão

1. **Navegação Cache-First e Deduplicação (`DailyDashboardPage`):**
   - Alterado `_selectDate` para utilizar `forceRefresh: false` (reservando `forceRefresh: true` exclusivamente para o gesto explícito de *pull-to-refresh* e para o botão de *Tentar Novamente* em estado de erro) e adicionada guarda para ignorar cliques repetidos na mesma data já carregada.
2. **Idempotência de Texto Verificado, Circuit Breaker de Imagem e Saúde Real do Buffer (`daily_liturgy_worker.dart`):**
   - Criado `_inspectExistingDocument` distinguindo `isTextVerified` (`theologicalStatus == 'verified'` e `readings.length >= 2`) de `hasSacredIcon`.
   - Documentos com texto já verificado jamais têm seu texto/exegese/gotas regenerados pelo LLM: se houver ícone disponível, aplica-se apenas um `PATCH` cirúrgico (`updateMask.fieldPaths=sacredIconUrl`); se a cota de imagem estiver esgotada, preserva-se o documento intacto com custo zero de tokens.
   - Implementado *Circuit Breaker* (`_imageQuotaExhaustedInRun`) em `_generateSacredIconWithNanoBanana` ao detectar `429` em toda a hierarquia de imagem.
   - Atualizado `_evaluateBufferHealth` para aferir a disponibilidade litúrgica real com base em `isTextVerified`, reportando separadamente a contagem de ícones dedicados vs. fallback canônico Veni Creator.
3. **Expurgo Completo LGPD/GDPR em `ai_content_reports` (`firestore.rules` & `AuthRemoteDataSourceImpl`):**
   - Atualizada a regra `match /ai_content_reports/{reportId}` em `firestore.rules` (`allow read, delete: if isOwner(resource.data.uid); allow update: if false;`) e publicada em produção (`<REDACTED_GCP_PROJECT_ID>`).
   - Incluído o passo `'ai_content_reports'` via `_deleteQueryByUid` em `AuthRemoteDataSourceImpl._purgeUserDataFromFirestore` e removido o documento órfão residual no Firestore.
4. **Adiamento Pós-Primeiro-Frame da Migração RAG (`AuthMigrationListener`):**
   - Agendada a execução de `LectioMigrationService.runMigration()` via `WidgetsBinding.instance.addPostFrameCallback` com janela de estabilização de 3 segundos, liberando a thread principal durante a abertura do Dashboard.

## Consequências

- **Redução de Leituras e Tokens (FinOps):** Navegação instantânea entre datas já visitadas sem leituras repetidas no Firestore e economia de 100% dos tokens de texto no Cloud Run Worker para dias já verificados.
- **Conformidade Total LGPD/GDPR:** Nenhuma coleção do Cloud Firestore retém o `uid` de um usuário após `deleteAccount()`.
- **Observabilidade Limpa:** Eliminação de falsos alertas críticos no `Buffer Health Monitor` do Cloud Run.
