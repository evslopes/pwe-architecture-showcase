# Máquinas de Estados do Sistema — pwE (Pray With Me)

Este documento mapeia visualmente e detalha as principais **Máquinas de Estados** do aplicativo pwE, implementadas com `flutter_bloc` e orquestradas por eventos reativos, rigorosamente alinhadas à base de código atual (`v0.9.113+141` / ADRs 0001–0050).

---

## 1. Máquinas de Estados do Domínio Lectio Divina (Sub-BLoCs Desacoplados)

Com a arquitetura desacoplada de Sub-BLoCs (ADR 0015 e ADR 0027), o ciclo orante é governado por máquinas de estados especializadas:

### 1.1 `LectioSessionBloc`: Ciclo de Vida da Sessão e Degraus Orantes

```mermaid
stateDiagram-v2
    [*] --> LectioSessionInitial: Injeção GetIt / App Start
    
    LectioSessionInitial --> LectioSessionInProgress: StartLiturgicalSessionEvent / StartFreePassageSessionEvent
    
    state LectioSessionInProgress {
        [*] --> Step0_Lectio: currentStep = 0
        Step0_Lectio --> Step1_Meditatio: AdvanceToStepEvent(1)
        Step1_Meditatio --> Step2_Oratio: AdvanceToStepEvent(2)
        Step2_Oratio --> Step3_Contemplatio: AdvanceToStepEvent(3)
        
        Step1_Meditatio --> Step1_Meditatio: SaveMeditatioEvent(notes)
        Step2_Oratio --> Step2_Oratio: SaveOratioEvent(notes)
        Step3_Contemplatio --> PersistingSession: CompleteSessionEvent / SaveSessionEvent
    }

    PersistingSession --> LectioSessionSaved: Cifrado com AES-256-GCM e Gravado no Hive
    PersistingSession --> LectioSessionError: Falha na Cifra / Persistência
    
    LectioSessionSaved --> LectioSessionInitial: Nova Sessão Iniciada
    LectioSessionError --> LectioSessionInProgress: Retry / Recuperação
```

### 1.2 `ExegesisBloc`: Exegese Central e Gotas de Sabedoria

```mermaid
stateDiagram-v2
    [*] --> ExegesisInitial
    
    ExegesisInitial --> ExegesisLoading: RequestExegeseCentralEvent / RequestContextDropsEvent
    ExegesisLoading --> ExegesisLoaded: Exegese e Gotas Prontas (com ou sem cache prévio)
    ExegesisLoading --> ExegesisError: Falha ao Obter Hermenêutica
    
    ExegesisLoaded --> ExegesisLoaded: ToggleGotaExpandedEvent(gotaId)
    ExegesisLoaded --> ExegesisInitial: ResetExegesisEvent (Mudança de Leitura/Idioma)
    ExegesisError --> ExegesisLoading: Retry
```

### 1.3 `PassageDiscoveryBloc`: Busca de Passagem e Inspiração

```mermaid
stateDiagram-v2
    [*] --> PassageDiscoveryInitial
    
    PassageDiscoveryInitial --> PassageDiscoveryLoading: FetchPassageTextEvent / SuggestPassageEvent
    PassageDiscoveryLoading --> PassageTextLoaded: Texto da Perícope Encontrado
    PassageDiscoveryLoading --> PassageDiscoveryLoaded: Passagem Sugerida por Intenção
    PassageDiscoveryLoading --> PassageDiscoveryError: Referência Bíblica Inválida / Fora do Cânon
    
    PassageDiscoveryLoaded --> PassageDiscoveryLoading: FetchPassageTextEvent
    PassageTextLoaded --> PassageDiscoveryInitial: SetPassageEvent / Reset
```

---

## 2. Máquina de Estados: `SubscriptionBloc`

Gerencia o ciclo de monetização sustentável e transparente do pwE via RevenueCat SDK, calculando a acolhida de 7 dias e governando o acesso aos recursos de Benfeitor.

```mermaid
stateDiagram-v2
    [*] --> SubscriptionInitial: App Start / Injeção GetIt
    
    SubscriptionInitial --> SubscriptionLoading: LoadSubscriptionStatusEvent
    SubscriptionLoading --> SubscriptionLoaded: CustomerInfo e Planos Carregados
    SubscriptionLoading --> SubscriptionError: Falha ao Conectar à Loja
    
    state SubscriptionLoaded {
        [*] --> FreeOrTrialActive: subscriptionStatus.isTrialActiveAt == true
        FreeOrTrialActive --> FreeExpired: 7 dias pós-instalação decorridos
        FreeOrTrialActive --> BenefactorActive: isBenefactor == true (Assinante Ativo)
        FreeExpired --> BenefactorActive: Assinatura Realizada
    }

    SubscriptionLoaded --> PurchaseInProgress: PurchaseSelectedPlanEvent(plan)
    PurchaseInProgress --> SubscriptionLoaded: Compra Concluída (Entitlement Atualizado)
    PurchaseInProgress --> SubscriptionLoaded: Compra Cancelada pelo Usuário
    PurchaseInProgress --> SubscriptionError: Falha no Billing

    SubscriptionLoaded --> RestoreInProgress: RestorePurchasesEvent
    RestoreInProgress --> SubscriptionLoaded: Recibos Restaurados com Sucesso
    RestoreInProgress --> SubscriptionError: Falha na Restauração
```

---

## 3. Máquina de Estados: `ModelDownloadBloc` (LiteRT Gemma On-Device)

Gerencia a verificação, download em segundo plano e validação de integridade por hash do modelo de Inteligência Artificial local compacto (LiteRT Gemma 4 E2B, arquivo `gemma_4_e2b.litertlm`).

```mermaid
stateDiagram-v2
    [*] --> ModelDownloadInitial: Inicialização da Feature Offline AI
    
    ModelDownloadInitial --> CheckingLocalModelStatus: CheckModelStatusEvent
    
    CheckingLocalModelStatus --> ModelReady: Arquivo Presente e SHA-256 Válido
    CheckingLocalModelStatus --> ModelNotDownloaded: Arquivo Inexistente no Storage
    CheckingLocalModelStatus --> ModelCorrupted: Arquivo Presente mas Hash Inválido

    ModelCorrupted --> ModelNotDownloaded: PurgeCorruptedFileEvent
    
    ModelNotDownloaded --> PreparingDownload: StartModelDownloadEvent
    PreparingDownload --> ModelDownloading: Conexão Estabelecida com Bucket
    
    state ModelDownloading {
        [*] --> ProgressStream
        ProgressStream --> ProgressStream: DownloadChunkReceived(bytes, total)
    }

    ModelDownloading --> ModelDownloadPaused: PauseModelDownloadEvent
    ModelDownloadPaused --> ModelDownloading: ResumeModelDownloadEvent
    ModelDownloading --> ModelDownloadCancelled: CancelModelDownloadEvent
    ModelDownloading --> ModelReady: Download Finalizado & Hash SHA-256 Aprovado
    ModelDownloading --> ModelDownloadError: Falha de Conexão / Espaço em Disco Insuficiente
    
    ModelReady --> ModelNotDownloaded: DeleteLocalModelEvent
```

---

## 4. Máquina de Estados: `VaultSecurityBloc` (Cofre com Senha Opcional — ADR 0026)

Governa o estado de segurança e derivação de chave mestra para o Caderno Espiritual na rota `/vault_security`.

```mermaid
stateDiagram-v2
    [*] --> VaultSecurityInitial
    
    VaultSecurityInitial --> VaultSecurityLoading: CheckVaultSecurityEvent
    VaultSecurityLoading --> VaultSecurityLoaded: Status Recuperado (VaultSecurityInfo)
    
    state VaultSecurityLoaded {
        [*] --> VaultUnlocked: info.isUnlocked == true
        VaultUnlocked --> VaultLocked: Bloqueio Manual / Timeout
        VaultLocked --> VaultUnlocked: UnlockVaultEvent(passphrase) com Sucesso
    }

    VaultSecurityLoaded --> VaultSecurityLoading: SetVaultPassphraseEvent / RemoveVaultPassphraseEvent
    VaultSecurityLoading --> VaultSecurityError: Senha Incorreta / Erro no Keystore
    VaultSecurityError --> VaultSecurityLoaded: Retorno ao Estado Seguro
```
