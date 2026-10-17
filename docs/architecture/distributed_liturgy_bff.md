# Arquitetura Distribuída — Daily Liturgy Worker (BFF & Static CDN)

Este diagrama ilustra o fluxo de dados do backend distribuído executado no **GCP (Cloud Run Job + Cloud Scheduler às 03:00 UTC / 00:00 BRT)**, que pré-processa as leituras da Igreja e disponibiliza o payload pronto no **GCS Static CDN** (`gs://<REDACTED_GCS_CDN_BUCKET>/liturgies/`) e no **Cloud Firestore** com custo operacional de R$ 0,00 (Free Tier perpétuo — ADR 0047).

---

## 1. Diagrama de Sequência do Pipeline Noturno

```mermaid
sequenceDiagram
    autonumber
    participant Cron as Cloud Scheduler (GCP, 03:00 UTC)
    participant Worker as Cloud Run Job (scripts/daily_liturgy_worker.dart)
    participant Web as Fonte Litúrgica Oficial (CNBB / LitCal v5 / Canção Nova)
    participant Gemini as Google AI Studio (Active Gemini Flash Model)
    participant GCS as GCS Static CDN (liturgies/{lang}/{date}.json)
    participant Firestore as Cloud Firestore (daily_liturgies)
    participant Flutter as Aplicativo pwE (Mobile & Web Client)

    Note over Cron,Firestore: Execução Noturna Automatizada (GCP Cloud Run Job; GitHub Actions apenas contingência manual)
    Cron->>Worker: Dispara execução agendada (03:00 UTC / 00:00 BRT)
    Worker->>Web: Requisita leituras oficiais (API CNBB / LitCal v5 / Fallback Canção Nova)
    Web-->>Worker: Retorna perícopes canônicas
    Worker->>Worker: Sanitização Canônica & Normalização de Versículos
    Worker->>Gemini: Solicita Exegese + 7 Gotas + Propostas de Oração + Ícone + Áudio TTS
    Gemini-->>Worker: Retorna Payload JSON Estruturado & Mídia
    Worker->>GCS: Publica JSON estático em liturgies/{lang}/{YYYY-MM-DD}.json (Cache-Control 7d)
    Worker->>Firestore: Grava documentos em daily_liturgies/{YYYY-MM-DD}_{lang} (buffer 7 dias)
    Worker-->>Cron: Pipeline Concluído com Sucesso
    
    Note over Flutter,Firestore: Pela manhã ao abrir o aplicativo:
    Flutter->>GCS: Consulta liturgies/{lang}/{YYYY-MM-DD}.json via GCS JSON API CORS-safe
    GCS-->>Flutter: Retorna Payload JSON Pronto (Zero leituras no Firestore)
    Flutter->>Flutter: Salva em Cache Local (Hive com TTL 7 dias) e exibe Dashboard
```

---

## 2. Resiliência e Estratégia de Fallback em 4 Níveis

```mermaid
graph TD
    App[App pwE - Abertura Matinal] --> CheckLocal{1. Cache Local Hive válido?}
    CheckLocal -->|Sim| UseLocal[Exibir Dashboard Imediatamente]
    CheckLocal -->|Não| FetchGCS[2. Buscar em GCS Static CDN: liturgies/{lang}/{date}.json]
    
    FetchGCS --> GCSFound{Encontrou no GCS CDN?}
    GCSFound -->|Sim| SaveLocalAndShow[Gravar no Hive & Exibir Dashboard]
    GCSFound -->|Não| FetchFirestore[3. Buscar em Cloud Firestore: daily_liturgies/{date}_{lang}]
    
    FetchFirestore --> FirestoreFound{Encontrou no Firestore?}
    FirestoreFound -->|Sim| SaveLocalAndShow
    FirestoreFound -->|Não| FallbackScraping[4. Fallback de Contingência: API CNBB / Web Scraping no Dispositivo]
    
    FallbackScraping --> GenerateOnFly[Gerar Exegese On-the-Fly via Gemini/Gemma]
    GenerateOnFly --> SaveLocalAndShow
```
