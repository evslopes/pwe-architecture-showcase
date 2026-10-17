# ADR 0013: Universalização do Design System Sacro e Internacionalização Quádrupla (PT, EN, ES, LA)

**Status:** Aprovado  
**Data:** 17 de Setembro de 2026  
**Contexto:** Sprints 5, 6 e 7 de Evolução Visual do pwE  

---

## 1. Contexto e Problema
Inicialmente, os componentes visuais sacros (`CandleFlameWidget`, `GoldenHalo`, `CrossOrnamentalDivider`) estavam restritos às telas principais de oração (`DailyDashboardPage` e `ImmersiveReadingPage`). As telas satélites (`BenefactorPage`, `PreparationPage`, `SessionHistoryPage`, `LoginPage`, `LectioPage`, `ProfilePage`, `OnboardingPage`, `SplashPage` e diálogos de boas-vindas) ainda utilizavam spinners circulares genéricos (`CircularProgressIndicator`), divisores cinzas sem mística e strings hardcoded em português. Além disso, a internacionalização não cobria todas as invocações, orações patrísticas e diálogos auxiliares nos 4 idiomas católicos do projeto.

## 2. Decisão Arquitetural
1. **Universalização de Tokens:** Implementação obrigatória de `CandleFlameWidget` em 100% dos fluxos de espera, busca ou carregamento, banindo spinners genéricos.
2. **Harmonização Sacra Integral:** Adoção de `CrossOrnamentalDivider` e `GoldenHalo` em todas as telas de autenticação, perfil, introdução e celebração.
3. **Internacionalização Canônica Quádrupla:**
   - Adicionadas 67+ novas chaves semânticas no `lib/l10n/app_pt.arb` e refletidas nos catálogos `app_en.arb`, `app_es.arb` e `app_la.arb`.
   - Tradução canônica de orações patrísticas de Santo Inácio de Loyola e São Bento para latim eclesiástico, espanhol e inglês.
   - Proibição estrita de strings hardcoded na camada de apresentação (`presentation/`).

## 3. Consequências
- **Positivas:**
  - Experiência de oração uniforme, nobre e sem quebras visuais em qualquer ponto do aplicativo.
  - Conformidade multilíngue com a Igreja Universal e preservação do patrimônio da língua latina.
  - 100% dos testes da suíte automatizada aprovados.
- **Diretrizes para Novos Desenvolvimentos:**
  - Toda nova tela deve usar `CandleFlameWidget` para carregamento e `context.l10n` para rótulos textuais.
