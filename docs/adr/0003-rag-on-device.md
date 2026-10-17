# ADR 0003 — Implementação de RAG On-Device (Embeddings Locais)

## Status
Aceito (Abril de 2026)

## Contexto
O aplicativo **pwE (Pray With Me)** necessita de um sistema de memória de longo prazo para as sessões de Lectio Divina. O objetivo é permitir que a IA recupere contextos de orações passadas (RAG - Retrieval-Augmented Generation) para oferecer um acompanhamento espiritual contínuo.

### Desafios:
- **Custos de API**: Gerar embeddings em nuvem para cada interação de cada usuário tornaria o projeto financeiramente insustentável no modelo Lean.
- **Privacidade**: O conteúdo das orações e sentimentos é extremamente sensível e pessoal. Minimizar o envio de dados para servidores externos é uma prioridade ética.
- **Latência**: Depender de uma chamada de rede adicional para a busca semântica poderia degradar a experiência de imersão/contemplação.

## Decisão
Implementar a etapa de geração de embeddings **diretamente no dispositivo** (On-Device) utilizando **TFLite** e modelos BERT otimizados (*quantized*), em vez de utilizar APIs de nuvem (como Gemini/OpenAI Embedding).

## Racional
- **Custo Zero**: Uma vez que o modelo está no dispositivo, o custo marginal de gerar um embedding é zero.
- **Privacidade por Design**: O processamento do texto para vetor acontece localmente. Apenas o prompt final enriquecido (contexto + input) é enviado ao LLM.
- **Performance**: A inferência local de modelos MiniLM (BERT) leva entre 100ms a 400ms em hardware moderno, sendo mais rápida que um round-trip de rede para APIs de embedding.
- **Independência de Rede**: A busca vetorial básica pode funcionar offline (embora a geração final da IA ainda dependa de conexão).

## Especificações Técnicas
1. **Modelo**: `all-MiniLM-L6-v2` (BERT Base Uncased).
2. **Framework**: `tflite_flutter` para execução do grafo.
3. **Dimensões**: 384 dimensões (balanço ideal entre precisão semântica e tamanho de storage).
4. **Armazenamento Vetorial**: Firestore (Vector Field) para sincronização multi-dispositivo, com cache local.

## Consequências
- **Aumento do Binário (APK/IPA)**: Adição de ~25MB ao tamanho do aplicativo devido ao modelo BERT e bibliotecas nativas do TFLite.
- **Consumo de Bateria/CPU**: Pequeno pico de processamento durante a fase de Input, aceitável dada a frequência de uso da Lectio Divina.
- **Complexidade de Engenharia**: Exige implementação manual de tokenizadores (*WordPiece*) e pós-processamento (*Mean Pooling* e *L2 Normalization*).

## Links
- Épico: #53
- Feature: `rag_contextual_memory.md`
- Documentação TFLite: [tflite_flutter](https://pub.dev/packages/tflite_flutter)
