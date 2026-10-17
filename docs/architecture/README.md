# Diagramas Técnicos de Arquitetura e Engenharia - pwE

Esta pasta reúne a documentação visual em formato **Mermaid** detalhando todos os aspectos operacionais, arquiteturais, de segurança e de negócio do aplicativo **pwE (Pray With Me)**.

---

## 📑 Índice de Diagramas

| Diagrama | Descrição | Arquivo |
| :--- | :--- | :--- |
| **1. Visão Geral da Arquitetura** | Camadas Clean Architecture (Presentation, Domain, Data) e Injeção de Dependências modular. | [architecture_overview.md](architecture_overview.md) |
| **2. Modelo C4 (Contexto, Containers e Componentes)** | Níveis 1, 2 e 3 do Modelo C4 detalhando integrações em nuvem, on-device e Clean Arch DDD. | [c4_model.md](c4_model.md) |
| **3. Diagramas de Sequência do Sistema** | 5 fluxos essenciais: Ingestão CNBB, 4 passos da Lectio, OCR livre, IA Híbrida e RevenueCat. | [sequence_diagrams.md](sequence_diagrams.md) |
| **4. Máquinas de Estados do Sistema** | Máquinas de estados completas: `LectioSessionBloc`, `ExegesisBloc`, `PassageDiscoveryBloc`, `SubscriptionBloc`, `ModelDownloadBloc` e `VaultSecurityBloc`. | [state_machines.md](state_machines.md) |
| **5. Fluxo de Sessão da Lectio Divina (Detalhado)** | Detalhes da experiência orante: Exegese, Gotas, Provocação Socrática e persistência. | [lectio_divina_sequence.md](lectio_divina_sequence.md) |
| **6. Observabilidade & Zero-Knowledge** | Dupla camada (Logs locais `[LectioJourney]`, GA4, Crashlytics e Langfuse) com filtro ético de privacidade. | [observability_flow.md](observability_flow.md) |
| **7. Backend Distribuído (BFF Noturno)** | Pipeline do Daily Liturgy Worker no GCP Cloud Run Job, GCS Static CDN e contingência offline. | [distributed_liturgy_bff.md](distributed_liturgy_bff.md) |
| **8. Segurança & Criptografia AES-GCM** | Ciclo de vida da cifragem e decifragem de notas e orações íntimas do fiel. | [security_and_encryption.md](security_and_encryption.md) |
