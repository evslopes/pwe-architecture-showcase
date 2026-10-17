# ADR 0034 — Arquitetura de Subagentes Assíncronos Nativos do Antigravity

**Data:** 05 de Outubro de 2026  
**Status:** 🟢 Aceito  
**Autores:** Arquiteto de Software Principal & Engenheiro de Software Sênior  

---

## 1. Contexto

A governança multiagente do pwE contava com uma estrutura distribuída entre `.agents/skills/` (Progressive Disclosure) e `.github/agents/` (formato do GitHub Copilot Workspace). Embora eficaz para a injeção sob demanda de diretrizes de contexto no agente primário, essa configuração apresentava as seguintes limitações operacionais no ecossistema **Google Antigravity**:

1. **Incompatibilidade com o Asynchronous Execution Model:** O Antigravity CLI e a IDE suportam execução concorrente de subagentes em segundo plano para delegar builds, varreduras de código, testes de regressão, auditorias FinOps e curadoria teológica sem bloquear a sessão do usuário. No entanto, o motor de descoberta de agentes do Antigravity requer a localização em `.agents/agents/<name>.md` (ou `.agents/agents/<name>/agent.md`).
2. **Ausência de Metadados Canônicos:** Os arquivos em `.github/agents/*.agent.md` não possuíam frontmatter YAML delimitado por `---`, impedindo o runtime de inferir parâmetros como `name`, `description`, `subagent: true`, `tools`, `model`, `commandExecutionPolicy` e `skills`.
3. **Invisibilidade Operacional:** Sem o diretório `.agents/agents/`, os especialistas não podiam ser invocados programaticamente via `invoke_subagent`, nem selecionados/monitorados no painel interativo `/agents`, impossibilitando o uso de atalhos ergonômicos como `Alt+J` (teleport de aprovação) e `Ctrl+K` (confirmação rápida).

---

## 2. Decisão

Adotamos a padronização oficial de subagentes do Google Antigravity ([https://antigravity.google/docs/subagents#asynchronous-subagents](https://antigravity.google/docs/subagents#asynchronous-subagents)), formalizando a coexistência de três camadas especializadas:

### 2.1 Estrutura Canônica de Subagentes (`.agents/agents/`)
Criamos e configuramos 16 subagentes customizados em `.agents/agents/<name>.md`:

```text
.agents/
├── agents/                   # Camada de Subagentes Assíncronos Concorrentes (Antigravity)
│   ├── agile.md
│   ├── ai-engineer.md
│   ├── data-engineer.md
│   ├── debugger.md
│   ├── design-a11y.md
│   ├── devops.md
│   ├── engineer.md
│   ├── finops.md
│   ├── flutter-ui.md
│   ├── liturgical-scheduler.md
│   ├── platform-mobile.md
│   ├── qa.md
│   ├── secops-privacy.md
│   ├── shalom-iconographer.md
│   ├── task-finisher.md
│   └── theologian.md
├── skills/                   # Camada de Progressive Disclosure (Sessão Principal)
├── rules/                    # Regras Hierárquicas Globais
└── mcp_config.json           # Configuração de Servidores MCP
```

### 2.2 Schema de Frontmatter YAML Estrito
Cada subagente implementa o contrato exigido pelo runtime:
- `name`: Identificador unívoco do especialista.
- `description`: Resumo semântico para decisão automática de delegação pelo planner.
- `tools`: Lista explícita de ferramentas permitidas, prevenindo congelamentos por ferramentas não mapeadas (conforme nota de advertência da documentação).
- `subagent: true`: Habilita a invocação assíncrona concorrente via `invoke_subagent`.
- `mainAgent: true`: Permite alternância manual como agente primário através do menu `/agents`.
- `model`: Alocação otimizada do tier (`inherit`, `flash`, `pro`).
- `commandExecutionPolicy`: Política de execução no terminal (`auto` ou `sandbox`).
- `skills`: Associação direta às instruções da skill correspondente em `skills/<name>`.

### 2.3 Preservação da Compatibilidade Multiferramenta
- Os catálogos em `.agents/skills/` são mantidos para injeção progressiva de contexto na conversa principal.
- Os arquivos em `.github/agents/` são mantidos para interoperabilidade com o GitHub Copilot Workspace.

---

## 3. Consequências

- **Execução Paralela Real:** O agente primário do Antigravity pode despachar tarefas de longa duração (ex: execução de suíte de testes pelo `qa`, refatorações pelo `engineer`, auditoria pelo `finops`) de forma assíncrona sem travar o fluxo interativo do desenvolvedor.
- **Rastreabilidade e Governança:** Todos os subagentes possuem ciclo de vida formal (`Running`, `Idle`, `Killed`), logs de raciocínio inspecionáveis em formato JSONL e navegação direta no painel `/agents`.
- **Alinhamento Arquitetural:** 100% de conformidade com os padrões de engenharia do Antigravity 2.0 e as diretrizes doutrinárias católicas do projeto pwE.
