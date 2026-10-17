# ADR 0011: Modernização da Passagem Livre, OCR Guiado e Paridade com a Leitura Litúrgica

## Status
**Aceito** (2026-09-01)

## Contexto
O aplicativo pwE evoluiu significativamente com a introdução do fluxo unificado e imersivo de 4 etapas (`Lectio`, `Meditatio`, `Oratio`, `Contemplatio`), exegese central revelada progressivamente, gotas de contexto, provocação socrática e orientações práticas de vida. Contudo, a tela de **Passagem Livre** (`LectioPage`) havia permanecido defasada, utilizando um formulário estático simples que não oferecia inspiração temática, flexibilidade de imagens para OCR (apenas câmera) nem paridade imediata com a riqueza contemplativa da Liturgia Diária.

## Decisão Arquitetural

1. **Estrutura por Abas Contemplativas (`TabBar`):**
   - **Aba 0 (Digitar / Colar):** Campo de referência com busca assistida de passagens por IA (`FetchPassageTextEvent`) e editor bíblico estilizado com tipografia *Lora*.
   - **Aba 1 (Inspiração por Intenção):** Grade de intenções espirituais católicas (*Paz na Tribulação*, *Ação de Graças & Louvor*, *Discernimento & Direção*, *Cura Interior & Consolo*, *Perdão & Reconciliação*, *Esperança & Confiança*) que dispara `SuggestPassageEvent(intention)` para sugestão guiada por IA alinhada ao Magistério da Igreja.
   - **Aba 2 (Escanear Bíblia):** Suporte flexível a captura via **Câmera** ou **Galeria de Fotos**, com pipeline de OCR (`ProcessOcrImageUseCase`), higienização (`DataNormalizer`), normalização (`NormalizeOcrTextUseCase`) e gatekeeper de cotas com diálogo fraterno de benfeitoria.

2. **Paridade Funcional e de Domínio com a Liturgia Diária:**
   - Ao iniciar a leitura orante pela Passagem Livre, o `LectioBloc` dispara sob demanda:
     - Geração de Exegese Central (`RequestExegeseCentralEvent`)
     - Geração de Gotas de Contexto (`RequestContextDropsEvent`)
     - Geração de Prompts de Oratio e Contemplatio durante a navegação.
   - A experiência é unificada na `ImmersiveReadingPage`, mantendo exatamente a mesma nobreza espiritual da liturgia diária.

3. **Observabilidade e Telemetria com Zero-Knowledge:**
   - Registro de telemetria `[LectioJourney]` com `reading_type: 'Passagem Livre'` e `is_from_bff: false`.
   - Eventos anonimizados no Google Analytics e Crashlytics sem envio de dados piedosos do fiel.

## Consequências

### Positivas
- **Paridade 100%:** Passagens livres recebem o mesmo tratamento exegético e orante da liturgia oficial.
- **Acessibilidade Aumentada:** O fiel pode escolher fotos da galeria além da câmera.
- **Experiência Acolhedora:** Fiéis que não sabem qual passagem rezar encontram inspiração imediata por intenção de oração.
- **Robustez:** 297/297 testes automatizados cobrindo o fluxo completo.

### Mitigações
- O OCR de fotos com pouca iluminação é mitigado por cards com dicas de enquadramento e fallback transparente para o leitor local caso a cota de IA em nuvem esteja esgotada.
