# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.9.116] - 2026-10-17

### Added
- **feat(tooling / showcase / adr)**: implementação do pipeline automatizado de sincronização e sanitização para o repositório público de vitrine arquitetural **`pwe-architecture-showcase`** (ADR 0051):
  - **Sincronizador Baseado em Allowlist (`tool/sync_showcase.dart`)**: orquestrador CLI que exporta exclusivamente artefatos autorizados (`CHANGELOG.md`, 51 ADRs em `docs/adr/`, 8 suítes de diagramas C4/Sequência/Estados em `docs/architecture/`, documentação do comitê de 17 agentes em `docs/ai-governance/` e 4 domínios de *Clean Code Slices* reais + testes em `showcase/`), preservando 100% de sigilo sobre prompts pastorais, matrizes exegéticas das *7 Gotas de Sabedoria*, workers de ingestão CNBB/LitCal e regras de cofre criptográfico.
  - **Motor de Sanitização e Security Leak Scanner (`sanitizeShowcaseContent` & `scanDirectoryForLeaks`)**: redação determinística de identificadores de projetos GCP/Firebase, buckets de ativos, tags de telemetria e links internos privados, seguida por varredura de bloqueio pós-geração contra padrões sensíveis antes de qualquer push.
  - **Suíte de Testes de Invariantes do Showcase (`test/core/architecture/sync_showcase_test.dart`)**: validação automatizada do motor de sanitização, detector de vazamentos e integridade `--dry-run` de toda a allowlist.
  - **Higiene de Links nos ADRs (`docs/adr/README.md` & `docs/adr/0051-*.md`)**: registro do **ADR 0051** e normalização dos caminhos relativos dos ADRs 0045 a 0049 no índice mestre.

## [0.9.115] - 2026-10-17

### Fixed
- **fix(startup / onboarding / profile)**: correção definitiva da reexibição indevida do fluxo de Onboarding e da configuração de perfil após atualizações de versão ou logins de usuários existentes:
  - **Reconciliação de Estado na Inicialização (`SplashPage`, `LoginPage`, `AuthMigrationListener`, `ProfileSetupPage`, `AiSelectionPage` & `WelcomeGuideDialog`)**: unificação e reconciliação automática das flags `onboarding_v2_completed`, `welcome_guide_shown`, `ai_selection_done`, `has_persistent_session` e do estado de consentimento `ICloudAiConsentService` sempre que o usuário já possuir sessão autenticada (`Authenticated`), perfil carregado (`ProfileLoaded`) ou histórico de uso anterior, impedindo o redirecionamento repetitivo para `/onboarding` pelo guard do `GoRouter`.
  - **Singleton Compartilhado para `ProfileBloc` (`profile_injection_container.dart` & `main.dart`)**: alteração do registro de `ProfileBloc` de `registerFactory` para `registerLazySingleton` e provisão via `BlocProvider<ProfileBloc>.value`, garantindo que `OnboardingPage`, `AiSelectionPage` e `SplashPage` leiam a instância já hidratada pelo `AuthMigrationListener` em vez de instanciar um BLoC vazio (`ProfileInitial`).

### Performance
- **perf(startup / liturgy / sacred-icon)**: pré-carregamento em segundo plano da Liturgia Diária e do Ícone Sacro durante a tela de abertura (`SplashPage`):
  - **Inicialização Eager da Liturgia (`main.dart`, `SplashPage` & `DailyDashboardPage`)**: configuração de `lazy: false` com disparo imediato de `LoadDailyLiturgyEvent()` na montagem do `PweApp` e alinhamento da resolução de idioma litúrgico no `DailyDashboardPage.initState` para evitar requisições duplicadas ao entrar no Dashboard.
  - **Pré-Download e Harmonização Assíncrona do Ícone Sacro (`SacredIconHarmonizer.preloadForLiturgy` & `DailyLiturgyBloc`)**: assim que `DailyLiturgyBloc` obtém a liturgia do dia (do cache local ou da CDN/Firestore), os bytes da imagem (`sacredIconUrl` ou fallback canônico) são baixados em segundo plano, salvos no `ISacredIconCacheService` e pré-harmonizados em memória (`ui.Image` no `SacredIconPixelHarmonizer`), entregando o `DailyDashboardPage` com o ícone sacro já renderizado no primeiro frame.

## [0.9.114] - 2026-10-17

### Added
- **docs(architecture / operations / adr)**: criação da suíte de Documentação Técnica Mestre e registro do **ADR 0050**:
  - **Catálogo Técnico de Módulos e Componentes (`docs/architecture/modules_and_components_catalog.md`)**: documentação exaustiva dos 16 subpacotes e 21 serviços de `lib/core/`, das 7 features de `lib/features/` (`auth`, `lectio_divina`, `onboarding`, `profile`, `settings`, `subscription`, `support`) com 13 BLoCs (incluindo os 8 Sub-BLoCs de `lectio_divina`), 36 UseCases, 12 Repositories, 22 DataSources, rota declarativa GoRouter e ecossistema Web/Landing Page (`landing/`).
  - **Manual de Integrações e APIs Externas (`docs/architecture/integrations_and_external_apis.md`)**: especificação técnica das 14 integrações externas e canais nativos (Google Gemini REST + RAG On-Device TFLite, Gemma 4 E2B LiteRT-LM via MethodChannel/EventChannel, GCS Static CDN de Liturgia Diária e Ícones Sagrados Veni Creator, Cloud Firestore com criptografia por campo AES-256-GCM, Firebase Auth/App Check/Remote Config/Crashlytics/Analytics/Performance/FCM, Langfuse REST API v2 para prompts e scores teológicos, RevenueCat SDK nativo + Web Billing REST v1, Google ML Kit OCR, TTS e `timezone`).
  - **Manual de Operações, Gerenciamento e Runbooks (`docs/operations/operations_and_management_manual.md`)**: guia operacional cobrindo gerenciamento de estado e concorrência de BLoCs, governança remota via Firebase Remote Config (`min_supported_build_number`, `recommended_build_number`, `pastoral_seasonal_banner_json`), ciclo fechado de qualidade teológica no Langfuse, segurança Zero-Knowledge, sincronismo dos 18 catálogos ARB (668 chaves), orquestração dos 17 agentes especialistas em 4 pilares, ferramentas CLI (`tool/pwe_release.dart`, `tool/pwe_local_deploy.dart`, `tool/i18n_sync.dart`, `scripts/pwe_doctor.dart`, `scripts/daily_liturgy_worker.dart`), validação em runtime via `/perf-validator` e runbooks Day-2.
  - **Índice de UX/UI Sacro (`docs/ux_ui/README.md`) & ADR 0050 (`docs/adr/0050-validacao-runtime-perf-validator-e-documentacao-tecnica-mestre.md`)**: formalização arquitetural da validação em runtime via Marionette/Dart MCP e da governança da documentação técnica viva.

### Changed
- **docs(sync)**: revisão e sincronização integral dos 35 documentos existentes em `docs/` (`README.md`, `adr/`, `architecture/`, `diagrams/`, `product/`, `features/`, `infrastructure/`, `sdlc/`, `releases/` e `compliance/`) para refletir com 100% de fidelidade o estado atual da versão `v0.9.114+142` (18 idiomas ARB × 668 chaves, 17 agentes especialistas, decomposição completa do antigo `LectioBloc` em 8 Sub-BLoCs, GCS Static CDN >98% offload e deploy híbrido Local Zero-CI vs. Nuvem GitHub Actions).

## [0.9.113] - 2026-10-17

### Added
- **feat(agents / tooling / perf-validator)**: implementação do especialista em validação de runtime `perf-validator` (skill, subagente e workflow `/perf-validator`) para condução autônoma de testes em modo debug via Marionette e Dart MCP:
  - **Procedimento Canônico em 7 Fases (`.agents/skills/perf-validator/SKILL.md`)**: protocolo de validação de estados BLoC, integridade de fluxos da Lectio Divina (Onboarding → Auth Visitante → Perfil Orante → Lectio → Meditatio → Oratio → Contemplatio → Selamento no Caderno Espiritual), detecção de erros em runtime e medição de memória (PSS).
  - **Subagente Assíncrono Somente Leitura (`.agents/agents/perf-validator.md`)**: persona especializada em testes de runtime sem alteração de código-fonte, reportando achados e métricas em `relatorio_validacao_debug.md`.
  - **Workflow Interativo (`.agents/workflows/perf-validator.md`)**: atalho `/perf-validator` integrado ao Antigravity IDE para disparo da suíte de validação em modo debug.
  - **Validação em Dispositivo Real**: execução e homologação com 100% de sucesso em hardware físico (Samsung Galaxy A34 5G, Android 16 API 36) com zero erros de runtime e persistência validada no Cloud Firestore local.

### Added
- **feat(tooling / local-deploy)**: orquestrador CLI de build e publicação direta do notebook para a Google Play Store e Firebase Hosting com consumo zero de minutos do GitHub Actions (ADR 0049):
  - **Publicação Direta na Google Play (`tool/pwe_local_deploy.dart`)**: leitura automática do `.env` local, compilação do `.aab` de produção assinado e ofuscado e upload transacional via **Google Play Android Publisher API v3** (`edits.insert`, `bundles.upload`, `tracks.update`, `edits.commit`) com autenticação OAuth2 JWT RS256 nativa para as trilhas `internal`, `alpha` (Teste Fechado), `beta` e `production`, fallback automático para `draft`, deploy Web integrado (`--web` / `--only-web`) e sincronização opcional da `main` + tag com marcador `[local-release]` (`--sync-main`).
- **chore(ci / agents / skills)**: racionalização de gatilhos de CI/CD e governança de modalidade de release (Local vs. Nuvem):
  - **Economia de Cota de CI (`.github/workflows/ci.yml` & `.github/workflows/release-on-main.yml`)**: remoção do gatilho redundante `push: branches: [develop]` em `ci.yml` e adição de guarda condicional `!contains(github.event.head_commit.message, '[local-release]')` em `release-on-main.yml` para evitar recompilação em nuvem quando a release já foi publicada a partir do notebook.
  - **Rito de Decisão de Modalidade de Release (`task-finisher`, `devops`, `AGENTS.md`, `GEMINI.md`)**: atualização dos agentes, skills e diretrizes para exigir pergunta interativa obrigatória (`ask_question`) ao usuário definindo se a publicação da release será **Local (no notebook)** ou **em Nuvem (no GitHub Actions)**.


## [0.9.111] - 2026-10-16

### Added
- **feat(tooling / automation)**: automação de processos de engenharia, governança de internacionalização, diagnóstico operacional e invariantes visuais (ADR 0045):
  - **CLI do Rito de Release & DoD (`tool/pwe_release.dart`)**: automação do bump monotônico SemVer (`--bump=patch|minor|major`) no `pubspec.yaml`, espelhamento atômico entre `CHANGELOG.md` e `docs/releases/CHANGELOG.md`, linter sacro de notas `whatsnew` ($\le 500$ caracteres e sem termos técnicos) e execução encadeada dos Quality Gates (`dart format`, `flutter analyze --no-fatal-infos` e `flutter test`).
  - **CLI Sincronizador e Auditor i18n (`tool/i18n_sync.dart` & `arb_integrity_test.dart`)**: auditoria de paridade das 668 chaves nos 18 catálogos ARB (`ar`, `de`, `en`, `es`, `fr`, `hi`, `it`, `ja`, `ko`, `la`, `nl`, `pl`, `pt`, `sw`, `tl`, `uk`, `vi`, `zh`), validação de placeholders ICU contra `@key.placeholders` de `app_pt.arb`, higienização de `@metadados` fora do template (`--fix-metadata`) e injeção em lote (`--inject=<json>`).
  - **Orquestrador de Saúde Operacional (`scripts/pwe_doctor.dart`)**: diagnóstico unificado de FinOps Free Tier, verificação de cabeçalhos CORS da JSON API do Google Cloud Storage nos Ícones Sagrados e auditoria da janela litúrgica de 7 dias ($D+0$ a $D+6$) com suporte a auto-reparo (`--auto-heal`).
  - **Matriz de Viewports e Invariantes Arquiteturais de UI (`test/helpers/viewport_matrix_helper.dart` & `test/core/architecture/ui_invariants_test.dart`)**: helper de teste para 6 viewports canônicos (`360x640`, `390x844`, `844x390`, `768x1024`, `1366x768`, `1920x1080`) com `TextScaler` `1.0x` e `2.0x` e auditoria estática contra `CircularProgressIndicator` e `IntrinsicHeight` inseguro.
- **feat(governance / gitops / langfuse)**: governança remota de ciclo de vida do app, Firebase GitOps e ciclo fechado de qualidade teológica no Langfuse (ADR 0046):
  - **Governança de Versão (`RemoteConfigService` & `VersionGovernanceBanner`)**: suporte às chaves remotas `min_supported_build_number`, `recommended_build_number` e `pastoral_seasonal_banner_json`, com banner e modal pastoral localizado nos 18 idiomas (`updateAvailableTitle`, `updateRequiredMessage`, `updateNowAction`).
  - **Firebase GitOps (`remoteconfig.template.json`, `firestore.indexes.json`, `firebase.json`)**: versionamento declarativo do template de Remote Config e dos índices compostos do Cloud Firestore.
  - **Scores de Qualidade no Langfuse (`LangfuseService.recordQualityScore`, `AiContentReportRemoteDataSource`, `scripts/seed_langfuse_prompts.dart`)**: correlação automática de relatos de conteúdo da IA com o `lastTraceId` da meditação/oração via endpoint `/api/public/scores` (`theological_orthodoxy`) e semeadura idempotente de prompts por comparação de hash.
- **feat(cdn / audio / fcm)**: offload de leituras do Firestore via Google Cloud Storage Static CDN, áudio sacro pré-computado e tópicos litúrgicos FCM (ADR 0047):
  - **Liturgia Estática CDN-First (`scripts/daily_liturgy_worker.dart` & `DailyLiturgyRemoteDataSourceImpl`)**: publicação automática de `liturgies/{lang}/{date}.json` no bucket `gs://<REDACTED_GCS_CDN_BUCKET>` com `Cache-Control: public, max-age=86400` e resolução prioritária via GCS JSON API antes do fallback para o Cloud Firestore.
  - **Áudio Sacro Compartilhado e Tópicos FCM (`DailyLiturgy.gospelAudioUrl`, `TtsService`, `PushNotificationService.syncLiturgicalLanguageTopic`)**: suporte a URL de áudio pré-computado na entidade/modelo de liturgia e no `TtsService.speak`, além de assinatura automática do tópico `liturgy_{lang}` e broadcast de Solenidades no worker diário.
- **feat(platform / web-billing / cicd)**: entrega contínua multiplataforma (Web, Landing Page e iOS TestFlight) e RevenueCat Web Billing REST v1 (ADR 0048):
  - **RevenueCat Web Billing REST v1 (`SubscriptionRemoteDataSourceImpl`, `SubscriptionStatusModel.fromRevenueCatRestJson`, `EnvConfig`)**: suporte a `REVENUECAT_WEB_KEY` e `REVENUECAT_WEB_CHECKOUT_URL` para verificação direta de entitlements (`benefactor` / `benfeitor_pwe`) via `GET /v1/subscribers/{app_user_id}` no Flutter Web.
  - **Pipelines CD Web & iOS TestFlight (`.github/workflows/release-on-main.yml` & `.github/workflows/ios-release-testflight.yml`)**: job `deploy-web-and-landing` integrando `flutter build web --base-href="/app/"` em `landing/app/` com deploy automático no Firebase Hosting, e workflow sob demanda para compilação de `.ipa` assinado e envio ao Apple TestFlight via App Store Connect API.

## [0.9.110] - 2026-10-16

### Fixed
- **fix(subscription / revenuecat)**: blindagem da integração do módulo "Amigos da Missão pwE" (Benfeitoria) com o **RevenueCat** e **Google Play Billing v5+** (ADR 0017):
  - **Resolução Bidirecional de Entitlement (`SubscriptionStatusModel.fromCustomerInfo`)**: suporte simultâneo e bidirecional entre `benfeitor_pwe` (configurado no painel do RevenueCat) e `benefactor` em qualquer combinação de variáveis de ambiente.
  - **Casamento de Identificadores Compostos (`SubscriptionRemoteDataSourceImpl.findMatchingPackage` & `SubscriptionPlanModel.fromRevenueCatPackage`)**: suporte nativo ao formato `<subscriptionId>:<basePlanId>` da Google Play Store (ex.: `pwe_benefactor_annual:annual-base` e `pwe_benefactor_monthly:monthly-base`) e inferência resiliente de tipo de plano mesmo em pacotes `PackageType.custom`.
  - **Acessibilidade Semântica (`BenefactorPage`)**: adição de identificadores semânticos explícitos (`benefactor_confirm_button`, `benefactor_restore_purchases_button`, `benefactor_terms_of_use_button`, `benefactor_privacy_policy_button`) e `ExcludeSemantics` em ícones ornamentais nos layouts retrato e paisagem (`AdaptiveTwoPane`).
- **fix(l10n / web / ci)**: tradução integral das chaves remanescentes em Alemão (`app_de.arb`), Francês (`app_fr.arb`) e Italiano (`app_it.arb`), alinhamento geométrico do Dashboard em duas colunas na Web (`/app`), proteção contra `IntrinsicHeight` em viewports com altura limitada no `AdaptiveTwoPane` (`LayoutBuilder` / `SessionHistoryPage`), correção de indentação YAML nas notas pastorais de `release-on-main.yml`, contraste aprimorado no tema claro, atualização de ícones/favicon Web e inclusão dos ícones sacros de 17/10 e 18/10.

## [0.9.109] - 2026-10-16

### Fixed
- **fix(ui / web-responsive)**: harmonização geométrica, alinhamento vertical e proporções para Web, Notebooks (`1366×768`) e Desktops Full HD (`1920×1080+`):
  - **Fundação Responsiva (`ResponsiveContext` & `AdaptiveTwoPane`)**: distinção explícita entre paisagem compacta de celular (`isCompactLandscape: screenHeight < 520`) e telas largas de notebook/desktop (`isDesktopOrWide: screenWidth >= 900`), suporte a `maxWidth` centralizado em `AdaptiveTwoPane`, fallback de borda dourada vertical quando inserido em `SingleChildScrollView` (sem uso de `IntrinsicHeight`) e limite de colunas em `adaptiveColumns` (`maxColumns: 4`).
  - **Dashboard da Liturgia Diária (`DailyDashboardPage`, `SacredIconAltarpieceCard`, `LiturgyThreePillarsSection`)**: nivelamento milimétrico entre o selo de data à esquerda e o cabeçalho da liturgia à direita (`56dp`), unificação da largura da coluna do altar (`380dp`), restauração da seção `"LEITURAS DO DIA"`, pílulas de referência e prévia de 2 linhas dos textos bíblicos em notebooks/desktops, e centralização dos rodapés canônicos abaixo das duas colunas.
  - **Diálogos Contemplativos e Pedagógicos (`SacredIconContemplationDialog`, `WelcomeGuideDialog`, `LectioPedagogicalSlides`)**: correção das restrições invertidas em modo paisagem (`maxWidth: 920, maxHeight: 640`), centralização vertical dos painéis de leitura e restauração da seção invitatória.
  - **Fluxo da Lectio Divina, Caderno Espiritual e Perfil (`ImmersiveReadingPage`, `PreparationPage`, `LectioPage`, `SessionHistoryPage`, `SessionDetailPage`, `LoginPage`, `ProfilePage`, `ProfileSetupPage`, `OnboardingPage`, `BenefactorPage`, `SacredCompactAppBar`)**: remoção do botão `LectioAdvanceButton` duplicado na etapa *Lectio* em modo paisagem, centralização de títulos em `SacredCompactAppBar`, refatoração do modo Master-Detail (`isEmbedded: true`) no Caderno Espiritual para evitar `AppBar` e split-view aninhados, e contenção de largura máxima em formulários, abas e CTAs inferiores.

## [0.9.108] - 2026-10-16

### Changed
- **fix(landing / web-url)**: alinhamento do botão "Acessar Versão Web" (`btn-web`) em `landing/pt-br/index.html` e `landing/index.html` para utilizar a rota canônica do domínio oficial (`https://pwe.jhhsolutions.dev/app`), que redireciona para o aplicativo Web no Firebase Hosting.

## [0.9.107] - 2026-10-16

### Fixed
- **fix(ios / build)**: registro de `GemmaInferencePlugin.swift` nas seções `PBXBuildFile`, `PBXFileReference`, `PBXGroup` e `PBXSourcesBuildPhase` de `ios/Runner.xcodeproj/project.pbxproj` e sincronização das 18 regiões (`knownRegions`) com o `Info.plist`, corrigindo erro de compilação no Xcode.
- **fix(ios / ai-security)**: implementação completa de `FlutterStreamHandler` (`pwe/gemma_local_stream`), métodos `warmup` e `abort` em `GemmaInferencePlugin.swift` e retorno estruturado `IOS_ENGINE_UNAVAILABLE` para acionar o fallback Cloud / Patrístico de `LlmRepositoryImpl` sem vazar textos técnicos na experiência orante; implementação do `MethodChannel` `br.com.jhhsolutions.praywithme/security` em `AppDelegate.swift` com detecção de `UIScreen.capturedDidChangeNotification` e verificação real de `checkPermissions()` em `LocalNotificationService.isPermissionGranted`.
- **fix(web / compatibility)**: remoção de imports diretos de `dart:io` e `path_provider` em `SacredShareService` (migrado para `XFile.fromData` multiplataforma) e `ScreenSecurityService` (migrado para `defaultTargetPlatform`), viabilizando compartilhamento de imagens e compilação Web/Wasm; suporte a `reauthenticateWithPopup(GoogleAuthProvider())` em `AuthRemoteDataSourceImpl.deleteAccount` na Web e preservação da emulação local de Benfeitor na Web em `SubscriptionRemoteDataSourceImpl.purchasePlan`.

### Changed
- **refactor(web / ux)**: ocultação contextual na Web (`!kIsWeb`) de controles exclusivos de hardware/SO mobile nativo em `AiSelectionPage` (card de Modo Local Embarcado), `DailyDashboardDrawer` (toggle Offline e gerenciamento de modelo local), `ProfilePage` (Lembretes Diários locais, Inteligência Local e Modo de Máxima Privacidade) e `LectioPage` (aba de OCR via câmera/ML Kit).

## [0.9.106] - 2026-10-16

### Fixed
- **fix(web / sacred-icons)**: correção definitiva do erro de CORS e eliminação de downloads duplicados ao carregar os Ícones Sagrados na versão Web (`https://pwe.jhhsolutions.dev`):
  - **Política CORS no Bucket GCS (`scripts/gcp/cors-sacred-assets.json`, `setup_gcp_cicd.ps1`, `setup_gcp_cicd.sh`)**: configuração e aplicação das regras de CORS (`GET`, `HEAD`, `OPTIONS`) para os domínios Web oficiais e ambientes locais no bucket `gs://<REDACTED_GCS_CDN_BUCKET>`.
  - **Resolução CORS-Safe via GCS JSON API (`SacredIconPixelHarmonizer.resolveCorsSafeUrl`)**: conversão automática de URLs públicas da XML API do Cloud Storage para o endpoint de mídia da JSON API (`/storage/v1/b/<bucket>/o/<object>?alt=media`), contornando o *Built-in Cache* sem `Vary: Origin` e assegurando a emissão consistente de `Access-Control-Allow-Origin`.
  - **Cabeçalho `Origin` no Worker Diário (`scripts/daily_liturgy_worker.dart`)**: envio explícito de `Origin: https://pwe.jhhsolutions.dev` na checagem `HEAD` de idempotência para evitar envenenamento de cache na CDN do GCS.
  - **Deduplicação de Requisições e Cache Síncrono (`SacredIconHarmonizer`, `SacredIconContemplationDialog`, `SacredShareCard`)**: unificação do download via `http.get` com deduplicação de requisições concorrentes (`_inFlightDownloads`), consulta síncrona ao cache em memória (`getCachedImage`) no `initState` e remoção de widgets `Image.network` / `Image.asset` redundantes durante o processamento de harmonização.

## [0.9.105] - 2026-10-16

### Added
- **feat(privacy / secops)**: controle de privacidade de tela soberano do fiel com "Modo de Máxima Privacidade" configurável e sob demanda (ADR 0044):
  - **Serviço Core e Injeção (`ScreenSecurityService`)**: serviço dedicado para gerenciar e persistir (`screen_security_enabled`) o estado de segurança de tela via `SharedPreferences`, integrado ao ciclo de vida e registrado no GetIt.
  - **Interface de Controle no Perfil (`ProfilePage`)**: opção acessível e rotulada com `Semantics(identifier: 'switch_screen_security')` permitindo ao fiel ligar/desligar voluntariamente o bloqueio de capturas de tela.
  - **MethodChannel Nativo Dinâmico (`MainActivity.kt`)**: canal `br.com.jhhsolutions.praywithme/security` com métodos `setSecureScreen` e `isSecureScreenEnabled` para aplicar ou remover `FLAG_SECURE` em tempo de execução sem reiniciar o app.
- **feat(share / evangelization)**: recurso de partilha visual e textual de conteúdos sacros para evangelização pastoral (ADR 0044):
  - **Serviço de Partilha Sacra (`SacredShareService`)**: formatação orante de citações e leituras com assinatura `pwE • Pray With Me ✠ Leitura Orante` e exportação nativa multiplataforma via `share_plus`.
  - **Card Sacro de Alta Resolução (`SacredShareCard` & `SacredShareBottomSheet`)**: componente visual de arte sacra com cruz dourada, data litúrgica, ornatos e citação bíblica renderizado em alta definição (`pixelRatio: 3.0`) para WhatsApp e Instagram Stories, com opções de partilha como imagem ou texto simples.
  - **Ações de Partilha no Dashboard e Contemplação**: botões de partilha integrados à `AppBar` do Dashboard Diário (`DailyDashboardPage`) e ao diálogo de contemplação dos Ícones Sagrados (`SacredIconContemplationDialog`).
- **feat(i18n)**: 8 novas chaves de internacionalização registradas com 100% de paridade em todos os **18 catálogos ARB** (`app_pt.arb`, `app_en.arb`, `app_es.arb`, `app_la.arb`, `app_fr.arb`, `app_de.arb`, `app_it.arb`, `app_nl.arb`, `app_pl.arb`, `app_uk.arb`, `app_zh.arb`, `app_ja.arb`, `app_ko.arb`, `app_vi.arb`, `app_tl.arb`, `app_ar.arb`, `app_hi.arb`, `app_sw.arb`).

### Changed
- **refactor(android / secops)**: remoção do `FLAG_SECURE` incondicional/global no `onCreate` nativo do Android, permitindo a livre captura de tela para estudo pessoal e evangelização, mantendo a blindagem visual de segundo plano (`PrivacyScreenWrapper`) no alternador de tarefas do sistema.
- **docs(adr / product)**: criação do **ADR 0044** e atualização da regra de negócio `RN-SEC-092` em `docs/product/business_rules.md` para formalizar a soberania orante de privacidade e o fluxo de partilha sacra.

## [0.9.104] - 2026-10-16

### Added
- **feat(store / landing)**: geração do pacote gráfico oficial para a **Google Play Store** (`landing/assets/store/`) e captura das 8 telas em alta resolução (`01_home.png` a `08_fruto_da_graca.png`) sincronizadas com a vitrine da Landing Page (`landing/assets/screens/`):
  - **Ativos da Loja**: ícone em alta resolução (`play_store_icon_512.png`, `512×512`) e *Feature Graphics* bilíngues (`feature_graphic_pt_1024x500.png` e `feature_graphic_en_1024x500.png`, `1024×500`).
  - **Sincronização Integral da Landing Page (`landing/`)**: alinhamento de todas as páginas institucionais e jurídicas (`index.html`, `privacy.html`, `terms.html`, `delete-account.html` em PT-BR e EN-US), folhas de estilo (`styles.css`, `home.css`) e atualização do link institucional no rodapé de `DailyDashboardDrawer` para `https://pwe.jhhsolutions.dev/`.

### Changed
- **fix(devops / play-store)**: substituição do dump de `git log` técnico por notas de versão pastorais bilíngues (`whatsnew-pt-BR` e `whatsnew-en-US`) no workflow `.github/workflows/release-on-main.yml`.
- **chore(android / secops)**: condicionamento de `WindowManager.LayoutParams.FLAG_SECURE` em `MainActivity.kt` exclusivamente às builds de produção (`(applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) == 0`), preservando a blindagem de privacidade em *release* e viabilizando inspeção visual e capturas automatizadas em modo *debug*.

## [0.9.103] - 2026-10-15

### Changed
- **feat(dashboard / ux)**: harmonização editorial completa do Dashboard Diário (`DailyDashboardPage`), diálogo do Ícone Sagrado e rodapé do menu lateral:
  - **Cabeçalho Limpo (`DailyDashboardPage`)**: remoção dos ícones redundantes de Onboarding (`?`) e Perfil da `AppBar`, preservando apenas o botão do menu (`☰`) e a marca `✨ pwE ✨` para máxima respiração visual.
  - **Retábulo do Ícone Sagrado Ampliado (`SacredIconAltarpieceCard`)**: ampliação do palco do ícone para `320×375` (`aspectRatio: 0.78`), cabeçalho litúrgico com pílula de grau/ano e título editorial em `GoogleFonts.lora`, e correção de truncamento no divisor `✨ LEITURAS DO DIA ✨` (`LiturgyThreePillarsSection`).
  - **Botão Principal Adaptativo (`LectioCTAButton`)**: adaptação dinâmica do subtítulo conforme as leituras do dia, exibindo `"1ª Leitura, Salmo Responsorial, 2ª Leitura e Evangelho"` nos Domingos e Solenidades e `"1ª Leitura, Salmo Responsorial e Evangelho"` nos dias feriais.
  - **Grade 2×2 Unificada de Caminhos de Oração (`PrayerPathsSection` & `PreparationInviteCard`)**: substituição dos cartões verbosos por uma grade simétrica 2×2 concisa (*Preparação* | *Meu Coração* | *Passagem Livre* | *Caderno Espiritual*) com medalhões circulares dourados ampliados (`30×30` / `32×32`) e espaçamento contemplativo generoso.
  - **Convite "Amigo do pwE" no Banner de Degustação (`TrialWelcomeBanner`)**: reformulação com linha de status concisa e pílula interativa `"Apoie a missão • Seja Amigo do pwE"` navegando diretamente para `/benefactor`.
  - **Rodapé Institucional no Menu Lateral (`DailyDashboardDrawer`)**: remoção do sufixo `(73 Livros)`, inclusão da assinatura clicável `"Desenvolvido por JHH Solutions ↗"` direcionando para a landing page oficial (`https://pwe.jhhsolutions.dev`) e exibição da versão do aplicativo.
- **feat(lectio / contemplation)**: harmonização da jornada imersiva (`ImmersiveReadingPage`), `SacredIconContemplationDialog`, `ReadingSettingsSheet` e `LanguageSelectionDialog`:
  - **Pílulas da Tradição e Barra Integrada em `2. Meditatio` (`ImmersiveReadingPage`)**: substituição dos cartões retangulares de Exegese e Gotas de Sabedoria por pílulas concisas em linha única com abertura em Bottom Sheet, e integração da ação `"Iluminação da Consciência"` na barra de ferramentas do caderno espiritual (com proteção `SingleChildScrollView` / `Flexible` contra overflow no modo paisagem).
  - **Contemplação do Ícone Sagrado (`SacredIconContemplationDialog` & `ContemplationPage`)**: cabeçalho editorial com medalhão circular dourado, palco ampliado (`50%` da altura) com selo flutuante de tela cheia e pílulas lado a lado para *Ver o Mistério* e *Ouvir a Liturgia*.

## [0.9.102] - 2026-10-15

### Changed
- **feat(langfuse / otel-v4)**: migração completa da instrumentação do **Langfuse** para o modelo *Observations-First v4* via **OpenTelemetry (OTLP/HTTP)**:
  - **Ingestão OTLP v4 no App (`lib/core/services/langfuse/langfuse_service.dart` & `test/core/services/langfuse_service_test.dart`)**: substituição do endpoint legado `/api/public/ingestion` (descontinuado em 16/11/2026) por `POST /api/public/otel/v1/traces` com cabeçalho `x-langfuse-ingestion-version: 4`, versão atualizada (`0.9.102`), eliminação de spans duplicados e inclusão de resumos estruturados de `langfuse.observation.input` e `langfuse.observation.output` com preservação Zero-Knowledge (`zero-knowledge-redacted`) das reflexões espirituais dos fiéis.
  - **Telemetria OTLP v4 no Worker Diário (`scripts/daily_liturgy_worker.dart`)**: implementação de `WorkerLangfuseClient.recordTrace` e instrumentação das chamadas Gemini (`daily-liturgy-enrichment`, `worker_biblical_verses`, `worker_biblical_psalm` e `sacred-icon-generation`).
  - **Sincronização de Segredos e Cloud Run Job (`scripts/deploy_liturgy_gcp.ps1` & `.sh`)**: propagação de `LANGFUSE_HOST`, `LANGFUSE_PUBLIC_KEY` e `LANGFUSE_SECRET_KEY` nos GitHub Secrets e no GCP Cloud Run Job `daily-liturgy-worker`.

## [0.9.101] - 2026-10-15

### Fixed
- **fix(analytics / router / lectio)**: restauração completa da telemetria em tempo real no **Firebase Analytics / Google Analytics 4 (GA4)**:
  - **Rastreamento de `screen_view` nas 16 Rotas (`sacred_page_transitions.dart` & `app_router.dart`)**: propagação do identificador da rota (`name: state.name ?? state.matchedLocation`) para `CustomTransitionPage` em todas as transições contemplativas (`sacredFadeTransition`, `sacredVeilLiftTransition`, `sacredDissolveTransition`, `sacredSlideTransition`), corrigindo o descarte silencioso de 15 das 16 telas pelo `FirebaseAnalyticsObserver`.
  - **Reconexão da Jornada Orante (`LectioSessionBloc` & `lectio_divina_injection_container.dart`)**: injeção de `AnalyticsService` no `LectioSessionBloc` para emissão dos eventos `lectio_started`, `lectio_step_advanced` e `lectio_completed` (incluindo breadcrumbs do Crashlytics).
  - **Telemetria de Autenticação (`AuthBloc` & `auth_injection_container.dart`)**: vinculação do identificador pseudônimo (`setUserId`) e registro de eventos `login` (`google`, `apple`, `anonymous`) e `logout`.
  - **Google Analytics 4 na Vitrine Web (`landing/*.html` & `landing/pt-br/*.html`)**: inclusão da tag `gtag.js` (`G-REDACTED` com `anonymize_ip: true`) em todas as páginas estáticas de `praywithme.app`.
- **fix(devops / integrations)**: alinhamento das integrações de terceiros (Langfuse, Appetize.io e Cloud Run Worker):
  - **Langfuse (`langfuse_service.dart`, `.env.example`, `release-on-main.yml` & `daily-liturgy-cron.yml`)**: unificação do host padrão para `https://us.cloud.langfuse.com` e injeção das variáveis `--dart-define=LANGFUSE_*` no build de produção (`.aab`) e no worker de contingência.
  - **Appetize.io (`ios-simulator-appetize.yml`)**: migração do upload para a API v2 (`https://api.appetize.io/v2/apps` com header `X-API-KEY` e fallback transparente para v1) e injeção de `--dart-define=GEMINI_API_KEY` no build do simulador iOS.
  - **Worker Docker (`Dockerfile.worker` & `daily-liturgy-cron.yml`)**: inclusão de `python3` e `python3-pil` no estágio runtime do container para habilitar o recorte automático de dípticos (`_cropPngLeftHalf`) pelo `IconGuard` no GCP Cloud Run Job, e desativação de `setup-java` desnecessário no workflow de contingência.

## [0.9.100] - 2026-10-15

### Added
- **test(qa / pyramid)**: reequilíbrio da pirâmide de testes e ampliação da cobertura filtrada de CI de **73.71% para 76.82%** (`15.199 / 19.786` linhas):
  - **Cobertura Integral da Camada BLoC e Data (`SacredIconBloc`, `SpiritualGuidanceBloc`, `LectioSessionBloc`, `ConsentGuardedLlmRemoteDataSource` & `LlmRepositoryImpl`)**: novos testes cobrindo geração de ícone e explicação mistagógica (`GenerateSacredIconEvent`, `GenerateSacredIconExplanationEvent`), análise de reflexão em streaming (`RequestUserReflectionAnalysisEvent`), salvaguardas patrísticas offline, transições completas e debounce de `ScrollReachedEndEvent`, proteção de consentimento explícito ADR 0025 em todas as 14 operações remotas e roteamento de `LlmRepositoryImpl`.
  - **Suítes de Widget para Telas Críticas (`SessionHistoryPage` / Caderno Espiritual & `VaultSecurityPage`)**: testes cobrindo listagem, busca textual, filtro por estado da alma, modo paisagem em dois painéis (`AdaptiveTwoPane` + `SessionDetailPage`) e fluxos de definição, desbloqueio e remoção de senha do cofre espiritual.

### Changed
- **refactor(test / perf)**: higienização da suíte de testes com redução de **45.5% no tempo total de execução** (de `285s` para `155s`):
  - **Isolamento de Micro-Benchmarks (`tool/benchmarks/`)**: realocação de `daily_liturgy_model_benchmark.dart`, `lectio_session_parse_benchmark.dart` e `vector_search_benchmark.dart` para fora de `test/`, eliminando ~130s de espera artificial em toda execução do `flutter test`.
  - **Extinção Definitiva de `legacy_lectio_state_fixture.dart`**: migração integral de `daily_dashboard_page_test.dart`, `daily_dashboard_drawer_test.dart`, `lectio_page_test.dart`, `landscape_layout_test.dart` e `immersive_reading_page_test.dart` para injetar estados tipados reais dos sub-blocs (`DailyLiturgyBloc`, `LectioSessionBloc`, `ExegesisBloc`, `SpiritualGuidanceBloc`, `PassageDiscoveryBloc`), eliminando o acoplamento legado ao monolito `LectioState`.

### Removed
- **chore(cleanup)**: remoção de código morto (*zombie code* sem referências em `lib/`), testes 100% duplicados e artefatos órfãos:
  - Exclusão dos casos de uso e parâmetros obsoletos `GenerateMeditationUseCase` (`meditation_params.dart`) e `GeneratePrayerUseCase` (`prayer_params.dart`), widgets sem uso (`LiturgicalManuscriptCard`, `SacredIconCard`, `SoulCheckInSheet`, `SpiritualFruitUiExtension`), testes duplicados (`auth_usecases_test.dart`, `profile_usecases_test.dart`) e PNGs órfãos de falhas de golden (`test/.../failures/`).

### Fixed
- **fix(ui / history)**: substituição de `Row` rígida por `Wrap` adaptativo no cabeçalho de `SacredJournalCard` e proteção com `Flexible` nas tags de etapas concluídas, prevenindo `RenderFlex overflow` no painel lateral estreito do Caderno Espiritual em modo paisagem (`AdaptiveTwoPane`).

## [0.9.99] - 2026-10-15

### Added
- **feat(lectio / ux)**: reformulação da hierarquia visual do Dashboard, suporte integral à Segunda Leitura Dominical e navegação entre leituras dentro da jornada imersiva:
  - **Navegação entre Leituras em `1. Lectio` (`ImmersiveReadingPage`)**: inclusão de barra superior de pílulas interativas (*Primeira Leitura*, *Salmo Responsorial*, *Segunda Leitura*, *Evangelho* e *Liturgia Completa*), suporte a gesto de deslize horizontal (*swipe*) e botões de transição sequencial (`Voltar` / `Próximo: [Leitura]`) ao final de cada leitura individual, preservando a fluidez contemplativa sem necessidade de retornar ao Dashboard.
  - **Selo de Contemplação no Ícone Sagrado (`SacredIconAltarpieceCard`)**: adição de badge translúcida inferior *"Contemplar Mística do Ícone"* com `Semantics(identifier: 'sacred_icon_contemplate_button')`, sinalizando com clareza que o toque no ícone abre o diálogo mistagógico (`SacredIconContemplationDialog`).

### Changed
- ** Hierarquia de Entrada no Dashboard (`DailyDashboardPage`, `LectioCTAButton`, `PreparationInviteCard` & `PrayerPathsSection`)**:
  - Desacoplamento do botão primário `LectioCTAButton` (*"Iniciar Lectio Divina"*) para iniciar imediatamente a sessão imersiva com a Liturgia Completa (`_startWithCompleteLiturgy`), exibindo subtítulo explicativo explícito (`completeLiturgySubtitle`).
  - Destaque tipográfico do `PreparationInviteCard` (até 2 linhas sem truncamento precoce + subtítulo de recolhimento) e reorganização de `PrayerPathsSection` em layout sem corte lateral (card de largura total para *Como está seu coração hoje?* seguido de grade em 2 colunas para *Passagem Livre & Bíblia* e *Caderno Espiritual*).

### Fixed
- **fix(lectio)**: exibição integral da **Segunda Leitura** aos Domingos e Solenidades em `LiturgyThreePillarsSection` (com grade adaptativa 2x2 no modo retrato quando há 4 leituras e cabeçalho `☩ LEITURAS DO DIA ☩`), corrigindo a omissão anterior de `secondReading`.

## [0.9.98] - 2026-10-15

### Fixed
- **fix(lectio / ai)**: restauração da geração de pontos de meditação (`Meditatio`), inspiração orante (`Oratio`), exegese central e Gotas de Sabedoria (`contextDrops`) no fluxo de **Passagem Livre & Bíblia**:
  - **Orientação Espiritual Sob Demanda (`SpiritualGuidanceBloc` & `SpiritualGuidanceEvent`)**: introdução de `RequestMeditatioGuidanceEvent` e `RequestOratioGuidanceEvent` integrados ao `ILlmRepository` (`generateMeditationPoints` e `generatePrayerPrompts`) com fallback patrístico automático (`PatristicFallbackDataSourceImpl`) em caso de falha ou modo offline, disparados na abertura da sessão em `LectioPage._submitLectio` e na transição de etapas em `ImmersiveReadingPage`.
  - **Anti-Burst Granular por Operação no Rate Limiter (`LlmRateLimiter` & `GeminiRemoteDataSourceImpl`)**: rastreamento de intervalo mínimo (`minIntervalBetweenRequests`) por chave de operação (`operationKey`), evitando que chamadas legítimas paralelas no início da sessão (`startSpiritualSession`, `generateMeditationPoints`, `generateExegeseCentral` e `generateContextDrops`) colidam e lancem `RateLimitExceededException`, mantendo o teto global de requisições por minuto (`maxRequestsPerMinute`).
  - **Roteamento Online/Offline e Referência Canônica em Exegese e Gotas (`LlmRepositoryImpl`, `GenerateExegeseUseCase` & `GeminiRemoteDataSourceImpl`)**: propagação da referência bíblica real (`passageReference`) para os prompts de `generateExegeseCentral` e `generateContextDrops` (substituindo o literal fixo `'Passagem Lida'`) e correção da guarda em `LlmRepositoryImpl.generateContextDrops` para acionar o retorno estático imediato apenas quando o modo offline explícito estiver ativo (`prefer_offline_ai` ou `offline_mode_enabled`).

## [0.9.97] - 2026-10-13

### Fixed
- **fix(perf / finops / lgpd)**: otimização Cache-First na navegação de datas, idempotência parcial do Worker Cloud Run, expurgo LGPD em `ai_content_reports` e fluidez de inicialização (ADR 0043):
  - **Navegação de Datas Cache-First (`DailyDashboardPage._selectDate`)**: restauração de `forceRefresh: false` na seleção de datas do calendário e guarda contra recarregamento duplicado da mesma data já carregada, eliminando leituras redundantes no Cloud Firestore para liturgias já persistidas no Hive.
  - **FinOps, Idempotência Parcial e Circuit Breaker no Worker (`scripts/daily_liturgy_worker.dart`)**: preservação integral de documentos com `theologicalStatus == "verified"` sem regenerar textos/exegeses via Gemini quando apenas `sacredIconUrl` estiver ausente por cota do Free Tier (`429 RESOURCE_EXHAUSTED`), atualização cirúrgica de ícone via `PATCH` (`updateMask.fieldPaths=sacredIconUrl`), *Circuit Breaker* de cota de imagem na execução e separação entre saúde litúrgica de texto e iconografia no `_evaluateBufferHealth`.
  - **Expurgo LGPD/GDPR em `ai_content_reports` (`AuthRemoteDataSourceImpl` & `firestore.rules`)**: inclusão da exclusão paginada por `uid` na coleção `ai_content_reports` durante `deleteAccount()`, atualização de `firestore.rules` (`allow read, delete: if isOwner(resource.data.uid)`) e limpeza de registros órfãos no Cloud Firestore (`<REDACTED_GCP_PROJECT_ID>`).
  - **Desacoplamento Pós-Primeiro-Frame da Migração RAG (`AuthMigrationListener`)**: agendamento de `LectioMigrationService.runMigration()` após o primeiro frame renderizado e janela de estabilização de 3 segundos, evitando competição de CPU do `BertTokenManager` (`vocab.txt`) na abertura do Dashboard.
  - **Estabilização de CI/CD & Migração para Google Play Console (`ci.yml` & `release-on-main.yml`)**: remoção da compilação duplicada de `.apk` e do envio legado ao Firebase App Distribution em `release-on-main.yml`, passando a compilar exclusivamente o `.aab` assinado com pacote de símbolos de ofuscação (`pwE-symbols.zip`) e publicação direta nas trilhas do Google Play Console (`internal`, `alpha`, `beta`, `production`); ajuste de `fetch-depth: 2` no `dorny/paths-filter`, ampliação de `timeout-minutes` nos testes unitários e limpeza otimizada de espaço em disco antes da extração do Android NDK 28.2.
  - **Integridade de Fontes nas Gotas de Sabedoria (`DailyLiturgyRepositoryImpl` & `daily_liturgy_worker.dart`)**: revalidação transparente do cache local no Hive quando `contextDrops` não possuem o atributo `source` preenchido (sem inferências ou fontes estáticas desconexas), exigência estrita de `source` na validação do `TheologicalCuratorAgent` e do `_inspectExistingDocument` no Worker Cloud Run, atualização da imagem do `daily-liturgy-worker` no Artifact Registry e enriquecimento de todo o buffer de liturgias no Cloud Firestore (`2026-10-12` a `2026-10-15` em 7 idiomas).

## [0.9.96] - 2026-10-13

### Added
- **feat(data / security / arch / stores)**: reconciliação bidirecional Offline-First, expurgo local LGPD/GDPR, inversão de dependências core e prontidão para Apple App Store e Google Play Store (ADR 0042):
  - **Reconciliação Bidirecional Offline-First (`LectioRepositoryImpl`)**: união inteligente por `id` entre a caixa local criptografada (`CACHED_SESSIONS_BOX_V2`) e o Cloud Firestore em `getArchivedSessions()`, hidratando sessões remotas localmente via `cacheSessionsBatch` e sincronizando automaticamente sessões criadas offline para a nuvem.
  - **Cache Local de Perfil e Constância (`ProfileLocalDataSource`)**: persistência local em `SharedPreferences` para `UserProfileModel`, assegurando abertura offline do Perfil e cálculo resiliente da constância orante (`recordActivity`).
  - **Expurgo Local Pós-Logout e Crypto-Shredding LGPD/GDPR (`ILocalUserDataCleaner`)**: limpeza integral da caixa de sessões e caches de perfil no `signOut()` e destruição/rotação da chave criptográfica AES-256 (`pwe_data_encryption_key_v1`) no `FlutterSecureStorage` durante `deleteAccount()`, com tentativa de recuperação (*retry*) no `EncryptedHiveBoxOpener`.
  - **Desacoplamento Estrito de `lib/core/` e Domínio Puro**: inversão de dependência em `SacredTypography` via `SacredTypographyConfig` e `SacredFontFamily`, extração de `LiturgicalLanguageDialog` para `features/lectio_divina/`, migração de `SoulState`, `SpiritualFruit` e `GotaCategory` para `lib/core/domain/`, extração de `ImmersiveStep`, remoção de `lectio_state.dart` de `lib/` e substituição de `kDebugMode` por `bool.fromEnvironment('dart.vm.product')` nos UseCases de assinatura.
  - **Prontidão Nativa para Apple App Store & Google Play Store**: remoção de `processing` de `UIBackgroundModes` (Apple Guideline 2.5.4), configuração de `CFBundleURLTypes` e `CFBundleLocalizations` (18 idiomas) no `ios/Runner/Info.plist`, criação de `ios/Podfile` (`iOS 15.0`), suporte a reautenticação interativa com `AppleAuthProvider` na exclusão de conta (Apple Guideline 5.1.1(v)), substituição de `SCHEDULE_EXACT_ALARM` por `inexactAllowWhileIdle` no Android, criação de `landing/delete-account.html` e endurecimento de CI/CD e `lefthook.yml`.

## [0.9.95] - 2026-10-12

### Fixed
- **fix(cache / perf)**: erradicação de downloads redundantes de liturgia e persistência em disco de ícones sacros (ADR 0041):
  - **Estratégia Cache-First no Repositório (`DailyLiturgyRepositoryImpl`)**: consulta imediata à caixa local do Hive (`liturgyBox`) antes de disparar requisições remotas, eliminando chamadas repetidas ao Cloud Firestore na abertura do app e suportando atualização forçada (`forceRefresh: true`).
  - **Persistência de Ícones em Disco (`ISacredIconCacheService` / `SacredIconCacheServiceImpl`)**: armazenamento em disco local de imagens sagradas baixadas do Cloud Storage via `path_provider` com chaveamento criptográfico SHA-256, eliminando downloads redundantes no `SacredIconHarmonizer`.
  - **Normalização de Chaves Canônicas**: padronização de datas ISO 8601 (`YYYY-MM-DD`) no `HtmlLiturgyParser` e resolução bidirecional no `DailyLiturgyLocalDataSourceImpl` com suporte a datas com barras (`DD/MM/YYYY`), variantes regionais (`pt-BR`) e chaves legadas.
  - **Compatibilidade Android & Notificações Nativas**: ativação de `coreLibraryDesugaring` (`desugar_jdk_libs:2.1.4`) no Gradle e estabilização de `flutter_local_notifications: ^22.3.2`, assegurando suporte pleno a alarmes precisos de oração e fusos horários no Android.
  - **Testes de Regressão e Validação Unitária**: cobertura ampliada de testes unitários para o repositório com Cache-First, UseCase `GetDailyLiturgy`, `DailyLiturgyBloc`, `DailyLiturgyLocalDataSource` e `SacredIconCacheServiceImpl`.

## [0.9.94] - 2026-10-09

### Added
- **feat(notifications)**: implementação de lembretes locais agendados e arquitetura de push notifications FCM (ADR 0040):
  - **Serviço de Notificações Locais (`LocalNotificationService`)**: agendamento diário recorrente (*on-device*) via `flutter_local_notifications` e `timezone` com suporte a fuso horário local e fallback resiliente de alarme exato.
  - **Diálogo Pós-Oração Aprimorado (`DailyReminderInviteDialog`)**: inclusão de seletor visual de horário litúrgico com `showTimePicker` e persistência imediata do agendamento diário no aparelho.
  - **Gestão de Lembretes no Perfil (`ProfilePage`)**: exibição do horário configurado com edição interativa em tempo real e cancelamento automático de alarmes ao desativar o interruptor.
  - **Inscrição em Tópico e Roteamento FCM (`PushNotificationService`)**: suporte à subscrição do tópico `daily_liturgy` e tratamento de clique na notificação redirecionando por padrão ao Dashboard da Liturgia Diária (`/`).
  - **Internacionalização Plena (18 ARBs)**: registro e sincronização de 6 novas chaves em todos os catálogos de tradução de `lib/l10n/`.
  - **Permissões Nativas**: configuração de `RECEIVE_BOOT_COMPLETED`, `VIBRATE` e `SCHEDULE_EXACT_ALARM` no `AndroidManifest.xml`.

## [0.9.93] - 2026-10-08

### Fixed
- **fix(lectio / session)**: isolamento estrito de sessão e erradicação de vazamento de cache entre Evangelho do Dia e Passagem Livre:
  - **Submissão de Passagem Livre Desacoplada**: atualização de `LectioPage._submitLectio()` para despachar `StartFreePassageSessionEvent` diretamente para o `LectioSessionBloc` com a referência e texto da passagem bíblica livre selecionada, além de redefinir o `SpiritualGuidanceBloc` e o `ExegesisBloc`.
  - **Reset Canônico de Estado**: criação do evento `ResetSpiritualGuidanceEvent` no `SpiritualGuidanceBloc` para cancelamento imediato de requisições ativas ao LLM e restauração de estado limpo entre transições de sessões orantes.
  - **Isolamento de Sessão na Tela Imersiva**: blindagem do fallback de meditação em `ImmersiveReadingPage`, garantindo que meditações consolidadas da Liturgia Diária sejam exibidas exclusivamente para sessões do tipo `complete_liturgy`, sem vazar para passagens livres.
  - **Limpeza no Painel e Preparação**: disparo de `ResetSpiritualGuidanceEvent` ao iniciar sessões a partir do `DailyDashboardPage` e `PreparationPage`.

## [0.9.92] - 2026-10-08

### Fixed
- **fix(finops / security)**: isolamento estrito de chaves entre ambientes e erradicação de contaminação cruzada multi-projeto (ADR 0039):
  - **Paridade Canônica de Chaves**: sincronização da `GEMINI_API_KEY` em todos os ambientes (`.env` local, GitHub Secrets `secrets.GEMINI_API_KEY` e GCP Secret Manager `pwe-gemini-api-key`) apontando estritamente para o projeto Free Tier `pwE-AiStudio` (`<REDACTED_AI_STUDIO_PROJECT_ID>`) com faturamento desativado (`billingEnabled: false`), erradicando o erro `HTTP 402 PaymentRequired` decorrente do uso inadvertido do projeto Blaze (`<REDACTED_GCP_PROJECT_ID>`).
  - **Higienização de Caracteres BOM**: publicação da Versão 5 no GCP Secret Manager (`pwe-gemini-api-key`) codificada em UTF-8 puro, eliminando o byte BOM `\ufeff` que causava falhas no runtime de containers e inspeção por CLI.
  - **Script de Auditoria Automatizada (`scripts/audit_finops.dart`)**: criação de ferramenta de inspeção em 5 etapas para validação contínua de paridade de credenciais, status de faturamento do Google AI Studio, integridade de segredos e monitoramento de tráfego de IA.
  - **Governança FinOps Endurecida**: atualização da skill de FinOps (`.agents/skills/finops/SKILL.md`), agente especialista (`.agents/agents/finops.md`) e manual diário (`docs/infrastructure/finops_daily_audit_prompt.md`), tornando obrigatória a aprovação do `audit_finops.dart` antes de releases.

### Added
- **feat(landing / web)**: melhorias de layout, harmonização de botões e citações magistrais na vitrine web:
  - Harmonização de botões de download e acesso web com tags pastorais de validação.
  - Centralização de conteúdos dos botões e unificação de tags em ouro sacro.
  - Layout responsivo flexível para desktop e mobile com proporções preservadas.
  - Acesso web configurado para modalidade por convite com citação literal do parágrafo 126 da encíclica *Magnifica Humanitas*.

## [0.9.91] - 2026-10-08

### Added
- **feat(lectio / exegese)**: ancoragem documental e canônica das Gotas de Contexto da Lectio Divina:
  - **Atributo `source` em `GotaContextoEntity`**: inclusão do campo canônico identificando a proveniência documental de cada gota (Patrística com obra e capítulo, Magistério com número de parágrafo, Escrituras com referências e léxicos gregos/hebraicos, historiadores antigos e arqueologia).
  - **Engenharia de Prompt Canônica**: atualização das diretrizes de sistema (`PromptTemplateFactory`) com exigência estrita de fontes autênticas nas 7 categorias hermenêuticas da Leitura Orante.
  - **Design System Sacro e UI**: renderização do selo de citação `✠ Fonte: [obra]` em tipografia sacra (`Lora`) com `ExcludeSemantics` no glifo sacro páteo e acessibilidade semântica em `GotaExpansionTile`.
  - **Internacionalização Plena (18 ARBs)**: inclusão da chave `canonicalSourceLabel` nos 18 catálogos ARB (`ar`, `de`, `en`, `es`, `fr`, `hi`, `it`, `ja`, `ko`, `la`, `nl`, `pl`, `pt`, `sw`, `tl`, `uk`, `vi`, `zh`), validada por teste automatizado de integridade.
  - **Worker de Liturgia e Backfill Firestore**: atualização do schema em `daily_liturgy_worker.dart` e enriquecimento cirúrgico do buffer futuro no Cloud Firestore (42 documentos de 07/10 a 12/10 nos 7 idiomas) via `PATCH` com `updateMask` atômica.
  - **Blindagem e Retrocompatibilidade**: padrão *Tolerant Reader* assegura compatibilidade bidirecional — versões antigas ignoram o campo extra e novas versões suportam leituras legadas sem quebras.

## [0.9.90] - 2026-10-07

### Fixed
- **fix(android / signing)**: padronização de assinatura de debug e prevenção do erro `INSTALL_FAILED_UPDATE_INCOMPATIBLE` no ADB:
  - **Suporte a `signDebugWithReleaseKey`**: adicionado suporte no `build.gradle.kts` para assinar compilações de depuração (debug) com a mesma keystore de release quando configurada no `key.properties` ou via variável de ambiente `SIGN_DEBUG_WITH_RELEASE_KEY=true`, eliminando desinstalações automáticas do ADB que apagavam dados locais de teste.
  - **Documentação e Template**: criado `android/key.properties.example` e atualizado `docs/features/google_play_release.md` orientando o fluxo de testes em dispositivos físicos.
  - **Permissão no AndroidManifest**: inclusão de `<uses-permission android:name="android.permission.RUN_USER_INITIATED_JOBS"/>` para downloads em segundo plano de modelos no Android 14+ (API 34+) via `background_downloader`.
  - **Regras do Cloud Firestore**: publicação e deploy das regras de segurança de `ai_content_reports` e cofre de chaves (`key_vault`), corrigindo o erro `PERMISSION_DENIED` nas denúncias de conteúdo gerado por IA.
  - **Firebase App Check**: registro e vinculação do Debug Token do dispositivo físico de teste no console do Firebase para acesso contínuo às APIs protegidas por atestação.

## [0.9.89] - 2026-10-07

### Fixed
- **fix(edge_llm)**: sincronização de sessão única do LiteRT-LM nativo e tratamento de concorrência com warmup.

## [0.9.88] - 2026-10-07

### Changed
- **perf(ci / finops)**: otimização estrutural de workflows no GitHub Actions para contenção de custos e economia de até 75% da cota mensal de computação (ADR 0038):
  - **Desacoplamento de Gatilho Android**: remoção de `pubspec.yaml` e `pubspec.lock` do filtro de caminhos `android` em `ci.yml`, eliminando a compilação espúria de APK Android a cada bump de versão de tarefas comuns.
  - **Modularização de `setup-flutter-env`**: criação da flag `setup-java: false` na composite action, dispensando o download de JDK 17 (Temurin) e Gradle nos jobs puramente Dart (`analyze` e `test`).
  - **Aceleração de Testes Unitários**: adição de concorrência paralela (`--concurrency=4`) e migração para `--reporter compact` no `flutter test` dos workflows `ci.yml` e `release-on-main.yml`.
  - **Blindagem do Runner macOS**: restrição do workflow `ios-simulator-appetize.yml` para execução estritamente sob demanda via label de PR (`preview-ios`) ou manual (`workflow_dispatch`), prevenindo o consumo acelerado em máquinas Apple (multiplicador 10x de cota).
  - **Correção de Staging no Google Cloud Build**: adição de `--gcs-source-staging-dir` para apontar ao bucket de artefatos dedicado no GCP, evitando erros de permissão no bucket padrão do Cloud Build.

## [0.9.87] - 2026-10-07

### Fixed
- **fix(edge_llm / background_download)**: refatoração completa e blindagem do download assíncrono em segundo plano do modelo Gemma local:
  - **Adoção do Padrão `FileDownloader().enqueue(task)`**: migração da chamada síncrona bloqueante `download()` para `enqueue()`, delegando ao pipeline nativo do sistema operacional (WorkManager/ForegroundService no Android e NSURLSession no iOS) a persistência em segundo plano, mesmo com a tela desligada ou o app suspenso.
  - **Eliminação de Corrida (Race Condition) na Validação**: resolução do conflito entre o callback global `taskStatusCallback` e a finalização de arquivo, que tentava renomear o arquivo `.part` duas vezes e disparava falsos erros de validação e rebaixamento forçado para HTTP streaming.
  - **Finalização Idempotente no Disco**: detecção inteligente em `_finalizeDownloadedFile` que valida se o arquivo final `.litertlm` já existe e está íntegro (> 1 GB), evitando erros de "arquivo temporário não encontrado" em transições assíncronas do SO.
  - **Proteção de Inicialização Concorrente**: implementação de guarda por `Completer` e flags de estado em `initialize()`, eliminando chamadas redundantes simultâneas ao MethodChannel nativo no startup.
  - **Persistência de Hash Criptográfico**: armazenamento de `_expectedHashKey` em `SharedPreferences`, assegurando validação SHA-256 fidedigna mesmo se o processo do aplicativo for reiniciado pelo SO enquanto a tarefa roda em segundo plano.

## [0.9.86] - 2026-10-07

### Fixed
- **fix(edge_llm / background_download)**: correção e blindagem do download de modelo de IA local (`gemma-4-E2B-it.litertlm` ~2.58 GB) em primeiro e segundo plano:
  - **Remoção de Watchdog Prematuro**: eliminação do timer de 6 segundos que cancelava a tarefa nativa do `background_downloader` antes do término de handshakes e redirects (302) da CDN Hugging Face / CloudFront.
  - **Configuração de Foreground Service no Android**: ativação de `(Config.runInForeground, Config.always)` e solicitação de permissão de notificação (Android 13+ / API 33) para superar a restrição de 9 minutos do Android WorkManager.
  - **Gestão de Quota de Armazenamento**: definição de `(Config.useCacheDir, Config.never)` para salvar arquivos parciais e finais no diretório de suporte persistente (`ApplicationSupportDirectory`), prevenindo erros de cota esgotada na partição de cache.
  - **Reconexão com Tarefas em Andamento**: recuperação automática de downloads ativos via `database.recordForId` durante a inicialização do serviço e eliminação de estados fantasmas de download no `ModelDownloadBloc`.
  - **Blindagem no ProGuard e iOS Info.plist**: regras `-keep` no `proguard-rules.pro` para `com.bbflight.background_downloader` e `androidx.work`, além de `UIBackgroundModes` (`fetch`, `processing`) no `Info.plist` para suporte a transferências em segundo plano no iOS.
  - **Observabilidade**: telemetria de falhas e interrupções encaminhada com stack trace para o `FirebaseCrashlytics`.

## [0.9.85] - 2026-10-07

### Added
- **feat(web / app_check)**: suporte a `providerWeb` em `AppCheckServiceImpl` com `WebDebugProvider` para desenvolvimento e `ReCaptchaV3Provider` para release (`RECAPTCHA_V3_SITE_KEY` em `EnvConfig`), blindando requisições Web contra abusos e garantindo conformidade com a política de atestação do Cloud Firestore.
- **feat(perf / llm_traces)**: instrumentação ativa do `FirebasePerformance` em `LlmExecutionMetrics`, gerando Custom Traces (`llm_<stage>`) com métricas de duração (`duration_ms`), caracteres (`input_chars`, `output_chars`), tokens estimados (`estimated_tokens`) e status das chamadas do Gemini na Web e no Mobile.
- **feat(web / error_telemetry)**: telemetria de exceções não tratadas na Web via `AnalyticsService` (`web_flutter_error`, `web_platform_error`, `app_error` no GA4), suprindo a ausência do Crashlytics na Web com privacidade estrita Zero-Knowledge (ADR 0010, ADR 0037).

### Changed
- **chore(web / fcm)**: isolamento seguro de Push Notifications na Web em `PushNotificationServiceImpl`, prevenindo erros de Service Worker ausente no navegador e concentrando notificações no ambiente móvel nativo.

## [0.9.84] - 2026-10-07

### Changed
- **feat(branding / identity)**: padronização canônica do nome e título do aplicativo no ecossistema completo:
  - Título oficial da aplicação no Firebase App Distribution e lojas: `Pray With Me ✠ Lectio Divina` (28 caracteres, dentro do limite de 30 da Google Play).
  - Título no launcher / ícone do celular (home screen): `pwE` em todas as plataformas (Android `launcher_name` e iOS `CFBundleDisplayName`).
  - Internacionalização oficial do subtítulo nos 18 catálogos ARB: `Pray With Me ✠ Leitura Orante` (PT), `Pray With Me ✠ Lectura Orante` (ES) e `Pray With Me ✠ Lectio Divina` nos demais 16 idiomas.
- **fix(onboarding / ftue)**: correção e ativação definitiva da experiência de primeiro uso (*First-Time User Experience* - FTUE) na inicialização do aplicativo:
  - Desacoplamento da verificação de Onboarding do estado de autenticação em `SplashPage` e adoção da flag de ativação `onboarding_v2_completed`, garantindo que todo novo fiel no cold start vivencie os 4 slides contemplativos e a escolha pastoral de IA (ADR 0035) antes da tela de login.
  - Alinhamento de `resolveAuthRedirect` em `auth_redirect.dart` para redirecionar usuários com consentimento de IA pendente para `/onboarding` (onde o seletor pastoral está integrado no 4º slide).
  - Adição de atalhos explícitos no perfil (`profile_page.dart`) e gaveta (`daily_dashboard_drawer.dart`) para que o usuário possa rever o Guia da Lectio Divina e os slides de acolhimento sob demanda a qualquer momento.

## [0.9.83] - 2026-10-07

### Added
- **feat(landing / screenshots)**: substituição de todos os mockups estáticos recortados da Landing Page por capturas de tela reais em alta definição (1080p, sem banner de debug e sem barras de sistema operacional) capturadas diretamente do aplicativo via Marionette MCP em dispositivo físico Android sem fio.
- **feat(landing / showcase)**: vitrine visual fidedigna com os 4 passos da Lectio Divina (Lectio oficial com Gl 1,13-24, Meditatio com meditação guiada, Oratio com oração filial e Contemplatio com o Caderno Espiritual e Fruto da Graça), mais a tela do Ícone Sagrado do Pantocrator e as Gotas de Sabedoria com hermenêutica histórica expandida em inglês.
- **chore(dev / privacy)**: configuração de `PrivacyScreenWrapper(enabled: !kDebugMode)` e `debugShowCheckedModeBanner: false` em `lib/main.dart` para permitir diagnósticos e capturas via Marionette em depuração sem véu de privacidade ou banner visual.

## [0.9.82] - 2026-10-06

### Changed
- **feat(landing / ux)**: redesenho da home (EN e PT-BR) orientado à experiência do app: texto reduzido ao essencial (título, uma linha de subtítulo, 4 selos de confiança e uma linha por passo), com mockups reais do aplicativo (Liturgia Diária, Lectio, Meditatio, Oratio, Contemplatio, Ícone do dia e Gotas de Sabedoria) em molduras de celular, carrossel com *scroll-snap* no mobile e revelação suave ao rolar (respeitando `prefers-reduced-motion`).
- **refactor(landing)**: FAQ, citação papal e seção longa de Benfeitores removidos da home (Termos e Privacidade permanecem completos); benfeitores resumidos em uma linha no CTA final.
- **chore(landing)**: novo `landing/home.css` (apenas home) e screenshots otimizadas em `landing/assets/screens/`.

## [0.9.81] - 2026-10-06

### Added
- **feat(landing / i18n)**: inversão canônica de rota e idioma da Landing Page oficial do pwE: a raiz global (`/`) passa a ser servida nativamente em **Inglês** (`https://pwe.jhhsolutions.dev/`), enquanto a versão em Português do Brasil passa a ser servida na subpasta `/pt-br/` (`https://pwe.jhhsolutions.dev/pt-br/`), com redirecionamento de contingência da rota `/en/` para a raiz e mapeamento completo no `sitemap.xml`.
- **test(landing / browser)**: validação de proporcionalidade visual e responsividade automatizada via Chrome DevTools Protocol (CDP) em Microsoft Edge headless para desktop (1280x850) e mobile (375x812), com renderização 100% simétrica do retábulo sagrado de Cristo Pantocrator e dos botões de instalação.

### Fixed
- **fix(landing / responsive)**: resolução de overflow horizontal e proporcionalidade mobile em `landing/styles.css`: correção de fechamento de media query não balanceada (`@media (max-width: 900px)`), inclusão de `flex-wrap: wrap` nas garantias de privacidade (`.hero-guarantees`), e desacoplamento estrutural do seletor de idiomas `.lang-switch` para exibição nobre e sem cortes no cabeçalho mobile.
- **fix(landing / typography)**: inclusão de quebras de linha pontuais nos títulos hero em inglês e português para ritmo sacro e simetria áurea em telas pequenas sem truncamento de palavras.

## [0.9.80] - 2026-10-06

### Added
- **feat(landing / web)**: implementação da vitrine institucional e Landing Page estática oficial do pwE no diretório `landing/`, projetada para carregamento ultrarrápido (< 300ms), zero overhead e pontuação máxima no Google PageSpeed Insights (ADR 0036).
- **feat(landing / seo)**: inclusão de metatags completas de SEO, tags OpenGraph para pré-visualização enriquecida no WhatsApp, Telegram e redes sociais, Twitter Cards, `robots.txt`, `sitemap.xml` e dados estruturados Schema.org (`SoftwareApplication` em JSON-LD).
- **feat(landing / legal)**: criação das páginas públicas e canônicas `terms.html` (Termos de Uso e EULA com cláusula de tolerância zero para a Apple) e `privacy.html` (Política de Privacidade com transparência de IA, criptografia e exclusão de conta sob LGPD/GDPR).
- **feat(landing / design)**: design system sacro harmonizado com a Comunidade Shalom em HTML/CSS nativo, com tipografia Cinzel e Lora, paleta de Pergaminho e Ouro Litúrgico, mockup do retábulo sagrado com Cristo Pantocrator e acordeão FAQ contemplativo.
- **feat(landing / distribution)**: integração oficial do link de convite do Firebase App Distribution (`https://appdistribution.firebase.dev/i/97c8443ce5459a29`) no Hero e no CTA final da Landing Page, permitindo que os primeiros fiéis instalem a versão preliminar de testes diretamente no celular.
- **feat(landing / i18n)**: criação da versão completa oficial em língua inglesa (`landing/en/index.html`, `landing/en/terms.html`, `landing/en/privacy.html`), com seletor de idiomas bidirecional (`PT | EN`) na barra de navegação e metatags `hreflang` para indexação internacional no Google.
- **fix(landing / icon)**: substituição do ícone genérico do Flutter na navbar e nos favicons pelo ícone oficial do aplicativo pwE (Cruz Gloriosa com Chama Dourada e Halo Litúrgico).
- **docs(adr)**: elaboração do **ADR 0036** formalizando a arquitetura de desacoplamento entre a vitrine estática de SEO e o binário Flutter Web no Firebase Hosting.

## [0.9.79] - 2026-10-06

### Refactor
- **refactor(onboarding / ai-consent)**: unificação da escolha de enriquecimento e consentimento de IA no 4º slide do Onboarding (`OnboardingPage`), eliminando a tela intermediária `/ai_selection` do caminho crítico de primeiro uso e permitindo que o fiel entre diretamente na Liturgia Diária sem nenhuma interrupção ou modal durante a oração (ADR 0035).
- **feat(onboarding / ui)**: integração de seletor pastoral nobre no 4º slide de `LectioPedagogicalSlides` via parâmetro `privacyCustomBody`, com duas vias límpidas: *Reflexões com os Santos Padres (Recomendado / Nuvem segura)* e *Oração Estritamente no Aparelho (Offline / No device)*.
- **feat(compliance / stores)**: atendimento às políticas do Google Play (*Generative AI Policy & In-app Prominent Disclosure*) e da Apple (*App Review Guidelines 1.2, 5.1.1 e 5.1.2*), incluindo link direto para os Termos de Uso (EULA) e Política de Privacidade no encerramento da acolhida.
- **feat(i18n)**: registro de 6 novas chaves de internacionalização com metadados em `lib/l10n/app_pt.arb` e paridade integral em todos os 18 idiomas suportados (`ar`, `de`, `en`, `es`, `fr`, `hi`, `it`, `ja`, `ko`, `la`, `nl`, `pl`, `pt`, `sw`, `tl`, `uk`, `vi`, `zh`).
- **test(profile)**: atualização da suíte `onboarding_page_test.dart` cobrindo o seletor pastoral, a gravação de consentimento e a navegação direta para `/profile_setup`.
- **docs(adr)**: elaboração do **ADR 0035** formalizando a arquitetura de seleção pastoral de IA no onboarding e a blindagem regulatória para as lojas.

### Added
- **feat(auth)**: suporte a autenticação Google Sign-In no ambiente Flutter Web via `signInWithPopup`, com tratamento e isolamento de cancelamento voluntário do usuário (`popup-closed-by-user`) e de bloqueadores de popup (`popup-blocked`), evitando falsos alertas no Crashlytics.
- **feat(worker)**: aprimoramento da inferência canônica de cor litúrgica no worker noturno da liturgia diária (`scripts/daily_liturgy_worker.dart`) para Santos Doutores, Confessores, Pastores, Santos Anjos e Arcanjos (Branco) e Santos Mártires e Apóstolos (Vermelho).
- **docs(architecture)**: alinhamento completo dos diagramas de arquitetura (C4, Sequência, Máquinas de Estado e Observabilidade) ao estado real do código pós-ADR 0025 a 0034, com remoção do `LectioBloc` legado e formalização dos novos sub-BLoCs (`LectioSessionBloc`, `ExegesisBloc`, `VaultSecurityBloc`, etc.).

## [0.9.78] - 2026-10-06

### Fixed
- **fix(ui / sacred-icon)**: resolução de letterbox/pillarbox (bordas brancas espessas de estúdio fotográfico de 124px nas laterais) no retábulo do altar (`SacredIconAltarpieceCard`) e no diálogo de contemplação (`SacredIconContemplationDialog`), harmonizando visualmente a apresentação do ícone litúrgico no tema claro e escuro.
- **fix(ui / framing)**: correção da moldura central do `SacredIconContemplationDialog` e do retábulo para proporção áurea estrita de 3:4 (`AspectRatio(3/4)`), eliminando vãos laterais entre a pintura e a borda dourada com `BoxFit.cover` e preenchimento nobre de madeira escura de iconostase (`0xFF0F0C08`).

### Added
- **feat(ui / sacred-icon)**: inclusão de detector e auto-crop de letterboxing/pillarbox ($\ge 12\text{px}$) no `SacredIconPixelHarmonizer`, que isola a têmpera sagrada e elimina fundos de estúdio fotográfico em tempo de execução via `Canvas.drawImageRect`.
- **feat(ui / sacred-icon)**: suporte assíncrono a imagens remotas (`imageUrl`) com download e harmonização de pixels em `SacredIconHarmonizer`.
- **feat(assets)**: recorte para proporção 3:4 pura (776x1024) nos assets locais de outubro (`icon_2026_10_05.jpg`, `icon_2026_10_06.jpg`, `icon_2026_10_07.jpg` e variantes otimizadas) e sincronização com o Google Cloud Storage (`gs://<REDACTED_GCS_CDN_BUCKET>/icons/daily_icon_2026_10_06.png`).

### Refactor
- **refactor(dashboard)**: consolidação da Jornada Unificada (Opção 2) no `DailyDashboardPage`, eliminando pílulas e badges sobrepostas à arte sacra do retábulo, consagrando o ícone como pórtico único e monumental da Lectio Divina.

## [0.9.77] - 2026-10-05

### Added
- **feat(agents)**: implementação da arquitetura canônica de subagentes assíncronos do Google Antigravity em `.agents/agents/`, disponibilizando os 16 especialistas (`engineer`, `theologian`, `agile`, `finops`, `data-engineer`, `ai-engineer`, `secops-privacy`, `flutter-ui`, `design-a11y`, `platform-mobile`, `liturgical-scheduler`, `shalom-iconographer`, `qa`, `debugger`, `devops`, `task-finisher`) com frontmatter YAML estrito (`subagent: true`, ferramentas explícitas, políticas de execução e alocação de modelos) para execução concorrente e monitoramento no painel `/agents`.
- **docs(adr)**: criação do **ADR 0034** formalizando a arquitetura multiagente em 3 camadas (Subagentes Antigravity em `.agents/agents/`, Progressive Disclosure em `.agents/skills/` e interoperabilidade Copilot em `.github/agents/`).
- **docs(governance)**: atualização de `AGENTS.md`, `GEMINI.md` e `agent_governance_and_security.md` com o catálogo dos 16 especialistas e referências cruzadas aos subagentes.

## [0.9.76] - 2026-10-05

### Fixed
- **fix(ui)**: resolução de `RenderFlex overflow` de 20 pixels na `AiSelectionPage` em telas compactas sob escalonamento de fontes de acessibilidade (`textScaler >= 1.1x`, diagnosticado em teste manual no Samsung Galaxy A55 5G).
- **refactor(layout)**: remoção do anti-padrão `IntrinsicHeight` + `Spacer()` no container de rolagem da `AiSelectionPage`, substituindo por `Column(mainAxisAlignment: MainAxisAlignment.spaceBetween)` adaptativo que preserva o espaçamento estético em telas amplas e rola suavemente em viewports restritas.
- **fix(a11y)**: adição de `Flexible` no texto do botão de continuidade sem assistente (`continueWithoutAi`), prevenindo transbordamento horizontal de texto em altas densidades de escala tipográfica.
- **test**: inclusão de teste de regressão em `ai_selection_page_test.dart` simulando a resolução física do Samsung Galaxy A55 (`Size(360, 800)`) com `textScaleFactor = 1.15x`.

## [0.9.75] - 2026-10-05

### Refactor
- **feat(ux)**: reestruturação do fluxo de acolhimento e consentimento de IA; a seleção de motor de IA deixa de interceptar prematuramente o login/splash e passa a ser acionada organicamente ao término do onboarding (`OnboardingPage`), respeitando a pedagogia da Lectio Divina (ADR 0033).
- **feat(router)**: inclusão de `/onboarding` e `/profile_setup` no conjunto `kAiChoiceRoutes` em `lib/core/routes/auth_redirect.dart`, blindando o usuário contra redirects compulsivos durante a experiência de primeiro uso (FTUE).
- **feat(splash)**: encaminhamento no cold start para `/onboarding` quando o guia de acolhimento ainda não tiver sido concluído.
- **feat(design)**: refatoração completa da tela `AiSelectionPage` e do diálogo `showCloudAiConsentDialog` harmonizados ao Design System Sacro (Comunidade Shalom / Pergaminho Nobre), com paleta `SacredThemeColors`, tipografia Cinzel e Lora, divisores com cruz `CrossOrnamentalDivider`, substituição do ícone de processador (`Icons.memory`) pelo escudo sacro (`Icons.shield_outlined`), remoção de sombras comerciais de precificação e valorização contemplativa da Lectio Divina clássica sem assistente.
- **fix(haptic)**: desacoplamento assíncrono de feedback háptico (`unawaited(HapticFeedback...)`) eliminando bloqueios em testes de widget e interfaces headless.
- **test**: criação de suíte completa de testes de widget para `AiSelectionPage` e `showCloudAiConsentDialog`, além de testes de navegação pós-onboarding em `onboarding_page_test.dart` e `auth_redirect_test.dart`.
- **docs**: **ADR 0033**.

## [0.9.74] - 2026-10-04

### Refactor
- **refactor(security_vault)**: estruturação Clean Architecture completa da feature `security_vault`, com entidade `VaultSecurityInfo`, repositório `IVaultSecurityRepository` (`VaultSecurityRepositoryImpl`), use cases (`GetVaultSecurityInfoUseCase`, `SetVaultPassphraseUseCase`, `UnlockVaultPassphraseUseCase`, `RemoveVaultPassphraseUseCase`), container isolado `security_vault_injection_container.dart` e purga do registro acoplado no core DI (ADR 0032).
- **refactor(lectio_divina)**: remoção do arquivo duplicado órfão `domain/datasources/vector_search_datasource.dart`.
- **security(subscription)**: salvaguarda `if (!kDebugMode)` adicionada aos use cases de simulação (`SimulateTrialStatusUseCase`, `SimulateZeroOcrQuotaUseCase`, `ResetSubscriptionStatusUseCase`), retornando `PermissionFailure` fora de debug.
- **docs(sdlc)**: criação do plano executivo `docs/sdlc/sprint_store_readiness.md` para as pendências que dependem de contas Google Play e Apple Developer (teste fechado de 14 dias, certificados iOS, RevenueCat produção e `firebase_ai`).
- **docs**: **ADR 0032**.
## [0.9.73] - 2026-10-04

### Documentation
- **docs(adr)**: **ADR 0031** — alinhamento documental com o código (código como fonte de verdade); índice de ADRs com 0001–0031 listados uma única vez no índice principal (0029 e 0030 movidos do histórico de PRs).
- **docs(product)**: `RN-SUB-112` reescrita a partir do código (gratuito × acolhida de 7 dias × Benfeitor, com evidências arquivo:linha) em `business_rules.md`, `ethical_monetization.md` e `product_scope.md` §2.5; rastreabilidade do BRD (§12) sem classes fantasma — `RN-LEC-020` aponta `LectioSessionBloc`; `SoulState` e `LectioMaturityLevel` com os nomes canônicos dos enums.
- **docs(infra)**: worker da liturgia documentado como Cloud Run Job + Cloud Scheduler (GCP); `daily-liturgy-cron.yml` apenas como disparo manual de contingência (nota de atualização no ADR 0009). Notas de atualização também nos ADRs 0005 (Edge LLM implementado) e 0008 (`PreparationPage` reintroduzida na rota `/preparation`).
- **docs(sdlc)**: Gitflow do titular registrado (commits só em branches de desenvolvimento, consolidação em `develop`, `main` apenas por PR de promoção); gate oficial de cobertura de 70% (`ci.yml`) com pendência registrada para `release.yml` (60%) e comentário de PR (75%); package `br.com.jhhsolutions.praywithme.app` e versionCode ≥ 100 nos guias de go-live.
- **docs**: "Gemma 2B" → Gemma 4 E2B (LiteRT-LM); 18 ARBs de UI × 7 idiomas litúrgicos do worker (AGENTS.md §4.5 e GEMINI.md); modelos Gemini conforme Remote Config/worker; "Diário Orante/Espiritual" → Caderno Espiritual; contagens voláteis de testes removidas; Fastlane/upload automático ao Play removidos; roadmap com marco v1.0 (Advento, 29/11/2026) e TTS em nuvem entregue; README com versão 0.9.73, Flutter 3.47.5 e "Todos os direitos reservados"; `docs/releases/CHANGELOG.md` definido como fonte e o da raiz como espelho byte-idêntico.
- **docs(privacy)**: Política de Privacidade (`PRIVACY_POLICY.md`, `public/index.html`) e textos legais do app (pt, en, es, la) citam o consentimento explícito para IA em nuvem (ADR 0025) e a senha opcional do cofre (ADR 0026), sem alegar sigilo absoluto quando não há senha.
- **docs(compliance)**: guia de lojas com data 04/10/2026 e status real; `PrivacyInfo.xcprivacy` já referenciado no target (v0.9.65), pendente validação no Xcode.

## [0.9.72] - 2026-10-04

### Fixed
- **fix(lectio)**: normalização universal de códigos de idioma ISO 639-1 (`pt-BR`, `pt_BR` -> `pt`) ao consultar liturgia diária pré-computada no Firestore (`DailyLiturgyRemoteDataSource`), na validação e seleção de cards no `DailyDashboardPage`, no envio de eventos no `PreparationPage` e na blindagem de descarte indevido de exegese no `ExegesisBloc`.
- **fix(network)**: aumento do timeout de busca do documento litúrgico no Firestore de 4s para 7s para resiliência em conexões móveis lentas, evitando ativação prematura do fallback HTTP da CNBB (que não contém meditações nem exegeses pré-computadas).

## [0.9.71] - 2026-10-04

### Changed
- **refactor(core)**: 47 `catch (_) {}` vazios passam a registrar a exceção em debug via `logSwallowedError`.
- **chore(deps)**: `package_info_plus` atualizado (patch). `marionette_flutter` mantido em `dependencies` (import em `main.dart`).
- **docs**: **ADR 0030** (inclui pendências de dependências major).
## [0.9.70] - 2026-10-04

### Security
- **feat(storage)**: caixa Hive de sessões agora é cifrada em repouso (AES-256, chave no `flutter_secure_storage`) com migração segura da caixa legada. A caixa pública de liturgia segue sem cifra.
- **docs**: **ADR 0029**.
## [0.9.69] - 2026-10-04

### Security
- **fix(rules)**: `firestore.rules` valida o formato do cofre de chaves (`users/{uid}/security/key_vault`) e isola `security` da regra genérica de subcoleções; `storage.rules` limita uploads do usuário a 10 MB. Regras **precisam ser implantadas** (ver ADR 0028).
- **docs**: **ADR 0028**.
## [0.9.68] - 2026-10-04

### Removed
- **refactor**: `LectioBloc`, `LectioEvent` e seu registro no DI (código morto desde o ADR 0024), junto com 4 suítes de teste acopladas. `lectio_state.dart` permanece.
- **docs**: **ADR 0027**.
## [0.9.67] - 2026-10-03

### Added
- **feat(security)**: senha opcional do usuário para o cofre de chaves (`wrapped:v3`, PBKDF2 + HKDF + pepper via `--dart-define=VAULT_PEPPER`), com migração sem perda a partir de v1/v2, tela "Proteção do Caderno" (`VaultSecurityBloc`) e desbloqueio guiado em novos aparelhos.
- **docs**: **ADR 0026**.

### Changed
- **fix(security)**: `syncKeyVault` nunca sobrescreve um cofre protegido por senha; `VAULT_PEPPER` entra na allowlist do `EnvConfig` sem impedir a abertura de cofres existentes.
## [0.9.66] - 2026-10-03

### Added
- **feat(privacy)**: consentimento explícito para IA em nuvem (`ICloudAiConsentService`). Sem aceite, nenhuma passagem ou reflexão é enviada ao Gemini: `ConsentGuardedLlmRemoteDataSource`, `GeminiEmbeddingService` e `CloudTtsProvider` bloqueiam a chamada e os fallbacks local/patrístico assumem.
- **feat(ui)**: diálogo de consentimento, opção "Continuar sem assistente" e escolha do modo de IA no primeiro acesso (`/ai_selection` via `redirect`); no menu lateral, voltar à nuvem pede consentimento e o modo offline o revoga.
- **docs**: **ADR 0025**.

### Changed
- **fix(i18n)**: `cloudModeDesc` deixa de afirmar "100% protegidas por criptografia" e informa o envio ao serviço Gemini (18 idiomas).
## [0.9.65] - 2026-10-03

### Added
- **feat(a11y)**: `resolveAppTextScaler` combina a escala de texto do **sistema** com a preferência de leitura (base 18) e limita a 0,8–2,0×; antes o app sobrescrevia o `TextScaler` do aparelho (clamp 0,8–1,45).
- **docs**: `.env.example` com todas as variáveis suportadas (exceção `!.env.example` no `.gitignore`) e **ADR 0024**.

### Changed
- **perf(bootstrap)**: `Purchases.configure` (RevenueCat) saiu do caminho crítico do cold start: `initialize()` é idempotente e as operações do datasource aguardam a configuração (`_ensureConfigured`); o DI usa `unawaited`.
- **perf(bootstrap)**: `LectioBloc` não é mais instanciado no cold start nem recebe despacho do seletor de idioma (a liturgia é carregada só pelo `DailyLiturgyBloc`). A classe permanece temporariamente (remoção na próxima sprint).
- **refactor(domain)**: `SoulState`, `SpiritualFruit` e `ReadingPreferences` não dependem mais de `package:flutter` (membros visuais ficam nas extensões de `presentation/extensions/`).
- **docs**: `README.md` corrigido (versão, testes, 18 idiomas, Gemma 4, setup com `.env.example`, nota de segurança); 222 links `file:///c:/Dev/pwE/...` convertidos para caminhos relativos (URLs do GitHub nos `CHANGELOG.md`).
- **chore(release)**: Bump monotônico de versão para `v0.9.65+91`.

### Fixed
- **fix(ios)**: `Runner.entitlements` (Sign in with Apple + `aps-environment`), `PrivacyInfo.xcprivacy` incluído no target e realinhado à política de privacidade, deployment target iOS 15.0 e bundle id do RunnerTests. *Configuração não validada em Xcode (sem Mac/conta Apple); ver ADR 0024.*
- **fix(bloc)**: `ModelDownloadBloc` (singleton no DI) provido com `BlocProvider.value`, evitando fechar a instância compartilhada.

### Tests
- `text_scale_utils_test.dart`; teste de inicialização idempotente/preguiçosa do `SubscriptionRemoteDataSourceImpl`.
## [0.9.64] - 2026-10-03

### Fixed
- **fix(router)**: Guard de autenticação do `GoRouter` agora é efetivo. O `AuthBloc` era `registerFactory`, então cada `redirect` criava um bloc novo em `AuthInitial` (nunca redirecionava) e vazava a subscription do stream de auth. `AuthBloc` virou singleton (`BlocProvider.value` em `main.dart`), a lógica foi extraída para `resolveAuthRedirect` (função pura) e o roteador reavalia o redirect via `refreshListenable` (`GoRouterRefreshStream`). `AuthError` transitório não expulsa o usuário da rota. Novo `buildAppRouter` com observers injetáveis.
- **fix(auth,lgpd)**: Exclusão de conta não engole mais erros. O expurgo do Firestore (`users/sessions`, `session_embeddings`, `security/key_vault`, `users/{uid}`, `profiles/{uid}`) é estrito e idempotente, registra cada falha no Crashlytics e, se algo falhar, lança `ServerException` **antes** de remover o usuário do Firebase Auth (a conta é mantida e a exclusão pode ser repetida). Subcoleções apagadas em lotes de 400 com paginação.

### Tests
- Novo `test/core/routes/auth_redirect_test.dart` (rotas públicas, `Unauthenticated`, `AuthWebAccessRestricted`, `AuthError` transitório, `GoRouterRefreshStream`).
- `auth_remote_datasource_test.dart`: testes de `deleteAccount` migrados para `fake_cloud_firestore` (expurgo completo, isolamento entre usuários, paginação > 400 docs, falha mantém a conta e registra no Crashlytics).

### Docs
- **ADR 0023** (guard reativo e exclusão sem falhas silenciosas) com a lista de decisões em aberto da Onda 2 (R1 pepper do cofre, R2 chave Gemini/`firebase_ai`, consentimento para nuvem, Hive sem cifra).

### Changed
- **chore(release)**: Bump monotônico de versão para `v0.9.64+90`.
## [0.9.63] - 2026-10-03

### Added
- **feat(lectio_divina)**: Ação **"Sinalizar este trecho"** em todo conteúdo gerado (exegese, meditação, oração e contemplação) — exigência da política de IA generativa do Google Play. Nova tríade Clean Architecture (`AiContentReport`, `SubmitAiContentReportUseCase`, `AiContentReportRepository`, `AiContentReportBloc`, `ReportAiContentButton`) com persistência em `ai_content_reports` (Firestore), minimização de dados (trecho ≤ 600 caracteres) e i18n nos 18 idiomas. Testes de use case, Bloc e datasource.
- **sec(firestore)**: Regra `ai_content_reports` que permite somente `create` pelo próprio usuário autenticado, com validação de campos, enumerações e tamanhos.
- **docs(audit)**: Relatório de maturidade `docs/releases/app-maturity-audit-2026-10.md` e **ADR 0022**.

### Changed
- **ci(release)**: `release-on-main.yml` agora injeta `GEMINI_API_KEY` e `REVENUECAT_*` via `--dart-define` (AAB e APK), falha o build se faltarem `FIREBASE_API_KEY`, `GEMINI_API_KEY` ou a assinatura Android (*smoke check*). A chave RevenueCat é opcional enquanto não há conta de desenvolvedor Google/Apple (emite aviso e o build sai sem assinaturas), porém uma chave de Test Store (`test_...`) **bloqueia** o build, pois o SDK trava em release; `REVENUECAT_ENTITLEMENT_ID` é opcional (padrão `benefactor`) e executa `flutter analyze` + `flutter test` antes do build de produção.
- **fix(privacy)**: `PRIVACY_POLICY.md`, `public/index.html` e `legal_texts.dart` (pt/en/es/la) reescritos para refletir os fluxos reais (reflexão e resumos enviados ao Gemini, GA4, Crashlytics, App Check, FCM, sinalização), bases legais da LGPD e transferência internacional; removida a alegação indevida de "ponta a ponta / zero-knowledge" e termos proibidos ("Diário Espiritual", "Minhas Orações").
- **docs(compliance)**: Declarações de Data Safety / App Privacy Details corrigidas; item do `PrivacyInfo.xcprivacy` desmarcado (arquivo ainda não está no target do Xcode).
- **fix(subscription)**: `subscriptionAutoRenewNote` nos 18 idiomas com a cláusula exigida pela Apple 3.1.2 (renovação automática salvo cancelamento ≥ 24 h antes do fim do período).
- **docs**: Corrigidos caminho dos ADRs (`docs/adr/`), package name e versionCode nos playbooks de go-live.

### Fixed
- **fix(android)**: `build.gradle.kts` não assina mais builds de release com a chave de debug silenciosamente; falha sem keystore (opt-out explícito `ALLOW_DEBUG_SIGNING=true`).
- **fix(android)**: Remoção da permissão `AD_ID` (o app não exibe anúncios).
- **docs(changelog)**: Removido marcador de conflito de merge (`>>>>>>> develop`) de `docs/releases/CHANGELOG.md`.
- **sec(ci)**: Token de exemplo do Appetize substituído por placeholder em `ios-simulator-appetize.yml`.
## [0.9.62] - 2026-10-02

### Fixed
- **fix(lectio_divina,exegesis)**: Correção do carregamento e retenção das Gotas de Sabedoria e Exegese Central nas leituras individuais:
  - Adicionado `currentPassageReference` ao `ExegesisState` para detectar mudança de passagem/perícope e invalidar o cache com fidelidade, impedindo que requisições de leituras individuais sejam abortadas silenciosamente por guardas cegas quando o BLoC é singleton global.
  - Implementado reset explícito via `ResetExegesisEvent` ao iniciar sessões em `DailyDashboardPage` (`_startWithReading` e `_startWithCompleteLiturgy`), `PreparationPage` (`_startIndividualReading` e `_startCompleteLiturgy`) e `LectioPage`.
  - Aperfeiçoada a seleção teológica de gotas em `_resolveCompleteDrops`: quando uma leitura individual recebe a lista completa da liturgia (fallback), o algoritmo extrai com fidelidade os 3 eixos nucleares espirituais da Leitura Individual (`historico`, `teologico`/`patristico`, `ascetico`), em vez de truncar cegamente nos três primeiros itens gerais da liturgia.
  - Parametrizado o `targetCount` (7 para Liturgia Completa e 3 para Leitura Individual) nas chamadas de fallback de UI em `ImmersiveReadingPage` e `GotasBottomSheet`.

### Changed
- **chore(release)**: Bump monotônico de versão para `v0.9.62+88`.

### Tests
- Adicionados testes de transição e extração dos eixos nucleares das Gotas no `exegesis_bloc_test.dart`.
- Suíte completa de testes de `lectio_divina` aprovada com 578 testes (100% passing).
- `flutter analyze --no-fatal-infos` com 0 issues.

## [0.9.61] - 2026-10-02

### Added
- **feat(ui,a11y)**: Validação e harmonização integral de coerência de telas e acessibilidade em todo o app pwE:
  - Blindagem de glifos sacros puramente ornamentais (`✠` e `☩`) com `ExcludeSemantics` na `ImmersiveReadingPage` e `LiturgyThreePillarsSection`, impedindo leituras ruidosas em leitores de tela (TalkBack e VoiceOver).
  - Rotulagem semântica explícita com identificadores `snake_case` e `button: true` para compatibilidade assistiva e automação do *Firebase App Testing Agent* (IA Gemini):
    - `DailyDashboardPage`: `welcome_guide_button` e `profile_app_bar_button`.
    - `SacredIconAltarpieceCard`: `altarpiece_previous_day_button`, `altarpiece_next_day_button` e `altarpiece_date_seal_button`.
    - `LiturgyThreePillarsSection`: `liturgy_reading_${id}_button` dinâmicos por nicho.
    - `PrayerPathsSection`: `prayer_path_free_passage_chip`, `prayer_path_heart_checkin_chip` e `prayer_path_spiritual_journal_chip`.
    - `PreparationInviteCard`: `preparation_invite_button`.
    - `ImmersiveReadingPage`: `tts_play_stop_button` e `reading_settings_button`.
    - `AISelectionPage`: diferenciação entre `cloud_ai_option_card` e `offline_ai_option_card`.
    - `WebAccessRestrictedPage`: `web_restricted_sign_out_button`.
  - Normalização tipográfica em `WebAccessRestrictedPage` utilizando chamadas tipadas `GoogleFonts.cinzel()` e `GoogleFonts.lora()`.

### Changed
- **chore(release)**: Bump monotônico de versão para `v0.9.61+87`.

### Tests
- Suíte completa de testes de regressão de `lectio_divina`, `auth` e `splash` aprovada com 696 testes (100% passing).
- `flutter analyze --no-fatal-infos` com 0 issues.

## [0.9.60] - 2026-10-02

### Security
- **sec(crypto,key-vault)**: Hardening da derivação de chaves mestras KEK (`lib/core/services/encryption_service.dart`) para o padrão RFC 5869 HKDF-SHA256 (`wrapped:v2:salt:iv:ciphertext`) com salt criptográfico aleatório de 32 bytes e pepper de ambiente, eliminando a dependência do salt estático hardcoded anterior e preservando total retrocompatibilidade com envelopes legado `wrapped:v1:` (VULN-01).
- **sec(secrets)**: Remoção de `- .env` da seção `assets:` em `pubspec.yaml`, impedindo empacotamento de segredos de desenvolvimento no binário APK/AAB distribuído para lojas (VULN-02).
- **sec(langfuse)**: Remoção definitiva de `LANGFUSE_SECRET_KEY` do compilado cliente mobile em `lib/core/config/env_config.dart`. Operação estritamente delimitada com `publicKey` pública (VULN-03).
- **sec(subscription)**: Blindagem do Paywall e cotas de OCR (`lib/features/subscription/data/repositories/subscription_repository_impl.dart`). Status de Benfeitor tornado estritamente Server-Authoritative em `getSubscriptionStatus` e `restorePurchases`, rejeitando qualquer spoofing via cache local desprotegido (VULN-04).
- **sec(firestore)**: Regra em `firestore.rules` para a coleção `/allowed_testers/{email}` restrita a `allow get` pontual apenas se o e-mail coincidir com `request.auth.token.email` e `allow list: if false;`, erradicando enumeração e vazamento de e-mails de testadores (VULN-05).
- **sec(lgpd,privacy)**: Conformidade estrita com o Direito ao Esquecimento da LGPD/GDPR em `lib/features/auth/data/datasources/auth_remote_datasource.dart`. Implementado expurgo atômico e recursivo de `profiles`, `sessions`, `session_embeddings` e `key_vault` antes de efetivar `user.delete()` no Firebase Authentication (VULN-06).
- **sec(platform,privacy)**: Proteção visual da intimidade orante com `FLAG_SECURE` na janela nativa Android (`android/app/.../MainActivity.kt`) e máscara de blur visual no ciclo de vida iOS (`ios/Runner/AppDelegate.swift`) para o App Switcher (VULN-07).
- **sec(llm,prompt-injection)**: Blindagem de injeção de prompt indireta em normalização de OCR (`lib/features/lectio_divina/data/utils/prompt_template_factory.dart`) com delimitação XML `<untrusted_ocr_text>` e diretivas anti-override para a IA. Adição de padrões de detecção multilíngues (Português/Espanhol) no `InputSanitizer` (VULN-08).
- **sec(navigation)**: Implementação de Route Guard via callback `redirect` no `GoRouter` (`lib/core/routes/app_router.dart`), impedindo acesso a rotas privadas (`/lectio`, `/history`, `/benefactor`, etc.) por usuários deslogados via links diretos ou Web (VULN-10).
- **sec(gcp,iam)**: Restrição de privilégios na Service Account de CI/CD (`scripts/gcp/setup_gcp_cicd.sh`), substituindo permissão global de projeto por concessão cirúrgica de `secretAccessor` aos segredos indispensáveis (Least Privilege) (VULN-11).

### Changed
- **chore(release)**: Bump monotônico de versão para `v0.9.60+86`.

### Tests
- Suíte completa de testes de regressão de segurança aprovada: 113 testes em `test/core/services/`, `test/core/security/`, `test/features/subscription/`, `test/features/auth/` e `test/features/lectio_divina/` (100% passing).
- Análise estática com `flutter analyze --no-fatal-infos` concluída com 0 issues.

## [0.9.59] - 2026-10-02

### Added
- **feat(brand)**: Adoção do ícone mestre oficial definitivo inspirado no "básico bem feito" e no minimalismo sacro da Comunidade Shalom:
  - Cruz esguia em bronze litúrgico (`#8B6914`) conectada ao aro nímbico circular de ouro suave, com a **chaga gloriosa do Ressuscitado (mandorla dourada incandescente `#C5A059`)** em seu centro, emanando a Paz (*Shalom*).
  - Assentado sobre a superfície nobre do pergaminho marfim (`#FBF7EF`), trazendo silêncio e sacralidade visual para o celular.
  - Atualização completa do catálogo de ícones do iOS (`AppIcon.appiconset`) com `remove_alpha_ios: true` e todos os mipmaps do Android (mdpi até xxxhdpi).
- **feat(platform,android)**: Camada de primeiro plano transparente (`ic_launcher_foreground.png`), camada monocromática nativa (`ic_launcher_monochrome.png`) para Themed Icons do Android 13+ (Material You) e harmonização da Splash Screen noturna nativa com `@drawable/splash_icon_dark` em ouro champagne e mandorla luminosa.
- **feat(testing,mcp)**: Integração do **Marionette MCP** (`marionette_flutter` e servidor MCP `marionette`):
  - Inicialização condicional de `MarionetteBinding.ensureInitialized()` sob `kDebugMode` em `lib/main.dart`, blindando completamente compilações de release contra sobrecargas de depuração.
  - Configuração do servidor MCP `marionette` no workspace (`.agents/mcp_config.json`) e no ambiente global do Antigravity (`~/.gemini/config/mcp_config.json`), permitindo aos agentes de IA inspecionar widgets, simular ações de usuário e capturar screenshots da tela do app ao vivo.
  - Homologação formal no **ADR 0021** (`docs/adr/0021-marionette-mcp-e-interacao-em-tempo-de-execucao-para-agentes-ia.md`) e enriquecimento das diretrizes do agente `qa` em `.agents/skills/qa/SKILL.md`.

### Changed
- **chore(release)**: Bump monotônico de versão para `v0.9.59+85`.
## [0.9.58] - 2026-10-01

### Added
- **feat(privacy)**: Redesign do `PrivacyScreenWrapper` (`lib/core/widgets/privacy_screen_wrapper.dart`) alinhado à identidade visual sacra:
  - Substituição do ícone ciano genérico anterior pelo logotipo oficial da aplicação (`assets/images/app_logo.png`) envolvido por um resplendor sacro (`GoldenHalo`) com cantos arredondados (22dp) e sombra suave.
  - Tipografia litúrgica em `GoogleFonts.lora` para o título "Pray With Me (pwE)" com acento em ouro (`context.sacred.goldAccent`) e o subtítulo "Ambiente de Oração Protegido" em itálico de tom sereno (`context.sacred.softText`).
  - Divisor ornamental cruciforme (`CrossOrnamentalDivider`) com degradê litúrgico central.
  - Fundo adaptativo ao tema: papiro nobre (`sacred.parchment`) no modo claro e superfície contemplativa (`sacred.contemplativeSurface`) no modo escuro.
- **feat(platform,android)**: Harmonização geométrica do `@drawable/splash_icon_dark` na Splash Screen noturna nativa, eliminando completamente a máscara circular escura do protótipo anterior e garantindo a mesma geometria canônica do livro aberto e da cruz luminosa do Pergaminho Nobre.

### Changed
- **chore(release)**: Bump monotônico de versão para `v0.9.58+84`.

### Tests
- Testes automatizados de widgets `test/core/widgets/privacy_screen_wrapper_test.dart` e `test/features/splash/presentation/pages/splash_page_test.dart` 100% aprovados.
- Análise estática com `flutter analyze --no-fatal-infos` concluída com 0 issues.

## [0.9.57] - 2026-10-01

### Added
- **feat(brand)**: Adoção do ícone mestre oficial no conceito **Pergaminho Nobre** (`assets/images/app_logo.png`) com fundo papiro nobre (`#FBF7EF`), traços em Bronze Litúrgico (`#8B6914`) e luz sagrada centralizada na Palavra.
- **feat(platform,android)**: Implementação de **Splash Screen Dinâmica e Adaptativa ao Tema**:
  - **Modo Claro**: Fundo Pergaminho Nobre (`#FBF7EF`) com emblema em Bronze (`@drawable/ic_launcher_foreground`).
  - **Modo Escuro**: Fundo Noite Contemplativa (`#161616`) com emblema em Ouro Champagne (`@drawable/splash_icon_dark`).
  - Retrocompatibilidade nativa para versões anteriores ao Android 12 via `drawable/launch_background.xml` e `drawable-night/launch_background.xml`.
- **feat(platform,android)**: Suporte a **Themed Icons** do Android 13+ (Material You) com camada monocromática `@drawable/ic_launcher_monochrome`, adaptando o ícone do launcher dinamicamente às cores do sistema.
- **test(splash)**: Teste de widget automatizado para a `SplashPage` (`test/features/splash/presentation/pages/splash_page_test.dart`).

### Changed
- **chore(release)**: Bump monotônico de versão para `v0.9.57+83`.

### Tests
- Suíte completa de testes de regressão aprovada com 1080 testes (100% passing).
- `flutter analyze --no-fatal-infos` com 0 issues.

## [0.9.56] - 2026-10-01

### Added
- **feat(platform,android)**: Implementação canônica da Android 12+ SplashScreen API em `values-v31/styles.xml` e `values-night-v31/styles.xml`, com background `@color/ic_launcher_background` (`#0E1A30` / Deep Navy) e ícone `@drawable/ic_launcher_foreground` dourado, eliminando a tela branca e o ícone recortado.
- **feat(platform,android)**: Configuração de ícones adaptativos (Android 8.0+) em `res/mipmap-anydpi-v26/ic_launcher.xml` e `colors.xml`, garantindo suporte nativo a máscaras dinâmicas (círculo, squircle) nos launchers sem distorção.
- **feat(brand)**: Novo logotipo e ícone oficial da aplicação (`assets/images/app_logo.png`) alinhado ao tema "Luz na Palavra" com traços em Ouro Champagne (`#C5A059`), Chama da Oração (`#D4AF37`) e fundo Deep Navy (`#0E1A30`), além de todos os assets atualizados para Android e iOS.

### Changed
- **perf(startup)**: Otimização de inicialização (*Cold Start*) no `lib/main.dart` com execução assíncrona desacoplada (`unawaited`) dos serviços periféricos (`AppCheckService`, `RemoteConfigService`, `PushNotificationService`, `IModelDownloadService`), liberando `runApp()` imediatamente e eliminando o travamento da tela de splash.
- **chore(release)**: Bump monotônico de versão para `v0.9.56+82`.

### Tests
- Suíte completa de testes de regressão aprovada com 1079 testes (100% passing).
- `flutter analyze --no-fatal-infos` com 0 issues.

## [0.9.55] - 2026-10-01

### Added
- **feat(drawer)**: Exibição da versão do aplicativo no rodapé do menu lateral (`DailyDashboardDrawer`), acompanhando a insígnia de fidelidade ao Cânon Bíblico Católico (`pwE • Cânon Católico (73 Livros)`).
- **feat(core)**: Criação do contrato `IAppInfoService` e da implementação `AppInfoService` em `lib/core/services/app_info_service.dart`, integrando o plugin oficial `package_info_plus` e registrando o serviço no container de injeção de dependências global (`sl`).
- **feat(i18n)**: Suporte completo à internacionalização da versão (`drawerAppVersion`) em todos os 18 catálogos ARB (`pt`, `en`, `es`, `la`, `de`, `fr`, `it`, `ar`, `hi`, `ja`, `ko`, `nl`, `pl`, `sw`, `tl`, `uk`, `vi`, `zh`).
- **feat(a11y)**: Identificador semântico acessível `drawer_footer_version_info` em conformidade com as diretrizes do Firebase App Testing Agent e WCAG.

### Changed
- **chore(release)**: Bump monotônico de versão para `v0.9.55+81`.

### Tests
- Testes unitários para `AppInfoService` (`test/core/services/app_info_service_test.dart`) cobrindo versão semântica, número de build e mock.
- Testes de widget do `DailyDashboardDrawer` atualizados e expandidos (`test/features/lectio_divina/presentation/widgets/daily_dashboard_drawer_test.dart`).
- Suíte completa de testes de regressão aprovada com 1079 testes (100% passing).
- `flutter analyze --no-fatal-infos` com 0 issues.

## [0.9.54] - 2026-10-01

### Added
- **feat(ci,ios)**: Adicionado workflow automatizado `.github/workflows/ios-simulator-appetize.yml` para compilar o aplicativo no simulador iOS (`flutter build ios --simulator --debug --no-codesign`) e despachar automaticamente o artefato compactado (`Runner.zip`) para a plataforma Appetize.io via API REST v1.
- **docs(adr)**: ADR 0019 registrando a decisão arquitetural de homologação visual iOS no Appetize.io, dispensando hardware Mac físico e eliminando a dependência do Apple Developer Program pago ($99/ano).

### Changed
- **chore(release)**: Bump monotônico de versão para `v0.9.54+80`.
## [0.9.53] - 2026-10-01

### Fixed
- **fix(worker)**: `TheologicalLinter` agora utiliza regex com delimitadores léxicos de palavra (`\b`) em vez de `String.contains()`, eliminando o falso positivo que marcava o vocábulo teológico "promptings" (moções do Espírito Santo) como infração. Lista `kProhibitedTechRules` adicionada como `List<({String label, RegExp regex})>` com delimitadores `\b` em todos os padrões.
- **fix(worker)**: `_buildLocalizedLiturgy()` agora gera títulos, celebrações e estações litúrgicas completamente localizados para todos os 6 idiomas secundários (en, es, la, it, de, fr). Implementados: ordinais nativos em inglês via `toOrdinalEn()`, algarismos romanos via `toRoman()` para latim, e tabela `knownFeasts` com traduções das festas canônicas de setembro-outubro para os 6 idiomas.
- **fix(worker)**: Prompt Gemini para geração de `sacredIconExplanation` agora utiliza `iconSectionHeaders` com cabeçalhos de seção no idioma do documento alvo, em vez de emitir sempre em português.
- **fix(firestore)**: Remediados 48 documentos não-PT da coleção `daily_liturgies` com campos `title`, `celebration` e `liturgicalSeason` corretamente internacionalizados (ordinais e termos nativos por idioma).
- **fix(firestore)**: Documento `2026-10-02_en` revalidado com o novo motor léxico do `TheologicalLinter`; atualizado para `metadata.theologicalStatus = "verified"`, `nihilObstat = true` e `auditIssues = []`.

### Added
- **feat(firestore)**: Ícone sagrado dos Santos Mártires (`icon_saints_martyrs.png`) sincronizado nos 7 documentos `2026-10-03_{pt,en,es,la,it,de,fr}` via upload para `gs://<REDACTED_GCS_CDN_BUCKET>/icons/daily_icon_2026_10_03.png`.

### Changed
- **chore(release)**: Bump monotônico de versão para `v0.9.53+79`.

### Tests
- `flutter analyze --no-fatal-infos` → **0 issues** após remoção dos scripts de diagnóstico temporários.
- `flutter test test/features/lectio_divina/` → **592 testes aprovados** (100% passing).
- Auditoria final da coleção: `{verified: 56}` (100%), `sacredIconUrl` presente em `56/56 (100%)`, `auditIssues` em `0/56`.

## [0.9.52] - 2026-09-30

### Fixed
- **fix(lectio,typography)**: Correção da inconsistência tipográfica na Primeira Leitura em relação ao Salmo e Evangelho:
  - Substituição de `RichText` bruto por `Text.rich` em `SacredDropCapText`, assegurando que o parágrafo inicial com letra capitular respeite adequadamente a escala de texto do sistema (`MediaQuery.textScalerOf(context)`).
  - Parametrização de `fontFamily: SacredFontFamily` em `LiturgicalDialogueCard`, permitindo que os versículos e aclamações litúrgicas acompanhem a família tipográfica sacra selecionada pelo fiel em vez de fixar `GoogleFonts.lora`.
  - Consolidação de fórmulas de introdução oratória curtas terminadas em `:` ou `,` (ex: "Jó respondeu a seus amigos e disse:") com o primeiro parágrafo de leitura em `_extractCleanParagraphs`, impedindo que a capitular fique isolada em uma linha oratória curta.
  - Harmonização da cor e tipografia da referência bíblica (`passage.reference`) na leitura imersiva, substituindo a cor ciano genérica (`theme.colorScheme.primary`) por `GoogleFonts.cinzel` com token sacro `context.sacred.goldAccent`.

### Changed
- **refactor(lectio,ui)**: Harmonização do botão de cópia da leitura com a interface sacra do pwE:
  - Remoção do botão flutuante em formato de chip/pílula que causava ruído visual no topo da leitura entre o título da festa litúrgica e a perícope.
  - Inclusão do botão de cópia na `SliverAppBar.actions` (tanto em modo retrato quanto paisagem) com ícone áureo, tooltip e semântica acessível (`immersive_copy_scripture_button` e `immersive_landscape_copy_scripture_button`).
  - Adição de botão solene e centrado no rodapé da leitura (`sacred_reading_copy_button`) antes do crédito canônico, estilizado com `GoogleFonts.cinzel`, borda suave e haptic feedback sagrado.
- **chore(release)**: Bump monotônico de versão para `v0.9.52+78`.

### Tests
- Suítes de testes de `sacred_drop_cap_text_test.dart` (2/2), `liturgical_dialogue_card_test.dart` (2/2), `sacred_reading_content_test.dart` (12/12) e `immersive_reading_page_test.dart` (8/8) 100% aprovados.
- Suíte global do app com 1075 testes aprovados (100% passing).

## [0.9.51] - 2026-09-30

### Fixed
- **fix(profile,ux)**: Eliminação do flicker de erro vermelho na inicialização da `ProfilePage` ao renderizar o `CandleFlameWidget(size: 44)` para os estados `ProfileInitial` e `ProfileLoading`.
- **fix(profile,auth)**: Adicionado listener reativo para `AuthState.authenticated` no `ProfilePage`, disparando automaticamente o `LoadProfileEvent` após o login do fiel.
- **fix(profile,data)**: Mapeamento de `permission-denied` em `ProfileRemoteDataSource.saveProfile` para `PermissionException` do core, assegurando coerência no tratamento funcional de erros com dartz `PermissionFailure`.
- **fix(profile,domain)**: Cálculo de diferença de dias imune a transições de horário de verão (DST) em `UpdateStreakUseCase` utilizando `DateTime.utc(y, m, d)`.
- **fix(profile,onboarding)**: Desbloqueio do fluxo assíncrono de navegação ao desacoplar `HapticFeedback.mediumImpact()` via `unawaited(...)` em `OnboardingPage`.

### Added
- **feat(profile,a11y)**: Blindagem completa de acessibilidade semântica e suporte ao Firebase App Testing Agent (Regra 10):
  - Identificadores snake_case declarativos em `ProfilePage`: `switch_daily_reminders`, `tile_edge_llm_privacy`, `tile_legal_notice`, `btn_save_profile`, `btn_sign_out`, `btn_delete_account`, `input_profile_age`, `dropdown_profile_gender`, `input_prayer_intentions`, `radio_maturity_*`, `btn_confirm_delete_account`, `btn_cancel_delete_account`.
  - Identificadores snake_case em `ProfileSetupPage`: `input_setup_age`, `dropdown_setup_gender`, `input_setup_intentions`, `btn_finish_profile_setup`, `btn_switch_account`.
  - Identificadores snake_case em `OnboardingPage`: `btn_onboarding_skip`, `btn_onboarding_back`, `btn_onboarding_next`, `btn_onboarding_customize`.
  - Identificador semântico em `MaturityCelebrationDialog`: `btn_close_maturity_dialog`.
  - Proteção `ExcludeSemantics` em divisores decorativos (`CrossOrnamentalDivider`), halos áureos (`GoldenHalo`) e ícones sacros puramente ornamentais.
- **test(profile)**: Nova suíte de testes de widgets `onboarding_page_test.dart` com 4 cenários cobrindo renderização, navegação de slides, alternância de CTAs e persistência em SharedPreferences.

### Changed
- **refactor(profile,clean-arch)**: Encapsulamento da regra de negócio de maturidade espiritual natural na entidade `UserProfile` via getter `naturalMaturityLevel` baseado em `highestStreak`, simplificando a resolução de maturidade e eliminando duplicações na camada de apresentação.
- **refactor(profile,data)**: Normalização resiliente de gênero no `UserProfileModel.fromJson` delegando a `UserProfile.normalizeGender` sem fallback fixo em texto arbitrário.
- **chore(release)**: Bump monotônico de versão para `v0.9.51+77`.

### Tests
- Suíte completa do módulo `profile` com 68 testes aprovados (100% passing).
- Suíte global do app com 1075 testes aprovados (100% passing).

## [0.9.50] - 2026-09-30

### Fixed
- **fix(lectio_divina,layout)**: Correção de RenderFlex overflow de 65px no rodapé de sigilo espiritual de `SoulJournalBlock` (`sacred_canvas_blocks.dart`) ao envolver o texto informativo em `Flexible(child: Text(..., overflow: TextOverflow.ellipsis))`.
- **fix(lectio_divina,test)**: Blindagem determinística do teste de padding em `session_detail_page_test.dart` fixando dimensões de viewport em retrato (`tester.view.physicalSize = Size(800, 1200)`), prevenindo disparo acidental do layout landscape `AdaptiveTwoPane`.

### Added
- **feat(lectio_divina,i18n)**: Suporte completo à internacionalização quádrupla (pt, en, es, la) e demais 14 idiomas nos catálogos ARB para tags de seção do Caderno Espiritual (`journalLectioTag`, `journalMeditatioTag`, `journalOratioTag`) e rótulo semântico (`journalCardSemantics`), zerando avisos de mensagens não traduzidas no `flutter gen-l10n`.
- **feat(lectio_divina,a11y)**: Blindagem de acessibilidade semântica e suporte ao Firebase App Testing Agent (Regra 10):
  - Adicionados identificadores semânticos snake_case nos botões de alternância de modo, cópia, configurações de leitura e chips de filtro em `SessionDetailPage` (`session_detail_carousel_toggle_button`, `session_detail_copy_button`, `session_detail_reading_settings_button`, `session_detail_filter_${index}_chip`).
  - Adicionado `Semantics(identifier: 'sacred_journal_card_${session.id}', ...)` e proteção `ExcludeSemantics` em glifos sacros ornamentais (`✦`) no `SacredJournalCard`.
  - Adicionados `clear_search_button` e `soul_state_filter_${state.name}` nos controles de busca e pílulas de humor espiritual em `SessionHistoryPage`.

### Changed
- **refactor(lectio_divina)**: Erradicação de strings hardcoded em `SessionDetailPage` e `SacredJournalCard`, consumindo estritamente chaves de `context.l10n`.
- **chore(release)**: Bump monotônico de versão para `v0.9.50+76`.

### Tests
- Suíte completa do módulo `lectio_divina` com 592 testes aprovados (100% passing).
- Suíte global do app com 1065 testes aprovados (100% passing).

## [0.9.49] - 2026-09-30

### Added
- **feat(auth)**: Stream reativo `watchAuthState()` — o `AuthBloc` agora assina `firebaseAuth.authStateChanges()` via `WatchAuthStateUseCase`, reagindo automaticamente a expiração de token, logout em outro dispositivo ou mudanças externas de sessão. O handler ignora eventos do stream durante operações explícitas (`AuthLoading`) para evitar race conditions. A subscription é cancelada no `close()` do Bloc.
- **feat(auth)**: Novo `AuthStateChangedEvent` na tríade Bloc para suportar transições reativas de autenticação emitidas pelo stream do Firebase.
- **test(auth)**: Widget tests completos para `LoginPage` (7 testes) — cobertura de renderização do título, botões Google/Convidado com `Semantics(identifier:)`, `CandleFlameWidget` durante loading, dispatch de eventos e links legais.
- **test(auth)**: Testes unitários para `WatchAuthStateUseCase` (3 testes) — delegação ao repositório, emissão de null e propagação de erros.
- **test(auth)**: Testes unitários para `WebAccessRepositoryImpl` (8 testes) — isWebPlatform, isWebAccessRestricted, autorização via Remote Config, fallback Firestore, negação e degradação graciosa.

### Changed
- **refactor(auth,clean-arch)**: Extração de dependências Firebase/Flutter do `CheckWebAccessUseCase` (camada Domain) para a camada Data — criado contrato `WebAccessRepository` (Domain) com implementação `WebAccessRepositoryImpl` (Data) que encapsula `RemoteConfigService`, `FirebaseFirestore` e `kIsWeb`. A camada Domain permanece pura e sem imports de frameworks externos.
- **refactor(auth)**: Container de DI da feature (`auth_injection_container.dart`) atualizado para registrar `WatchAuthStateUseCase`, `WebAccessRepository → WebAccessRepositoryImpl` e novo parâmetro `watchAuthState` no `AuthBloc`.
- **chore(release)**: Bump monotônico de versão para `v0.9.49+75`.

### Fixed
- **fix(auth)**: Método `signOut()` no `AuthRemoteDataSourceImpl` agora trata erros do `googleSignIn.signOut()` de forma independente (best-effort), garantindo que `firebaseAuth.signOut()` sempre seja executado mesmo se o Google Sign-In falhar.
- **fix(auth)**: Tipo de retorno de `AuthEvent.props` corrigido de `List<Object>` para `List<Object?>`, alinhando com o contrato `Equatable` e permitindo `AuthStateChangedEvent(UserAuth?)`.

### Tests
- Cobertura do módulo auth subiu de **81 → 102 testes** (+21 novos), todos passando.
- Suíte de testes atualizada para refletir a nova assinatura do `CheckWebAccessUseCase` (mocka `WebAccessRepository`) e do `AuthBloc` (mocka `WatchAuthStateUseCase`).

## [0.9.48] - 2026-09-30

### Security
- **fix(subscription)**: Blindagem de simulação em produção — em `kReleaseMode`, erros da loja (Google Play / App Store) agora propagam `PlatformException` ao invés de conceder acesso gratuito via simulação local silenciosa.
- **fix(subscription)**: Trial anti-reset via `CustomerInfo.firstSeen` do RevenueCat — data de primeiro acesso agora é reconciliada entre servidor (imutável) e local (`SharedPreferences`), usando a mais antiga. Limpar dados do app não reinicia mais o trial de 7 dias.

### Fixed
- **fix(subscription)**: Migração de API deprecada `Purchases.purchasePackage()` para `Purchases.purchase(PurchaseParams.package(...))` conforme RevenueCat SDK v10.
- **fix(subscription)**: Strings hardcoded em português no `SubscriptionBloc` substituídas por `SubscriptionSuccessType` enum semântico. A resolução i18n via `context.l10n` agora ocorre exclusivamente na camada de UI (`BenefactorPage`).
- **fix(subscription)**: Impureza temporal na entidade `SubscriptionStatus` — getters `isExpired`, `isTrialActive`, `trialDaysRemaining`, `canAccessCompleteLiturgy` e `canAccessFreePassage` agora possuem variantes `*At(DateTime?)` para testes determinísticos.
- **fix(subscription)**: Removido override manual redundante de `==`/`hashCode` em `SubscriptionStatus` (já fornecidos pelo Equatable via `props`).

### Changed
- **refactor(subscription)**: Método monolítico `_getFallbackPlans` (~410 linhas, 14 idiomas) extraído de `SubscriptionRepositoryImpl` para `fallback_plans_catalog.dart` como função de nível superior `getFallbackSubscriptionPlans()`.
- **refactor(subscription)**: `SubscriptionRepositoryImpl.getSubscriptionStatus()` agora reconcilia `firstInstalledAt` entre RevenueCat server-side e cache local.
- **chore(release)**: Bump monotônico de versão para `v0.9.48+74`.

## [0.9.47] - 2026-09-30

### Fixed
- **fix(policy,lifecycle)**: Eliminação de crash por `Null check operator used on a null value` no `OrientationPolicy` durante o desmonte (`dispose`/`unmount`) de telas imersivas:
  - **RCA (Root Cause Analysis)**: Em `_ImmersiveReadingPageState.dispose()`, a invocação de `lockPortrait()` chamava `context.isTabletOrDesktop` (`MediaQuery.sizeOf(context)`). Durante a desmontagem do widget, o `Element` é marcado como inativo e perde acesso seguro a `InheritedWidget`s, violando a regra de ciclo de vida do Flutter e disparando exceção interna em `Element.widget!`.
  - **Blindagem Defensiva**: Introduzido cache seguro `_isTabletCache` capturado de forma reativa no ciclo `didChangeDependencies()` do mixin `OrientationPolicy`.
  - **Fallback Nativo**: O método `lockPortrait()` consome prioritariamente o valor em cache sem acessar `BuildContext` no `dispose()`, com fallback para `PlatformDispatcher.instance.views` da janela nativa.
  - **Proteção em Diálogos**: `disableLandscape()` blindado para mitigar consultas de tela quando invocado em callbacks de fechamento de diálogos.
  - **Testes de Regressão**: Criada suíte completa em `test/core/utils/orientation_policy_test.dart` com 6 testes garantindo zero exceções em desmontagens e validação das orientações em celular e tablet.
- **chore(release)**: Bump monotônico de versão para `v0.9.47+73`.

## [0.9.46] - 2026-09-30

### Added
- **feat(ux,orientation)**: Política de Orientação Seletiva — landscape inteligente por tela:
  - `OrientationPolicy` mixin (`lib/core/utils/orientation_policy.dart`): Sistema de controle de orientação por tela. Em celulares, portrait é travado por padrão; telas imersivas liberam landscape individualmente via `allowLandscape()` / `lockPortrait()`. Tablets (`shortestSide >= 600dp`) sempre permitem landscape.
  - `LandscapeRotationHint` widget (`lib/core/widgets/landscape_rotation_hint.dart`): Banner sutil e respeitoso que aparece **uma única vez** (persistido via `SharedPreferences`) em telas que suportam landscape, sugerindo ao fiel girar o celular. Animação de slide-up com auto-dismiss em 8s.
  - **Telas que permitem landscape:**
    - `ImmersiveReadingPage`: Experiência "Bíblia Aberta" — texto sagrado e meditação lado a lado.
    - `SacredIconContemplationDialog` (Contemplação Pura): Ícone sacro preenche a tela widescreen.
  - **Telas travadas em portrait (celulares):** Dashboard, Preparação, Login, Profile, SessionHistory, Benefactor, ModelManagement, Onboarding, Splash e todas as demais.
  - `main.dart` atualizado para travar `portraitUp` por padrão em celulares.
- **chore(release)**: Bump monotônico de versão para `v0.9.46+72`.

## [0.9.45] - 2026-09-30

### Added
- **feat(ui,landscape)**: Redesign completo e unificação do modo paisagem (Landscape) em todas as 17 telas do pwE, seguindo o conceito arquitetural **"Scriptorium Sacro"**:
  - **Infraestrutura Core:**
    - `SacredCompactAppBar` (`lib/core/widgets/sacred_compact_app_bar.dart`): Novo widget de AppBar compacta (44dp) para modo paisagem, com identidade sacra (título Lora entre cruzes ✠ douradas) e feedback tátil, extraído e unificado a partir do padrão inline do `ImmersiveReadingPage`.
    - `AdaptiveTwoPane`: Adicionadas propriedades `respectSafeArea` (proteção automática contra entalhes laterais/notch/Dynamic Island em landscape) e `compactVerticalMode` (adaptação automática de espaçamentos para alturas < 500dp). Divisor sacro dourado como padrão visual.
    - `ResponsiveContext`: 3 novos métodos — `horizontalSafeInsets`, `landscapeContentPadding()` (padding consciente do notch) e `adaptiveColumns()` (cálculo inteligente de colunas para grids responsivos).
  - **Telas Existentes Refatoradas (5):**
    - `DailyDashboardPage`: SafeArea horizontal + padding adaptativo + AppBar compacta em landscape.
    - `ImmersiveReadingPage`: AppBar inline substituída por `SacredCompactAppBar` reutilizável + hint text no painel Lectio.
    - `PreparationPage`: `Row` manual migrada para `AdaptiveTwoPane` com divisor sacro e scroll independente.
    - `LoginPage`: `Row` manual migrada para `AdaptiveTwoPane` + botões de autenticação constrained (max 320dp).
    - `LectioPage`: Tab 0 com SafeArea/divider, Tab 1 com `adaptiveColumns()`, Tab 2 (OCR) com `AdaptiveTwoPane`.
  - **Telas com Landscape Novo (9):**
    - `SessionHistoryPage`: Padrão **Master-Detail** — lista do Caderno Espiritual à esquerda, preview da sessão selecionada à direita.
    - `SessionDetailPage`: Padrão **Pergaminho Duplo** — passagem bíblica à esquerda, blocos de meditação/oração/resolução à direita.
    - `ProfilePage`: Padrão **Retábulo Pessoal** — identidade/streak à esquerda, configurações à direita.
    - `ProfileSetupPage`: Padrão **Formulário Dividido** — boas-vindas à esquerda, campos do formulário à direita.
    - `BenefactorPage`: Padrão **Convite Fraternal** — citação espiritual à esquerda, planos de contribuição à direita.
    - `ModelManagementPage`: Padrão **Scriptorium Digital** — capacidade do dispositivo à esquerda, modelos à direita.
    - `OnboardingPage`: Paddings adaptativos para `isCompactHeight`, botões visíveis sem overflow vertical.
    - `SplashPage`: Logo/halo reduzidos (80x80), espaçamentos compactados, disclaimer visível.
    - `AiSelectionPage`: `Row` manual migrada para `AdaptiveTwoPane` consistente.
- **chore(release)**: Bump monotônico de versão para `v0.9.45+71`.

## [0.9.44] - 2026-09-30


### Fixed
- **fix(ui,contemplation)**: Harmonização do tema sacro e alinhamento tipográfico no modal de Contemplação do Mistério (`SacredIconContemplationDialog`):
  - **Fundo da Moldura da Arte Sacra**: Substituída a cor preta fixa (`Colors.black`) na moldura do ícone bizantino pelo token temático sacro (`0xFFF5EFEB` no tema claro e `0xFF14100B` no tema escuro), garantindo que áreas não preenchidas por ícones em proporções widescreen (com `BoxFit.contain`) integrem-se organicamente com a estética de pergaminho/noite contemplativa e o halo dourado.
  - **Pílula de Modo Contemplação Pura**: Fundo e bordas adaptados ao tema (`0xFFFDFBF7` translúcido no tema claro e escuro no tema escuro com halo dourado e sombras elevadas), eliminando blocos pretos rígidos.
  - **Alinhamento do CTA 'Iniciar Lectio Divina com este Mistério'**: Reformulada a estrutura interna do botão de ação com `Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center)` e `Text(..., textAlign: TextAlign.center, height: 1.25)`, eliminando o desalinhamento visual assimétrico onde a segunda linha ("Mistério") ficava recuada à extrema esquerda e o ícone do livro ficava desequilibrado.
  - **Modo Paisagem (Landscape)**: Ajustada a moldura do ícone e o botão CTA para compartilharem a mesma elegância e centralização em orientações horizontais.
- **chore(release)**: Bump monotônico de versão para `v0.9.44+70`.

## [0.9.43] - 2026-09-30

### Fixed
- **fix(ui,halo)**: Resolução de exceção de asserção de ciclo de vida do Flutter em `_GoldenHaloState` (`dependOnInheritedWidgetOfExactType<MediaQuery>() called before initState() completed`):
  - **RCA (Root Cause Analysis)**: A função `_handleMotionPreference()` realizava chamada a `MediaQuery.maybeOf(context)` dentro de `initState()`, violando as diretrizes de ciclo de vida do framework Flutter onde `InheritedWidget`s não podem ser consultados antes do término do `initState()`.
  - **Correção Cirúrgica**: Removida a invocação prematura em `initState()`, delegando a checagem da preferência de acessibilidade (`disableAnimations`) exclusivamente para `didChangeDependencies()` e `didUpdateWidget()`.
  - **Teste de Regressão**: Adicionado teste automatizado em `sacred_painters_test.dart` (`respects disableAnimations from MediaQuery without throwing exception`).
- **chore(release)**: Bump monotônico de versão para `v0.9.43+69`.

## [0.9.42] - 2026-09-30

### Fixed
- **fix(bloc,concurrency)**: Blindagem defensiva e resolução de condições de corrida em 4 BLoCs estratégicos diagnosticados pelo `@debugger`:
  - **`SubscriptionBloc`**: Adicionado guardrail no início de `PurchaseSelectedPlanEvent` e `RestorePurchasesEvent` para descartar toques concorrentes e requisições simultâneas enquanto o processamento já está ativo (`SubscriptionUIStatus.purchasing` ou `loading`), eliminando o risco de duplicidade de compras nas lojas oficiais.
  - **`LectioSessionBloc`**: Implementada trava de segurança em `CompleteSessionEvent` para impedir duplo salvamento concorrente (`isLoading: true`) e introduzido debouncing temporal (400ms) em `ScrollReachedEndEvent` para evitar que rajadas de scroll ou toques rápidos pulem acidentalmente etapas sagradas da Lectio Divina (ex: salto direto de Lectio para Oratio ignorando Meditatio).
  - **`ProfileBloc`**: Adicionada blindagem contra requisições concorrentes em `SaveProfileEvent` (`ProfileLoading`) e descarte de operações redundantes de mesmo perfil para evitar concorrência assíncrona fora de ordem (*out-of-order writes*) no Firestore e Hive após auto-salvamento de maturidade espiritual.
  - **`DailyLiturgyBloc`**: Substituído o bloqueio rígido que descartava novas datas solicitadas por um identificador sequencial de requisição (`_currentRequestId`), garantindo que respostas de requisições obsoletas sejam silenciosamente descartadas e que alternâncias rápidas no calendário litúrgico sempre exibam a data mais recente solicitada pelo fiel.
  - **Testes de Regressão Automatizados**: Adicionados testes de regressão em `subscription_bloc_test.dart`, `lectio_session_bloc_test.dart`, `profile_bloc_test.dart` e `daily_liturgy_bloc_test.dart` comprovando a blindagem contra corridas e descartes indevidos.
- **chore(release)**: Bump monotônico de versão para `v0.9.42+68`.

## [0.9.41] - 2026-09-30

### Added
- **feat(agents,finops)**: Integração do 14º Agente Especialista em Governança Financeira e Eficiência de Nuvem (`@finops`):
  - Nova skill especializada [.agents/skills/finops/SKILL.md](https://github.com/evslopes/pwE/blob/develop/.agents/skills/finops/SKILL.md) e workflow operacional [.agents/workflows/finops.md](https://github.com/evslopes/pwE/blob/develop/.agents/workflows/finops.md).
  - Persona no GitHub Copilot em [.github/agents/finops.agent.md](https://github.com/evslopes/pwE/blob/develop/.github/agents/finops.agent.md).
  - Ampliação do Pilar I (Governança, FinOps, Produto & Doutrina) nos catálogos [AGENTS.md](https://github.com/evslopes/pwE/blob/develop/AGENTS.md), [GEMINI.md](https://github.com/evslopes/pwE/blob/develop/GEMINI.md), [.github/copilot-instructions.md](https://github.com/evslopes/pwE/blob/develop/.github/copilot-instructions.md), [docs/README.md](https://github.com/evslopes/pwE/blob/develop/docs/README.md), [agent_governance_and_security.md](https://github.com/evslopes/pwE/blob/develop/docs/architecture/agent_governance_and_security.md) e [development_lifecycle.md](https://github.com/evslopes/pwE/blob/develop/docs/sdlc/development_lifecycle.md).
  - **Quality Gate Financeiro Mandatório (Parecer FinOps Pré-Release on Main)**: Adição do 5º pilar eliminatório no checklist oficial [docs/releases/release-checklist.md](https://github.com/evslopes/pwE/blob/develop/docs/releases/release-checklist.md) com emissão obrigatória do *FinOps Clearance Certificate* validando que o custo projetado de toda release para `main` é estritamente **R$ 0,00 / mês**.
  - **Rotina Periódica de Auditoria e Otimização**: Cadência quinzenal de inspeção ativa de telemetria no GCP Billing, detecção de recursos zumbis no Artifact Registry/Cloud Run e proposição de estratégias para preservação perpétua das cotas gratuitas (Free Tier) mantendo a qualidade orante da entrega.
  - Vínculo formal de governança com o modelo de custos em [docs/architecture/cost_optimization_model.md](https://github.com/evslopes/pwE/blob/develop/docs/architecture/cost_optimization_model.md).
- **chore(release)**: Bump monotônico de versão para `v0.9.41+67`.

## [0.9.40] - 2026-09-30

### Added
- **feat(agents,debugger)**: Criação do 13º Agente Especialista e Skill de Diagnóstico Avançado (`@debugger`):
  - Nova skill especializada [.agents/skills/debugger/SKILL.md](https://github.com/evslopes/pwE/blob/develop/.agents/skills/debugger/SKILL.md) e workflow operacional [.agents/workflows/debugger.md](https://github.com/evslopes/pwE/blob/develop/.agents/workflows/debugger.md).
  - Persona no GitHub Copilot em [.github/agents/debugger.agent.md](https://github.com/evslopes/pwE/blob/develop/.github/agents/debugger.agent.md).
  - Ampliação do Pilar IV de Qualidade, Diagnóstico & Infraestrutura nos catálogos [AGENTS.md](https://github.com/evslopes/pwE/blob/develop/AGENTS.md), [GEMINI.md](https://github.com/evslopes/pwE/blob/develop/GEMINI.md) e [.github/copilot-instructions.md](https://github.com/evslopes/pwE/blob/develop/.github/copilot-instructions.md).
  - Heurísticas consolidadas para Root Cause Analysis (RCA), auditoria de vazamento de memória em streams de BLoC, resolução de RenderFlex overflows, conformance com TextScaler 2.0x e diagnóstico de integrações externas (Gemini, Firebase, OCR).
- **chore(release)**: Bump monotônico de versão para `v0.9.40+66`.

## [0.9.39] - 2026-09-30

### Added
- **feat(a11y,semantics)**: Resgate e aplicação estrita das melhorias de acessibilidade visual, WCAG e Firebase App Testing Agent:
  - Rotulagem semântica explícita com `Semantics(identifier: '...', button: true)` nos fluxos de autenticação (`sign_in_apple_button`, `sign_in_google_button`, `terms_of_use_link`, `privacy_policy_link`), salvamento (`hold_to_save_button`), benfeitores (`benefactor_card`, `benefactor_plan_card`) e seleção de IA (`ai_provider_card`).
  - Suporte ao respeito de redução de movimento do sistema (`disableAnimations` / `reduceMotion`) em `GoldenHalo` e `CandleFlameWidget`.
  - Blindagem de divisores ornamentais sacros com `ExcludeSemantics` (`CrossOrnamentalDivider`).
  - Conformidade com dimensões mínimas de toque WCAG (48x48 dp) nos botões e links de navegação.
- **docs(agents)**: Protocolo Mandatório de Conclusão de Tarefas (Task Completion Protocol, Develop Release & Branch Cleanup):
  - Criação da regra `.agents/rules/task_completion_protocol.md` e da skill `.agents/skills/task-finisher/SKILL.md`.
  - Atualização dos ritos operacionais em `.agents/rules/git_conventions.md`, `.agents/workflows/devops.md`, `AGENTS.md`, `GEMINI.md`, `.github/copilot-instructions.md`, `.github/agents/devops.agent.md`, `.github/agents/engineer.agent.md` e `.agents/skills/agile/SKILL.md`.
  - Rito de 4 etapas: (1) Revisão documental, (2) Quality Gates & Bump SemVer, (3) Release em `develop`, (4) Higienização de worktrees e branches.
- **chore(release)**: Bump monotônico de versão para `v0.9.39+65`.

## [0.9.38] - 2026-09-29

### Added
- **feat(profile,maturity)**: Auto-salvamento reativo e propagação do nível de maturidade na Lectio Divina:
  - Seleção imediata de maturidade (`beginner`, `practitioner`, `contemplative` ou automático por constância) no perfil com feedback tátil háptico (`HapticFeedback.selectionClick()`), cache local anti-flicker e salvamento instantâneo via `ProfileBloc` sem necessidade de ação manual no botão Salvar.
  - Propagação do nível de maturidade do perfil do usuário para o início da Lectio Divina (`LectioSessionBloc`), `DailyDashboardPage`, `PreparationPage` e `ImmersiveReadingPage`.
  - Enriquecimento tipográfico do cabeçalho de seção no modo contemplativo (`LectioSectionHeader`) com insígnia áurea `✦ TÍTULO ✦` em Cinzel e subtítulo centralizado em Lora itálico.
  - Carregamento automático do perfil do usuário no listener de autenticação (`AuthMigrationListener`) para sincronização imediata pós-login.
- **docs(architecture)**: Atualização integral da modelagem de otimização de custos e arquitetura GCP a custo zero (`docs/architecture/cost_optimization_model.md`):
  - Documentação da migração para GCP Cloud Run Jobs (`daily-liturgy-worker`) e Cloud Scheduler (`daily-liturgy-trigger`).
  - Isolamento de chave Gemini API no Secret Manager vinculada ao projeto `pwE-AiStudio` com faturamento desativado (`billingEnabled: false`) para garantia absoluta contra cobranças.
  - Políticas de ciclo de vida e retenção do Artifact Registry (máx. 3 versões) e Cloud Storage (expiração de builds e relatórios em 7 dias).
  - Teto orçamentário no GCP Billing com alerta em 4 patamares para teto de R$ 5,00/mês.
- **chore(l10n)**: Sincronização e regeneração dos catálogos de localização Dart gerados (`lib/l10n/generated/app_localizations_*.dart`) para os 18 idiomas suportados.

### Fixed
- **test(auth)**: Injeção de `MockProfileBloc` no `MultiBlocProvider` do `AuthMigrationListenerTest`, garantindo 100% de cobertura e estabilidade nos testes de widget de autenticação.
- **chore(release)**: Bump e consolidação de versão para `v0.9.38+64`.

## [0.9.37] - 2026-09-29

### Added
- **feat(firestore,security)**: Blindagem de privacidade em embeddings e vetores espirituais:
  - Criptografia simétrica AES-GCM (`enc:v2:`) aplicada aos campos `relevantText` e `compressedSummary` em `FirestoreVectorSearchDataSource` via injeção de `IEncryptionService`.
  - Elevação do modelo de migração para `pwe-minilm-v2` no `LectioMigrationService` para re-cifragem automática de registros legados.
  - Correção canônica de cores litúrgicas no worker com prevalência do LitCal v5 em português.
  - Regra de segurança em `firestore.rules` para a coleção `allowed_testers` e controle de allowlist no Flutter Web.
  - Complementação de chaves de contemplação nos catálogos secundários ARB em todos os 18 idiomas.
- **chore(release)**: Bump e consolidação de versão para `v0.9.37+63`.

## [0.9.36] - 2026-09-29

### Added
- **feat(contemplation,ui)**: Redesign da Contemplação do Mistério no Retábulo Sacro (`SacredIconContemplationDialog`):
  - Animação de entrada contemplativa escalonada (fade + escala de 800ms) com desaceleração suave.
  - Seção invitatória com texto espiritual entre o ícone sagrado e os tópicos hermenêuticos.
  - Botão estilizado em card-style para o Sentido Espiritual das Leituras.
  - Card de Exegese com cabeçalho de cruz pátea `✠` e subtítulo lírico.
  - Transições expansíveis suaves com `AnimatedSize` (340ms easeInOutCubic).
  - Rotulagem semântica para acessibilidade e Firebase App Testing Agent nos botões e CTAs com `ExcludeSemantics` nos elementos ornamentais.
- **chore(release)**: Bump e consolidação de versão para `v0.9.36+62`.

## [0.9.35] - 2026-09-29

### Added
- **perf(architecture)**: Auditoria e otimizações de performance do aplicativo:
  - Redução de rebuilds desnecessários na camada de apresentação e otimização de consumo de memória em sessões contínuas de oração.
  - Ajustes de concorrência e alinhamento de inicializações de serviços assíncronos no bootstrap da aplicação.
- **chore(release)**: Bump e consolidação de versão para `v0.9.35+61`.

## [0.9.34] - 2026-09-28

### Added
- **feat(architecture,bloc)**: Migração e desacoplamento integral do OCR da UI para o BLoC:
  - Criação do evento `ProcessOcrImageEvent` no `LectioBloc`.
  - Injeção desacoplada de `ProcessOcrImageUseCase`, `ConsumeOcrQuotaUseCase` e `NormalizeOcrTextUseCase` via `LectioDivinaInjectionContainer`.
  - Notificação de estado na `LectioPage` via `BlocListener` eliminando chamadas diretas de casos de uso na camada presentation.
- **feat(architecture,domain)**: Movimentação de `IVectorSearchDataSource` para `domain/services/vector_search_datasource.dart`, sanando confusão de camadas.
- **feat(observability,bloc)**: Adição do campo `errorMessage` ao `ExegesisState` com feedback pastoral na interface em caso de falha de conexão com LLM.
- **feat(state,bloc)**: Uniformização do `LectioSessionBloc` com subclasses polimórficas estritas, adição do campo `isLoading` e fábrica privada `_copyWithState`.
- **test(coverage,bloc)**: Criação de 4 novas suítes de teste de BLoC completas (`ExegesisBloc`, `LectioSessionBloc`, `PassageDiscoveryBloc`, `SpiritualGuidanceBloc`) com `blocTest` e `mocktail`.
- **test(coverage,usecases)**: Criação de 6 novas suítes de teste para UseCases críticos de Autenticação (`DeleteAccountUseCase`, `GetCurrentUserUseCase`), Subscrição (`PurchasePlanUseCase`, `RestorePurchasesUseCase`) e Perfil (`GetProfileUseCase`, `SaveProfileUseCase`).
- **docs(releases)**: Criação do relatório de auditoria e governança `docs/releases/v0.9.34-audit-improvements-and-pending.md`.

### Changed
- **refactor(imports)**: Conversão de 127 importações relativas (`../../../`) que cruzavam fronteiras de features em imports canônicos de pacote (`package:pwe/...`).
- **chore(deps)**: Substituição da dependência descontinuada `flutter_markdown` por `flutter_markdown_plus: ^1.0.12`.
- **chore(deps)**: Atualização de `flutter_secure_storage` para `^11.2.0` e atualização segura de dependências patch/minor (`go_router 18.0.2`, `purchases_flutter 10.13.2`, `background_downloader 9.6.3`, etc.).
- **chore(release)**: Bump e consolidação de versão para `v0.9.34+60`.

## [0.9.33] - 2026-09-27

### Added
- **feat(liturgy,precedence)**: Implementação da Precedência Litúrgica Dominical Canônica (Tabela de Precedência n. 59 das Normas Universais sobre o Ano Litúrgico):
  - Primazia inegociável do Domingo sobre Memórias Obrigatórias, Memórias Facultativas e Festas de Santos.
  - Omissão canônica de memórias de santos coincidentes com Domingos do Tempo Comum (ex: São Vicente de Paulo no 26º Domingo do Tempo Comum).
  - Preservação do ciclo dominical trienal (`Ano A`, `Ano B` ou `Ano C`) nos domingos, evitando contaminação por ciclos feriais bienais (`Ano Par/Ímpar`).
  - Campo imutável `omittedCelebration` em `DailyLiturgy` e `DailyLiturgyModel` com persistência no Firestore e ingestão pelo Cloud Run Job (`daily_liturgy_worker.dart`).
- **feat(l10n,i18n)**: Internacionalização da notificação pastoral de omissão litúrgica:
  - Registro da chave parametrizada `omittedCelebrationNotice` em todos os catálogos ARB (`pt`, `en`, `es`, `la`, `de`, `fr`, `it`, etc.).
- **feat(ui,sacred)**: Exibição da nota litúrgica de omissão no `SacredIconAltarpieceCard` e `LiturgicalManuscriptCard`:
  - Tipografia sacra contemplativa com token `context.sacred.softText`.
  - Retábulo e seleção de ícones preservam a dignidade dominical do Mistério Pascal com o ícone de *Cristo Pantocrator*.
- **docs(liturgy,adr)**: Criação do `ADR 0018` e inclusão da regra `RN-LIT-016` no catálogo oficial de Regras de Negócio (`business_rules.md`).

### Fixed
- **fix(liturgy,parsers)**: Ajuste em `CnbbLiturgyParser` e `HtmlLiturgyParser` para aplicar a precedência dominical e capturar a memória omitida sem sobrescrever as leituras e perícopes dominicais.
- **fix(liturgy,cycle)**: Correção do cálculo do ano litúrgico em `DailyLiturgyModel.fromFirestore` e `DailyLiturgy.displayYear` para assegurar o ciclo dominical nos domingos.
- **chore(release)**: Bump e consolidação de versão para `v0.9.33+59`.

## [0.9.32] - 2026-09-27

### Added
- **feat(monetization,revenuecat)**: Padronização da arquitetura do RevenueCat e resiliência de entitlement:
  - Centralização da configuração via `REVENUECAT_ENTITLEMENT_ID` no `EnvConfig`, com suporte a `--dart-define` em compilação e `.env` em tempo de desenvolvimento.
  - Resolução resiliente com compatibilidade dupla em `SubscriptionStatusModel.fromCustomerInfo`, suportando tanto o identificador canônico `benefactor` quanto o legado `benfeitor_pwe`.
  - Mapeamento resiliente de pacotes de compra em `SubscriptionRemoteDataSourceImpl.purchasePlan` por ID de pacote (`$rc_annual`, `$rc_monthly`, `$rc_lifetime`), ID de produto da loja ou tipo de plano (`PackageType`), prevenindo quedas acidentais no modo de simulação.
  - Mapeamento explícito de produtos `lifetime` para o tipo de plano `SubscriptionPlanType.singleDonation`.
- **feat(l10n,pricing)**: Internacionalização integral e precificação por Paridade de Poder de Compra (PPP):
  - Inclusão das chaves canônicas de benfeitoria (`planMonthlyTitle`, `planMonthlyDesc`, `planAnnualTitle`, `planAnnualDesc`, `planOfferingTitle`, `planOfferingDesc`) em todos os **17 idiomas** suportados pelo aplicativo pwE (`pt`, `en`, `es`, `la`, `it`, `fr`, `de`, `pl`, `tl`, `vi`, `ko`, `ja`, `zh`, `ar`, `uk`, `sw`, `nl`, `hi`).
  - Arquitetura híbrida de exibição no `BenefactorPlanCard`: títulos e descrições são teologicamente canônicos e acompanham o idioma ativo do app, enquanto o preço e moeda (`priceString`) refletem fielmente a loja nativa (Google Play / App Store) do usuário.
  - Sanitizador nativo (`cleanStoreTitle`) para expurgar sufixos automáticos adicionados por lojas de aplicativos nos títulos dos produtos (ex: `"(pwE: Lectio Divina)"`).
  - Tabela mestra de precificação regionalizada (PPP) para operação offline e fallback em `SubscriptionRepositoryImpl._getFallbackPlans` cobrindo 14 zonas monetárias (BRL, USD, EUR, GBP, PLN, PHP, VND, KRW, JPY, INR, UAH, KES).
- **docs(revenuecat,adr)**: Criação do `ADR 0017` e atualização do guia oficial `revenuecat_production_publishing_guide.md` com a tabela PPP e instruções de publicação.

### Fixed
- **fix(subscription,test)**: Expansão da cobertura de testes automatizados com 6 novos testes unitários para resolução de entitlement, fallback legado e mapeamento de produtos no `SubscriptionStatusModelTest` e `SubscriptionRemoteDataSourceTest` (92 testes verdes com 100% de sucesso).
- **chore(release)**: Bump e consolidação de versão para `v0.9.32+58`.

## [0.9.31] - 2026-09-26

### Added
- **feat(liturgy,ui)**: Implementação do seletor sagrado de data da oração litúrgica (`PrayerDatePickerSheet`):
  - Interface modal em folha inferior com janela deslizante de 7 dias (hoje, 3 dias anteriores e 3 dias posteriores).
  - Identificação visual imediata do dia corrente ("Hoje") e destaque áureo contemplativo para o dia selecionado.
  - Ação de atalho e retorno instantâneo ao dia de hoje quando uma data pretérita ou futura estiver selecionada.
  - Atualização reativa e sincronizada de todo o aplicativo: leituras do dia, orações, meditações e ícone sagrado litúrgico.
- **feat(liturgy,navigation)**: Selo litúrgico interativo e navegação rápida por chevrons no `SacredIconAltarpieceCard`:
  - Selo circular com data, mês e dia da semana transformado em ponto focal interativo para invocação do seletor.
  - Chevrons laterais discretos para avanço e recuo diário imediato com feedback háptico suave.
- **feat(l10n,i18n)**: Internacionalização completa em **18 idiomas** para todas as novas chaves litúrgicas e acessibilidade:
  - Catálogos ARB atualizados em Português (`pt`), Inglês (`en`), Espanhol (`es`), Latim (`la`), Alemão (`de`), Francês (`fr`), Italiano (`it`), Holandês (`nl`), Polonês (`pl`), Ucraniano (`uk`), Árabe (`ar`), Hindi (`hi`), Japonês (`ja`), Coreano (`ko`), Chinês (`zh`), Suaíli (`sw`), Tagalog (`tl`) e Vietnamita (`vi`).
  - Formatação nativa de abreviações de meses e dias da semana via `intl DateFormat` com fallbacks canônicos litúrgicos para todos os sistemas de escrita.

### Fixed
- **fix(worker,storage)**: Detecção e reaproveitamento de ícones sagrados existentes no Cloud Storage (GCS) entre múltiplos idiomas e passagem explícita do idioma ativo no painel diário (`daily_liturgy_worker.dart` e `daily_dashboard_page.dart`).
- **chore(release)**: Bump e consolidação de versão para `v0.9.31+57`.

## [0.9.30] - 2026-09-26

### Added
- **feat(infra,gcp)**: Migração e homologação completa do worker de Liturgia Diária e gerador de ícones sacros para **GCP Cloud Run Jobs** (`daily-liturgy-worker`) e **Cloud Scheduler** (`daily-liturgy-trigger`):
  - Execução autônoma programada diariamente às 00:00 BRT (03:00 UTC) com autenticação nativa via Service Account (`roles/run.invoker`).
  - Sincronização e injeção de segredos via **Google Cloud Secret Manager** (`pwe-gemini-api-key`).
  - Custo operacional R$ 0,00 sustentado pelo Always Free Tier do GCP e cache de idempotência no Cloud Firestore.
- **feat(ai,billing)**: Homologação e transição da chave Gemini API para o **Plano 1 (Paid Tier 1 / Pay-As-You-Go)**:
  - Eliminação de bloqueios 429 de taxa e garantia estrita de privacidade (não-utilização de orações/textos para treinamento do Google).
  - Teto de gastos e orçamento mensal seguro ("pwE - Alerta Custo Zero") de R$ 5,00/mês com alertas em 20%, 50%, 90% e 100%.
  - Restrição de segurança da chave delimitada estritamente à `generativelanguage.googleapis.com`.

### Fixed
- **fix(theology,l10n)**: Sincronização dos catálogos de localização gerados em Dart (`lib/l10n/generated/`) a partir dos arquivos ARB sanitizados, assegurando o isolamento de terminologia tecnológica e a consagração do termo canônico sagrado "Meus Cadernos Espirituais".
- **chore(release)**: Bump e consolidação de versão para `v0.9.30+56`.

## [0.9.29] - 2026-09-25

### Fixed
- **fix(arch,clean)**: Resolução de violação de Clean Architecture na feature `lectio_divina`:
  - Criação da interface abstrata `IDataNormalizer` em `domain/services/` e do adaptador `DataNormalizerAdapter` em `data/utils/`.
  - Migração de `IVectorSearchDataSource` para `domain/datasources/` e injeção por contrato de domínio em `GenerateMeditationUseCase`, `GeneratePrayerUseCase`, `NormalizeOcrTextUseCase` e `LectioMigrationService`.
  - Registro de `IDataNormalizer` no contêiner modular de injeção de dependências (`lectio_divina_injection_container.dart`).
- **fix(routes,imports)**: Eliminação de 20 imports relativos em `app_router.dart`, convertendo-os integralmente para imports absolutos `package:pwe/...`.
- **fix(theology,isolation)**: Purificação e blindagem terminológica e de isolamento tecnológico em todos os 18 catálogos ARB (`pt`, `en`, `es`, `la`, `de`, `fr`, `it`, `ar`, etc.):
  - Substituição da denominação profana "Meus Diários" pelo termo canônico sagrado "Meus Cadernos Espirituais" (`myJournals`) e ajuste semântico em `SacredJournalCard`.
  - Expurgada a menção a termos seculares de IA e tecnologia ("Inteligência Artificial", "IA", "Gemini") em textos visíveis ao fiel (`freePassageDialogBody`, `missionFriendsQuotaBody`, `monthlyQuotaReached`, `benefit1Desc`, `aiDisclaimerNotice`, `localIntelligenceTitle`).
- **fix(ai,llm)**: Calibração de temperatura para `temperature: 0.3` no `GenerationConfig` do `GenerativeModel` (`llm_remote_datasource.dart`), prevenindo alucinações exegéticas e garantindo máxima fidelidade ao Magistério.
- **fix(security,android)**: Blindagem contra tráfego HTTP em claro no Android através da criação do `network_security_config.xml` com `cleartextTrafficPermitted="false"` e referência explícita no `AndroidManifest.xml`.
- **fix(devops,release)**: Inclusão obrigatória de ofuscação de código e divisão de símbolos de depuração (`--obfuscate --split-debug-info=build/app/outputs/symbols`) nos builds de `.aab` e `.apk` no workflow `release-on-main.yml`.
- **chore(release)**: Bump e consolidação de versão para `v0.9.29+55`.

## [0.9.28] - 2026-09-24

### Fixed
- **fix(ux,layout)**: Correção de truncamentos de texto na interface:
  - `SacredStepperHeader`: Remoção de transparência de fundo (`alpha: 1.0`), inclusão de `FittedBox` nos passos para evitar quebras em telas estreitas, e substituição de ícone secular mecânico por ícone de iluminação espiritual (`Icons.light_mode_outlined`).
  - `SpiritualFruitCarousel`: Inclusão de `FittedBox` nos títulos de frutos espirituais ("Conversão & Perdão").
  - `SacredIconAltarpieceCard`: Suporte a `maxLines: 3` e escalonamento dinâmico de fonte para títulos litúrgicos extensos (ex: "Quinta-feira da 25ª Semana do Tempo Comum").
  - `SessionDetailPage`: Ativação de `useMarkdown: true` no bloco de Lectio para renderização tipográfica adequada de títulos de leituras litúrgicas (`###`).
- **fix(ux,a11y)**:
  - `ImmersiveReadingPage`: Opacidade 100% no `SliverAppBar` para evitar sobreposição/vazamento de texto ao rolar a página; ocultação automática do Floating Action Button (`socratic_fab`) quando o teclado virtual estiver ativo (`MediaQuery.viewInsetsOf(context).bottom > 0`); remoção dos seletores de fonte/tamanho de texto em inglês no `QuillSimpleToolbarConfig` (`showFontFamily: false`, `showFontSize: false`).
  - `GlobalDownloadTracker`: Reposicionamento da pílula de download offline para a parte inferior central (`bottom: 16`) no modo retrato com `SafeArea`, impedindo sobreposição e colisão com as AppBars do aplicativo.
  - `GotasBottomSheet`: Inclusão de `SafeArea` no modo tela cheia para evitar colisão com o notch e a barra de status.
- **fix(theology,isolation)**: Sanitização de termos técnicos e vazamentos de vocabulário secular/IA nos 4 catálogos de internacionalização (`pt`, `en`, `es`, `la`):
  - `prayerPersonalNotice`: Remoção de "nenhuma IA pode fazer isso por você", restabelecendo o convite filial ao diálogo íntimo com Deus a partir do coração.
  - `contemplatioResolutionPrompt`: Substituição de "não de um algoritmo" pela ênfase na "ação viva da graça em seu íntimo".
  - `makeSpiritualOffering`: Substituição de "Oferta Espiritual" por "Contribuição Fraterna" para donativos de benfeitores.
  - `privacyEdgeLlm`, `downloadingAiTitle`, `aiNotInstalledTitle`, `deviceRamRequirement`, `ageHint`, `maturityLevelDesc`, `premiumAudioHint`: Eliminação de siglas e termos técnicos ("Edge LLM", "IA", "Gemma-4-E2B-it", "Gemini") em favor de linguagem pastoral e centrada no recolhimento espiritual.
- **chore(release)**: Bump e consolidação de versão para `v0.9.28+54`.

## [0.9.27] - 2026-09-24

### Fixed
- **fix(auth,crashlytics)**: Correção crítica do Google Sign-In adicionando `serverClientId: DefaultFirebaseOptions.webClientId` no `GoogleSignIn` (`injection_container.dart`) para garantir a emissão de `idToken` para o Firebase Auth no Android e Web; telemetria ativa via `FirebaseCrashlytics.recordError` com captura de stack trace em erros de autenticação (`auth_remote_datasource.dart`).
- **fix(oauth,certs)**: Cadastro e vinculação dos certificados digitais SHA-256 e SHA-1 da upload keystore oficial e debug keystore no Firebase Console; sincronização do `oauth_client` no mock de setup do CI (`mock_google-services.json`) e injeção canônica via Google Cloud Secret Manager no `cloudbuild.yaml`.
- **fix(edge)**: Prevenção de banner espúrio de sucesso no startup e preservação de preferências de leitura offline do usuário (`fix_edge_model_flow`).
- **fix(build)**: Elevação do `compileSdk` para subprojetos de bibliotecas em `build.gradle.kts` para compatibilidade com dependências atualizadas.
- **fix(subscription)**: Remoção de imports não utilizados e alinhamento de props de eventos com parâmetro de idioma nos testes.

### Added
- **feat(l10n)**: Suporte completo à localização nativa do aplicativo (`CFBundleDisplayName` no iOS e `app_name` no Android) e em runtime para Português, Inglês, Espanhol e Latim.
- **feat(subscription)**: Preços multilíngues e mapeamento dinâmico de planos pelo RevenueCat para paridade de monetização global.
- **docs**: Reestruturação documental dos diretórios `docs/`, consolidação de inventários de produto, resolução de mais de 80 links e expurgo de relatórios sensíveis.
- **chore(release)**: Bump e consolidação de versão para `v0.9.27+53`.

## [0.9.26] - 2026-09-23

### Fixed
- **fix(l10n,icon)**: Explicação mística do Ícone Sagrado e os 4 tópicos hermenêuticos traduzidos e parametrizados nos 7 idiomas ativos (`pt`, `en`, `es`, `la`, `de`, `fr`, `it`), eliminando vazamentos de títulos e subtítulos em português no diálogo de contemplação (`SacredIconContemplationDialog` e `CanonicalIconCatalog`).
- **fix(exegesis,bloc)**: Rastreamento do idioma ativo no `ExegesisBloc`, descarte de textos em português pré-computados quando o app estiver em idioma estrangeiro (`de`, `en`, etc.), e limpeza do estado com `ResetExegesisEvent` ao alternar idioma.
- **fix(drops,l10n)**: Suporte completo aos 7 eixos das Gotas de Sabedoria em Alemão (`de`), Francês (`fr`) e Italiano (`it`) em `GotaContextoFallback`, com propagação do idioma ativo no `GotasBottomSheet` e `ImmersiveReadingPage`.
- **fix(legal,extensions)**: Fallback gracioso dos termos legais e política de privacidade para inglês (`_englishLegal`) para usuários de `de`, `fr`, `it`, e tradução de descrições dos frutos espirituais em `l10n_extensions.dart`.
- **fix(edge,gemma)**: Otimização de performance e estabilidade do motor Edge LLM local (Gemma):
  - Warm-up em segundo plano (`initialize()`) assíncrono disparado no boot da aplicação, eliminando a latência de cold load de ~26s na primeira oração.
  - Janela bíblica em `PromptTemplateFactory.buildEdgePrompt` truncada/priorizada no Evangelho ou nos primeiros 800 caracteres para reduzir tempo de prefill (<1s).
  - Interrupção precoce de decodificação no plugin nativo Android (`GemmaInferencePlugin.kt`) limitada a 1 parágrafo conciso (~180 tokens), prevenindo loops infinitos e timeout de 65s em GPU/CPU móvel.
  - Correção de tipagem na verificação de pontuação de parada em Kotlin (`chunk.toString().any`).
- **fix(firestore,exegesis)**: Priorização imediata dos dados pré-computados da liturgia do dia:
  - Preservação dos campos `precomputedExegese`, `precomputedDrops`, `precomputedMeditatioText` e `precomputedOratioPrompts` no `LectioSessionState` com resolução por nível de maturidade (`resolvedMeditatioPrompt`).
  - `ExegesisBloc` agora emite dados pré-computados instantaneamente em 0ms **sem disparar chamadas à LLM**, acionando a IA apenas como fallback resiliente.
  - Propagação dos dados pelas páginas `DailyDashboardPage`, `PreparationPage` e `ImmersiveReadingPage`.
- **fix(drops,hermeneutics)**: Sanitização das Gotas de Sabedoria da Tradição:
  - Implementação de `_sanitizePassageReference` em `GotaContextoFallback` para detectar passagens longas e cabeçalhos litúrgicos brutos, extraindo a referência canônica (ex: `Pr 30, 5-9`, `Jo 1, 1-14`) ou adotando o fallback `"Liturgia da Palavra"` / `"Sagradas Escrituras"`.
  - Propagação correta de `passageReference` em `ILlmRepository`, `LlmRepositoryImpl` e `GenerateContextDropsUseCase`, eliminando o vazamento de 2.000+ caracteres de texto bíblico bruto dentro dos cards hermenêuticos.

### Added
- **test(qa)**: Suíte de testes automatizados para paridade de tradução nos 7 idiomas ativos (`canonical_icon_catalog_test.dart`, `gota_contexto_fallback_test.dart`, `exegesis_bloc_test.dart`, `sacred_icon_contemplation_dialog_test.dart` e `arb_integrity_test.dart`).
- **chore(release)**: Bump e consolidação de versão para `v0.9.26+52`.

## [0.9.25] - 2026-09-23

### Added
- **feat(arch,bloc)**: Decomposição do God BLoC `LectioBloc` em 6 sub-blocs independentes e coesos:
  - `DailyLiturgyBloc`: Responsável pelo ciclo de vida, caching e seleção da liturgia católica do dia.
  - `SacredIconBloc`: Gerenciamento do ícone sagrado do dia e metadados teológicos.
  - `PassageDiscoveryBloc`: Busca semântica e exploração de passagens bíblicas.
  - `ExegesisBloc`: Exegese central e 7 Gotas de Contexto hermenêutico sob demanda.
  - `SpiritualGuidanceBloc`: Provocação socrática, geração de orações e direcionamento da contemplatio.
  - `LectioSessionBloc`: Orquestração sequencial das 4 etapas (`Lectio`, `Meditatio`, `Oratio`, `Contemplatio`), notas de editor rico e persistência no Caderno Espiritual.
  - Fachada retrocompatível mantida temporariamente em `LectioBloc` para estabilidade.
- **feat(data,parsers)**: Modularização e desacoplamento do motor de parsing de `DailyLiturgyModel`:
  - `LiturgySanitizer`: Normalização de texto bíblico, remoção de aclamações litúrgicas ("Palavra do Senhor", "Glória a vós"), diálogos e rubricas.
  - `LiturgyTranslator`: Tradução canônica e normalização de cores litúrgicas e enums de tipos de leitura.
  - `CnbbLiturgyParser`: Parser dedicado para payload JSON da API oficial da CNBB.
  - `HtmlLiturgyParser`: Parser de scraping resiliente do DOM HTML para fallback Canção Nova.
- **feat(preferences,usecases)**: Desacoplamento do `ReadingPreferencesBloc` através de UseCases dedicados (`GetReadingPreferencesUseCase`, `SaveReadingPreferencesUseCase`), eliminando dependência direta de infraestrutura na camada de apresentação.
- **feat(monetization,models)**: Criação dos modelos de dados `SubscriptionPlanModel` e `SubscriptionStatusModel` com suporte a igualdade polimórfica (`operator ==` e `hashCode`) para interoperabilidade transparente com as entidades de domínio.
- **docs(architecture)**: Novo guia mestre `docs/architecture/data_modeling_and_bloc_decomposition.md` e novo registro arquitetural ADR 0015 (`docs/adr/0015-decomposicao-god-bloc-e-higiene-arquitetura-dados.md`).

### Changed
- **refactor(models)**: Redução drástica de `DailyLiturgyModel` de 1.142 para 207 linhas, blindando contratos de serialização JSON.
- **refactor(ui)**: Migração de 5 telas e componentes (`DailyDashboardPage`, `ImmersiveReadingPage`, `LectioPage`, `PreparationPage`, `SacredIconContemplationDialog`, `SacredStepperHeader`, `VerticalBookRibbonStepper`) para o consumo direto dos novos sub-blocs.
- **test(qa)**: Ampliação da suíte automatizada para 931 testes unitários, blocs e testes de widgets com 100% de taxa de aprovação.
- **chore(release)**: Bump de versão para `v0.9.25+51`.

### Security
- **sec(cache)**: Implementação de política de retenção de cache com TTL de 7 dias e expurgo automático (`_evictExpiredEntries()`) em `DailyLiturgyLocalDataSource` (Hive).

### Removed
- **refactor(clean)**: Remoção definitiva de UseCases legados e descontinuados (`GenerateMeditationUseCase`, `GeneratePrayerUseCase`).

## [0.9.24] - 2026-09-23

### Added
- **feat(icons)**: Inclusão do Ícone Sagrado de São Pio de Pietrelcina (Padre Pio) para a Liturgia de 23/09/2026:
  - Criação artística em têmpera a ovo e folha de ouro inspirada na tradição da Oficina de Ícones Veni Creator (Comunidade Shalom).
  - Assets registrados em `assets/images/icons/icon_2026_09_23.jpg` e `icon_2026_09_23_optimized.jpg` (88.9 KB).
  - Sincronização do metadado e imagem Data URL Base64 em todos os 7 registros canônicos no Cloud Firestore (`daily_liturgies/2026-09-23_*`).

### Changed
- **fix(ci,cloudbuild)**: Atualização da imagem Docker no `cloudbuild.yaml` de `ghcr.io/cirruslabs/flutter:3.38.4` para `ghcr.io/cirruslabs/flutter:3.47.5`, harmonizando o runner na GCP com a versão oficial do Flutter SDK 3.47.5 e restrição do Dart `^3.13.4`.
- **chore(release)**: Bump de versão para `v0.9.24+50`.

## [0.9.23] - 2026-09-23

### Added
- **feat(i18n)**: Suporte completo e expandido a 18 idiomas nativos com 17 novas chaves de internacionalização:
  - Localização canônica e litúrgica adicionada a todos os 18 catálogos ARB: Português (`pt`), Inglês (`en`), Espanhol (`es`), Latim (`la`), Árabe (`ar`), Alemão (`de`), Francês (`fr`), Hindi (`hi`), Italiano (`it`), Japonês (`ja`), Coreano (`ko`), Holandês (`nl`), Polonês (`pl`), Suahili (`sw`), Filipino/Tagalog (`tl`), Ucraniano (`uk`), Vietnamita (`vi`) e Chinês (`zh`).
  - Eliminação de strings literais/hardcoded em toda a camada de apresentação (`ProfilePage`, `ContextDropFab`, `PrivacyScreenWrapper`, `SessionDetailPage`, `SacredJournalCard`, `SacredIconAltarpieceCard` e `ModelManagementPage`).
- **feat(ui,dry)**: Novo widget compartilhado `LanguageSelectionDialog` unificando a seleção e persistência de idioma litúrgico entre a gaveta lateral (`DailyDashboardDrawer`) e o painel de leitura (`ReadingSettingsSheet`), eliminando código redundante.

### Changed
- **refactor(ui,sacred)**: Harmonização e refinamento estético do Design System Sacro:
  - Unificação tipográfica da marca para a fonte canônica `GoogleFonts.lora` na `SplashPage`.
  - Migração de instâncias legadas de `ElevatedButton` para `FilledButton` em `BenefactorPage`, `ModelManagementPage` e `SessionHistoryPage`.
  - Adoção de tokens sacros (`context.sacred.goldAccent`, `goldLight`) no cartão de ofensivas espirituais (`ProfilePage`) e no cartão de benfeitores (`BenefactorCard`).
  - Unificação de seções jurídicas em `LegalTermsPage` e conversão de imports relativos para caminhos absolutos (`package:pwe/...`).

## [0.9.22] - 2026-09-22

### Changed
- **chore(flutter,deps)**: Atualização completa do ecossistema para Flutter 3.47.5 e Dart 3.13.4 no canal stable:
  - Promoção de pacotes compatíveis com o Flutter 3.47: `go_router ^18.0.1`, `wakelock_plus ^1.8.0`, `flutter_quill ^11.6.0`, `intl ^0.20.3`, `google_mlkit_text_recognition ^0.17.1` e `background_downloader ^9.6.2`.
  - Modernização do toolchain nativo Android para os padrões oficiais do Flutter 3.47: Gradle Wrapper 9.3.1, Android Gradle Plugin 9.1.0, Kotlin Gradle Plugin 2.4.0, Google Services 4.4.2, Crashlytics 3.0.3 e Perf Plugin 2.0.2.
  - Correção de retenção de locks de arquivos no Windows com `kotlin.incremental=false` e ampliação de heap para `-Xmx4096m`.
  - Resolução da nova asserção de `ListTile` no Flutter 3.47 encapsulando com `Material(color: Colors.transparent)` em `GotaExpansionTile` e `ProfilePage`.

### Added
- **feat(ui,landscape)**: Layout adaptativo para orientação horizontal (landscape) e telas amplas:
  - Novo `LectioLandscapeLayout` e stepper vertical em formato de fita de livro litúrgico (`VerticalBookRibbonStepper`) com microinterações táteis (*haptic feedback*).

## [0.9.20] - 2026-09-22

### Fixed
- **fix(ui,theme)**: Harmonização visual da borda e fundo dos cartões de ícones sagrados com a cor do tempo litúrgico.

### Changed
- **ci(gcp)**: Otimização da infraestrutura de CI/CD para execução escalável via Cloud Build no Google Cloud Platform.

## [0.9.19] - 2026-09-22

### Fixed
- **fix(model_download)**: Correção completa do fluxo de download do modelo on-device (Gemma) no Android:
  - `AndroidManifest.xml`: inclusão da permissão `WAKE_LOCK` e declaração mandatória do serviço `SystemForegroundService` com `foregroundServiceType="dataSync"` para compatibilidade estrita com Android 14+ (API 34), evitando que o WorkManager suspenda workers com `onStopJob`.
  - `main.dart` & `model_download_service_io.dart`: inicialização formal de `FileDownloader().start(autoCleanDatabase: true)` no bootstrap, eliminando exceções de `Flutter method not implemented` e limpando tarefas órfãs acumuladas.
  - `model_download_bloc.dart` & `model_download_service_io.dart`: proteção robusta contra concorrência e tarefas duplicadas com flags de guarda e cancelamento prévio de tarefas residuais de mesmo `taskId`.
  - `model_download_service_io.dart`: detecção antecipada do tamanho do arquivo via requisição `HEAD`, emissão consistente de progresso na UI e ativação imediata de fallback resiliente via Streaming HTTP (Dio) com Range Request caso o worker nativo seja cancelado inesperadamente pelo SO.

## [0.9.18] - 2026-09-22

### Fixed
- **fix(telemetry)**: Resolução de perda de traces com smart sampling e instrumentação de stream no serviço Langfuse.

## [0.9.17] - 2026-09-22

### Added
- **feat(worker,cron)**: Suporte completo e nativo aos 7 idiomas canônicos no worker e automação de liturgia diária:
  - `.github/workflows/daily-liturgy-cron.yml`: inclusão de todos os 7 idiomas suportados (`pt`, `en`, `es`, `la`, `it`, `de`, `fr`) no agendamento noturno (23:30 / 00:05 BRT) e no trigger manual.
  - `Dockerfile.worker`: atualização do comando padrão `CMD` para execução contínua com os 7 idiomas.
  - `scripts/daily_liturgy_worker.dart`: localização poliglota da explicação teológica dos ícones sagrados (`sacredIconExplanation`) no modo de contingência/fallback para inglês, espanhol, latim, italiano, alemão e francês, fiel à Tradição da Paz e Oficina de Ícones Veni Creator.
  - `scripts/manual_liturgy_runner.dart`: ferramenta operacional de contingência com autenticação automática via Google Cloud ADC para sincronização manual do Firestore em caso de indisponibilidade de CI/CD.
  - `scripts/audit_firestore_docs.dart` & `scripts/audit_sacred_icons.dart`: ferramentas de auditoria e monitoramento da integridade de documentos e ícones sagrados na coleção `daily_liturgies`.

## [0.9.16] - 2026-09-22

### Fixed
- **fix(i18n,liturgy)**: Correção completa da alternância de idiomas e atualização dinâmica das leituras diárias e componentes de interface:
  - `DailyDashboardPage`: guarda `isAlreadyLoadedForToday` atualizada para verificar se o idioma da liturgia em memória corresponde ao idioma preferido ativo, recarregando a liturgia do dia quando houver divergência.
  - `LectioBloc`: resolução dinâmica do idioma do sistema via `PlatformDispatcher.instance.locale.languageCode` quando `languageCode` é nulo, com fallbacks multilíngues enriquecidos para alemão, francês e italiano.
  - `DailyDashboardDrawer`: seleção de idioma dispara recarregamento forçado da liturgia (`LoadDailyLiturgyEvent`), fecha simultaneamente modal e gaveta, e exibe dinamicamente o idioma selecionado no subtítulo.
  - `LiturgyThreePillarsSection`: suporte multilíngue para detecção das perícopes (Primeira Leitura, Salmo Responsorial e Evangelho) em alemão, francês, italiano, latim, espanhol e inglês, corrigindo cabeçalhos com `type == 'reading'`.
  - `LiturgicalDateFormatter` & `DailyLiturgy`: suporte canônico completo para meses, dias da semana, ciclos dominicais/feriais e inferência de graus litúrgicos (Solenidade, Festa, Memória) em alemão, francês e italiano.
  - `SacredReadingContent` & `SacredIconAltarpieceCard`: fórmulas litúrgicas oficiais dos Evangelistas e abreviações litúrgicas de calendário para todas as línguas ativas.
  - `scripts/daily_liturgy_worker.dart`: inclusão de alemão (`de`) e francês (`fr`) com versões bíblicas católicas oficiais (*Einheitsübersetzung* e *AELF / Bible de Jérusalem*).

## [0.9.15] - 2026-09-22

### Added
- **docs(architecture)**: Documentação arquitetural abrangente (referência de arquitetura limpa, engenharia de dados, catálogo e governança dos 12 agentes especialistas).

### Fixed
- **fix(widgets)**: Restauração da hierarquia de widgets de fallback bizantino com `CustomPaint` e monogramas sacros em `sacred_icon_card.dart`.
- **fix(core)**: Restauração da classe canônica desacoplada `MessageService` para exibição resiliente de SnackBars sacras.
- **fix(test)**: Alinhamento e padronização do `CancellationToken` em `llm_repository_impl_test.dart` e saneamento de imports e variáveis não utilizadas.

## [0.9.14] - 2026-09-22

### Changed
- **refactor(core,cleanup)**: Saneamento e expurgo profundo de Dead Code em todo o projeto (-3.000+ linhas de código obsoleto):
  - Remoção de 17 arquivos de produção mortos e descontinuados (`byzantine_altarpiece_frame.dart`, `fallback_prompt_catalog.dart`, `liturgical_seasonal_themes.dart`, `shimmer_loading.dart`, `adaptive_two_pane_layout.dart`, `device_capability_service`, `memory_compression_service`, `hero_greeting_card.dart`, `liturgy_readings_card.dart`, etc.).
  - Remoção da cadeia zumbi legada da OpenAI (`GetGuidedMeditationPromptUseCase` e métodos REST associados em Repositories e DataSources).
  - Remoção da classe não utilizada `MessageService` em `message_service.dart`, preservando `rootScaffoldMessengerKey` e `SnackBarDismissObserver`.
  - Unificação de tokens de cancelamento eliminando o redundante `LlmCancellationToken` em favor de `CancellationToken`.
  - Expurgados 6 arquivos de testes unitários órfãos correspondentes aos componentes descontinuados.

### Fixed
- **fix(security)**: Correção de bug no `LlmRateLimiter.reset()` onde a lista `_requestTimestamps` não era limpa devido a chamada tear-off sem parênteses (`.clear` -> `.clear()`).
- **refactor(widgets)**: Eliminação de duplicação do painter bizantino privado em `sacred_icon_card.dart`, reutilizando a classe pública canônica `ByzantineCrossPainter`.
- **test(naming)**: Correção de nomenclatura de `cnbb_liturgy_api_test.dart` para `cnbb_slug_util_test.dart`.

## [0.9.13] - 2026-09-22

### Added
- **feat(web)**: Suporte completo e nativo à plataforma **Flutter Web** e formato **Progressive Web App (PWA)**:
  - Scaffolding web completo (`web/index.html`, `web/manifest.json`) com estética sacra, metadados católicos e tema imersivo.
  - Hospedagem e distribuição configuradas via **Firebase Hosting** (`firebase.json`) com suporte a Single Page Application (SPA rewrites para o `GoRouter`) e headers de segurança/cache.
  - Registro de credenciais web no Firebase (`firebase_options.dart`) com guards reativos de plataforma.
- **feat(platform,architecture)**: Desacoplamento multiplataforma de serviços para isolamento de `dart:io` e APIs nativas:
  - `DeviceCapabilityService` e `ModelDownloadService` desacoplados através de exportações condicionais (`_io.dart` e `_web.dart`).
  - Graceful degradation para OCR (`OcrServiceImpl`) e embeddings locais (`OnDeviceEmbeddingService`), acionando modo Cloud e APIs Gemini automaticamente no navegador.
  - Blindagem de inicialização de serviços nativos (`FirebaseCrashlytics`, orientações de tela, `TtsService`, `PrivacyScreenWrapper`) com guards `kIsWeb`.
  - Fallback resiliente para gerenciamento de assinaturas e benfeitores na Web (`SubscriptionRemoteDataSourceImpl`).
- **docs(release)**: Instituição do Protocolo Oficial de Release e Governança SemVer:
  - Criação do catálogo canônico em `docs/releases/CHANGELOG.md` e do checklist operacional em `docs/releases/release-checklist.md` cobrindo os 4 pilares mandatórios (bump SemVer, checksum TFLite, notas no changelog e testes sem dependência de hardware externo).
  - Quality gates nos workflows de CI/CD (`release.yml` e `release-on-main.yml`) bloqueando publicações sem notas correspondentes no changelog.
  - Auditoria e saneamento integral de links Markdown em toda a árvore de documentação (`docs/` e `README.md`).

## [0.9.12] - 2026-09-22

### Added
- **feat(llm,performance)**: Suporte a cancelamento ativo de inferência (`CancellationToken`) síncrono e reativo com interrupção imediata de streams HTTP da nuvem (Gemini) e comando nativo `abort` no LiteRT-LM (Gemma) para descarregar CPU/GPU no Android.
- **feat(llm,presentation)**: Streaming progressivo de respostas socráticas e reflexões no `LectioBloc` (`CancelLlmGenerationEvent`), com cancelamento preemptivo automático ao avançar etapas ou fechar telas.
- **feat(llm,edge)**: Janela deslizante contextual atômica (`EdgePromptWindow`), preservando integralmente o System Instruction do Magistério da Igreja e a Passagem Bíblica sem corte de tags ou estouro de memória (OOM).

### Changed
- **refactor(error)**: Introdução de `OperationCancelledException` e `CancellationFailure` integrados ao padrão funcional `Either<Failure, Type>` da Clean Architecture.

## [0.9.11] - 2026-09-22

### Added
- **feat(ai,performance)**: Aceleração por hardware GPU-First resiliente para o Gemma (LiteRT-LM) no Android com fallback automático e gracioso para CPU em caso de falha de driver OpenCL/Vulkan.
- **perf(streaming)**: Desacoplamento assíncrono do pipeline de streaming no `EventChannel` com token batching a 40ms (~25 FPS), eliminando contenção na UI Thread.
- **feat(platform)**: Exposição de telemetria de hardware (`activeBackend`) e alinhamento da arquitetura iOS com Metal Performance Shaders sob salvaguarda dos limites do Jetsam.
- **feat(model-delivery)**: Otimização da arquitetura de entrega de modelos de IA com suporte nativo a downloads em background (`background_downloader`) via `NSURLSession` no iOS e `WorkManager` / `ForegroundService` no Android.
- **feat(store-compliance)**: Blindagem de assets no `pubspec.yaml` e `.gitignore` eliminando risco de inclusão acidental de modelos massivos (~2.5GB) no bundle das lojas (garantindo conformidade estrita com limites de 150MB da Google Play Store e diretrizes da Apple App Store).
- **test(safety)**: Teste automatizado de CI/CD em `asset_bundle_safety_test.dart` para prevenção contra inclusão de arquivos pesados (>30MB) ou modelos generativos locais na pasta `assets/`.
- **docs(compliance)**: Guia oficial de conformidade de IA e Privacidade para submissão nas lojas em `docs/compliance/app_store_play_store_ai_privacy.md`.

### Changed
- **refactor(service)**: `ModelDownloadServiceImpl` desacoplado com execução nativa em segundo plano e fallback resiliente por streaming HTTP com Range Request.

## [0.9.1] - 2026-09-13

### Added
- **feat(ai,secops)**: Resiliência absoluta do LLM com Rate Limiter (sliding-window) e compêndio patrístico offline para fallback automático sem rede.
- **feat(security)**: Endurecimento de segurança (DevSecOps) com sanitização de inputs (anti-prompt-injection), integração do Gitleaks no CI/CD e SHA Pinning em todas as GitHub Actions.
- **docs**: Inclusão do Documento de Registros de Decisão Arquitetural (ADRs) refletindo as implementações técnicas de resiliência, segurança e migração da liturgia.

### Changed
- **refactor(liturgy)**: Migração definitiva da fonte primária da liturgia diária para a API REST Oficial da CNBB, substituindo o web scraping por parsing estruturado com failover.
- **refactor(security)**: Tratamento gracioso a falhas de bloco de *padding* no `EncryptionService`, garantindo integridade e estabilidade na recuperação das anotações do Diário Orante.
- **ci(coverage)**: Elevação da meta obrigatória de cobertura de testes automatizados de 65% para 80%, atingindo a marca de 80.31% reais.

### Fixed
- **fix(liturgy)**: Resolução de duplicidade de leituras na janela deslizante causada pela defasagem da API antiga e fixação do cron job do Liturgy Worker.
- **fix(ux)**: Correções pontuais no fluxo de inicialização (Splash) e criptografia de intenções do usuário.
- **fix(deps)**: Atualizações semanais de segurança via Dependabot para Ações do GitHub (auth, upload/download-artifact, github-script).

## [0.9.0] - 2026-09-09

### Added
- **feat(ui)**: **Novo Dashboard Litúrgico & Estética Sacra da Comunidade Shalom (`DailyDashboardPage`)**:
  - Nova tela inicial imersiva com paleta nobre (pergaminho, ouro velho e sépia) e tipografia clássica *Lora*.
  - **Acolhida Pedagógica (`WelcomeGuideDialog`):** Diálogo com 4 etapas explicando a pedagogia da Lectio Divina no primeiro acesso e botão permanente de ajuda litúrgica (`help_outline`) na barra superior.
  - **Card Devocional de "Check-in do Coração" (`LiturgicalDialogueCard`):** Convite à introspecção antes da oração, direcionando para reflexão de sentimentos e oração livre.
  - **Banner de Degustação:** Apresentação acolhedora do período de degustação fraterna de 7 dias para novos orantes.
- **feat(typography)**: **Orquestração Litúrgica Viva & Letra Capitular Iluminada (`SacredDropCapText` & `SacredReadingContent`)**:
  - **Drop Cap Iluminado:** Letra capitular nobre em *Cinzel* dourado no início de cada leitura bíblica com recuo harmônico de duas linhas.
  - **Salmos Responsoriais:** Desduplicação inteligente do refrão/antífona (`— R.`), exibido em card dourado destacado, e estrofes líricas com respiro contemplativo (`~ ✠ ~`).
  - **Evangelho:** Inclusão dos diálogos oficiais de aclamação e proclamação (*"O Senhor esteja convosco..."* / *"Palavra da Salvação..."*).
  - **Liturgia Completa:** Parser automático de seções delimitadas por `---`, aplicando estilo litúrgico específico para cada leitura.
- **feat(navigation)**: **Stepper Litúrgico Superior (`SacredStepperHeader`)**:
  - Cabeçalho de degraus orantes anexado ao topo da `ImmersiveReadingPage`, indicando visualmente o degrau atual (*Lectio, Meditatio, Oratio, Contemplatio*) com navegação animada por rolagem suave ao toque.
  - Divisórias litúrgicas entre degraus ornamentadas com estrelas douradas (`✦ DEGRAU X · TÍTULO ✦`).
- **feat(history)**: **Busca Unificada & Filtros Emocionais no Histórico (`SessionHistoryPage`)**:
  - Campo de busca instantânea filtrando passagens, referências e anotações pessoais.
  - Filtro horizontal por chips de sentimentos/emoções com ícones devocionais e contorno áureo.
- **feat(i18n)**: **Internacionalização Integral para 4 Idiomas Litúrgicos**:
  - Suporte completo a **Português, Inglês, Espanhol e Latim** em arquivos `app_pt.arb`, `app_en.arb`, `app_es.arb` e `app_la.arb`.
  - Extensões de tradução e formatação tipográfica em `l10n_extensions.dart` e desoneração de termos legais em `legal_texts.dart`.
- **feat(auth,legal)**: **Conformidade com Diretrizes Apple, Termos Legais & LGPD**:
  - Implementação de *Sign in with Apple* para conformidade estrita com a App Store.
  - Telas dedicadas de Termos de Uso e Política de Privacidade (`LegalTermsPage`).
  - Criptografia em repouso de notas íntimas e diários com AES-GCM e proteção biométrica.
- **feat(infrastructure)**: **Containerização e Automação de Deploy na Google Cloud Platform**:
  - Criação de `Dockerfile.worker` para containerizar o worker Dart de liturgia diária.
  - Scripts de deploy automatizado para Cloud Run Job na GCP (`scripts/deploy_liturgy_gcp.ps1` e `.sh`).
  - Guias operacionais e de migração em `docs/infrastructure/`.
- **perf(ci)**: **Otimização de Workflows de CI/CD**:
  - Eliminação de dependência do `bundletool`, acelerando pipelines e garantindo integridade de assinaturas digitais.
  - Simplificação dos fluxos `ci.yml`, `release.yml` e `release-on-main.yml` sem concorrência e desperdício de runners.
- **docs(adr)**: Registro da Decisão Arquitetural **ADR 0012** (`docs/adr/0012-redesenho-sacro-dashboard-shalom-e-orquestracao-liturgica.md`).

### Fixed
- **fix(profile)**: Correção de erro no `DropdownButton` de gênero na tela de perfil, normalizando os valores no modelo `UserProfile`.
- **fix(liturgy)**: Correção no parser do `daily_liturgy_worker.dart` para suportar novas estruturas de scraping da Canção Nova, restaurando leituras completas de 09/09/2026 no Firestore.
- **test(suite)**: Expansão da cobertura com testes dedicados para todos os novos componentes e telas, alcançando **448 testes automatizados aprovados (100% green)**.

## [1.3.0] - 2026-09-01

### Added
- **feat(free_passage)**: Modernização completa e paridade da funcionalidade de **Passagem Livre** (`LectioPage`):
  - **Interface Contemplativa em 3 Abas (`TabBar`):**
    - **Aba 0 (Digitar/Colar):** Campo de referência com busca assistida de passagens bíblicas via IA (`FetchPassageTextEvent`) e editor bíblico estilizado com tipografia *Lora*.
    - **Aba 1 (Inspiração por Intenção):** Grade com 6 intenções católicas (*Paz na Tribulação*, *Ação de Graças & Louvor*, *Discernimento & Direção*, *Cura Interior & Consolo*, *Perdão & Reconciliação*, *Esperança & Confiança*) disparando `SuggestPassageEvent(intention)` para sugestão contextual de passagens com justificativa em `SpiritualMarkdown`.
    - **Aba 2 (Escanear Bíblia):** Suporte flexível a captura via **Câmera** ou **Galeria de Fotos** do smartphone com processamento OCR (`ProcessOcrImageUseCase`), binarização adaptativa e normalização (`NormalizeOcrTextUseCase`).
  - **Paridade 100% com a Leitura Litúrgica:** Ao iniciar com uma passagem livre, o `LectioBloc` dispara sob demanda a exegese central, gotas de contexto, provocação socrática e direcionamento prático, conduzindo o fiel pelo mesmo fluxo imersivo de 4 etapas na `ImmersiveReadingPage`.
  - **Novo Evento de Domínio:** `StartFreePassageSessionEvent` para inicialização limpa e contextual de sessões de passagem livre com resolução de maturidade do fiel e telemetria `[LectioJourney]`.
- **docs(adr)**: Registro da Decisão Arquitetural **ADR 0011** (`docs/adr/0011-modernizacao-passagem-livre-e-ocr-guiado.md`).
- **fix(resilience)**: Resiliência absoluta nas Gotas de Contexto e hierarquia oficial do Google AI Studio:
  - Expurgado o modelo legado `gemini-1.5-flash` e alinhada a `_modelHierarchy` com os modelos ativos do projeto (`gemini-3.7-flash`, `gemini-3.6-flash`, `gemini-3.5-flash`, `gemini-2.5-flash`, `gemini-3.5-flash-lite`, `gemini-3.1-flash-lite`).
  - Criação de `GotaContextoFallback` com as 7 gotas hermenêuticas católicas (*Histórico, Social, Filológico, Patrístico, Magistério, Teológico, Ascético*) para contingência de rede ou parse.
  - Sanitização de JSON e extração resiliente de blocos markdown em `LlmRepositoryImpl.generateContextDrops`.
  - Remoção da trava `!state.isLoadingExegese` no botão `_AdvanceButton` da Meditatio, tornando o avanço para a Etapa 3 (Oratio) 100% acessível e visível.
- **test(suite)**: Expansão da suíte de testes com testes de widget da nova `LectioPage`, testes de BLoC e testes unitários de fallback hermenêutico, totalizando **300 testes passando**.

## [1.2.3] - 2026-09-01

### Added
- **feat(analytics)**: Observabilidade em dupla camada convergente:
  - Logs descritivos estruturados no console com tag `[LectioJourney]` cobrindo início, BFF, transição entre as 4 etapas, métricas de caracteres e conclusão.
  - Eventos tipados no Google Analytics 4 (`lectio_started`, `lectio_step_advanced`, `lectio_gota_opened`, `lectio_completed`) e sincronização automática de *breadcrumbs* e *custom keys* no Firebase Crashlytics.
  - Princípio de **Privacidade Zero-Knowledge** assegurando que nenhuma oração íntima ou reflexão pessoal trafegue para serviços analíticos de terceiros.
- **feat(ui)**: Experiência enriquecida na `ImmersiveReadingPage`:
  - **Etapa 3 (Oratio):** Card dourado de proposta de oração (`state.prayerPrompt`) inspirada nos Salmos e na Tradição católica.
  - **Etapa 4 (Contemplatio):** Card de direcionamento para a vida prática (`state.contemplatioGuidance`).
  - Layout responsivo anti-overflow em títulos e ícones com `Expanded`.
- **feat(journal)**: Preservação de formatação rica no diário espiritual:
  - Criação do utilitário `QuillMarkdownConverter` para serializar Deltas do Quill em Markdown padrão (negrito, itálico, sublinhado, cabeçalhos `#`, `##` e listas com marcadores `•`).
  - Renderização das anotações do fiel na `SessionDetailPage` via `SpiritualMarkdown` com `useMarkdown: true`.
- **feat(security)**: Criptografia simétrica AES-GCM (256-bit) via `EncryptionService` para proteção de anotações do diário e orações pessoais em repouso no Firestore e no cache local.
- **docs(adr)**: Registro da Decisão Arquitetural **ADR 0010** (`docs/adr/0010-observabilidade-dupla-camada-e-privacidade-zero-knowledge.md`).

### Changed
- **fix(cron)**: Agendamento do workflow noturno `daily-liturgy-cron.yml` atualizado para as **00:05 BRT** (`cron: '5 3 * * *'`) com disparo preventivo antecipado às **23:30 BRT** (`cron: '30 2 * * *'`).
- **fix(release)**: Atualização do App ID do Firebase App Distribution no GitHub Actions para o applicationId oficial de produção `br.com.jhhsolutions.praywithme.app`.
- **refactor(llm)**: Carrossel de resiliência e failover dinâmico entre `gemini-3.7-flash` e `gemini-3.6-flash` em caso de instabilidade externa (503).

## [1.1.0] - 2026-08-30

### Added
- **feat(bff)**: Arquitetura Distribuída com worker noturno em Dart puro (`scripts/daily_liturgy_worker.dart`) rodando em workflow agendado do GitHub Actions (`daily-liturgy-cron.yml`), pré-computando liturgia e meditações via Gemini com custo operacional de R$ 0,00.
- **feat(firestore)**: Atualização de `DailyLiturgyRemoteDataSource` para leitura de cache distribuído pré-gerado no Cloud Firestore (`daily_liturgies/{date}`) com fallback de contingência para scraping HTTP.
- **feat(subscription)**: Criação da feature modular `lib/features/subscription/` com Clean Architecture, injeção de dependência fechada (`subscription_injection_container.dart`) e BLoC de assinatura.
- **feat(ui)**: Tela sóbria e contemplativa de adesão fraterna `BenefactorPage` (`/benefactor`) com citação bíblica de 2 Coríntios 9, 7 e planos Benfeitor Mensal, Anual e Oferta Avulsa.
- **feat(ocr)**: Gatekeeper gracioso de OCR na `LectioPage` com limite de 3 correções gratuitas com IA por mês e diálogo acolhedor para apoiar a comunidade ou continuar a oração com texto local.
- **docs(adr)**: Registro da Decisão Arquitetural ADR 0009 (`docs/adr/0009-arquitetura-distribuida-bff-e-monetizacao.md`) e documentações técnicas em `docs/`.

### Changed
- **refactor(entity)**: `DailyLiturgy` e `LiturgyReading` enriquecidos com `fullLiturgyMeditatio`, `meditatio` (3 níveis) e `oratioPrompts`.
- **refactor(model)**: Implementação de `DailyLiturgyModel.fromFirestore` e `toJson`.

## [1.0.1] - 2026-08-30

### Added
- **feat(immersive)**: Reintegração do editor de texto rico (`flutter_quill`) nas seções de *Meditatio* e *Oratio* na `ImmersiveReadingPage`, com toolbar contextual minimalista e tipografia Lora contemplativa.
- **feat(socratic)**: Reintegração da Provocação Socrática (*Magnifica Humanitas*) na etapa de Meditatio da `ImmersiveReadingPage`, permitindo que o fiel acione a interrogação profunda da IA sobre suas notas via botão dedicado e FAB com feedback espiritual.
- **test(immersive)**: Criação de suíte de testes de widget cobrindo `ImmersiveReadingPage`, `QuillEditor` e respostas socráticas (`immersive_reading_page_test.dart`).

## [1.0.0] - 2026-08-29

### Added
- **feat(release)**: Preparação completa para lançamento de produção na Google Play Store.
- **feat(identity)**: Atualização do Application ID para `br.com.jhhsolutions.praywithme.app` e nome `pwE — Leitura Orante`.
- **feat(security)**: Configuração de assinatura de release com keystore de produção (`upload-keystore.jks`) e `key.properties`.
- **feat(legal)**: Criação de página web oficial de Política de Privacidade (`public/index.html`) e documentação (`PRIVACY_POLICY.md`) em conformidade com a LGPD e diretrizes da Google Play.
- **feat(bloc)**: Adição do evento `ResetSessionEvent` no `LectioBloc` para garantia de estado limpo entre sessões de oração.

### Changed
- **refactor(ux)**: Unificação dos fluxos de Lectio Divina (liturgia diária e passagem livre) na `ImmersiveReadingPage`, oferecendo uma experiência contemplativa única em scroll contínuo.
- **refactor(navigation)**: `DailyDashboardPage` navega diretamente para `/immersive` com leitura pré-carregada e disparo automático de exegese central.
- **refactor(router)**: Simplificação de rotas em `appRouter`, removendo rotas concorrentes (`/meditatio`, `/oratio`, `/contemplatio`, `/preparation`).

### Removed
- **cleanup**: Remoção de telas legadas e concorrentes descontinuadas (`preparation_page.dart`, `meditatio_page.dart`, `oratio_page.dart`, `contemplatio_page.dart`).

## [1.10.0-alpha.1] - 2026-04-20

### Added
- **feat(ux)**: Onboarding imersivo de seleção de IA (`AiSelectionPage`) com visual premium e animações de seleção.
- **feat(ux)**: `GlobalDownloadTracker` — rastro de progresso de download não-bloqueante visível em todo o aplicativo.
- **feat(ux)**: Suporte a redirecionamento via `appRouter` a partir de alertas de sistema.
- **feat(arch)**: Refatoração do `ModelDownloadBloc` para Singleton, garantindo que o download persista durante janelas de navegação.
- **feat(privacy)**: Persistência de preferência de processamento (Cloud vs Edge) em `SharedPreferences`.

### Fixed
- **fix(arch)**: Resolução do erro `Bad state: Cannot add new events after calling close` no lifecycle do Bloc.
- **fix(ui)**: Correção de roteamento `No GoRouter found in context` em overlays de sistema.

## [1.9.0-alpha.1] - 2026-04-18

### Added
- **feat(privacy)**: Integração nativa real do modelo Gemma 4 via MethodChannel (Sprint 8.2-8.4).
- **feat(privacy)**: Plugin Android (`GemmaInferencePlugin.kt`) utilizando motor LiteRT-LM para inferência em GPU/NPU.
- **feat(privacy)**: Plugin iOS (`GemmaInferencePlugin.swift`) skeleton estrutural para expansão via CoreML.
- **feat(ui)**: Página de **Gerenciamento do Modelo** (ModelManagementPage) com progresso de download e limpeza de cache.
- **feat(hardware)**: Detecção de RAM e plataforma no `DeviceCapabilityService` estendida para iOS.

### Fixed
- **fix(compilation)**: Resolução de conflitos de tipos em `RetrievedContext` e correção de imports de pacote no `ModelDownloadBloc`.
- **fix(ui)**: Correção de deprecations visuais (`surfaceVariant` -> `surfaceContainerHighest` e `withOpacity` -> `withValues`).

### Maintenance
- **test**: Estabilização da suite de testes alcançando **224 testes passing** (Exit Code 0).
- **task**: Atualização do checklist do Épico 8 no repositório de inteligência.

## [1.8.0-alpha.1] - 2026-04-17

### Added
- **feat(privacy)**: Épico 7 — Inferência Local (Edge LLM) com Roteamento de Fallback (US-047).
- **feat(privacy)**: `DeviceCapabilityService` para triagem de hardware (RAM/NPU) na inicialização.
- **feat(privacy)**: `GemmaLocalDataSourceImpl` (skeleton) preparado para inferência local via LiteRT-LM/MethodChannel.
- **feat(privacy)**: Strategy Pattern no `LlmRepositoryImpl` — tenta local primeiro, fallback silencioso para cloud.
- **feat(privacy)**: Enum `LlmProcessingOrigin` e entidade `LlmResponse` para rastreio de origem do processamento.
- **feat(privacy)**: Widget `PrivacyOriginIndicator` (escudo dourado = local, nuvem azul = remoto) na `ImmersiveReadingPage`.
- **feat(config)**: Remote Config keys `enable_gemma_local` e `gemma_model_min_ram_mb` para controle remoto.
- **feat(error)**: `LocalInferenceException`/`LocalInferenceFailure` para erros específicos de inferência local.
- **docs**: ADR 0005 — Estratégia de Inferência Local (Edge LLM).
- **test**: Testes de fallback no `LlmRepositoryImpl` (local/remote/falha dupla) e widget tests do indicador de privacidade.

### Changed
- **refactor**: `ILlmRepository` agora retorna `LlmResponse` (com metadados de origem) nos métodos de geração de conteúdo.
- **refactor**: UseCases `GenerateMeditation`, `GeneratePrayer`, `GenerateContemplatio` atualizados para `LlmResponse`.
- **refactor**: `LectioBloc` propaga `processingOrigin` no `LectioState` para transparência de privacidade.
- **refactor**: `LectioInProgress.copyWith` e `props` atualizados com campo `processingOrigin`.
- **refactor**: DI condicional — `GemmaLocalDataSource` instanciado apenas se hardware suporta e Remote Config habilitado.

## [1.7.0-alpha.1] - 2026-04-13

### Added
- **feat(profile)**: Épico 6 concluído - Sistema de Níveis de Maturidade (Beginner, Practitioner, Contemplative) estruturado na tela de perfil.
- **feat(ai)**: Implementação de Fading Scaffolding na geração de respostas, ajustando verbosidade e prompts (`PromptTemplateFactory`) conforme a maturidade do usuário.
- **feat(firebase)**: Introdução de serviços escaláveis e analytics: `RemoteConfigService`, `PushNotificationService` e `AnalyticsService`.
- **docs**: Registros técnicos criados informando o design do sistema de maturidade e Fading Scaffolding.
- **test**: Estabilização do uso do RAG contíguo a restrição dos níveis diários (`UserProfile` test suit coverage incrementada).

## [1.6.0-alpha.3] - 2026-04-10

### Added
- **feat(ci)**: Integração com Firebase App Distribution para distribuição automatizada de builds Android (#55).

### Fixed
- **fix(ci)**: Ajuste de nomes de segredos no workflow para sincronização com o GitHub Secrets (#56).

### Maintenance
- **chore**: Limpeza de avisos de análise (lint) e atualização de métodos depreciados do Flutter (ex: `withOpacity` para `withValues`).

## [1.6.0-alpha.2] - 2026-04-09

### Added
- **feat(brand)**: Novo Logo Oficial Concept (Bíblia + Cruz + Luz) para o pwE (#50).
- **feat(splash)**: Splash Screen obrigatória como `initialLocation` para reforçar a identidade e segurança (#51).
- **feat(splash)**: Disclaimer de IA solene com fonte Lora e 6s de exibição para leitura obrigatória (#52).
- **feat(ui)**: Design adaptativo (Light/Dark Mode) na Splash com paleta Premium (Champagne/Bronze) (#53).
- **docs**: Documentação detalhada de Identidade e Segurança em `docs/features/identity_and_safety.md` (#54).

## [1.6.0-alpha.1] - 2026-04-09

### Added
- **feat(ux)**: Novo Fluxo Imersivo de Lectio Divina (Épico 2) em ecrã único com scroll contínuo (#46).
- **feat(ux)**: Componente `ProgressiveTextReveal` para revelação gradual do texto sagrado via toque ou scroll (#41).
- **feat(ux)**: Componente `HoldToSaveButton` para confirmação segura de conclusão de etapa (#42).
- **feat(ux)**: Componente `ThinkingFeedback` com animações e mensagens espirituais para processamento de IA (#10).
- **refactor**: Implementação de estado cumulativo no `LectioBloc` para persistência visual das etapas anteriores (#43).
- **refactor**: Integração da nova rota `/immersive` no `AppRouter` (#44).
- **docs**: Documentação técnica detalhada em `docs/features/immersive_reading.md`.
- **test**: Adição de 30 novos testes automatizados garantindo a estabilidade do fluxo imersivo (#45).

## [1.5.0-alpha.1] - 2026-04-08

### Added
- **feat(liturgy)**: Integração com Liturgia Diária da Canção Nova (#39).
- **feat(liturgy)**: Sistema de scraping e parsing de HTML com limpeza resiliente via Regex.
- **feat(liturgy)**: Prévisualização de textos bíblicos limpos no BottomSheet de seleção.
- **feat(ui)**: Redesign da `PreparationPage` com nuvem orgânica de sentimentos e botões cleans.
- **docs**: Documentação técnica da feature em `docs/features/daily_liturgy.md`.
- **test**: Suite de testes para `DailyLiturgyModel` e `DailyLiturgyRemoteDataSource`.

## [1.4.0-alpha.1] - 2026-04-08

### Added
- **feat(auth)**: Implementação de login via Google Sign-In e Login Anônimo (#36).
- **feat(auth)**: Integração com Firebase Auth para persistência de tokens sociais.
- **feat(profile)**: Novo fluxo de configuração de perfil inicial (Idade, Gênero, Preferências) (#37).
- **feat(ui)**: Cabeçalho de perfil na tela de preparação exibindo dados do usuário logado.
- **docs**: Documentação técnica de autenticação em `docs/features/authentication.md`.
- **docs**: Relatório de resolução de bugs críticos em `docs/bugs/auth_bug_fix_report.md`.

### Fixed
- **fix(auth)**: Resolução do `DEVELOPER_ERROR` (Erro 10) através da migração para configuração dinâmica via `google-services.json`.
- **fix(auth)**: Correção de redirecionamento precoce no roteador durante a transição de sessão anônima para social.
- **test**: Estabilização dos testes de `AuthBloc` e `ProfileBloc` com mocks atualizados.

## [1.3.0-alpha.1] - 2026-04-06

### Added
- **feat(accessibility)**: Implementação do `ReadingPreferencesBloc` para controle dinâmico de interface.
- **feat(accessibility)**: Ajuste de tamanho de fonte em tempo real (12px a 32px) com redimensionamento proporcional.
- **feat(accessibility)**: Controle de alinhamento de texto (Esquerda vs Justificado) via `SegmentedButton`.
- **feat(accessibility)**: Ajuste de margens laterais dinâmicas (0px a 48px) para maior foco na leitura.
- **feat(accessibility)**: Botão de "Redefinir Padrões" para restauração rápida das configurações originais.
- **feat(ui)**: Novo `ReadingSettingsSheet` (Bottom Sheet) acessível em todas as etapas da Lectio e no histórico.
- **docs**: Manual técnico de acessibilidade adicionado em `docs/accessibility_feature.md`.

### Fixed
- **test**: Estabilização de regressões em `LectioPage` e `SessionDetailPage` relacionadas à injeção de BLoC em menus modais.
- **test**: Correção de erros de `mocktail` com `registerFallbackValue` para eventos de preferências de leitura.

## [1.2.0-alpha.2] - 2026-04-06

### Added
- **test**: Meta de cobertura de testes de 80% superada (Atual: **82.34%**).
- **test**: Implementação de testes unitários para a camada de Dados (Models e DataSources).
- **test**: Implementação de testes de Widget para `LectioPage` e `SpiritualMarkdown`.
- **test**: Adicionado script `test/detailed_coverage.dart` para relatórios granulares de cobertura.
- **ci**: Estabilização do pipeline de CI com injeção automática de configurações do Firebase (`firebase_options.dart` e `google-services.json`).
- **ci**: Correção automática de formatação em arquivos gerados via Workflow para garantir aprovação nos checks de qualidade.

### Changed
- **refactor**: Refatoração do `LLMRemoteDataSource` para suportar injeção de dependência do `GenerativeModel`, possibilitando mocking completo.
- **refactor**: Estabilização da suite de testes, eliminando falhas intermitentes e dependências de chaves de API reais em testes.

## [1.2.0-alpha.1] - 2026-04-01

### Added
- **feat(firebase)**: Integração com Firebase Authentication (Anônimo) e Cloud Firestore.
- **feat(firebase)**: Persistência de sessões de Lectio Divina no Firestore com suporte a histórico.
- **feat(ai)**: Migração para o modelo **Gemini 3.1 Flash Lite** (via ID preview), proporcionando maior cota diária (500 RPD).
- **feat(ai)**: Implementação de **Smart Retry** com jitter e backoff exponencial para lidar com instabilidades da API.
- **feat(ai)**: Sistema de **Cache de Sessão** no `LectioBloc` para evitar chamadas redundantes ao navegar entre etapas.
- **feat(ui)**: Novo componente `SpiritualMarkdown` para renderização de conteúdo gerado por IA com tipografia `Lora` e estilos espirituais.
- **feat(ui)**: Telas de Histórico de Sessões e Detalhes da Sessão.

### Fixed
- **chore(android)**: Correção de erros de compilação em modo Release relacionados ao Kotlin DSL (`isMinifyEnabled`).
- **chore(android)**: Inclusão de regras de ProGuard (R8) para evitar "Missing classes" no plugin do ML Kit.
- **fix(ui)**: Correção de caracteres brutos de Markdown exibidos erroneamente como texto simples.

### Changed
- Refatoração do `LectioBloc` para suportar repositórios de IA e Persistência desacoplados.
- Atualização da injeção de dependência (`GetIt`) com novos DataSources e Repositories.
