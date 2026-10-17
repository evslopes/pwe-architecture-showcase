# ADR 0028 — Endurecimento das Regras do Firestore e do Storage

**Data:** 04 de Outubro de 2026  
**Status:** 🟢 Aceito (regras validadas sintaticamente; **ainda não implantadas** nem testadas no emulador)  
**Autores:** Arquiteto de Software Principal, Especialista `security`  

---

## 1. Contexto

A auditoria apontou regras sem validação de schema/tamanho: o titular podia gravar qualquer conteúdo em qualquer subcoleção, inclusive no cofre de chaves (`users/{uid}/security/key_vault`), e no Storage não havia limite de tamanho.

## 2. Decisão

**Firestore**
- Função `isOwner(userId)` centraliza a checagem de titularidade.
- `users/{uid}/{collection}/{rest=**}` deixa de cobrir `security`. O cofre ganha regra própria: leitura/exclusão do titular; criação/atualização só se o documento tiver `wrapped_key` (string 1–2.000 caracteres, prefixo `wrapped:v1|v2|v3:`), `updated_at == request.time`, `version ∈ {1,2,3}`, `passphrase_protected` booleano e `key_fingerprint` ≤ 64 caracteres.
- Sem `hasOnly` no cofre, de propósito: documentos antigos podem ter campos extras e a sincronização usa `merge`.
- Demais subcoleções do usuário **não** receberam validação de schema (os modelos de sessão ainda variam por versão do app); isso fica como pendência.

**Storage**
- `users/{uid}/**`: leitura e exclusão do titular; criação/atualização limitadas a < 10 MB. O app não envia arquivos hoje.

## 3. Consequências / Pendências

- **Implantar** as regras (`firebase deploy --only firestore:rules,storage`) e testá-las no emulador antes de um release; um erro de regra aparece como `permission-denied` e a sincronização do cofre falha silenciosamente (try/catch), então a validação em emulador é recomendada.
- Validar schemas de `sessions`, `session_embeddings` e `profiles` quando os modelos estabilizarem.