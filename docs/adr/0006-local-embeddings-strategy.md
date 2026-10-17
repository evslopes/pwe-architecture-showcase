# ADR 0006: Estratégia de Embeddings Locais (Épico 9)

*   **Status:** Proposto
*   **Data:** 2026-04-18
*   **Decisor:** Agente de IA / Engenheiro Principal
*   **Assunto:** Geração de vetores (embeddings) on-device para RAG 100% privado.

## Contexto e Problema

O Épico 7 (RAG) introduziu a memória de longo prazo no pwE, mas depende de chamadas à API do Gemini para converter o texto das sessões em vetores de busca. Embora o processamento nativo do Gemma 4 (Épico 8) proteja a geração de texto, a indexação de novas sessões ainda "vaza" conteúdo para a nuvem através dos embeddings.

Para atingir a **Privacidade Absoluta**, precisamos que o pipeline de busca vetorial seja também 100% local.

## Opções Consideradas

1.  **Google ML Kit Entity Extraction / Smart Reply**: Modelos leves pré-treinados, mas com vetores de baixa dimensionalidade ou sem acesso direto aos embeddings.
2.  **LiteRT (TFLite) com modelos BERT/MobileBERT**: Oferece controle total sobre o vetor (768d no BERT-base ou 384d no Small), mas exige integração nativa manual para o pré-processamento de tokens.
3.  **HuggingFace Transformers (Dart/Flutter packages)**: pacotes como `fast_sentence_transformers` podem ser pesados (50MB+ de runtime adicional).

## Decisão Proposta

Adotar **LiteRT com modelo MobileBERT (quantizado)** para geração de embeddings locais.

### Justificativa

*   **Privacidade**: O texto nunca deixa o dispositivo durante a indexação ou busca.
*   **Desempenho**: MobileBERT é otimizado para CPU de smartphones e gera vetores comparáveis em qualidade aos modelos base de nuvem para textos curtos de oração.
*   **Consistência**: Mantém a stack técnica (LiteRT/MethodChannel) já estabelecida no Épico 8.

## Consequências

### Positivas
*   **Offline First**: A busca semântica em sessões passadas funcionará em modo avião.
*   **Custo Zero**: Removemos dependência de cotas de API de embedding.
*   **Privacidade Máxima**: O pwE se torna um "Vault" espiritual impenetrável.

### Negativas
*   **Tamanho do App**: Acréscimo de aproximadamente 25MB-40MB no APK/IPA para o modelo de embedding.
*   **Complexidade de Migração**: As sessões antigas (indexadas via Gemini) precisarão ser re-indexadas localmente se os vetores não forem compatíveis.

## Implementação (Alta-Nível)

1.  **Interface de Embedding**: `IEmbeddingService`.
2.  **Implementação Local**: `OnDeviceEmbeddingService` (Sprint 9.2).
3.  **Fallback**: Manter `GeminiEmbeddingService` como fallback ou para dispositivos ultra-low-end que não suportam o modelo de embedding.
