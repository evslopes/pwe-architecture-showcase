# ADR 0038 — Otimização FinOps dos Workflows de CI/CD e Eficiência de Cotas do GitHub Actions

**Data:** 07 de Outubro de 2026  
**Status:** 🟢 Aceito  
**Autores:** Especialistas em FinOps & DevOps pwE  

---

## 1. Contexto

Durante auditoria de custos e governança financeira (FinOps), foi identificada uma queima acelerada da cota mensal de minutos de computação do **GitHub Actions**:
- O ciclo mensal consumiu **1.241 minutos de 3.000 minutos (41,37%)** em apenas 5 a 6 dias de ciclo, restando 25 dias para o encerramento da fatura.
- **95,8%** de todo o consumo da conta (\$7,30 de \$7,62) concentrava-se no repositório `pwE`.
- No ritmo vigente de ~180 a 200 minutos faturáveis/dia, a franquia gratuita esgotaria completamente antes da metade do ciclo mensal, interrompendo esteiras e publicações.

A investigação de causa-raiz apontou as seguintes ineficiências técnicas e de fluxo:
1. **Falso-positivo de Build Android Nativo no CI:** O filtro `paths-filter` no `ci.yml` incluía `pubspec.yaml`. Como todo fechamento de tarefa pelo `task-finisher` exige bump monotônico de versão no `pubspec.yaml`, 100% dos pushes para `develop` (46 nos primeiros 7 dias) disparavam compilação nativa Android.
2. **Falha Silenciosa de Permissão no Google Cloud Build:** A chamada ao Cloud Build falhava por falta de especificação do diretório de staging no Cloud Storage (`--gcs-source-staging-dir`), caindo no fallback local e consumindo ~7 minutos adicionais de runner do GitHub por execução.
3. **Instalação Desnecessária de Java e Gradle em Jobs de Dart Puro:** Os jobs `analyze` e `test` executavam a action `setup-flutter-env`, que instalava o JDK 17 (Temurin) e inicializava o Gradle para tarefas que rodam estritamente na VM do Dart.
4. **Execução de Testes Extensa e Single-Thread:** A suíte de 193 arquivos de teste era executada com `--reporter expanded` e sem concorrência paralela (`--concurrency`), levando quase 14 minutos por execução de CI.
5. **Risco Latente do Runner macOS no iOS Simulator:** O workflow `ios-simulator-appetize.yml` executava com `runs-on: macos-latest` em qualquer PR alterando `lib/**`, consumindo cota com multiplicador de 10x por minuto de runner.

---

## 2. Decisão

1. **Desacoplamento do Build Android do CI Diário:**
   - Removido `pubspec.yaml` e `pubspec.lock` do filtro de caminhos `android` em `ci.yml`. O build nativo no CI agora é restrito a alterações reais em `android/**` ou disparo manual (`workflow_dispatch`).
2. **Modularização de Dependências em `setup-flutter-env`:**
   - Adicionado o input `setup-java` (default `true`) na composite action `.github/actions/setup-flutter-env/action.yml`.
   - Nos jobs `analyze` e `test`, o parâmetro é passado como `'false'`, eliminando o download e configuração desnecessários de Java e Gradle para ferramentas puramente Dart/Flutter.
3. **Aceleração e Concorrência na Suíte de Testes:**
   - Adicionada a flag `--concurrency=4` e substituído `--reporter expanded` por `--reporter compact` no `flutter test` do `ci.yml` e do `release-on-main.yml`, reduzindo I/O e aproveitando os múltiplos núcleos do runner.
4. **Blindagem Contra Consumo Excessivo de macOS (10x):**
   - No workflow `ios-simulator-appetize.yml`, o gatilho automático cego foi substituído por disparo estritamente sob demanda via label de PR (`preview-ios`) ou manual (`workflow_dispatch`). Desativada a instalação de Java/Gradle também neste fluxo.
5. **Correção de Staging no Google Cloud Build:**
   - Adicionada a flag `--gcs-source-staging-dir="gs://${{ vars.GCP_ARTIFACTS_BUCKET || '<REDACTED_GCP_PROJECT_ID>-ci-artifacts' }}/source"` na submissão de builds no GCP para evitar bloqueios no bucket padrão.

---

## 3. Consequências

- **Positivas:**
  - Redução estimada de **até 75%** no consumo diário de minutos de GitHub Actions (~1.800 a 2.200 minutos economizados por mês).
  - Eliminação de ~7 a 8 minutos de tempo de relógio por commit no branch `develop`.
  - Blindagem absoluta contra drenagem inadvertida de cotas por runners macOS (multiplicador 10x).
  - Preservação da sustentabilidade financeira perpétua do projeto sem custos de CI/CD.
- **Mitigações Operacionais:**
  - Desenvolvedores que precisarem testar o preview interativo iOS no Appetize devem aplicar a label `preview-ios` no Pull Request correspondente.
