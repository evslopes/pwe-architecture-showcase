# ADR 0048: RevenueCat Web Billing (REST API v1) e Entrega Contínua Multiplataforma (Web & iOS TestFlight)

- **Status:** Aceito
- **Data:** 16 de Outubro de 2026
- **Decisores:** Arquiteto de Software Principal, Agentes `devops`, `platform-mobile`, `engineer`, `finops`

## Contexto e Problema

Com a disponibilização oficial da versão Web (`https://pwe.jhhsolutions.dev/app`) e a preparação para publicação na Apple App Store, era necessário:
1. Automatizar a compilação e publicação do Flutter Web (`/app/`) integrado à Landing Page a cada release na branch `main`.
2. Permitir que fiéis benfeitores mantenham seu status de apoiador reconhecido na versão Web via RevenueCat REST API v1 (`GET /v1/subscribers/{app_user_id}`).
3. Disponibilizar um pipeline dedicado de compilação e envio de `.ipa` assinado ao Apple TestFlight sem onerar os minutos de CI em commits comuns.

## Decisão

1. **CD Web + Landing + Firebase GitOps (`.github/workflows/release-on-main.yml`):** Adição do job `deploy-web-and-landing` que compila `flutter build web --release --base-href="/app/"`, integra os artefatos em `landing/app/` e publica no Firebase Hosting junto com `remoteconfig` e `firestore:indexes`.
2. **RevenueCat Web Billing REST v1 (`SubscriptionRemoteDataSourceImpl` & `SubscriptionStatusModel.fromRevenueCatRestJson`):** Suporte à chave pública `REVENUECAT_WEB_KEY` e consulta direta ao endpoint REST v1 do RevenueCat quando executado na Web (`kIsWeb`), preservando o modo de emulação local quando a chave não estiver definida.
3. **Pipeline iOS TestFlight Sob Demanda (`.github/workflows/ios-release-testflight.yml`):** Workflow `workflow_dispatch` em `macos-latest` com importação segura de certificado `.p12` em Keychain efêmero, geração de `.ipa` ofuscado e upload via App Store Connect API (`xcrun altool`), com fallback automático para validação `--no-codesign` quando executado sem certificados.

## Consequências

- **Positivas:** Paridade completa de entrega contínua entre Android (Google Play), Web (Firebase Hosting) e iOS (TestFlight), com reconhecimento unificado de benfeitores multiplataforma e proteção estrita da franquia de minutos do GitHub Actions.
- **Negativas / Trade-offs:** Exige configuração de `REVENUECAT_WEB_KEY` nos Secrets do GitHub para ativar a verificação REST real na Web em produção.
