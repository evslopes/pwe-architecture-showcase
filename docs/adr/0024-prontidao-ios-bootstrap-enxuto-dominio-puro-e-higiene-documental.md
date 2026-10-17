# ADR 0024 — Prontidão iOS, Bootstrap Enxuto, Domínio Puro e Higiene Documental

**Data:** 03 de Outubro de 2026  
**Status:** 🟢 Aceito (parcial — itens remanescentes da Onda 3 listados em §4)  
**Autores:** Arquiteto de Software Principal, Especialistas `engineer`, `mobile-ios`, `a11y`, `technical-writer`  

---

## 1. Contexto

A auditoria de maturidade de 03/10/2026 (Onda 3 — iOS, limpeza e v1.0.0) apontou, entre outros:

1. **iOS incompleto:** sem `.entitlements` (Sign in with Apple já implementado, mas sem capability; FCM sem `aps-environment`), `PrivacyInfo.xcprivacy` **fora do target** do Xcode e divergente da política de privacidade, `IPHONEOS_DEPLOYMENT_TARGET = 13.0` (Firebase SDK 12 exige iOS 15+) e bundle id `com.example.pwe.RunnerTests` residual.
2. **Cold start pesado:** `await Purchases.configure` dentro de `di.init()` e `LectioBloc` (1.379 linhas, 15 dependências) instanciado no bootstrap apenas para duplicar o carregamento da liturgia já feito pelo `DailyLiturgyBloc`.
3. **Acessibilidade tipográfica:** `main.dart` substituía por completo o `TextScaler` do sistema (clamp 0,8–1,45), ignorando a configuração do aparelho.
4. **Camada de domínio impura:** `soul_state.dart`, `spiritual_fruit.dart` e `reading_preferences.dart` importavam `package:flutter/material.dart` (com extensões de UI duplicadas já existentes em `presentation/extensions/`).
5. **Provider incorreto:** `ModelDownloadBloc` é `registerLazySingleton`, mas era provido com `BlocProvider(create:)`, o que o fecha ao desmontar o provider.
6. **Higiene documental:** `README` desatualizado (badge v0.9.27, "939 testes", "4 idiomas", "Gemma 2B", "Flutter 3.10", sem passo de `.env`), ausência de `.env.example` (bloqueado pelo `.gitignore`), 222 links `file:///c:/Dev/pwE/...` (quebrados fora da máquina do autor).

## 2. Decisão

### 2.1 iOS (configuração — **não validada em dispositivo/Xcode**, pois o ambiente é Windows e ainda não há conta Apple)
- `ios/Runner/Runner.entitlements` com `com.apple.developer.applesignin` e `aps-environment`; `CODE_SIGN_ENTITLEMENTS` nas três configurações do target Runner.
- `PrivacyInfo.xcprivacy` adicionado ao grupo Runner e à fase *Resources*; conteúdo realinhado à política (e-mail, nome, user ID, conteúdo do usuário, histórico de compras, falhas, desempenho e interação — todos vinculados ao usuário; sem tracking).
- Deployment target `15.0` (projeto e `AppFrameworkInfo.plist`); bundle id do RunnerTests alinhado ao app.

### 2.2 Bootstrap enxuto
- `SubscriptionRemoteDataSourceImpl.initialize()` passou a ser **idempotente** (`Future` memoizado) e toda operação aguarda a configuração via `_ensureConfigured()`. O DI dispara `unawaited(initialize())` — o `Purchases.configure` sai do caminho crítico sem criar corrida.
- `LectioBloc` deixa de ser provido em `main.dart` e deixa de receber despacho no `language_selection_dialog` (a liturgia é carregada exclusivamente pelo `DailyLiturgyBloc`). A classe e seus testes permanecem **temporariamente** (acoplados a `lectio_state.dart`, reexportado por `LectioSessionState`) — remoção física na próxima sprint (§4).

### 2.3 Acessibilidade
- Novo `resolveAppTextScaler` (`lib/core/utils/text_scale_utils.dart`): multiplica a escala do **sistema** pela preferência de leitura (base 18) e limita a 0,8–2,0. Testado.

### 2.4 Pureza do domínio e providers
- Removidos de `SoulState`, `SpiritualFruit` e `ReadingPreferences` os membros dependentes de Flutter (`icon`, `accentColor`, `textAlign`, `locale`), já existentes nas extensões de `presentation/extensions/`. Consumidores passaram a importar a extensão.
- `ModelDownloadBloc` provido com `BlocProvider.value`.

### 2.5 Documentação
- `README.md` corrigido; novo `.env.example` (com exceção `!.env.example` no `.gitignore`); links `file:///c:/Dev/pwE/...` convertidos para caminhos relativos (e para URLs do GitHub nos dois `CHANGELOG.md`, que precisam permanecer byte-idênticos).

## 3. Consequências

**Positivas:** domínio livre de Flutter; menos trabalho no cold start; respeito à escala de fonte do sistema; privacidade iOS coerente com a política; documentação navegável fora da máquina do autor.

**Riscos / trade-offs:**
- Alterações em `project.pbxproj` e entitlements **não puderam ser compiladas** neste ambiente; devem ser validadas em um Mac (ou macOS runner) antes do primeiro TestFlight. As capabilities exigem App ID configurado no portal Apple.
- Texto até 2,0× pode expor *overflows* em telas densas (cobertos por revisão manual/golden na próxima sprint).
- Combinação multiplicativa: um usuário com fonte de sistema grande **e** preferência de leitura grande atinge o teto de 2,0×.

## 4. Pendências da Onda 3 (não implementadas aqui)

| Item | Observação |
|---|---|
| Remoção física de `LectioBloc`/`lectio_event` e dos 8 arquivos de teste acoplados | Requer separar `lectio_state.dart` (usado por `LectioSessionState`). |
| Google Sign-In iOS (`GIDClientID`, URL scheme, `GoogleService-Info.plist`) | Depende de criar o app iOS no Firebase. |
| `Podfile`/SPM, pipeline de IPA/TestFlight, Fastlane | Depende da conta Apple; `features-inventory.md` ainda afirma que há Fastlane. |
| Camadas: `core → features` (37 imports), `presentation → data` (4), UseCase via `di.sl` em `lectio_page.dart` | Refatoração incremental. |
| 13 *god files* > 800 linhas; cobertura baixa em `llm_*`, `benefactor_page`, `model_download_service_io`; sem golden/`integration_test` | Sprint de qualidade. |
| Dependências (`google_sign_in` 6→7, `equatable` 2, override `pointycastle`, `dio`), assets pesados | — |
| Demais inconsistências documentais (matriz RN-SUB-112, contagens, 9 classes fantasma em `business_rules.md`, gates de cobertura, cloudbuild vs Flutter 3.47.5) | — |
| `LICENSE` | Decisão jurídica do titular. |
