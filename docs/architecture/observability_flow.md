# Fluxo de Observabilidade & Princípio Zero-Knowledge

Este diagrama detalha a arquitetura de observabilidade em dupla camada adotada no pwE e demonstra como o filtro de privacidade **Zero-Knowledge** assegura que nenhum dado espiritual íntimo trafegue para servidores analíticos de terceiros.

---

## 1. Arquitetura de Observabilidade em Dupla Camada

```mermaid
graph TD
    subgraph Client_App [Aplicativo pwE Mobile]
        Bloc[LectioSessionBloc / DailyDashboardPage / ImmersiveReadingPage]
        DevConsole[dart:developer Log]
        AnalyticsSvc[AnalyticsService]
    end

    subgraph Privacy_Shield [Filtro Zero-Knowledge / LGPD Shield]
        direction TB
        Sanitizer[Sanitização Estrita de Parâmetros]
        BlockIntimate[❌ Bloqueia: Textos Bíblicos, Orações, Notas Íntimas]
        AllowMetrics[✅ Permite: Step, Duração, Flag de BFF, Nível de Maturidade]
    end

    subgraph External_Analytics [Serviços Externos de Produção]
        GA4[Google Analytics 4]
        Crashlytics[Firebase Crashlytics]
    end

    Bloc -->|Emite marcos de jornada| DevConsole
    Bloc -->|Envia eventos de ciclo de vida| AnalyticsSvc
    AnalyticsSvc --> Sanitizer
    Sanitizer --> BlockIntimate
    Sanitizer --> AllowMetrics
    AllowMetrics -->|Eventos tipados: lectio_started, etc.| GA4
    AllowMetrics -->|Breadcrumbs de execução & Custom Keys| Crashlytics
```

---

## 2. Tabela de Mapeamento de Eventos e Parâmetros

| Evento | Camada de Console (`[LectioJourney]`) | Google Analytics 4 | Firebase Crashlytics |
| :--- | :--- | :--- | :--- |
| **Início da Leitura** | `✠ Iniciando Lectio: "{passage}"` | `lectio_started` (`reading_type`, `maturity_level`, `is_from_bff`) | Breadcrumb + Key `reading_type` |
| **Avanço de Etapa** | `📖 ➔ 🕊️ Transição para MEDITATIO` | `lectio_step_advanced` (`step_name`, `maturity_level`) | Breadcrumb de navegação |
| **Gotas de Contexto** | `💡 Abrindo gota de exegese` | `lectio_gota_opened` (`category`) | Breadcrumb |
| **Conclusão da Oração**| `💾 Persistindo sessão (Duração: {S}s)` | `lectio_completed` (`duration_seconds`, `has_notes`) | Key `duration_seconds` |
| **Erros e Falhas** | `❌ Falha na etapa {step}: {error}` | `error_occurred` (`error_type`) | `recordError(...)` com StackTrace |
