# ADR 0050: Especialista em Validação de Runtime (`perf-validator`) e Arquitetura da Documentação Técnica Mestre

- **Status:** Aceito
- **Data:** 17 de Outubro de 2026
- **Decisores:** Arquiteto de Software Principal, Agentes `perf-validator`, `engineer`, `devops`, `qa`, `task-finisher`

---

## 1. Contexto e Problema

Com a maturidade do ecossistema **pwE (Pray With Me)** na versão `0.9.113+141` — operando de forma multiplataforma (Android, iOS e Web `/app`), com 7 módulos de domínio, 13 BLoCs, 18 catálogos de internacionalização ARB, offload CDN-First no Google Cloud Storage e orquestração local/nuvem de releases — surgiram duas necessidades estruturais:

1. **Validação Autônoma de Runtime em Modo Debug:**
   Embora a pirâmide de testes estáticos e de unidade/widget (`flutter test`) cubra mais de 1.100 casos de teste, falhas sutis de integração em tempo de execução — como vazamentos de memória (crescimento de PSS após múltiplos ciclos de *Lectio Divina*), reconstruções excessivas de widgets, atrasos relativos de inicialização ou regressões na árvore semântica em dispositivos físicos — exigiam um protocolo determinístico e não-destrutivo operado por agente de IA via **Marionette MCP** e **Dart MCP**.
2. **Unificação e Aderência da Documentação Técnica (`docs/`):**
   A rápida evolução entre os ADRs 0032 e 0049 introduziu novos módulos (`security_vault`), novos serviços centrais (`ScreenSecurityService`, `SacredShareService`, `LocalUserDataCleaner`, `VersionGovernanceBanner`), novas integrações (RevenueCat Web Billing REST v1, Google Play Android Publisher API v3, Langfuse Scores API, GCS Static CDN JSON API) e novas ferramentas CLI (`tool/pwe_release.dart`, `tool/pwe_local_deploy.dart`, `tool/i18n_sync.dart`, `scripts/pwe_doctor.dart`). Tornou-se indispensável consolidar um **Catálogo Completo de Módulos e Componentes**, um **Manual de Integrações e APIs Externas** e um **Manual de Gerenciamento e Operações (Day-2)**.

---

## 2. Decisão Arquitetural

### 2.1. Instituição do 17º Especialista: `perf-validator` (Pilar IV — Qualidade, Diagnóstico & Infraestrutura)
Foi criado o agente especialista **somente leitura** `perf-validator`, acompanhado de sua habilidade progressiva `.agents/skills/perf-validator/SKILL.md` e do workflow interativo `/perf-validator`:
- **Escopo Estrito Somente Leitura:** O `perf-validator` nunca altera código-fonte de produção; sua missão é inspecionar o aplicativo em execução (modo `debug`) via **Marionette MCP** (`connect`, `get_interactive_elements`, `tap`, `enter_text`, `scroll_to`, `take_screenshots`, `get_logs`) e **Dart MCP** (`get_runtime_errors`, `vm_service`).
- **Procedimento Canônico em 7 Fases:**
  1. Pré-voo e conexão ao dispositivo físico ou emulador;
  2. Auditoria de inicialização (*Cold Start*, DI e serviços periféricos);
  3. Navegação automatizada ponta a ponta pelo fluxo completo da *Lectio Divina* (Onboarding $\to$ Login Visitante $\to$ Dashboard $\to$ Preparação $\to$ *Lectio* $\to$ *Meditatio* $\to$ *Oratio* $\to$ *Contemplatio* $\to$ Selamento no Caderno Espiritual);
  4. Inspeção de transições de estado dos BLoCs e ausência de exceções não tratadas;
  5. Verificação de estabilidade de memória (comparação de heap/PSS antes e após ciclos repetidos);
  6. Teste de resiliência a entradas inválidas e rotação de tela;
  7. Emissão do relatório estruturado (`relatorio_validacao_debug.md`).

### 2.2. Expansão da Arquitetura Documental (`docs/`)
A documentação oficial do projeto passa a contar com três manuais técnicos exaustivos que complementam a referência arquitetural existente:
1. **`docs/architecture/modules_and_components_catalog.md`:** Raio-X completo dos 16 subpacotes e 21 serviços de `lib/core/`, das 7 features de `lib/features/`, dos 13 BLoCs, 32 UseCases, 17 DataSources e da vitrine institucional `landing/`.
2. **`docs/architecture/integrations_and_external_apis.md`:** Especificação de contratos, autenticação, payloads, fallbacks e quotas das 14 integrações externas e pontes nativas (Android Kotlin & iOS Swift).
3. **`docs/operations/operations_and_management_manual.md`:** Guia de gerenciamento remoto (Remote Config, Feature Flags, Langfuse Scores), catálogo completo das ferramentas CLI (`tool/` e `scripts/`), fluxo híbrido de deploy (Local vs. Nuvem) e 5 Runbooks operacionais de resposta a incidentes.

---

## 3. Consequências

### Positivas
- **Cobertura de Qualidade em Runtime:** Homologado com 100% de sucesso em hardware físico (Samsung Galaxy A34 5G, Android 16 API 36), garantindo que cada release possa ser auditada dinamicamente sem intervenção manual repetitiva.
- **Rastreabilidade Total:** Engenheiros e agentes de IA dispõem de documentação 100% aderente ao código da série `v0.9.113+`, cobrindo módulos, integrações, gerenciamento e operação contínua.
- **Governança de 17 Especialistas Unificada:** Todos os índices (`AGENTS.md`, `GEMINI.md`, `docs/README.md`, `docs/architecture/agent_governance_and_security.md` e `docs/sdlc/development_lifecycle.md`) passam a refletir os 17 especialistas do projeto.

### Trade-offs
- **Manutenção Contínua:** A adição de novos módulos, serviços ou scripts CLI exige atualização concomitante dos manuais técnicos durante o Passo 1 do Rito de Finalização de Tarefas (`task-finisher`).
