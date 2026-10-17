# ADR 0010: Observabilidade em Dupla Camada, Zero-Knowledge e Hardening do Diário

## Status
Aceito

## Contexto
Durante a execução de sessões da Lectio Divina e em testes de campo, identificou-se a necessidade de:
1. **Instrumentação Clara da Jornada:** Os logs de console eram superficiais, dificultando o acompanhamento em tempo real das etapas da oração (`Lectio` ➔ `Meditatio` ➔ `Oratio` ➔ `Contemplatio`).
2. **Convergência com Telemetria e Monitoramento de Produção:** Integrar de forma unificada os logs locais ao Google Analytics 4 (funil de engajamento do produto) e ao Firebase Crashlytics (diagnóstico de falhas e breadcrumbs).
3. **Privacidade e Ética Religiosa (Zero-Knowledge / LGPD):** As orações íntimas, anotações reflexivas e textos bíblicos digitados pelos fiéis são de foro íntimo espiritual. Sob nenhuma hipótese esses conteúdos podem trafegar para provedores analíticos de terceiros.
4. **Preservação de Formatação no Caderno Espiritual:** As anotações ricas feitas no editor Quill (negrito, itálico, listas e cabeçalhos) estavam sendo convertidas para texto puro (`toPlainText()`), perdendo a estrutura visual no diário.
5. **Criptografia de Dados Pessoais:** O armazenamento de notas e reflexões no Firestore e em cache local deve ser criptografado em repouso (AES-GCM).

## Decisão

### 1. Observabilidade em Dupla Camada (Console + Nuvem)
Adotamos uma abordagem convergente através do `AnalyticsService` e dos BLoCs:
- **Camada 1 (Desenvolvimento / Debug Console):** Emissão de logs estruturados e descritivos sob a tag `[LectioJourney]` cobrindo:
  - Início da sessão com leitura bíblica, nível de maturidade e flag de BFF.
  - Transições explícitas de passos com emojis litúrgicos.
  - Métricas de caracteres redigidos nas etapas de Meditatio e Oratio.
  - Duração total da oração e confirmação de persistência criptografada.
- **Camada 2 (Produção / GA4 e Crashlytics):**
  - **Google Analytics 4:** Eventos estruturados tipados (`lectio_started`, `lectio_step_advanced`, `lectio_gota_opened`, `lectio_completed`).
  - **Firebase Crashlytics:** Sincronização automática de *breadcrumbs* para rastreamento de ciclo de vida e *custom keys* (`reading_type`, `maturity_level`, `duration_seconds`).

### 2. Estrita Privacidade Zero-Knowledge
Nenhum texto de oração pessoal, passagem bíblica ou anotação do diário é enviado como parâmetro para o Google Analytics ou Crashlytics. Apenas métricas de ciclo de vida (ex: `duration_seconds: 388`, `has_personal_reflection: true`) são transmitidas.

### 3. Conversão de Formatação Quill Delta ➔ Markdown
Criamos o utilitário `QuillMarkdownConverter` para traduzir com fidelidade documentos e deltas do Flutter Quill para Markdown padrão (com suporte a negrito `**`, itálico `*`, sublinhado, cabeçalhos `##` e listas com marcadores `•`). O Caderno Espiritual (`SessionDetailPage`) passa a renderizar as notas com o componente `SpiritualMarkdown`.

### 4. Criptografia Simétrica AES-GCM
Implementamos o `EncryptionService` para cifrar notas reflexivas, orações e resoluções com AES-GCM 256-bit antes da escrita no Cloud Firestore ou em armazenamento local seguro, assegurando privacidade absoluta mesmo em caso de inspeção de banco de dados.

## Consequências

### Positivas
- Rastreamento completo da jornada do fiel em tempo de desenvolvimento e em produção.
- Conformidade total com a LGPD e o sigilo espiritual (Zero-Knowledge).
- Preservação da experiência de escrita rica no diário da Lectio Divina.
- Diagnóstico imediato de resiliência e erros no Crashlytics através de breadcrumbs cronológicos.

### Negativas / Mitigações
- Necessidade de mockar chamadas do `AnalyticsService` em testes unitários e de integração de BLoCs (mitigado com testes de contrato e stubs padronizados).
