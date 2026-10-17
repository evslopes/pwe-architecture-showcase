# Diagramas de Sequência do Sistema — pwE (Pray With Me)

Este documento reúne os diagramas de sequência dos 5 fluxos operacionais mais críticos da arquitetura do aplicativo pwE, modelados em **Mermaid** e estritamente aderentes à base de código atual (`v0.9.113+141` / ADRs 0001–0050).

---

## 1. Ingestão e Pré-processamento Noturno da Liturgia Diária

Este fluxo ilustra o pipeline automatizado em nuvem que executa diariamente via **Cloud Scheduler e Cloud Run Job no Google Cloud Platform (GCP)** às 03:00 UTC (00:00 BRT) para popular a Liturgia no **GCS Static CDN** e no **Cloud Firestore** com antecedência para os fiéis.

```mermaid
sequenceDiagram
    autonumber
    actor Cron as Cloud Scheduler (GCP)
    participant Worker as Cloud Run Job (daily-liturgy-worker)
    participant CNBB as CNBB API / LitCal v5
    participant Fallback as Canção Nova Fallback (HTML Parser)
    participant AI as Gemini API (active_gemini_model)
    participant Security as TheologicalLinter & SHA-256
    participant GCS as GCS Static CDN (sacred-assets)
    participant Firestore as Cloud Firestore

    Note over Cron, Firestore: Execução Diária Automática no GCP (03:00 UTC / 00:00 BRT)
    Cron->>Worker: Executa job diário com buffer de 7 dias (D a D+7)
    
    rect rgb(240, 248, 255)
        Note over Worker, CNBB: Fase 1: Busca Oficial da CNBB & LitCal v5
        Worker->>CNBB: GET /cnbb-app/wp/v2/liturgy-day?slug={DD}-de-{mes}-de-{AAAA}
        alt CNBB API Responde 200 OK
            CNBB-->>Worker: JSON estruturado (cor litúrgica, leituras, salmo, evangelho)
        else Falha na CNBB (Timeout / 404 / 5xx)
            Worker->>Fallback: GET /liturgia-diaria (Canção Nova Fallback)
            Fallback-->>Worker: Payload estruturado via HtmlLiturgyParser
        end
    end

    rect rgb(255, 250, 240)
        Note over Worker: Fase 2: Sanitização & Normalização Canônica (LiturgySanitizer)
        Worker->>Worker: Limpar spans HTML e marcações espúrias
        Worker->>Worker: Fundir versículos soltos ao texto bíblico contíguo
        Worker->>Worker: Normalizar estrofes e refrão do Salmo Responsorial (— R.)
        Worker->>Worker: Validar Cânon Católico dos 73 livros
    end

    rect rgb(245, 255, 250)
        Note over Worker, AI: Fase 3: Enriquecimento Espiritual com IA (RN-GOT-030)
        Worker->>AI: Solicitar 7 Gotas de Sabedoria para a Liturgia Completa<br/>(Histórica, Social, Filológica, Patrística, Magistério, Teológica, Ascética)
        AI-->>Worker: 7 Gotas estruturadas (sem jargões técnicos)
        Worker->>AI: Solicitar 3 Gotas de Sabedoria por Leitura Individual<br/>(Histórica, Teológica, Ascética)
        AI-->>Worker: 3 Gotas por leitura estruturadas
        Worker->>AI: Gerar Âncora Exegética, Ícone Sacro e Áudio TTS (gospelAudioUrl)
        AI-->>Worker: Textos contemplativos e mídia validados
    end

    rect rgb(255, 245, 245)
        Note over Worker, Firestore: Fase 4: Assinatura Digital, Langfuse Scores e Persistência Dual (ADR 0046/0047)
        Worker->>Security: Validar pureza teológica e calcular Hash SHA-256
        Security-->>Worker: signature: "sha256:abc123..." + Langfuse Quality Scores
        Worker->>GCS: PUT liturgies/{lang}/{YYYY-MM-DD}.json (Cache-Control 7d)
        GCS-->>Worker: 200 OK (Static CDN Ready)
        Worker->>Firestore: Upsert documento em /daily_liturgies/{YYYY-MM-DD}_{lang}
        Firestore-->>Worker: 200 OK (Write Acknowledged)
    end

    Worker-->>Cron: Status: 0 (Sucesso do Job)
```

---

## 2. Jornada Imersiva da Lectio Divina (4 Degraus Desacoplados)

Demonstra o ciclo imersivo do orante no app pwE através dos Sub-BLoCs especializados da feature `lectio_divina` (ADR 0015 e ADR 0027), transitando pelas etapas da *Lectio*, *Meditatio*, *Oratio* e *Contemplatio*.

```mermaid
sequenceDiagram
    autonumber
    actor User as Orante (Fiel Católico)
    participant Dashboard as DailyDashboardPage
    participant Immersive as ImmersiveReadingPage
    participant SessionBloc as LectioSessionBloc
    participant ExegesisBloc as ExegesisBloc
    participant GuidanceBloc as SpiritualGuidanceBloc
    participant Crypto as AesEncryptionServiceImpl
    participant LocalDB as EncryptedHiveBoxOpener (Hive AES-GCM)

    User->>Dashboard: Toca em Leitura da Liturgia ou "Iniciar Leitura Orante"
    Dashboard->>SessionBloc: StartLiturgicalSessionEvent(readingRef, text, maturityLevel)
    Dashboard->>ExegesisBloc: RequestExegeseCentralEvent(text, ref)
    Dashboard->>ExegesisBloc: RequestContextDropsEvent(text, ref)
    Dashboard->>Immersive: context.push('/immersive')
    
    Note over User, Immersive: ETAPA 1: LECTIO (Leitura Sagrada)
    Immersive->>User: Exibe texto sagrado (Lora, Drop Cap) e Exegese Central suave
    User->>Immersive: Toca em "Elevar para Meditatio"
    Immersive->>SessionBloc: AdvanceToStepEvent(1)
    
    Note over User, Immersive: ETAPA 2: MEDITATIO (Ruminação Espiritual)
    User->>Immersive: Consulta Gotas de Sabedoria (FAB GotasBottomSheet)
    Immersive->>ExegesisBloc: ToggleGotaExpandedEvent(gotaId)
    User->>Immersive: Digita reflexão íntima no editor rico (QuillEditor)
    User->>Immersive: Toca em "Provocação Socrática"
    Immersive->>GuidanceBloc: RequestSocraticReviewEvent(userReflection, passageText)
    GuidanceBloc-->>Immersive: Pergunta socrática paternal (3-4 linhas)
    opt Denúncia de Conteúdo de IA (Google Play / ADR 0022)
        User->>Immersive: Toca em ReportAiContentButton
        Immersive->>GuidanceBloc: Envia relatório de contestação teológica
    end
    User->>Immersive: Toca em "Elevar para Oratio"
    Immersive->>SessionBloc: AdvanceToStepEvent(2)
    
    Note over User, Immersive: ETAPA 3: ORATIO (Diálogo com Deus)
    Immersive->>User: Exibe card de oração filial inspirada nos Salmos e Tradição
    User->>Immersive: Redige sua prece íntima a Deus
    User->>Immersive: Toca em "Elevar para Contemplatio"
    Immersive->>SessionBloc: AdvanceToStepEvent(3)

    Note over User, Immersive: ETAPA 4: CONTEMPLATIO (Silêncio, Frutos e Compromisso)
    User->>Immersive: Seleciona Fruto Espiritual (SpiritualFruitCarousel)
    User->>Immersive: Registra compromisso prático de vida cristã
    User->>Immersive: Pressiona e segura "Gravar no Meu Caderno Espiritual" (Hold-to-Save, 1.5s)
    
    Immersive->>SessionBloc: CompleteSessionEvent(contemplatioAction, spiritualFruit)
    SessionBloc->>Crypto: encrypt(sessionJsonPayload)
    Crypto-->>SessionBloc: EncryptedPayload(ciphertext, iv, authTag)
    SessionBloc->>LocalDB: Grava sessão na caixa Hive criptografada em repouso (ADR 0029)
    LocalDB-->>SessionBloc: Sucesso
    SessionBloc-->>Immersive: LectioSessionSaved
    Immersive-->>User: Feedback sereno de paz e conclusão orante
```

---

## 3. Passagem Livre e OCR Bíblico via Google ML Kit

Fluxo do usuário que acessa a rota `/lectio` (`LectioPage`) para rezar com sua Bíblia física ou qualquer trecho livre do Cânon Católico dos 73 livros.

```mermaid
sequenceDiagram
    autonumber
    actor User as Orante
    participant UI as LectioPage (/lectio)
    participant Discovery as PassageDiscoveryBloc
    participant MLKit as Google ML Kit (On-Device OCR)
    participant Normalizer as NormalizeOcrTextUseCase & DataNormalizer
    participant Quota as ConsumeOcrQuotaUseCase
    participant Exegesis as ExegesisBloc
    participant Immersive as ImmersiveReadingPage

    alt Aba 1: Digitar ou Colar
        User->>UI: Informa referência (ex: "Jo 3, 16")
        UI->>Discovery: FetchPassageTextEvent(reference)
        Discovery-->>UI: Texto bíblico carregado
    else Aba 2: Inspiração por Intenção Espiritual
        User->>UI: Seleciona intenção (ex: "Paz na Tribulação")
        UI->>Discovery: SuggestPassageEvent(intention)
        Discovery-->>UI: Referência e motivo pastoral sugeridos
    else Aba 3: Escanear Bíblia Física (OCR)
        User->>UI: Captura foto da página da Bíblia
        UI->>MLKit: processImage(InputImage.fromFilePath)
        MLKit-->>UI: Texto bruto reconhecido on-device
        UI->>Quota: execute() (Valida cota mensal de 3 OCRs no Free Tier)
        Quota-->>UI: Cota consumida / Benfeitor ilimitado
        UI->>Normalizer: normalize(rawOcrText)
        Normalizer-->>UI: Texto bíblico higienizado (sem cabeçalhos e hifens soltos)
    end

    User->>UI: Confirma texto e toca em "Iniciar Lectio Divina" (_submitLectio)
    UI->>Discovery: SetPassageEvent(reference, text)
    UI->>Exegesis: RequestExegeseCentralEvent(text, reference)
    UI->>Exegesis: RequestContextDropsEvent(text, reference)
    UI->>Immersive: context.push('/immersive')
```

---

## 4. Orquestração Híbrida de IA: Consentimento em Nuvem vs On-Device (LiteRT)

Demonstra o controle ético de privacidade estabelecido pela **ADR 0025** (Consentimento Explícito para IA em Nuvem) e os mecanismos de execução entre a nuvem (Gemini) e a borda local (LiteRT Gemma 4 E2B).

```mermaid
sequenceDiagram
    autonumber
    actor User as Orante
    participant Router as GoRouter & resolveAuthRedirect
    participant ConsentUI as AiSelectionPage (/ai_selection)
    participant ConsentSvc as ICloudAiConsentService
    participant LLMRepo as LlmRepositoryImpl
    participant ConsentDS as ConsentGuardedLlmRemoteDataSource
    participant GeminiCloud as Google Gemini (Cloud API)
    participant EdgeModel as LiteRT Gemma Engine (Local On-Device)
    participant Fallback as StaticPatristicFallback

    Note over Router, ConsentSvc: Verificação Inicial de Consentimento (Cold Start / Auth)
    Router->>ConsentSvc: hasDecided
    alt Ainda não decidiu sobre uso de IA
        ConsentSvc-->>Router: false (needsAiChoice = true)
        Router->>ConsentUI: Redireciona para /ai_selection
        User->>ConsentUI: Escolhe modo de IA desejado
        alt Usuário escolhe IA em Nuvem
            ConsentUI->>ConsentSvc: grant() (Grava consentimento explícito)
        else Usuário escolhe IA Local ou Sem IA
            ConsentUI->>ConsentSvc: revoke()
        end
    end

    Note over LLMRepo, Fallback: Execução da Meditação ou Exegese
    LLMRepo->>ConsentSvc: isGranted
    alt Consentimento em Nuvem Válido
        LLMRepo->>ConsentDS: generateContentStream(prompt)
        ConsentDS->>GeminiCloud: Streaming de tokens com isolamento teológico
        GeminiCloud-->>LLMRepo: Resposta concluída
    else Consentimento Revogado ou Dispositivo Offline
        alt Modelo LiteRT Gemma Instalado Localmente
            LLMRepo->>EdgeModel: runInference(prompt)
            EdgeModel-->>LLMRepo: Resultado gerado 100% on-device
        else Sem Modelo Local Baixado
            LLMRepo->>Fallback: getOfflinePatristicTemplate(tempoLiturgico)
            Fallback-->>LLMRepo: Meditação curada dos Santos Padres
        end
    end
```

---

## 5. Ciclo de Monetização, Acolhida e Benefactor via RevenueCat

Ilustra o ciclo de vida de acesso governado pelo `SubscriptionBloc` e pelo RevenueCat SDK, garantindo transparência fraterna e gratuidade perpétua da Liturgia Diária.

```mermaid
sequenceDiagram
    autonumber
    actor User as Orante
    participant Dashboard as DailyDashboardPage
    participant Paywall as BenefactorPage (/benefactor)
    participant SubBloc as SubscriptionBloc
    participant LocalDS as SubscriptionLocalDataSourceImpl
    participant RC as Purchases (RevenueCat SDK)
    participant Store as Google Play Billing / App Store

    Note over Dashboard, LocalDS: Avaliação de Acolhida de 7 Dias (RN-SUB-111)
    Dashboard->>SubBloc: LoadSubscriptionStatusEvent()
    SubBloc->>LocalDS: isTrialActiveAt(firstInstalledAt)
    alt Primeiros 7 Dias de Instalação (Trial Local Ativo)
        LocalDS-->>SubBloc: isTrialActive = true
        SubBloc-->>Dashboard: SubscriptionStatus (Liturgia Completa & Passagem Livre Liberadas)
    else Pós-7 Dias (Usuário Gratuito)
        LocalDS-->>SubBloc: isTrialActive = false
        SubBloc-->>Dashboard: SubscriptionStatus (Liturgia Completa Interceptada)
    end

    opt Usuário Tenta Acessar Recurso Exclusivo do Benfeitor
        User->>Dashboard: Toca no CTA "Liturgia Completa"
        Dashboard->>Dashboard: Intercepta: _showCompleteLiturgyBenefactorDialog
        User->>Dashboard: Toca em "Conhecer Benfeitores"
        Dashboard->>Paywall: context.push('/benefactor')
    end

    User->>Paywall: Seleciona Plano (Anual / Mensal)
    Paywall->>SubBloc: PurchaseSelectedPlanEvent(plan)
    SubBloc->>RC: purchasePackage(package)
    RC->>Store: Inicia fluxo nativo de pagamento da loja
    Store->>User: Confirmação de compra
    Store-->>RC: Recibo assinado
    RC-->>SubBloc: CustomerInfo (entitlements["benefactor"].isActive: true)
    SubBloc-->>Paywall: SubscriptionPurchasedSuccess
    Paywall-->>User: Mensagem fraterna de acolhimento e liberação total
```
