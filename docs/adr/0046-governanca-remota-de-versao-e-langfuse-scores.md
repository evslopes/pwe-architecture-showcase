# ADR 0046: Governança Remota de Versão, Firebase GitOps e Scores de Qualidade no Langfuse

- **Status:** Aceito
- **Data:** 16 de Outubro de 2026
- **Decisores:** Arquiteto de Software Principal, Agentes `engineer`, `ai-engineer`, `devops`, `theologian`

## Contexto e Problema

Após a publicação nas lojas (Google Play e Apple App Store), o aplicativo precisa de governança remota para orientar fiéis em versões antigas sobre atualizações críticas (ex.: mudanças de esquema ou certificados), além de versionar declarativamente os parâmetros do Firebase Remote Config e índices do Cloud Firestore no Git. Adicionalmente, os relatos de qualidade da IA enviados pelos usuários precisavam retroalimentar diretamente os traces de observabilidade do Langfuse.

## Decisão

1. **Governança de Ciclo de Vida (`RemoteConfigService` & `VersionGovernanceBanner`):** Adição das chaves remotas `min_supported_build_number`, `recommended_build_number` e `pastoral_seasonal_banner_json`, com componente visual sacro e discreto (`VersionGovernanceBanner`) localizado nos 18 idiomas.
2. **Firebase GitOps (`remoteconfig.template.json` & `firestore.indexes.json`):** Versionamento declarativo do template de Remote Config e dos índices compostos do Firestore na raiz do projeto, referenciados em `firebase.json` e publicados pelo CI/CD.
3. **Feedback Loop no Langfuse (`LangfuseService.recordQualityScore`):** Armazenamento do `lastTraceId` da sessão de meditação/oração e envio assíncrono de score (`POST /api/public/scores`, `name: 'theological_orthodoxy'`) quando um relatório é registrado em `AiContentReportRemoteDataSource`, acompanhado de semeadura idempotente de prompts em `scripts/seed_langfuse_prompts.dart`.

## Consequências

- **Positivas:** Controle remoto imediato de versões mínimas/recomendadas sem necessidade de novo deploy binário, rastreabilidade GitOps completa do Firebase e auditoria teológica fechada com métricas quantitativas no Langfuse.
- **Negativas / Trade-offs:** Nenhuma cobrança adicional de nuvem (Remote Config e Langfuse Scores operam 100% dentro do Free Tier).
