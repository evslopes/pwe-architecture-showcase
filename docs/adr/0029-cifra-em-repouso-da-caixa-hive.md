# ADR 0029 — Cifra em Repouso da Caixa Hive de Sessões

**Data:** 04 de Outubro de 2026  
**Status:** 🟢 Aceito  
**Autores:** Arquiteto de Software Principal, Especialista `security`  

---

## 1. Contexto

A auditoria apontou que a caixa Hive `CACHED_SESSIONS_BOX` ficava em claro no armazenamento do aparelho. Apenas as notas (`meditatioNotes`, `oratioNotes`, `contemplatioAction`) eram cifradas campo a campo; emoção, passagem e prompts ficavam legíveis.

## 2. Decisão

- Novo `EncryptedHiveBoxOpener` (`lib/core/storage/encrypted_hive_box_opener.dart`): abre caixas com `HiveAesCipher`; a chave de 256 bits fica no `flutter_secure_storage` (`pwe_hive_cipher_key_v1`).
- Migração sem perda: copia a caixa legada para uma caixa **nova** cifrada (`CACHED_SESSIONS_BOX_V2`), grava um marcador e só então apaga a legada. Interrupções são idempotentes; se o marcador existir e a legada reaparecer, ela é apagada.
- Caixa cifrada ilegível (chave perdida) é recriada vazia; os dados continuam recuperáveis pelo Firestore.
- A caixa pública de liturgia permanece sem cifra, de propósito (conteúdo público).
- A cifra por campo das notas é mantida (defesa em profundidade).

## 3. Consequências

- Desinstalar o app ou perder o Keystore/Keychain invalida o cache local; a sincronização restaura os dados.
- Testes em `test/core/storage/encrypted_hive_box_opener_test.dart` (migração, ausência de texto em claro, idempotência, interrupção, caixa ilegível).