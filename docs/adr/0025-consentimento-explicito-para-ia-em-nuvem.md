# ADR 0025 — Consentimento Explícito para IA em Nuvem

**Data:** 03 de Outubro de 2026  
**Status:** 🟢 Aceito  
**Autores:** Arquiteto de Software Principal, Especialistas `engineer`, `privacy`, `a11y`  

---

## 1. Contexto

A auditoria de 03/10/2026 mostrou que o modo nuvem era o padrão efetivo **sem consentimento**: a `AiSelectionPage` existia, mas nenhuma rota navegava até ela, e o texto `cloudModeDesc` afirmava que "orações e anotações permanecem 100% protegidas por criptografia", em contradição com a política de privacidade (a passagem e a reflexão são enviadas ao Gemini, do Google). As lojas (Apple 5.1.2(i), Play Data Safety) exigem divulgação clara e consentimento antes do envio de dados a IA de terceiros.

## 2. Decisão

1. **`ICloudAiConsentService`** (`lib/core/privacy/`): decisão persistida localmente (`cloud_ai_consent_v1` + timestamp). `hasConsent`, `hasDecided`, `grant()`, `revoke()`, `reset()`. Instalações que já usavam o modo local contam como "decididas", sem consentimento.
2. **Barreira técnica, não só de UI:** `ConsentGuardedLlmRemoteDataSource` (decorator registrado no DI) lança `CloudConsentRequiredException` (um `ServerException`) antes de qualquer chamada ao Gemini; `GeminiEmbeddingService` retorna `Left(ServerFailure)` e `CloudTtsProvider` lança a mesma exceção. Os repositórios reaproveitam os fallbacks local/patrístico já existentes, e o TTS recai no motor nativo.
3. **Fluxo de UI:** o `redirect` do router (`resolveAuthRedirect(needsAiChoice:)`) leva o usuário autenticado e indeciso a `/ai_selection`; escolher nuvem exibe o diálogo de consentimento (`showCloudAiConsentDialog`); escolher local ou "continuar sem assistente" registra a recusa. No menu lateral, voltar à nuvem pede consentimento e ativar o modo offline o revoga.
4. **Texto honesto** (18 idiomas): `cloudModeDesc` e novas chaves `cloudConsent*`/`continueWithoutAi` informam que passagem e reflexão vão ao serviço Gemini, do Google, e que o consentimento pode ser retirado.
5. Ao apagar o modelo local, quem usava só o modo offline volta a ser perguntado (nunca vira nuvem automaticamente).

## 3. Consequências

- Nenhum dado de oração sai do aparelho sem aceite explícito e revogável.
- Usuários que recusam seguem com conteúdo patrístico/local e o Caderno Espiritual.
- Usuários atuais sem decisão e sem modo local verão a escolha uma vez após o login.

## 4. Pendências (ondas seguintes)

- Migração para `firebase_ai` + App Check (remoção da chave Gemini do cliente) — depende de habilitar *Firebase AI Logic* no console e decisão sobre embeddings.
- Revisão jurídica dos textos; atualizar política de privacidade citando o consentimento como base legal.