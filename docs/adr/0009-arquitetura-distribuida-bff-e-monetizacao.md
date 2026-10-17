# ADR 0009: Arquitetura Distribuída (GitHub Actions + Dart Worker), Otimização de Custos e Monetização Ética

**Status:** Aceito  
**Data:** 30 de Agosto de 2026  
**Autores:** Arquiteto de Software Principal, Equipe pwE  
**Contexto Técnico:** Transição arquitetural para minimização de custos com IA e viabilização de monetização sustentável sem ferir a essência contemplativa católica.

---

## 1. Contexto e Problema

O aplicativo pwE (Pray With Me) foi arquitetado para guiar o usuário pelas etapas tradicionais da Lectio Divina (*Lectio*, *Meditatio*, *Oratio*, *Contemplatio*), integrando suporte de Inteligência Artificial para enriquecer a meditação segundo o Magistério da Igreja Católica.

Até a presente data, o aplicativo apresentava dois gargalos operacionais e econômicos:
1. **Scraping e Parsing Frágil no Cliente:** O datasource `DailyLiturgyRemoteDataSourceImpl` realizava scraping HTTP direto da Canção Nova no smartphone do usuário, tornando o app vulnerável a qualquer alteração de DOM do portal e causando lentidão de rede móvel.
2. **Redundância e Alto Custo de Chamadas LLM (Gemini Cloud):** A Liturgia Diária é universal para toda a Igreja Católica no Brasil em determinado dia. Cada usuário que abria o aplicativo e meditava sobre o Evangelho disparava chamadas independentes ao Gemini Cloud, multiplicando custos de tokens desnecessariamente.
3. **Sustentabilidade Financeira:** Havia a necessidade de monetizar a aplicação para cobrir custos de evolução e banco de dados, sem transformar o pwE em uma plataforma comercial invasiva ou quebrar o ambiente de recolhimento espiritual com anúncios pop-up.

---

## 2. Decisão Arquitetural

Decidiu-se pela transição para uma **Arquitetura Distribuída Serverless Baseada em Worker Agendado (GitHub Actions + Dart)** acoplada a um modelo de **Monetização Ética Católica ("Benfeitor pwE")**.

### Componentes Principais:

1. **Dart Worker Noturno no GitHub Actions (Custo R$ 0,00):**
   - Um workflow independente (`.github/workflows/daily-liturgy-cron.yml`) é acionado diariamente via cron às 00:05 BRT (03:05 UTC).
   - Executa o script nativo `scripts/daily_liturgy_worker.dart`, que extrai o texto bíblico oficial, dispara 1 única requisição gratuita ao Gemini 1.5/2.0 Flash (via Google AI Studio Free Tier) e produz:
     - Textos normalizados (1ª Leitura, Salmo, 2ª Leitura, Evangelho).
     - Lectio da liturgia completa da Missa.
     - Lectio individualizada para cada leitura.
     - 3 níveis de profundidade espiritual (Iniciante, Meditativo, Contemplativo) e prompts de oração.
   - O payload JSON final é gravado diretamente na coleção `daily_liturgies` do Cloud Firestore.

2. **Consumo no Cliente Flutter:**
   - O `DailyLiturgyRemoteDataSource` do Flutter é refatorado para ler o documento pré-computado do Firestore com tempo de resposta sub-segundo e cache local no Hive.
   - A geração de Meditatio e Oratio para a Liturgia Diária no aplicativo torna-se **instantânea e com custo zero de IA em tempo de execução**.

3. **Modelo de Monetização Ética ("Benfeitor pwE"):**
   - **Plano Gratuito:** Liturgia diária completa pré-gerada com meditações profundas, Caderno Espiritual local ilimitado e IA local (Gemma on-device).
   - **Plano Benfeitor (Assinatura Modesta / Oferta):** Acesso ao Gemini Cloud para qualquer passagem bíblica arbitrária (texto livre), OCR ilimitado e áudio narrado da Lectio.
   - **Isolamento Modular:** Implementado na nova feature `lib/features/subscription/` com container de injeção próprio `subscription_injection_container.dart`, preservando a inviolabilidade do Domínio e do `core/di/injection_container.dart`.

---

## 3. Alternativas Consideradas

| Opção | Custo Fixo | Custo Variável | Risco de Fatura | Avaliação |
| :--- | :--- | :--- | :--- | :--- |
| **Firebase Cloud Functions (Node.js/TS)** | R$ 0,00 | Grátis até 2M req | **Médio** (Exige cartão de crédito / Plano Blaze ativo) | Descartado pelo risco de cobrança e perda de reuso de código Dart. |
| **Dart Frog no Google Cloud Run** | R$ 0,00 | Grátis no Free Tier | **Baixo/Médio** (Exige Cloud Billing ativo para Scheduler) | Descartado para o estágio atual para manter infraestrutura zero. |
| **GitHub Actions + Dart Worker** | **R$ 0,00** | **R$ 0,00** | **Nenhum** (Opera dentro dos 2.000 min/mês grátis do GitHub) | **ESCOLHIDA**: Custo zero perpétuo, 100% em Dart e sem risco de surpresas. |

---

## 4. Consequências

### Positivas:
- **Redução de Custos de IA em 99%+:** Uma única chamada ao Gemini por dia atende a todos os usuários da liturgia do dia.
- **Custo Operacional Zero:** O worker consome ~15 minutos mensais do GitHub Actions (menos de 1% da cota gratuita) e 1 chamada/dia do Gemini (cota grátis permite até 1.500/dia).
- **Resiliência e Desacoplamento:** Mudanças no HTML da Canção Nova são corrigidas no script do worker sem exigir build ou atualização na Google Play Store.
- **Experiência do Usuário (UX):** Abertura do app instantânea, sem atrasos de rede na extração do texto bíblico.
- **Fidelidade à Essência Católica:** O aplicativo permanece livre de propagandas comerciais, incentivando a espiritualidade da partilha e do dízimo digital através do plano de Benfeitor.

### Negativas / Mitigações:
- **Dependência do Cron do GitHub Actions:** Pode haver pequenos atrasos de agendamento no GitHub Actions.  
  *Mitigação:* O cron roda às 00:05 BRT; os primeiros usuários normalmente acessam a liturgia após as 05:00 da manhã. Além disso, o script pode pré-gerar com 24h a 48h de antecedência (D+1).
- **Fallback de Scraping:** Caso o worker falhe por indisponibilidade externa, o app mantém mecanismo de contingência para leitura direta ou cache local da liturgia anterior.

---

## 5. Conformidade com Padrões do Projeto

- **Clean Architecture & DDD:** O domínio `DailyLiturgy` e `LectioDivina` continuam agnósticos ao meio de transporte.
- **Functional Error Handling:** Casos de uso continuam retornando `Either<Failure, Type>` via pacote `dartz`.
- **Governança de Segredos:** Credenciais do Gemini e Service Account do Firebase residem exclusivamente nos Secrets do GitHub Actions.

---

## Nota de Atualização (04/10/2026 — ADR 0031)

> Esta nota não reescreve a decisão histórica acima; registra o estado atual.

- **Execução principal do worker:** desde 26/09/2026 o worker roda no **GCP — Cloud Run Job `daily-liturgy-worker` disparado pelo Cloud Scheduler** às 03:00 UTC (00:00 BRT). Ver `gcp_cloud_run_liturgy_migration.md`.
- **`.github/workflows/daily-liturgy-cron.yml`:** o bloco `schedule:` foi desativado; o workflow permanece apenas como **disparo manual (`workflow_dispatch`) de contingência**. As menções acima a "cron do GitHub Actions" e a "Secrets do GitHub Actions" descrevem o desenho original de agosto/2026.
- **Modelos:** a menção a "Gemini 1.5/2.0 Flash" é histórica; a hierarquia atual do worker está em `kRunnerGeminiModelHierarchy` (`scripts/daily_liturgy_worker.dart`).
- **Matriz de direitos:** a divisão gratuito/Benfeitor descrita acima foi superada por `RN-SUB-112` (`docs/product/business_rules.md`), que reflete o código.
