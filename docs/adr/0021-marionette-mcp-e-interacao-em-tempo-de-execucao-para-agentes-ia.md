# ADR 0021 — Integração do Marionette MCP e Interação em Tempo de Execução para Agentes de IA

**Data:** 02 de Outubro de 2026  
**Status:** 🟢 Aceito e Homologado  
**Autores:** Arquiteto de Software Principal, Especialista `qa`, Especialista `engineer`, Especialista `flutter-ui`, Especialista `debugger`  

---

## 1. Contexto & Problema

Com o avanço do desenvolvimento assistido por agentes autônomos e semi-autônomos (Antigravity e Gemini), a equipe de engenharia do **pwE (Pray With Me)** necessitava de uma maneira ágil para os agentes validarem modificações de interface e regras de apresentação sem depender unicamente de:
1. **Compilação de testes de widgets estáticos:** Embora rápidos, testes unitários de widgets isolados não exercitam a pilha de navegação completa, animações contínuas e interações reais do `GoRouter` e `Dart VM Service`.
2. **Ciclos lentos de CI/Cloud Test Lab:** O *Firebase App Testing Agent* (ADR 0016) é excelente para validações E2E pré-release na nuvem, mas possui latência de minutos e consome cotas diárias de execução, sendo inviável para o loop interativo segundo a segundo de programação.
3. **Falta de "Olhos e Mãos" Locais:** Os agentes de IA necessitavam de capacidades para inspecionar a árvore viva de widgets, verificar overflow de layout (`RenderFlex`), tocar em elementos semânticos e capturar screenshots da tela do app em tempo real.

---

## 2. Decisão Arquitetural

Decidiu-se pela adoção oficial do **`marionette_mcp`** (desenvolvido pela LeanCode) integrado ao ecossistema do pwE sob o Model Context Protocol (MCP):

### A. Instrumentação Segura no Aplicativo (`marionette_flutter`)
- O pacote `marionette_flutter` foi adicionado em [pubspec.yaml](../../pubspec.yaml).
- No ponto de entrada `lib/main.dart`, a inicialização do binding é blindada estritamente contra vazamento em produção:
  ```dart
  void main() async {
    if (kDebugMode) {
      MarionetteBinding.ensureInitialized();
    } else {
      WidgetsFlutterBinding.ensureInitialized();
    }
    // ...
  }
  ```
  Isso garante que em compilações de release (App Store e Google Play) o runtime padrão `WidgetsFlutterBinding` seja utilizado sem qualquer sobrecarga de depuração.

### B. Servidor MCP no Antigravity IDE
- O servidor MCP é ativado via `dart pub global activate marionette_mcp`.
- Configurado via transporte `stdio` em `.agents/mcp_config.json` e globalmente em `~/.gemini/config/mcp_config.json`:
  ```json
  "marionette": {
    "command": "dart",
    "args": [
      "pub",
      "global",
      "run",
      "marionette_mcp"
    ]
  }
  ```

### C. Sinergia com Acessibilidade Semântica (ADR 0016)
- Os agentes de IA utilizam os identificadores semânticos padronizados no ADR 0016 (`Semantics(identifier: '...', button: true, label: ...)`) para localizar e acionar elementos da interface sem depender de seletores frágeis de texto ou coordenadas cartesianas.

---

## 3. Consequências

### Positivas
- **Ciclo de Feedback em Segundos:** O agente pode verificar a renderização de um novo widget ou tela diretamente na sessão ativa do aplicativo (`flutter run -d windows` ou emulador).
- **Detecção Imediata de Overflows:** Captura de telas e inspeção da árvore permitem identificar `RenderFlex overflow` em tempo de execução com variações de `TextScaler`.
- **Zero Custo de Nuvem:** Toda a comunicação opera localmente via socket do Dart VM Service.
- **Isolamento Sagrado:** Preserva integralmente o princípio de que o usuário final nunca é exposto a lógicas ou terminologias de depuração e IA.

### Mitigações
- **Uso estrito de `kDebugMode`:** Previne que hooks de automação sejam compilados em artefatos de homologação externa ou produção.
