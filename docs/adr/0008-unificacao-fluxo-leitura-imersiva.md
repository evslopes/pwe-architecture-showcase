# ADR 0008: Unificação do Fluxo de Leitura Imersiva e Preparação para Google Play

## Status
Aceito (Agosto de 2026 / v1.0.0)

## Contexto
Ao longo dos ciclos de desenvolvimento de US-049 e US-050, o pwE acumulou duas jornadas concorrentes de oração:
1. **Fluxo Litúrgico:** Partia do `DailyDashboardPage` e navegava para telas fragmentadas (`MeditatioPage` -> `OratioPage` -> `ContemplatioPage`), pulando visualmente o passo fundamental da *Lectio* do texto sagrado.
2. **Fluxo de Passagem Livre:** Partia da `LectioPage` e avançava para a `ImmersiveReadingPage`, que reunia todas as etapas em uma rolagem contínua sem distrações.
3. **Telas Legadas:** A `PreparationPage` permanecia como código órfão no repositório.

Essa duplicidade causava confusão no usuário, duplicação de lógica de estado no BLoC e dificultava a manutenção antes do lançamento na Google Play Store.

## Decisão
1. **Unificação Integral na `ImmersiveReadingPage`:**
   - Adotamos a `ImmersiveReadingPage` como **única** interface de execução da Lectio Divina para ambos os pontos de entrada (Liturgia Diária e Passagem Livre).
   - As telas fragmentadas `MeditatioPage`, `OratioPage` e `ContemplatioPage`, bem como a tela órfã `PreparationPage`, foram descontinuadas e removidas da base de código.
2. **Navegação a partir do Dashboard:**
   - Ao selecionar uma leitura ou Evangelho no `DailyDashboardPage`, o evento `StartLiturgicalSessionEvent` é despachado, a exegese central é disparada via `RequestExegeseCentralEvent` e o app navega diretamente para `/immersive`.
3. **Garantia de Estado Limpo:**
   - Implementado o evento `ResetSessionEvent` e reset das instâncias de LLM (`llmRepository.resetSession()`) na inicialização de novas sessões.
4. **Adequação para a Google Play Store:**
   - Application ID e namespace atualizados para `br.com.jhhsolutions.praywithme.app`.
   - Nome definitivo: `pwE — Leitura Orante`.
   - Configuração de assinatura de release com `upload-keystore.jks` e `key.properties`.
   - Criação da Política de Privacidade oficial em conformidade com a LGPD e publicação via Firebase Hosting.

## Consequências
- **Positivas:**
  - Redução de mais de 2.000 linhas de código legado e duplicado.
  - Experiência do usuário (UX) coesa, contemplativa e centrada na Palavra.
  - Zero rotas quebradas ou telas inacessíveis.
  - O aplicativo atende a 100% dos requisitos mandatórios de publicação na loja.
- **Negativas:**
  - Usuários que preferiam telas com paginação tradicional por botão "Avançar" utilizam agora a rolagem contínua com botões de avanço progressivo embutidos na mesma página.

---

## Nota de Atualização (04/10/2026 — ADR 0031)

> Nota de reconciliação com o código; a decisão histórica acima é preservada.

- A `PreparationPage` **existe novamente** no código (`preparation_page.dart`), registrada na rota `/preparation` (`lib/core/routes/app_router.dart`) e acessível pelo `PreparationInviteCard` no Dashboard e pela gaveta (`daily_dashboard_drawer.dart`). Ela foi reintroduzida como **preparação interior opcional** (invocação do Espírito Santo) antes da leitura — não como etapa obrigatória do fluxo — e o CHANGELOG 0.9.72 que a cita está correto.
- A `ImmersiveReadingPage` continua sendo a interface única de execução dos 4 passos; as telas `MeditatioPage`, `OratioPage` e `ContemplatioPage` permanecem removidas.
