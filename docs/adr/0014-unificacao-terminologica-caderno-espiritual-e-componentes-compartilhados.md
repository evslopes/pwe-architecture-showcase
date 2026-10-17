# ADR 0014: Unificação Terminológica do Caderno Espiritual e Componentes Compartilhados de Apresentação

**Status:** Aprovado  
**Data:** 17 de Setembro de 2026  
**Contexto:** Sprint 8 de Eliminação de Redundâncias e Harmonização de Navegação do pwE  

---

## 1. Contexto e Problema
Com a expansão do aplicativo, foram identificadas três fragilidades de design e engenharia:
1. **Ambiguidade Terminológica:** A mesma funcionalidade de registro das graças orantes recebia múltiplos nomes nos fluxos ("Histórico de Orações", "Diário Espiritual", "Caderno de Orações"), confundindo o usuário.
2. **Duplicação Massiva de Layout:** O fluxo pedagógico de explicação dos 4 passos da Lectio Divina estava duplicado integralmente com mais de 500 linhas de código idêntico entre o `WelcomeGuideDialog` e o `OnboardingPage`.
3. **Desalinhamento de Navegação:** O chip de "Check-in do Coração" no Dashboard abria a rota genérica `/lectio` (leitura bíblica crua), ignorando que a intenção do fiel era rezar com base em suas intenções e disposições de alma.
4. **Desperdício de Espaço Vertical:** A tela de histórico repetia o título "Caderno Espiritual" tanto na AppBar quanto no primeiro bloco do corpo da página.

## 2. Decisão Arquitetural
1. **Unificação Terminológica Canônica:**
   - Adotado o conceito teológico de **Caderno Espiritual** em todos os menus, cabeçalhos, gavetas, rotas e diálogos nos 4 idiomas.
   - Linguagem pastoral solene para os Benfeitores ("O apoio dos Benfeitores viabiliza o desenvolvimento contínuo da plataforma...").
2. **Componente Pedagógico Compartilhado:**
   - Criação do widget desacoplado `LectioPedagogicalSlides`, reutilizado no `WelcomeGuideDialog` e no `OnboardingPage`.
   - Redução de mais de 50% de linhas de código em ambas as telas.
3. **Navegação Parametrizada no GoRouter:**
   - Rota `/lectio` passa a aceitar o query parameter `?tab=X` para abrir a aba correspondente (`LectioPage(initialTab: ...)`).
   - O chip "Check-in do Coração" agora aponta diretamente para `/lectio?tab=1`.
4. **Eliminação de Cabeçalhos Duplos:**
   - Título litúrgico transferido unicamente para a `AppBar` (`✠ Caderno Espiritual ✠`), priorizando os contadores de graças e a barra de busca no primeiro fold.

## 3. Consequências
- Código limpo, sustentável e DRY (Don't Repeat Yourself).
- Coesão conceitual e clareza imediata para os orantes.
- 100% dos 781 testes automatizados aprovados sem regressões.
