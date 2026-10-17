# ADR 0033 — Harmonia Visual e Fluxo Contemplativo de Consentimento e Seleção de IA

**Data:** 05 de Outubro de 2026  
**Status:** 🟢 Aceito  
**Autores:** Arquiteto de Software Principal & Engenheiro de Software Sênior  

---

## 1. Contexto

A auditoria de maturidade de produto e usabilidade identificou duas oportunidades críticas de refinamento no fluxo de consentimento explícito e seleção de IA (introduzido no ADR 0025):

1. **Momento Inadequado de Interceptação:**
   - A guarda de autenticação (`resolveAuthRedirect`) redirecionava compulsivamente o usuário autenticado para `/ai_selection` logo no início, antes que o fiel conhecesse o aplicativo. O usuário era confrontado com termos como "Gemini", "IA em Nuvem" e pedidos de consentimento sem sequer compreender os quatro degraus da Lectio Divina (Lectio, Meditatio, Oratio, Contemplatio) nem a proposta do app.
2. **Dissonância Estética com o Design System Sacro:**
   - A tela `AiSelectionPage` apresentava elementos visuais tecnológicos frios (como o ícone `Icons.memory`), sombras fluorescentes douradas que remetiam a banners comerciais de precificação/upsell de software (SaaS), e uma apresentação diminuída da opção "Continuar sem assistente" como se fosse mero descarte.
   - O diálogo de consentimento `showCloudAiConsentDialog` utilizava o `AlertDialog` genérico do Material Design, sem integração com a paleta de pergaminho, sem divisores com cruz e com tipografia não litúrgica.

---

## 2. Decisão

### 2.1 Acolhimento Primeiro (Pedagogia antes da Decisão Técnica)
1. **Guarda de Rotas Amigável ao Onboarding (`lib/core/routes/auth_redirect.dart`):**
   - As rotas `/onboarding` e `/profile_setup` foram formalmente incluídas no conjunto `kAiChoiceRoutes`.
   - Usuários em fase de acolhimento inicial não são mais interceptados pelo guard de IA enquanto percorrem o onboarding ou realizam a personalização inicial de perfil.
   - A guarda continua protegendo de forma intransigente as telas de oração (`/`, `/lectio`, `/preparation`): se o fiel tentar rezar sem ter definido o consentimento de IA, o redirecionamento para `/ai_selection` continua garantido.
2. **Transição Orgânica no Onboarding (`lib/features/profile/presentation/pages/onboarding_page.dart`):**
   - Ao concluir o 4º slide contemplativo (que apresenta o Santuário de Privacidade e o sigilo do foro íntimo) ou ao tocar em Pular, o app avalia `needsAiChoice`.
   - Se a decisão estiver pendente, o usuário é convidado serenamente a configurar sua experiência em `/ai_selection`.
3. **Resolução Suave no Splash (`lib/features/splash/presentation/pages/splash_page.dart`):**
   - No cold start, usuários autenticados sem o onboarding concluído (`welcome_guide_shown == false`) são encaminhados para `/onboarding`, garantindo que o primeiro contato seja de acolhimento espiritual.
4. **Encaminhamento Pós-Seleção Inteligente (`lib/features/splash/presentation/pages/ai_selection_page.dart`):**
   - Após a escolha do motor (Nuvem, Offline ou Sem Assistente), se o usuário ainda não tiver perfil salvo (`ProfileBloc.state.profile == null`), ele é direcionado a `/profile_setup`. Caso já possua perfil, segue direto para o Dashboard (`/`).

### 2.2 Harmonia Visual do Design System Sacro
1. **Refatoração da `AiSelectionPage`:**
   - Adotada a paleta nobre da Comunidade Shalom (`context.sacred.parchment`, `cardSurface`, `sacredBorder`, `goldAccent`, `liturgicalGlow`).
   - Substituído o ícone de chip eletrônico `Icons.memory` por `Icons.shield_outlined`, comunicando proteção, autonomia interna e refúgio seguro no dispositivo.
   - Eliminadas as sombras berrantes de precificação, aplicando elevação litúrgica discreta (`liturgicalGlow`) e selo nobre "Recomendado" com tipografia Cinzel.
   - A opção "Continuar sem assistente" foi elevada a uma via de igual dignidade contemplativa (homenageando a tradição clássica monástica de Guigo II, o Cartuxo), com contorno sagrado e ícone `Icons.menu_book_outlined`.
   - Incorporados o halo sacro acolhedor (`GoldenHalo`) e o divisor litúrgico com cruz central (`CrossOrnamentalDivider`).
2. **Refatoração do Diálogo `showCloudAiConsentDialog`:**
   - Construído com fundo `cardSurface`, borda de pergaminho sagrado, cabeçalho solene com auréola, cruz ornamental divisória (`CrossOrnamentalDivider`) e texto em fonte Lora com espaçamento confortável.
   - Inserida caixa litúrgica de garantia de sigilo do Caderno Espiritual e aviso de reversibilidade da configuração a qualquer momento.

### 2.3 Resiliência de Feedback Háptico
- Substituição de `await HapticFeedback...` por `unawaited(HapticFeedback...)`, eliminando travamentos assíncronos e garantindo execução fluida em ambientes de teste de widget.

---

## 3. Consequências

- **Experiência do Usuário (UX):** O fiel é primeiro acolhido na pedagogia da Lectio Divina e no compromisso ético de privacidade do app, tomando uma decisão informada e consciente sobre o uso ou não de recursos em nuvem.
- **Harmonia Estética:** A interface está 100% alinhada com as diretrizes do Design System Sacro do pwE, preservando o clima de recolhimento, silêncio e solenidade.
- **Cobertura e Verificação:** Criados testes de widget completos para `AiSelectionPage` e `showCloudAiConsentDialog`, além de testes de navegação e onboarding, mantendo 100% dos testes verdes e zero issues de linter.
