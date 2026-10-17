# ADR 0031 — Alinhamento Documental com o Código

**Data:** 04 de Outubro de 2026  
**Status:** 🟢 Aceito  
**Autores:** Arquiteto de Software Principal, Titular do Projeto  

---

## 1. Contexto

A auditoria de maturidade de outubro/2026 (`docs/releases/app-maturity-audit-2026-10.md`) identificou divergências entre a documentação e o código da v0.9.72+98, entre elas:

- Matriz de direitos `RN-SUB-112` com recursos inexistentes (limite de 7 dias de histórico, "3 vs 7 lentes", bloqueio do modelo on-device, cantochão) e trial descrito como "acesso total".
- Worker da liturgia descrito como cron do GitHub Actions, embora rode no GCP (Cloud Run Job + Cloud Scheduler) desde 26/09/2026.
- Modelo on-device citado como "Gemma 2B" (o código usa Gemma 4 E2B, `gemma_4_e2b.litertlm`).
- Regras de i18n ("i18n quádruplo", 4 ARBs) em AGENTS.md/GEMINI.md, quando o projeto tem 18 ARBs.
- Rastreabilidade do BRD com classes inexistentes (incluindo `LectioBloc`, removido no ADR 0027).
- Termos proibidos ("Diário Orante/Espiritual"), contagens voláteis de testes, gate de cobertura incoerente, menção a Fastlane/upload automático ao Play, ADRs 0029/0030 fora do índice principal, README com versão 0.9.64 e link de licença inexistente.
- Política de privacidade sem menção ao consentimento explícito para IA em nuvem (ADR 0025) e à senha opcional do cofre (ADR 0026).

## 2. Decisão

1. **O código é a fonte de verdade.** Quando documentação e código divergem, a documentação é corrigida para refletir o código (salvo decisão explícita do titular em contrário).
2. **`RN-SUB-112`** é reescrita a partir de `SubscriptionStatus`, `ConsumeOcrQuotaUseCase`, `fallback_plans_catalog.dart` e dos gates de `DailyDashboardPage`, `ImmersiveReadingPage`, `ReadingSettingsSheet` e `LectioPage`, com evidências arquivo:linha (`docs/product/business_rules.md`, `docs/features/ethical_monetization.md`, `docs/product/product_scope.md` §2.5).
3. **Worker da liturgia:** execução principal no GCP (Cloud Run Job `daily-liturgy-worker` + Cloud Scheduler, 03:00 UTC). `daily-liturgy-cron.yml` é apenas disparo manual de contingência. ADRs históricos recebem **nota de atualização** (sem reescrever a decisão original): 0005, 0008 e 0009.
4. **Gitflow do titular:** commits somente em branches de desenvolvimento; release/consolidação em `develop`; `main` apenas por PR de promoção quando o titular decidir (`docs/sdlc/development_lifecycle.md`).
5. **Nomes de domínio canônicos** vêm dos enums: `LectioMaturityLevel` (`beginner`, `practitioner`, `contemplative`) e `SoulState` (`peace`, `joyful`, `anxious`, `tired`, `agitated`, `sad`, `repentant`).
6. **Idiomas:** 18 ARBs de UI (`ar`, `de`, `en`, `es`, `fr`, `hi`, `it`, `ja`, `ko`, `la`, `nl`, `pl`, `pt`, `sw`, `tl`, `uk`, `vi`, `zh`), com `@metadados` somente em `app_pt.arb`; 7 idiomas litúrgicos pré-gerados pelo worker (`pt`, `en`, `es`, `it`, `la`, `de`, `fr`).
7. **Contagens voláteis** (número de testes) não são fixadas na documentação; referencia-se o CI. Catálogo canônico de **14 agentes** (AGENTS.md §7) e **31 ADRs** (0001–0031).
8. **Gate oficial de cobertura:** 70%, valor aplicado em `.github/workflows/ci.yml`.
9. **CHANGELOG:** `docs/releases/CHANGELOG.md` é a fonte; `CHANGELOG.md` da raiz é espelho byte-idêntico.
10. **Privacidade:** a política pública, `PRIVACY_POLICY.md` e os textos legais do app (pt, en, es, la) citam o consentimento explícito para IA em nuvem e a senha opcional do cofre, deixando claro que, **sem senha, a proteção depende também da infraestrutura do serviço** (sem alegação de sigilo absoluto/zero-knowledge nesse modo).

## 3. Consequências

- **Positivas:** documentação auditável e rastreável até o código; menor risco de promessas indevidas nas lojas e na política de privacidade; onboarding de agentes com regras corretas (18 ARBs, Gitflow, gate de cobertura).
- **Negativas:** regras de negócio antes "aspiracionais" passam a constar como **não implementadas** (ex.: `RN-SEC-093` biometria, `RN-SUB-113` política local de período de graça, formatadores/serviços dedicados citados no BRD).

## 4. Pendências

- **Cobertura:** `release.yml` valida 60% (`min-coverage: '60'`) e o comentário de PR do `ci.yml` exibe "Meta: 75%". Alinhar ao gate oficial de 70% em tarefa de DevOps (workflows não alterados nesta revisão).
- **Privacy Manifest iOS:** `PrivacyInfo.xcprivacy` já está no target `Runner` (v0.9.65), mas ainda não foi validado em build real no Xcode.
- **Biometria (`RN-SEC-093`)**: não implementada; decidir se permanece no escopo da v1.0.
- **Textos legais em outros idiomas de UI:** `getLegalContent` cobre pt, en, es e la; `de`, `fr` e `it` recaem no texto em inglês e os demais idiomas no português.
- **Documentos históricos** (`docs/_archive/`, entradas antigas do CHANGELOG, relatórios de auditoria e ADRs que citam termos antigos como citação histórica — p. ex. ADR 0014/0024) foram preservados intencionalmente.
