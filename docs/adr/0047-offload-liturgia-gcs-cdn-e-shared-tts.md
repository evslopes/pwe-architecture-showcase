# ADR 0047: Offload da Liturgia Diária via GCS Static CDN, Shared Audio TTS e Tópicos Litúrgicos FCM

- **Status:** Aceito
- **Data:** 16 de Outubro de 2026
- **Decisores:** Arquiteto de Software Principal, Agentes `finops`, `data-engineer`, `liturgical-scheduler`

## Contexto e Problema

O limite gratuito do Cloud Firestore é de **50.000 leituras de documentos por dia**. Como todos os fiéis abrem o aplicativo diariamente buscando o mesmo documento imutável da Liturgia Diária (`daily_liturgies/{date}_{lang}`), o crescimento orgânico da base de usuários consumiria rapidamente a cota diária do Firestore.

## Decisão

1. **Publicação Estática no GCS (`scripts/daily_liturgy_worker.dart`):** Além de gravar no Firestore, o worker diário publica o JSON da liturgia como objeto estático no bucket `gs://<REDACTED_GCS_CDN_BUCKET>/liturgies/{lang}/{date}.json` com cabeçalho `Cache-Control: public, max-age=86400`.
2. **Estratégia CDN-First (`DailyLiturgyRemoteDataSourceImpl`):** O aplicativo tenta primeiro baixar a liturgia via endpoint público JSON API CORS-safe do GCS (`enableStaticCdn: true`), recorrendo ao Cloud Firestore e ao scraper/IA somente como fallbacks.
3. **Áudio Sacro Pré-Computado (`gospelAudioUrl` & `TtsService`):** Suporte ao campo opcional `gospelAudioUrl` em `DailyLiturgy`/`DailyLiturgyModel` e parâmetro `precomputedAudioUrl` em `TtsService.speak()` para priorizar áudio compartilhado no CDN antes de acionar o sintetizador local do sistema operacional.
4. **Broadcast Litúrgico via FCM (`PushNotificationService.syncLiturgicalLanguageTopic`):** Inscrição automática no tópico `liturgy_{lang}` e disparo pelo worker diário em Solenidades e tempos fortes.

## Consequências

- **Positivas:** Redução próxima a 100% nas leituras diárias do Cloud Firestore para a Liturgia Diária, mantendo o projeto perpetuamente no Free Tier mesmo com dezenas de milhares de fiéis ativos.
- **Negativas / Trade-offs:** Latência de fallback de até 5 segundos apenas no caso improvável de indisponibilidade simultânea do Google Cloud Storage antes de acionar o Firestore.
