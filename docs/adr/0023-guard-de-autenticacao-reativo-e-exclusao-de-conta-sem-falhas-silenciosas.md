# ADR 0023 — Guard de Autenticação Reativo e Exclusão de Conta sem Falhas Silenciosas

**Data:** 03 de Outubro de 2026  
**Status:** 🟢 Aceito (parcial — decisões R1/R2 e consentimento explícito permanecem em aberto, ver §4)  
**Autores:** Arquiteto de Software Principal, Especialistas `engineer`, `secops-privacy`, `debugger`, `qa`  

---

## 1. Contexto

A auditoria de maturidade de 03/10/2026 (`docs/releases/app-maturity-audit-2026-10.md`, Onda 2 — Segurança e LGPD) apontou dois defeitos de correção comprovados no código:

1. **R3 — Guard de rotas ineficaz e com vazamento.** O `redirect` do `GoRouter` consultava `di.sl<AuthBloc>().state`, mas o `AuthBloc` era `registerFactory`: **cada redirect criava um bloc novo** em `AuthInitial` (que nunca redireciona) e deixava a subscription do stream de autenticação aberta. Além disso não havia `refreshListenable`, então, mesmo com o estado correto, uma mudança para `Unauthenticated` não reavaliava a rota atual. Na prática o guard nunca bloqueava nada e vazava um bloc por navegação.
2. **R4 — Exclusão de conta engolia erros.** `_purgeUserDataFromFirestore` envolvia cada etapa em `catch (_) {}`. Qualquer falha parcial era ignorada e, em seguida, o usuário era removido do Firebase Auth — deixando dados religiosos sensíveis **órfãos e inalcançáveis** no servidor (descumprimento do direito ao apagamento — LGPD art. 18 / GDPR art. 17) sem qualquer registro. A exclusão também era feita documento a documento, sem paginação.

## 2. Decisão

### 2.1 Guard de autenticação (R3)
- `AuthBloc` passa a ser **`registerLazySingleton`**: o guard do roteador e a UI observam a mesma instância. Em `main.dart` é provido com `BlocProvider.value` (o ciclo de vida é o do app; não deve ser fechado pelo provider).
- Nova função pura `resolveAuthRedirect` (`lib/core/routes/auth_redirect.dart`), testável sem DI nem Firebase:
  - rotas públicas (`/splash`, `/login`, `/web_restricted`, `/legal`, `/onboarding`) nunca redirecionam;
  - `Unauthenticated` → `/login`; `AuthWebAccessRestricted` → `/web_restricted`;
  - `AuthInitial`/`AuthLoading` **não** redirecionam (sessão ainda sendo resolvida no cold start);
  - `AuthError` **não** redireciona: é transitório (ex.: falha ao excluir conta/sair) e a sessão continua válida — expulsar o fiel da oração por um erro de rede seria regressão.
- `GoRouterRefreshStream` adapta o `Stream` do bloc a `Listenable` (`refreshListenable`), reavaliando o `redirect` a cada mudança de estado (ex.: logout em outro ponto do app leva ao `/login`).
- `buildAppRouter(...)` extrai a construção do roteador (observers e `readAuthState` injetáveis); `appRouter` global é mantido para os consumidores existentes. A "validação defensiva" por `FirebaseAuth.instance` foi removida por ser inalcançável/redundante.

### 2.2 Exclusão de conta (R4)
- O expurgo agora é **estrito e idempotente**: cada etapa (`users/sessions`, `users/session_embeddings`, `users/security/key_vault`, `users/{uid}`, `profiles/{uid}`) é executada, registrada no **Crashlytics** em caso de falha (`reason` identifica a etapa) e, se qualquer uma falhar, lança `ServerException` **antes** de remover o usuário do Firebase Auth. A conta permanece e o titular pode repetir a exclusão (apagar o que já não existe é sucesso).
- Subcoleções são apagadas em **lotes de 400** (`WriteBatch`) paginando até esvaziar.
- O `catch (_) {}` do `googleSignIn.signOut()` pós-exclusão passou a registrar log (não crítico).

## 3. Consequências

**Positivas:** guard de rotas efetivo e sem vazamento; comportamento do roteador coberto por testes; direito ao apagamento verificável e auditável; nenhum dado órfão silencioso.

**Trade-offs / riscos:**
- Quem ainda estava em `Unauthenticated` e acessava rota protegida por deep link passa a ser enviado ao `/login` (comportamento desejado, antes inerte).
- O expurgo continua ocorrendo **antes** de `user.delete()` (as regras do Firestore exigem sessão ativa). Se a remoção no Auth falhar por `requires-recent-login` e a reautenticação for cancelada, os dados já foram apagados e a conta permanece; a mensagem orienta o fiel a reentrar e repetir (sem perda de consistência, pois a operação é idempotente).
- O `AuthBloc` singleton nunca é fechado durante a vida do app (intencional).

## 4. Pendências da Onda 2 que dependem de decisão (não implementadas neste ADR)

| Item | Resumo | Por que aguarda decisão |
|---|---|---|
| **R1** — pepper do cofre de chaves | `EncryptionService._deriveKekV2` usa `pwe_sacred_vault_master_seed_2026` como padrão em release; o KEK é função de `uid + pepper`, ambos deriváveis. Um vazamento do Firestore expõe a chave mestra das anotações. | Qualquer segredo embutido no binário é extraível; a correção real exige **segredo fora do cliente** (KMS/Cloud Function — custo e FinOps) ou **segredo do usuário** (passphrase — muda a UX). Requer migração `wrapped:v2 → v3` sem perder acesso às notas existentes. |
| **R2** — chave Gemini no cliente | Chave extraível do APK; SDK `google_generative_ai` descontinuado. | Migrar para `firebase_ai` + App Check **ou** proxy no Cloud Run; impacta custo/cota. |
| **Consentimento para nuvem** | Não há consentimento explícito antes de enviar a reflexão ao Gemini; `AiSelectionPage` existe mas não é roteada, e o texto `cloudModeDesc` afirma "100% protegidas por criptografia", incompatível com a política de privacidade. | Deve ser feito junto com R2 (os mesmos *datasources* serão reescritos). |
| Hive sem `HiveAesCipher` | `emotion` e `passage` ficam em claro no disco local. | Requer migração das caixas existentes. |
