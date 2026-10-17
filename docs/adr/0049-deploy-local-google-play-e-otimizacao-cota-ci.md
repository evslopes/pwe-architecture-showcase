# ADR 0049: Orquestrador de Deploy Local Google Play (API v3) e Otimização de Cota do GitHub Actions

- **Status:** Aceito
- **Data:** 17 de Outubro de 2026
- **Decisores:** Arquiteto de Software Principal, Agentes `devops`, `finops`, `platform-mobile`, `task-finisher`

## Contexto e Problema

Durante o ciclo de validação nas trilhas de **Teste Interno (`internal`)** e **Teste Fechado (`alpha`)** da Google Play Store:
1. O envio de builds dependia exclusivamente do workflow `release-on-main.yml` na nuvem do GitHub Actions (~22 a 28 minutos de cota por execução), mesmo estando toda a cadeia de assinatura (`android/key.properties`, `upload-keystore.jks`), chaves (`.env`) e credenciais de publicação (`<REDACTED_GCP_PROJECT_ID>-*.json`) disponíveis localmente no notebook de desenvolvimento.
2. O workflow `ci.yml` executava automaticamente a cada `push` na branch `develop` (~12 a 15 minutos por tarefa), duplicando os Quality Gates (`dart format`, `flutter analyze` e `flutter test`) que já são executados obrigatoriamente na máquina local pelo `tool/pwe_release.dart`.

## Decisão

1. **Orquestrador Local de Build & Publicação (`tool/pwe_local_deploy.dart`):**
   - Lê automaticamente o `.env` local e injeta todas as chaves via `--dart-define`;
   - Compila o Android App Bundle assinado e ofuscado (`flutter build appbundle --release --flavor prod --obfuscate --split-debug-info=build/app/outputs/symbols`);
   - Autentica diretamente na **Google Play Android Publisher API v3** (`edits.insert` $\rightarrow$ `bundles.upload` $\rightarrow$ `tracks.update` $\rightarrow$ `edits.commit`) via assinatura JWT RS256 nativa (`pointycastle`/`encrypt`) com fallback automático de status `completed` para `draft`;
   - Suporta publicação opcional da versão Web (`/app/`) e Landing Page no Firebase Hosting (`--web` / `--only-web`) e sincronização da branch `main` + tag Git com o marcador `[local-release]` (`--sync-main`).
2. **Racionalização de Gatilhos no CI/CD (`.github/workflows/ci.yml` e `.github/workflows/release-on-main.yml`):**
   - Remoção do gatilho redundante `push: branches: [develop]` em `ci.yml`, mantendo a execução automática em `pull_request` (`develop`, `main`, `feature/**`, `hotfix/**`) e `workflow_dispatch`.
   - Adição de guarda condicional `!contains(github.event.head_commit.message, '[local-release]')` no job inicial de `release-on-main.yml`, permitindo atualizar `main` e criar tags a partir de releases locais sem acionar novo build na nuvem.
3. **Governança nos Agentes e Skills (`task-finisher`, `devops`, `AGENTS.md`, `GEMINI.md`):**
   - Inclusão da pergunta interativa obrigatória (`ask_question`) no rito de release e finalização de tarefas para que o usuário escolha explicitamente se a release será **Local (no notebook)** ou **em Nuvem (no GitHub Actions)**.

## Consequências

- **Positivas:** Consumo de **0 minutos** da franquia do GitHub Actions para releases diárias de Teste Interno/Fechado e pushes na `develop`, reduzindo o tempo total de build + upload de ~25 minutos para ~3 a 4 minutos usando o cache local do Gradle, com controle explícito pelo usuário a cada release.
- **Negativas / Trade-offs:** Em testes locais onde não exista arquivo `.env` (como no runner de CI), o modo `--dry-run` aceita variáveis de ambiente ou placeholders quando em validação de sintaxe.
