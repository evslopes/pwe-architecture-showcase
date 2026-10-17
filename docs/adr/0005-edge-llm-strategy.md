# ADR 0005: Estratégia de Inferência Local (Edge LLM)

## Status
**Aceita** — 17/04/2026

## Contexto
O aplicativo pwE processa dados espirituais íntimos (diários pessoais, meditações, orações) exclusivamente via APIs remotas (Gemini Cloud). A US-047 exige que o processamento ocorra preferencialmente no dispositivo do usuário, utilizando a nuvem apenas como fallback.

### Opções Avaliadas

| Opção | Pacote | Prós | Contras |
|---|---|---|---|
| A) `flutter_gemma` | flutter_gemma | API Flutter nativa | Relatos de instabilidade e crashes em produção |
| B) `mediapipe_genai` | mediapipe_genai | Google oficial, 498 downloads | Versão 0.0.1, API limitada |
| C) `ai_edge` | ai_edge | Wrapper MediaPipe GenAI | Publisher independente |
| D) MethodChannel nativo | Kotlin/LiteRT-LM | Controle total, estabilidade máxima | Mais boilerplate, manutenção manual |

## Decisão
**Opção D – MethodChannel nativo com LiteRT-LM (Kotlin/Android)** como abordagem primária, encapsulado pela interface `ILlmLocalDataSource` na camada Dart.

Para o MVP deste épico, a implementação concreta (`GemmaLocalDataSourceImpl`) será preparada como **skeleton** (esqueleto funcional) com a interface completa, mas a inferência real depende do download prévio do modelo `.task` no dispositivo. A execução real do modelo será habilitada quando:
1. O modelo Gemma estiver disponível no dispositivo
2. O Remote Config `enable_gemma_local` estiver `true`
3. O hardware atender aos requisitos mínimos (RAM ≥ 4GB)

### Padrão Arquitetural
```
┌──────────────┐
│  ILlmRepository  │ (Domain - Interface)
└──────┬───────┘
       │
┌──────┴───────┐
│ LlmRepositoryImpl │ (Data - Strategy Pattern)
├──────────────┤
│ try: localDS │──→ GemmaLocalDataSource (Edge)
│ catch: remoteDS │──→ GeminiRemoteDataSource (Cloud)
└──────────────┘
```

### Fluxo de Decisão
```
App Init → DeviceCapabilityService.isLocalLlmSupported()
         → RemoteConfig.getBool('enable_gemma_local')
         → Se ambos true: instancia GemmaLocalDataSource
         → Se não: localDataSource = null (sempre cloud)
```

## Consequências

### Positivas
- **Privacidade**: Dados íntimos do usuário nunca saem do dispositivo quando inferência local funciona
- **Offline-First**: App funciona sem internet para geração de conteúdo
- **Desacoplamento**: Interface `ILlmLocalDataSource` permite trocar a engine sem impactar domínio
- **Kill Switch**: Remote Config permite desabilitar o modelo local em caso de bug crítico

### Negativas
- **Tamanho do modelo**: ~500MB–2GB download adicional (epic futuro)
- **Thermal throttling**: Uso prolongado pode aquecer o dispositivo
- **Qualidade**: Modelo local menor pode gerar respostas inferiores ao Gemini Pro
- **Plataforma**: Suporte apenas Android no primeiro release

### Riscos Mitigados
- **OOM (Out of Memory)**: Triagem de hardware impede carregamento em dispositivos fracos
- **Crash silencioso**: Fallback automático para cloud garante continuidade do serviço
- **Regressão**: Feature flag (Remote Config) permite reverter rapidamente

## Referências
- US-047: Inferência Local com Roteamento de Fallback
- [LiteRT-LM Documentation](https://ai.google.dev/edge/litert)
- [MediaPipe GenAI Tasks](https://developers.google.com/mediapipe/solutions/genai/llm_inference)

---

## Nota de Atualização (04/10/2026 — ADR 0031)

O Edge LLM foi **implementado no Épico 8**: inferência on-device via LiteRT-LM com o modelo **Gemma 4 E2B** (arquivo `gemma_4_e2b.litertlm`, baixado sob demanda — `lib/core/services/model_download_service_io.dart`; URL/SHA-256/RAM mínima via Remote Config em `remote_config_service.dart`), exposto pelo `GemmaLocalDataSourceImpl`. A habilitação é controlada pela flag remota `enable_gemma_local` (padrão `false`) e indisponível na Web.
