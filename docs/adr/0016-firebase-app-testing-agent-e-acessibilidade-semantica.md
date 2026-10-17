# ADR 0016 — Integração do Firebase App Testing Agent (IA) e Enriquecimento Semântico para Testes E2E Automatizados

**Data:** 26 de Setembro de 2026  
**Status:** 🟢 Aceito e Homologado  
**Autores:** Arquiteto de Software Principal, Especialista \`qa\`, Especialista \`design-a11y\`, Especialista \`devops\`  
**PR Relacionado:** PR #282 (\`feat(test): integrate Firebase App Testing Agent and enhance semantics for a11y\`)  

---

## 1. Contexto & Problema

O aplicativo **pwE (Pray With Me)** possui uma rica esteira de testes com pirâmide de qualidade bem consolidada (testes unitários, testes de BLoC e testes de widgets com \`mocktail\`). No entanto, a validação funcional de ponta a ponta (E2E) em dispositivos reais ou emuladores enfrentava desafios conhecidos:
1. **Fragilidade de Testes E2E Tradicionais:** Ferramentas baseadas em coordenadas ou IDs rígidos de driver tendem a quebrar com facilidade diante de microinterações sacras, animações contemplativas e variações sutis de layout entre diferentes tamanhos de tela.
2. **Avaliação da Árvore de Acessibilidade:** Componentes sacros e tipografia contemplativa necessitam de garantia contínua de reconhecimento por leitores de tela (TalkBack / VoiceOver), prevenindo a poluição sonora de símbolos litúrgicos decorativos (como \`✠\`).
3. **Custo e Limites de Infraestrutura em Nuvem:** A execução indiscriminada de testes em dispositivos de nuvem pode rapidamente estourar cotas de planos gratuitos e gerar custos desnecessários.

O Google Firebase introduziu o **Firebase App Testing Agent** (alimentado por IA generativa Gemini), capaz de interpretar a interface do usuário tanto visualmente quanto semanticamente, executando metas descritas em linguagem natural declarativa.

---

## 2. Decisão Arquitetural

Decidiu-se pela adoção oficial do **Firebase App Testing Agent** como a ferramenta padrão de testes funcionais E2E inteligentes do pwE, regida pelas seguintes diretrizes:

### A. Enriquecimento da Árvore Semântica (\`design-a11y\`)
- **Identificadores Semânticos Mandatórios:** Todos os botões, links e pontos de interação primários devem ser encapsulados em widgets \`Semantics\` contendo \`identifier\`, \`button: true\` e \`label\` internacionalizado.
  - Ex: \`continue_as_guest_button\`, \`start_lectio_cta\`, \`lectio_step_advance_button\`, \`drawer_menu_button\`, \`drawer_spiritual_journal\`.
- **Exclusão de Ornamentos Sacros:** Símbolos visuais decorativos (como a cruz pátea \`✠\` e divisores ornamentais) devem ser envolvidos em \`ExcludeSemantics\` para evitar confusão tanto para deficientes visuais quanto para os modelos de visão multimodal da IA.

### B. Suíte Declarativa YAML Versionada
- Os casos de teste residem obrigatoriamente no diretório versionado \`test/app_testing/smoke_tests.yaml\` (fora da pasta \`.firebase/\` gitignorada).
- Estrutura estrita conforme o schema do Firebase Tools:
  - Metas (\`goal\`), dicas de acessibilidade (\`hint\`) e asserções visuais de tela final (\`finalScreenAssertion\`).
  - Encadeamento de pré-requisitos através de \`prerequisiteTestCaseId\`: o teste de login anônimo (\`guest-login\`) precede os fluxos do dashboard e da Lectio Divina, resolvendo de forma determinística o primeiro acesso em dispositivos limpos.

### C. Esteira CI/CD Controlada Sob Demanda (\`workflow_dispatch\`)
- Criação de workflow isolado `.github/workflows/firebase-testing-agent.yml`.
- **Sem execução em gatilho de push/PR:** O workflow é estritamente manual, permitindo ao time de engenharia disparar testes com parâmetros de suíte, modelo de dispositivo e versão do Android.
- **Priorização de Dispositivos Virtuais:** O modelo padrão configurado é o dispositivo virtual \`MediumPhone.arm\` (\`default\`), que opera dentro da cota gratuita diária do Firebase Test Lab (Spark: 10 testes virtuais/dia).

---

## 3. Consequências

### Positivas
- **Resiliência a Mudanças de Layout:** A IA adapta-se a mudanças de posição de botões e textos, avaliando o propósito da tela sem depender de coordenadas físicas.
- **Auditoria Dupla de Acessibilidade:** Um teste que falha para o agente de IA é um forte indicativo de que um usuário com leitor de tela também encontraria barreiras para navegar.
- **Evidências Visuais Completas:** Cada passo executado pela IA gera capturas de tela e registros de decisões no console do Firebase App Distribution.
- **Zero Impacto no Faturamento:** A arquitetura manual garante consumo zero no dia a dia, reservando a cota gratuita para marcos de homologação e pré-release.

### Negativas / Mitigações
- **Latência de Execução:** Uma sessão de teste pelo agente de IA leva cerca de 2 a 4 minutos (em comparação a poucos segundos de testes unitários locais). Mitigado ao mantê-lo fora do \`ci.yml\` convencional.
- **Esquema Estrito de YAML:** O parser do Firebase Tools rejeita propriedades fora do padrão oficial (\`hints\` no plural ou \`description\`). Mitigado com documentação e suíte validada em schema.
