# ADR 0022 — Sinalização de Conteúdo Gerado, Blindagem do Release e Transparência de Dados

**Data:** 03 de Outubro de 2026  
**Status:** 🟢 Aceito  
**Autores:** Arquiteto de Software Principal, Especialistas `engineer`, `secops-privacy`, `devops`, `theologian`  

---

## 1. Contexto

A auditoria de maturidade de 03/10/2026 (`docs/releases/app-maturity-audit-2026-10.md`) identificou bloqueadores de publicação nas lojas:

1. **Release sem chaves de runtime:** em `kReleaseMode` o `EnvConfig` ignora o `.env` e lê somente `--dart-define`. O `release-on-main.yml` passava apenas `FIREBASE_API_KEY`, gerando um AAB sem Gemini e com paywall vazio. Nenhum teste detectava o problema (rodam em debug).
2. **Sem mecanismo de denúncia de conteúdo gerado**, exigido pela política de IA generativa do Google Play (e pela Guideline 1.2 da Apple para conteúdo gerado por usuários/IA).
3. **Política de Privacidade divergente do código:** afirmava que apenas a passagem bíblica era enviada ao Gemini, mas a reflexão pessoal (Meditatio) e resumos de sessões também são enviados. Havia ainda alegação de "criptografia de ponta a ponta / zero-knowledge" que não se sustenta (o cofre de chaves usa um pepper estático em release — pendência R1 da auditoria).
4. **Assinatura silenciosa com chave de debug** quando o keystore estava ausente.

## 2. Decisão

### 2.1 Sinalização de conteúdo ("Sinalizar este trecho")
- Nova capacidade na feature `lectio_divina`: entidade `AiContentReport`, `SubmitAiContentReportUseCase`, `AiContentReportRepository` (+ impl/datasource Firestore), `AiContentReportBloc` e widget `ReportAiContentButton`.
- O rótulo evita termos técnicos ("IA", "algoritmo"), preservando o **isolamento tecnologia × oração**; a divulgação técnica fica na política de privacidade.
- Dados mínimos: motivo, etapa, trecho (≤ 600 caracteres), comentário opcional (≤ 500) e `uid`. O truncamento é feito no caso de uso (minimização — LGPD).
- Persistência em `ai_content_reports` (Firestore). `firestore.rules` permite **somente `create`** pelo próprio usuário autenticado, com validação de campos, enumerações e limites de tamanho; leitura/edição/exclusão são negadas ao cliente.
- O Bloc é resolvido via DI **apenas ao abrir o diálogo** (`registerFactory`), sem custo no build das páginas de leitura.

### 2.2 Blindagem do pipeline de release
- `release-on-main.yml`: novo *smoke check* que **falha o build** se faltarem os segredos essenciais (Firebase, Gemini e assinatura Android). A chave RevenueCat é **opcional enquanto não houver conta de desenvolvedor Google/Apple** (emite aviso e o build sai sem assinaturas, adequado aos testes internos via App Distribution), mas uma chave de Test Store (`test_...`) **bloqueia** o build, pois o SDK trava em release. Antes de publicar na loja, a chave `goog_...` torna-se obrigatória; `GEMINI_API_KEY` e `REVENUECAT_*` passam a ser injetados via `--dart-define`; `flutter analyze` + `flutter test` rodam **antes** do build de produção.
- `android/app/build.gradle.kts`: tarefas `assemble*/bundle*Release` **falham sem keystore**, salvo opt-in explícito `ALLOW_DEBUG_SIGNING=true`.
- `AndroidManifest.xml`: permissão `AD_ID` removida (`tools:node="remove"`), pois o app não exibe anúncios.

### 2.3 Transparência de dados
- `PRIVACY_POLICY.md`, `public/index.html` e `legal_texts.dart` (pt/en/es/la) reescritos para refletir os fluxos reais (Gemini, GA4, Crashlytics, App Check, FCM, sinalização), bases legais (LGPD art. 7º/11) e transferência internacional.
- `docs/compliance/app_store_play_store_ai_privacy.md` corrigido (Data Safety e App Privacy Details); item falso do `PrivacyInfo.xcprivacy` desmarcado.
- `subscriptionAutoRenewNote` nos 18 idiomas inclui a cláusula exigida pela Apple 3.1.2 (cobrança na conta da loja e renovação salvo cancelamento ≥ 24 h antes do fim do período).

## 3. Consequências

**Positivas:** release deixa de poder sair "mudo" (sem IA/paywall); conformidade com a política de IA generativa do Play; política de privacidade verificável contra o código; menor superfície de erro humano na assinatura.

**Negativas / dívida assumida:**
- A chave Gemini ainda é embarcada no binário via `--dart-define` (extraível). Mitigação planejada: migração para Firebase AI Logic + App Check (Onda 2).
- Faltam o consentimento explícito antes do modo nuvem, a correção do pepper do cofre (R1) e toda a infraestrutura iOS (entitlements, PrivacyInfo no target, pipeline TestFlight) — Ondas 2 e 3.
- O fluxo de revisão das sinalizações é manual (Console do Firebase); uma Cloud Function de notificação é uma evolução futura.

## 4. Alternativas Consideradas
- **`mailto:` para denúncias:** descartado — sem rastreabilidade, depende de cliente de e-mail e vaza o endereço do usuário.
- **Enviar o texto integral da sessão:** descartado — viola minimização de dados em contexto de dado sensível (convicção religiosa).
