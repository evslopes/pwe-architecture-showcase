# ADR 0012: Redesenho Sacro, Dashboard Litúrgico Shalom e Orquestração Viva da Leitura

**Status:** Aceito  
**Data:** 2026-09-09  
**Autor:** Engenheiro de Software Principal & Agente Antigravity  
**Contexto:** Evolução da experiência contemplativa (UX/UI Sacra) e maturidade orante do aplicativo pwE.

---

## 1. Contexto e Motivação

O aplicativo pwE auxilia fiéis católicos na prática contemplativa da Lectio Divina. Embora a `ImmersiveReadingPage` já proporcionasse um fluxo contínuo de 4 etapas (*Lectio, Meditatio, Oratio, Contemplatio*), a entrada no aplicativo carecia de uma acolhida litúrgica profunda, nobre e imediatamente orante:
1. **Entrada Fria / Sem Pedagogia:** Novos usuários chegavam ao aplicativo sem compreender as 4 etapas da Lectio Divina ou a sacralidade da Liturgia do Dia.
2. **Tipografia Monótona:** A leitura bíblica era renderizada em markdown plano (`SpiritualMarkdown`), perdendo a tradição clássica dos manuscritos e lecionários católicos (Letra Capitular iluminada, diálogos de proclamação e aclamação).
3. **Salmos Desorganizados:** O Salmo Responsorial frequentemente repetia a antífona dentro do corpo textual, gerando ruído e quebrando o ritmo contemplativo.
4. **Navegação Rígida:** Não havia indicativo claro no topo da tela sobre qual das quatro etapas o fiel estava vivenciando, nem atalho para saltar suavemente entre elas.

---

## 2. Decisão Arquitetural

Adotou-se uma reformulação holística baseada na **Estética Sacra e Carisma Contemplativo da Comunidade Shalom**, implementando:

### 2.1. Novo Dashboard Litúrgico (`DailyDashboardPage`)
- **Identidade Visual Shalom:** Paleta quente de sépia, pergaminho e ouro velho com tipografia `Lora` e ornamentos da cruz (`✠`).
- **Acolhida Pedagógica (`WelcomeGuideDialog`):** Apresentação automática no primeiro uso (via `SharedPreferences`), explicando pedagogicamente cada etapa da Lectio Divina e botão permanente de ajuda litúrgica na `AppBar`.
- **Card Devocional de "Check-in do Coração" (`LiturgicalDialogueCard`):** Convite à introspecção e diagnóstico de sentimentos antes do início da oração.
- **Divisão Litúrgica Clara:** Visualização individual das leituras do dia (1ª Leitura, Salmo, 2ª Leitura, Evangelho) e botão CTA solene de *Liturgia Completa*.

### 2.2. Orquestração Litúrgica Viva (`SacredReadingContent` & `SacredDropCapText`)
- **Letra Capitular Nobre (Drop Cap):** Primeira letra de cada leitura destacada em fonte `Cinzel` dourada, com recuo tipográfico harmônico e adaptabilidade ao tamanho de fonte do leitor (`ReadingPreferencesBloc`).
- **Salmo Responsorial:** Extração e desduplicação automática da antífona (`— R.`), exibida em card dourado destacado, com estrofes separadas por respiros litúrgicos (`~ ✠ ~`).
- **Diálogos de Proclamação e Aclamação:** Inclusão dos versículos e respostas oficiais da Igreja (*"O Senhor esteja convosco" / "Ele está no meio de nós"*, *"Palavra do Senhor" / "Graças a Deus"*, *"Palavra da Salvação" / "Glória a vós, Senhor"*).
- **Liturgia Completa Decomposta:** Parser inteligente para quebras de leitura com subdivisões nobres.

### 2.3. Stepper Litúrgico Superior (`SacredStepperHeader`)
- Cabeçalho anexado ao `bottom` da `SliverAppBar` em `ImmersiveReadingPage`, ilustrando os 4 degraus com ícones piedosos e rolagem animada suave (`animateTo`) para cada seção ao toque.
- Divisórias de etapa ornamentadas com estrelas douradas (`✦ DEGRAU X · TÍTULO ✦`).

### 2.4. Histórico Enriquecido (`SessionHistoryPage`)
- Campo de busca unificada (perícope, texto, notas espirituais) e chips de filtro por estados emocionais e espirituais (*Em Paz, Ansioso, Cansado, Alegre, Triste, Agitado*).

---

## 3. Consequências

### Positivas
- **Elevação Espiritual e Estética:** Primeira impressão de excelência que transmite sacralidade e convida ao recolhimento interior.
- **Clareza Pedagógica:** Redução drástica da barreira de entrada para novos orantes.
- **Fidelidade Litúrgica:** Respeito integral às aclamações e ritos da Liturgia da Palavra conforme a CNBB e o Magistério.
- **Acessibilidade Tipográfica:** Todos os novos componentes respeitam o escalonamento proporcional com base no tamanho de fonte (`prefs.fontSize`).

### Considerações Técnicas
- O componente `WelcomeGuideDialog` foi isolado para proteger testes unitários de ambiente sem injeção de `SharedPreferences`.
- O Flutter framework não possui `MaterialLocalizations` nativo para Latim (`la`), exigindo a injeção do `LatinMaterialLocalizationsDelegate` nas suítes de teste de widget.

---

## 4. Conformidade e Validação
- **Testes:** Cobertura de 100% dos novos widgets (`sacred_drop_cap_text_test.dart`, `sacred_reading_content_test.dart`, `sacred_stepper_header_test.dart`, `welcome_guide_dialog_test.dart`, `liturgical_dialogue_card_test.dart`).
- **Status da Suíte:** 448 testes aprovados com sucesso.
