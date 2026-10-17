# Fluxo de Sessão — Lectio Divina (Experiência Imersiva Unificada)

Este diagrama de sequência detalha o ciclo de vida completo de uma prática de Lectio Divina na `ImmersiveReadingPage`, contemplando a resolução da Liturgia do Dia ou Passagem Livre, o editor de texto rico com Quill, a Provocação Socrática (*Magnifica Humanitas*), a denúncia de conteúdo de IA, o carrossel de frutos espirituais e a persistência criptografada em repouso (ADRs 0015, 0022, 0026, 0027 e 0029).

```mermaid
sequenceDiagram
    autonumber
    actor U as Fiel Católico
    participant Dash as DailyDashboardPage
    participant UI as ImmersiveReadingPage
    participant SBloc as LectioSessionBloc
    participant ExeBloc as ExegesisBloc
    participant GuiBloc as SpiritualGuidanceBloc
    participant UC as SaveSessionUseCase
    participant Sec as AesEncryptionServiceImpl
    participant HiveBox as EncryptedHiveBoxOpener (Hive Cifrado)
    participant Cloud as Cloud Firestore (Nuvem)

    Note over U,Dash: Entrada no Dashboard Litúrgico
    U->>Dash: Toca em Leitura ou Evangelho do Dia
    Dash->>SBloc: StartLiturgicalSessionEvent(readingRef, text, maturityLevel)
    Dash->>ExeBloc: RequestExegeseCentralEvent(text, ref)
    Dash->>ExeBloc: RequestContextDropsEvent(text, ref)
    Dash->>UI: context.push('/immersive')

    Note over U,UI: Etapa 1: Lectio (O que diz o texto sagrado em si?)
    UI->>U: Exibe texto bíblico sagrado (Lora, Drop Cap) com Exegese Central suave
    U->>UI: Toca em "Elevar para Meditatio"
    UI->>SBloc: AdvanceToStepEvent(1)

    Note over U,UI: Etapa 2: Meditatio (O que a Palavra diz para a minha vida?)
    UI->>U: Exibe QuillEditor (Lora) + FAB de Gotas de Sabedoria
    U->>UI: Redige reflexão pessoal íntima
    opt Consulta de Gotas de Contexto
        U->>UI: Abre gaveta de gotas
        UI->>ExeBloc: ToggleGotaExpandedEvent(gotaId)
        ExeBloc-->>UI: Exibe lente teológica/patrística selecionada
    end
    opt Provocação Socrática Espiritual
        U->>UI: Toca em "Provocação Socrática"
        UI->>GuiBloc: RequestSocraticReviewEvent(userReflection, passageText)
        GuiBloc-->>UI: Apresenta pergunta reflexiva paternal (3-4 linhas)
    end
    opt Sinalização de Conteúdo (ADR 0022)
        U->>UI: Toca em ReportAiContentButton
        UI->>GuiBloc: Registra reporte preventivo
    end
    U->>UI: Toca em "Elevar para Oratio"
    UI->>SBloc: AdvanceToStepEvent(2)

    Note over U,UI: Etapa 3: Oratio (O que eu digo a Deus a partir da Palavra?)
    UI->>U: Exibe Card Dourado com Inspiração de Oração (Salmos/Tradição) + Editor
    U->>UI: Redige sua prece sincera e íntima a Deus
    U->>UI: Toca em "Elevar para Contemplatio"
    UI->>SBloc: AdvanceToStepEvent(3)

    Note over U,UI: Etapa 4: Contemplatio (Que conversão o Senhor me pede hoje?)
    UI->>U: Exibe Carrossel de Frutos Espirituais (SpiritualFruitCarousel) + Campo de Resolução
    U->>UI: Seleciona fruto da graça e digita ação concreta do dia
    U->>UI: Pressiona e segura "Gravar no Meu Caderno Espiritual" (HoldToSaveButton, 1.5s)
    
    UI->>SBloc: CompleteSessionEvent(contemplatioAction, spiritualFruit)
    SBloc->>Sec: Criptografar notas e orações íntimas com AES-256-GCM
    Sec-->>SBloc: EncryptedPayload (Ciphertext + IV + AuthTag)
    SBloc->>UC: call(sessionEntity)
    UC->>HiveBox: Grava na caixa local Hive cifrada em repouso (ADR 0029)
    UC->>Cloud: Sincroniza documento em users/{uid}/sessions/{id}
    HiveBox-->>UC: Confirmação de persistência
    UC-->>SBloc: Either.Right(Success)
    SBloc-->>UI: LectioSessionSaved
    UI->>U: Feedback sacro com animação de vela, hápica serena e retorno ao Dashboard
```
