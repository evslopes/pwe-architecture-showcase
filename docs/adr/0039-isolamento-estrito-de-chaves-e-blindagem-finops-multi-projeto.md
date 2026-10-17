# ADR 0039: Isolamento Estrito de Chaves e Blindagem FinOps Multi-Projeto

## Status
Aprovado

## Data
08 de Outubro de 2026

## Contexto
O ecossistema do pwE opera com dois projetos distintos no Google Cloud Platform / Google AI Studio:
1. **`<REDACTED_GCP_PROJECT_ID>` (Plano Blaze / Faturado):** Projeto de infraestrutura onde residem os serviços de Cloud Run Jobs, Cloud Scheduler, Cloud Firestore, Firebase Authentication e Artifact Registry. Possui conta de faturamento ativa vinculada aos orçamentos de segurança.
2. **`<REDACTED_AI_STUDIO_PROJECT_ID>` (`pwE-AiStudio` / Free Tier Perpétuo):** Projeto criado exclusivamente para a API do Google Gemini, operando sob cota gratuita com faturamento desativado (`billingEnabled: false`) para assegurar risco financeiro zero.

Durante uma auditoria operacional de rotina em 07/10/2026, identificou-se que o arquivo `.env` de desenvolvimento local continha uma chave de API criada em 10/09/2026 pertencente ao projeto Blaze (`<REDACTED_GCP_PROJECT_ID>`), e que essa mesma chave estava gravada no segredo `GEMINI_API_KEY` do GitHub Actions.

Embora o worker noturno no GCP Secret Manager estivesse apontando para o projeto correto (`pwE-AiStudio`), execuções de testes locais e compilações de release pelo CI consumiram a chave vinculada ao projeto Blaze. Como a conta de faturamento do projeto Blaze operava com créditos pré-pagos esgotados, as requisições à API do Gemini foram rejeitadas com erro HTTP `402 PaymentRequired`, impedindo cobranças indevidas, mas evidenciando uma vulnerabilidade de governança e contaminação cruzada entre ambientes.

Além disso, identificou-se que a gravação anterior do segredo no GCP Secret Manager continha um caractere inicial Byte Order Mark (`\ufeff` / UTF-8 BOM), que causava problemas de codificação na inspeção via linha de comando.

## Decisão

1. **Paridade Mandatória de Chaves com o Projeto Free Tier:**
   - A variável `GEMINI_API_KEY` em **todos** os pontos do ciclo de vida do software deve pertencer exclusivamente ao projeto `pwE-AiStudio` (`<REDACTED_AI_STUDIO_PROJECT_ID>`), com prefixo canônico `AQ.Ab8RN6IThulDk`.
   - Isso inclui:
     - Arquivo local `.env` de desenvolvimento e testes.
     - Segredo do repositório GitHub (`secrets.GEMINI_API_KEY`), utilizado na compilação de release com `--dart-define=GEMINI_API_KEY`.
     - Segredo do GCP Secret Manager (`pwe-gemini-api-key`), consumido pelo Cloud Run Job `daily-liturgy-worker`.

2. **Proibição de Chaves de IA no Projeto Blaze:**
   - O projeto `<REDACTED_GCP_PROJECT_ID>` é reservado unicamente para computação serverless, banco de dados e hosting. Nenhuma credencial autorizada para `generativelanguage.googleapis.com` deve ser utilizada como chave de aplicação.

3. **Higienização e Padronização de Segredos sem BOM:**
   - Todos os segredos criados no Secret Manager passam a ser injetados em formato UTF-8 puro (`--data-file=-`), eliminando o byte BOM `\ufeff`. A Versão 5 do segredo `pwe-gemini-api-key` foi gerada segundo essa norma.

4. **Automação de Auditoria FinOps (`scripts/audit_finops.dart`):**
   - Criação de um validador automatizado executável em Dart com 5 verificações:
     1. Validação da chave no `.env` local contra assinaturas conhecidas.
     2. Verificação de `billingEnabled: false` no projeto `pwE-AiStudio`.
     3. Checagem de paridade e ausência de BOM no GCP Secret Manager.
     4. Detecção de tráfego indevido da API Gemini no projeto Blaze.
     5. Integridade do orçamento de alerta `pwE - Alerta Custo Zero` (R$ 5,00) no GCP Billing.

5. **Re-Release Obrigatório para as Lojas de Aplicativos:**
   - Como o binário de release anterior havia sido compilado com a chave legada injetada pelo GitHub Actions, estabelece-se a geração imediata de uma nova versão (`v0.9.92+118`) contendo a chave correta para distribuição na Google Play Store e Apple App Store.

## Consequências

### Positivas
- **Imunidade Financeira Absoluta:** O projeto `pwE-AiStudio` não possui faturamento ativado, garantindo que o consumo do Gemini API opere estritamente nas cotas gratuitas sem surpresas na fatura.
- **Rastreabilidade Imediata:** O script `audit_finops.dart` permite a qualquer desenvolvedor ou agente atestar a conformidade financeira em segundos antes de submeter código.
- **Prevenção de Falhas 402:** Usuários finais em release nunca mais serão afetados por bloqueios de faturamento em chamadas de IA.
- **Consistência de Segredos:** Segredos limpos sem BOM garantem interoperabilidade entre runtimes Dart, Python e scripts bash no Cloud Run.

### Negativas / Mitigações
- Necessidade de submissão de nova release para as lojas de aplicativos, mitigada pelo uso do pipeline automatizado `release-on-main.yml`.
