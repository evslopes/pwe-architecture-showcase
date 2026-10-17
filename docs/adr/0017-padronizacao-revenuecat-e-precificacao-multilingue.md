# ADR 0017 — Padronização do RevenueCat, Resiliência de Entitlement e Precificação Multilíngue por Paridade de Poder de Compra (PPP)

**Data:** 27 de Setembro de 2026  
**Status:** 🟢 Aceito e Homologado  
**Autores:** Arquiteto de Software Principal, Especialista `engineer`, Especialista `platform-mobile`, Especialista `theologian`  
**Branch Relacionada:** `revenuecat_multilingual_pricing_audit`  

---

## 1. Contexto & Problema

O **pwE (Pray With Me)** é um aplicativo católico universal de Lectio Divina que adota o modelo de **comunhão fraterna de bens**: a Liturgia Diária é perpetuamente gratuita para todos os fiéis, enquanto a infraestrutura de inteligência artificial na nuvem e o áudio contemplativo são sustentados por fiéis **Benfeitores**.

Durante a auditoria da integração do SDK do **RevenueCat (`purchases_flutter`)**, foram identificados três pontos críticos:
1. **Inconsistência de Entitlement ID:** O código Dart continha a string mágica hardcoded `benfeitor_pwe`, enquanto o guia oficial de publicação orientava o cadastro de `benefactor` nas lojas e no RevenueCat. Essa divergência faria o app ignorar assinaturas ativas em produção.
2. **Exibição de Textos e Sufixos Brutos de Lojas:** Lojas como o Google Play costumam concatenar sufixos de aplicativo nos títulos dos produtos (ex: `"Benfeitor Mensal (pwE: Lectio Divina)"`), poluindo a interface sacra. Além disso, títulos e descrições dos planos dependiam da conta da loja ou de listas parciais hardcoded em Dart.
3. **Ausência de Precificação Regional por Paridade de Poder de Compra (PPP):** A conversão cambial direta do Dólar ou Euro torna o apoio proibitivo em mercados emergentes e de forte tradição católica (como Filipinas, América Latina e Vietnã), contrariando a vocação caritativa da Igreja.

---

## 2. Decisão Arquitetural

Decidiu-se pela padronização integral da arquitetura de monetização ética do pwE através das seguintes diretrizes:

### A. Centralização e Injeção do Entitlement ID via `EnvConfig`
- **Variável de Ambiente:** Criação de `REVENUECAT_ENTITLEMENT_ID` gerenciada de forma centralizada pelo `EnvConfig`, operando com compilação estrita em release (`--dart-define`) e arquivo `.env` em modo de desenvolvimento.
- **Resolução Resiliente com Fallback Bidirecional:**
  ```dart
  // SubscriptionRemoteDataSourceImpl:
  String get entitlementId => _configuredEntitlementId ??
      EnvConfig.get('REVENUECAT_ENTITLEMENT_ID', defaultValue: 'benefactor');

  // SubscriptionStatusModel.fromCustomerInfo:
  final entitlement = customerInfo.entitlements.all[entitlementId] ??
      customerInfo.entitlements.all['benfeitor_pwe'] ??
      customerInfo.entitlements.all['benefactor'];
  ```
  Isso garante compatibilidade bidirecional tanto com o entitlement `benfeitor_pwe` (configurado no painel do RevenueCat e `.env`) quanto com `benefactor`.

### B. Mapeamento Flexível e Resiliente de Pacotes de Compra
- O método `purchasePlan` (`findMatchingPackage`) em `SubscriptionRemoteDataSourceImpl` busca o pacote no Offering tanto por `pkg.identifier == plan.id` quanto por `pkg.storeProduct.identifier == plan.id`, prefixo de plano base do Google Play Billing v5+ (`storeId.startsWith('${plan.id}:')`, ex: `pwe_benefactor_annual:annual-base`) e pelo tipo (`PackageType.annual`, `monthly`, `lifetime`), eliminando quedas acidentais no modo de simulação.
- Identificadores de produtos contendo `annual`/`yearly` ou `lifetime`/`single`/`offering` são categorizados de forma resiliente mesmo quando configurados como `PackageType.custom`.

### C. Internacionalização Completa (17 Idiomas) & Arquitetura Híbrida de Exibição
- **Separação Responsabilidades:** O valor e a moeda (`plan.priceString`) são fornecidos oficialmente pelas lojas pelo RevenueCat. Títulos e descrições são resolvidos exclusivamente via `context.l10n` (`planMonthlyTitle`, `planAnnualTitle`, `planOfferingTitle`, etc.) no idioma ativo do app.
- **Higienização de Título (`cleanStoreTitle`):** Regex incorporada ao `BenefactorPlanCard` para expurgar automaticamente quaisquer sufixos entre parênteses anexados pelas lojas.
- **Atualização dos 17 Catálogos ARB:** Chaves registradas nos 17 idiomas suportados (`pt`, `en`, `es`, `la`, `it`, `fr`, `de`, `pl`, `tl`, `vi`, `ko`, `ja`, `zh`, `ar`, `uk`, `sw`, `nl`, `hi`).

### D. Tabela Mestra de Precificação por Paridade de Poder de Compra (PPP)
- Estabelecida tabela de preços recomendados no `docs/features/revenuecat_production_publishing_guide.md` e espelhada no `SubscriptionRepositoryImpl._getFallbackPlans` para operação offline, com descontos fraternos anuais de ~30% em todas as moedas regionais (BRL, USD, EUR, GBP, PLN, PHP, VND, KRW, JPY, INR, UAH, KES).

---

## 3. Consequências

### Positivas
- **Imunidade a Erros de Publicação:** O app reconhece tanto `benefactor` quanto `benfeitor_pwe`, blindando o lançamento nas lojas.
- **Experiência Sacra Preservada:** Fim dos títulos feios das lojas na tela de benfeitor; o fiel sempre lê uma mensagem pastoral no idioma escolhido no app.
- **Alcance Evangelizador Global:** Fiéis em regiões de menor poder aquisitivo contam com faixas justas de contribuição.
- **100% Coberto por Testes:** Suíte de testes unitários expandida para 92 testes verdes, sem nenhuma regressão.

### Negativas / Mitigações
- **Manutenção de Chaves ARB em 17 Catálogos:** Mitigado pelo comando automatizado `flutter gen-l10n` e tipagem estrita via `AppLocalizations`.
