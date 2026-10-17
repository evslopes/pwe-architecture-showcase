# ADR 0035 — Seleção Pastoral de IA no Onboarding e Conformidade com as Lojas

**Data:** 06 de Outubro de 2026  
**Status:** 🟢 Aceito  
**Autores:** Arquiteto de Software Principal & Engenheiro de Software Sênior  

---

## 1. Contexto

A auditoria de transformação do aplicativo pwE em produto identificou um atrito na jornada de primeiro uso (*First-Time User Experience - FTUE*):
1. **Atrito no Primeiro Dia de Oração:**
   - O fluxo anterior (introduzido no ADR 0033) redirecionava o fiel para uma página dedicada `/ai_selection` logo após o Onboarding, confrontando-o com decisões técnicas sobre inferência em nuvem versus on-device antes mesmo de ele vivenciar sua primeira oração da Lectio Divina.
2. **Conformidade Regulatória (Apple App Store & Google Play Store):**
   - **Google Play (Generative AI Policy & Prominent Disclosure):** Exige divulgação destacada (*in-app prominent disclosure*) e consentimento explícito afirmativo antes da primeira transmissão de dados de prompts/reflexões para servidores em nuvem.
   - **Apple (Guidelines 1.2, 5.1.1 e 5.1.2):** Exige consentimento explícito prévio para compartilhamento de dados com terceiros (APIs de IA), tolerância zero a abusos nos Termos de Uso (EULA) e opção clara para o usuário.

---

## 2. Decisão

### 2.1 Integração da Escolha Pastoral no 4º Slide do Onboarding
1. **Componente Reutilizável (`LectioPedagogicalSlides`):**
   - O método `buildSlides` passou a aceitar o parâmetro opcional `Widget? privacyCustomBody`.
   - No diálogo sob demanda (`WelcomeGuideDialog`), o 4º slide permanece estritamente educativo.
   - No fluxo de boas-vindas inicial (`OnboardingPage`), o 4º slide exibe o seletor pastoral nobre.
2. **Design da Escolha Pastoral:**
   - **Opção Recomendada (Nuvem / Servidores Seguros):** Exegese católica e reflexões aprofundadas com os Santos Padres via servidores seguros sob sigilo e respeito à intimidade.
   - **Opção Soberana (No Aparelho / Offline):** Nenhum texto sai do dispositivo; ideal para retiros ou oração desconectada.
   - **Nota de Concordância Legal (EULA & Privacidade):** Inserção do link explícito aos Termos de Uso e Política de Privacidade em conformidade com o Guideline 1.2 da Apple.
3. **Persistência e Navegação Direta:**
   - Ao tocar em *"Começar a Rezar"* (`btn_onboarding_start_pilgrimage`) ou em *"Pular"* (`btn_onboarding_skip`), o app grava o consentimento diretamente via `ICloudAiConsentService` (`grant()` ou `revoke()`), registra `ai_selection_done: true`, `prefer_offline_ai: !_useCloudAssistant` e navega diretamente para `/profile_setup`, **eliminando a tela `/ai_selection` do caminho crítico de acolhimento**.

### 2.2 Internacionalização Integral (18 Catálogos ARB)
- Adição de 6 novas chaves (`onboardingAiChoiceTitle`, `onboardingAiChoiceCloudTitle`, `onboardingAiChoiceCloudSubtitle`, `onboardingAiChoiceOfflineTitle`, `onboardingAiChoiceOfflineSubtitle`, `onboardingTermsAgreement`) com metadados em `lib/l10n/app_pt.arb` e paridade estrita nos outros 17 idiomas (`ar`, `de`, `en`, `es`, `fr`, `hi`, `it`, `ja`, `ko`, `la`, `nl`, `pl`, `pt`, `sw`, `tl`, `uk`, `vi`, `zh`).

---

## 3. Consequências

- **Experiência do Usuário (UX):** Redução drástica da barreira de entrada; o fiel conclui o acolhimento pedagógico e entra diretamente na Liturgia Diária sem nenhuma interrupção ou modal durante a oração.
- **Blindagem Regulatória:** Atendimento simultâneo às exigências de *Prominent Disclosure* do Google Play e aos Guidelines 1.2 e 5.1.1 da Apple, com opção de modo 100% on-device.
- **Cobertura e Verificação:** Atualizados os testes unitários e de widget em `onboarding_page_test.dart` com 100% de aprovação e zero issues de linter (`flutter analyze` limpo).
