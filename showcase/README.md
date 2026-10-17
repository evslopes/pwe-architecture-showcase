# 🧩 Clean Code Slices — Recortes Reais de Engenharia do pwE

Esta pasta contém **recortes cirúrgicos reais** do código-fonte de produção (`lib/`) e de suas respectivas suítes de testes automatizados (`test/`) do aplicativo **pwE (Pray With Me)**.

> **Importante:** Estes arquivos foram extraídos do repositório privado principal para demonstrar o estilo de arquitetura, modelagem de estado, comunicação nativa via `MethodChannel`, segurança de plataforma, acessibilidade semântica e testes unitários/de widget. Como representam fatias isoladas (*slices*) de uma árvore Clean Architecture maior, eles **não formam um pacote Dart compilável de forma avulsa**, servindo como referência para inspeção técnica e revisão de código (*Code Review*).

---

## Estrutura das 4 Fatias de Engenharia

### 1. [`state_management/`](state_management/) — Desacoplamento BLoC & Clean Architecture
- **[`lectio_session_bloc.dart`](state_management/lectio_session_bloc.dart)**
- **[`lectio_session_event.dart`](state_management/lectio_session_event.dart)**
- **[`lectio_session_state.dart`](state_management/lectio_session_state.dart)**
- **[`lectio_session_bloc_test.dart`](state_management/lectio_session_bloc_test.dart)**

**O que avaliar neste recorte:**
- **Decomposição de Estado ([ADR 0015](../docs/adr/0015-decomposicao-god-bloc-e-higiene-arquitetura-dados.md)):** Orquestração limpa do ciclo de vida das 4 etapas da *Lectio Divina* (*Lectio, Meditatio, Oratio, Contemplatio*) sem acoplamento com detalhes de infraestrutura ou prompts de IA.
- **Fading Scaffolding ([ADR 0002](../docs/adr/0002-refactor-ux-ui.md)):** Adaptação progressiva da jornada conforme o nível de maturidade espiritual do usuário (`LectioMaturityLevel`).
- **Testabilidade com `bloc_test` e `mocktail`:** Verificação determinística de transições de estados, debounce de eventos de rolagem (`ScrollReachedEndEvent`) e tratamento funcional de falhas (`Either<Failure, T>`).

---

### 2. [`edge_ai_bridge/`](edge_ai_bridge/) — Ponte Nativa LiteRT-LM (Gemma 4 E2B) & Resiliência de IA
- **[`llm_local_datasource.dart`](edge_ai_bridge/llm_local_datasource.dart)**
- **[`llm_local_datasource_test.dart`](edge_ai_bridge/llm_local_datasource_test.dart)**
- **[`llm_rate_limiter.dart`](edge_ai_bridge/llm_rate_limiter.dart)**
- **[`llm_rate_limiter_test.dart`](edge_ai_bridge/llm_rate_limiter_test.dart)**

**O que avaliar neste recorte:**
- **Comunicação Nativa Assíncrona ([ADR 0005](../docs/adr/0005-edge-llm-strategy.md)):** Integração via `MethodChannel('pwe/gemma_local')` com o runtime nativo Kotlin/Swift do **LiteRT-LM (Gemma 4 E2B)**, incluindo *shader warmup* assíncrono e suporte a `CancellationToken`.
- **Auto-Healing Hardware Fallback (`GPU -> CPU`):** Detecção automática de timeouts ou falhas críticas de drivers gráficos móveis (`OpenCL`, `Vulkan`, `CL_OUT_OF_RESOURCES`) com recarregamento transparente do modelo na `CPU` (`_reloadOnCpu()`).
- **Rate Limiting Anti-Burst Granular:** Implementação em [`llm_rate_limiter.dart`](edge_ai_bridge/llm_rate_limiter.dart) com janela deslizante global por minuto (`maxRequestsPerMinute`) combinada a controle de intervalo mínimo por chave de operação (`operationKey`), permitindo chamadas legítimas paralelas no início da sessão sem colisão.

---

### 3. [`platform_security/`](platform_security/) — Soberania de Privacidade & `FLAG_SECURE` Dinâmico
- **[`screen_security_service.dart`](platform_security/screen_security_service.dart)**
- **[`screen_security_service_test.dart`](platform_security/screen_security_service_test.dart)**

**O que avaliar neste recorte:**
- **Privacidade Configurável em Runtime ([ADR 0044](../docs/adr/0044-privacidade-de-tela-configuravel-e-partilha-sacra.md)):** Alternância instantânea da proteção contra capturas e gravações de tela (`FLAG_SECURE` no Android e observação de captura no iOS) via `MethodChannel`, sem exigir reinicialização do aplicativo e com guarda segura para compilação Web/Wasm (`kIsWeb`).

---

### 4. [`sacred_design_system/`](sacred_design_system/) — Microinterações Contemplativas, Semântica IA & Responsividade
- **[`hold_to_save_button.dart`](sacred_design_system/hold_to_save_button.dart)**
- **[`hold_to_save_button_test.dart`](sacred_design_system/hold_to_save_button_test.dart)**
- **[`adaptive_two_pane.dart`](sacred_design_system/adaptive_two_pane.dart)**
- **[`adaptive_two_pane_test.dart`](sacred_design_system/adaptive_two_pane_test.dart)**

**O que avaliar neste recorte:**
- **Microinteração Intencional (`HoldToSaveButton`):** Botão de confirmação por pressão prolongada com anel de progresso renderizado via `CustomPainter` (`_ProgressRingPainter`), reversão suave em caso de soltura precoce, feedback háptico (`HapticFeedback.mediumImpact`) e rotulagem semântica explícita (`Semantics(identifier: 'hold_to_save_button')`) compatível com leitores de tela e com o *Firebase App Testing Agent* ([ADR 0016](../docs/adr/0016-firebase-app-testing-agent-e-acessibilidade-semantica.md)).
- **Layout Adaptativo Multi-Viewport (`AdaptiveTwoPane`):** Componente canônico *Scriptorium Sacro* que se adapta entre modo retrato (coluna única) e paisagem/desktop (dois painéis proporcionais com filigrana dourada vertical), utilizando `LayoutBuilder` para evitar o uso inseguro de `IntrinsicHeight` dentro de viewports roláveis ([ADR 0045](../docs/adr/0045-automacao-dod-i18n-e-viewport-matrix.md)).
