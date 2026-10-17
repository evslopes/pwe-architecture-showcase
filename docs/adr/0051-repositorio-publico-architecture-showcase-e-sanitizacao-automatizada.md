# ADR 0051: Repositório Público de Architecture Showcase (`pwe-architecture-showcase`) e Pipeline de Sanitização Automatizada (`tool/sync_showcase.dart`)

- **Status:** Aceito
- **Data:** 17 de Outubro de 2026
- **Decisores:** Arquiteto de Software Principal, Agentes `engineer`, `secops-privacy`, `devops`, `theologian`

## Contexto e Problema

O repositório principal do **pwE (Pray With Me)** permanece **100% privado** por conter propriedade intelectual crítica e sensível:
1. **Engenharia de Prompts Pastorais e Mistagógicos:** Matrizes exegéticas das *7 Gotas de Sabedoria*, heurísticas de *Fading Scaffolding* (progressão pedagógica por maturidade espiritual), prompts socráticos e diretrizes iconográficas da Oficina Veni Creator.
2. **Pipelines de Ingestão e Curadoria Litúrgica:** Workers distribuídos de reconciliação CNBB / LitCal v5, regras de precedência canônica e lógica server-authoritative de benfeitoria.
3. **Infraestrutura e Segredos Operacionais:** Identificadores de projetos GCP/Firebase, buckets privados, chaves de cofre criptográfico e configurações de deploy.

Contudo, para consolidar presença técnica pública no GitHub, permitir avaliação arquitetural de nível *Staff / Principal Engineer*, compartilhar práticas modernas de Engenharia de Software assistida por IA (17 Agentes Especialistas no Google Antigravity) e centralizar *Issues / Discussions* da comunidade sem abrir o código-fonte do produto, era necessário criar uma vitrine pública de arquitetura com **risco zero de vazamento de propriedade intelectual**.

## Decisão

1. **Repositório Público Dedicado (`github.com/evslopes/pwe-architecture-showcase`):**
   - Criação de um repositório público separado contendo exclusivamente documentação arquitetural sanitizada e recortes cirúrgicos de engenharia (*Clean Code Slices*):
     - `README.md`: Vitrine executiva com diagramas Mermaid (C4, Dual-AI Cloud/Edge, GCS Static CDN), indicadores de qualidade e links para [`pwe.jhhsolutions.dev/pt-br/`](https://pwe.jhhsolutions.dev/pt-br/).
     - `CHANGELOG.md`: Espelho público sanitizado das 115+ versões lançadas, demonstrando cadência real de engenharia e disciplina SemVer.
     - `docs/adr/`: Todos os ADRs (`0001` a `0051`) sanitizados.
     - `docs/architecture/`: Diagramas C4, fluxos de sequência, máquinas de estado, topologia de criptografia Zero-Knowledge (`AES-256-GCM` + `HKDF-SHA256`) e observabilidade `OTLP/HTTP v4`.
     - `docs/ai-governance/`: Arquitetura do Comitê de 17 Agentes Especialistas em 4 Pilares, validação em runtime via Marionette/Dart MCP e governança de prompts via hash SHA-256 no Langfuse (exibindo placeholders `[REDACTED_PASTORAL_PROMPT]`).
     - `showcase/`: 4 fatias reais de código e testes unitários/widget 100% livres de segredos de negócio (`state_management`, `edge_ai_bridge`, `platform_security`, `sacred_design_system`).

2. **Sincronizador Baseado em Allowlist e Sanitização (`tool/sync_showcase.dart`):**
   - Implementação de um orquestrador CLI no repositório privado que:
     - Opera exclusivamente por **Allowlist estrita** (nenhum arquivo fora da lista explícita é copiado).
     - Aplica um **Motor de Sanitização Regex (Redaction Engine)** que substitui identificadores de projetos GCP/Firebase (`<REDACTED_GCP_PROJECT_ID>`, `<REDACTED_AI_STUDIO_PROJECT_ID>`), nomes de buckets (`<REDACTED_GCS_CDN_BUCKET>`), tags de analytics (`G-REDACTED`) e URLs internas de infraestrutura.
     - Executa um **Security Leak Scanner (Guardrail Pós-Geração)** que varre 100% dos arquivos gerados contra uma *Denylist* de termos proibidos e padrões de segredos antes de permitir qualquer commit/push, abortando com código de erro caso detecte qualquer anomalia.

## Consequências

- **Positivas:**
  - Proteção hermética da propriedade intelectual teológica e de negócio no repositório privado.
  - Vitrine pública de altíssimo nível técnico com 51 ADRs, diagramas C4, recortes reais de código Flutter/Dart + testes e histórico vivo de releases.
  - Atualização determinística em comando único (`dart run tool/sync_showcase.dart --push`) a cada release relevante.
- **Negativas / Trade-offs:**
  - Os recortes de código em `showcase/` servem para inspeção arquitetural e leitura técnica, não compondo um projeto compilável isoladamente (documentado explicitamente em `showcase/README.md`).
