# ADR 0026 — Senha Opcional do Cofre de Chaves (`wrapped:v3`)

**Data:** 03 de Outubro de 2026  
**Status:** 🟢 Aceito  
**Autores:** Arquiteto de Software Principal, Especialistas `engineer`, `security`, `privacy`  

---

## 1. Contexto

A chave AES do Caderno Espiritual era envelopada (`wrapped:v2`) com um KEK derivado de `userId` + pepper + salt. O `userId` não é segredo e o pepper padrão estava no código-fonte: quem lesse o cofre no Firestore podia reconstruir o KEK. A política de privacidade, portanto, não podia alegar sigilo contra o operador do backend.

## 2. Decisão

1. **Senha opcional do usuário.** Novo formato `wrapped:v3:<iterações>:<salt>:<iv>:<cifra>`. KEK = HKDF-SHA256( PBKDF2-HMAC-SHA256(senha, salt‖userId, 150.000 iterações) ‖ pepper ). Iterações gravadas no blob (aceitas entre 1.000 e 2.000.000, evitando DoS por blob adulterado); PBKDF2 roda fora da thread de UI (`compute`).
2. **Pepper via `--dart-define=VAULT_PEPPER`** (agora na allowlist do `EnvConfig`). Camada extra, **não** dependência crítica: cofres v2 e v3 também são tentados com o pepper padrão, então definir/trocar o pepper não impede abrir dados existentes.
3. **Migração sem perda.** A senha é opt-in. `setPassphrase` reenvelopa a *mesma* chave local (v1/v2 → v3); nada é recifrado e nenhuma nota muda. Cofres v1/v2 continuam abrindo como antes.
4. **Cofre protegido nunca é sobrescrito.** `syncKeyVault` não grava por cima de um v3; compara a impressão digital da chave (`key_fingerprint`, HMAC truncado, não reversível) e, se diferir, sinaliza `VaultSyncStatus.passphraseRequired`, e o app leva o usuário a `/vault_security` para abrir o cofre.
5. **Remover a senha** exige a senha atual (abrir restaura a mesma chave) e regrava em v2.
6. **Capacidade separada:** `IPassphraseKeyWrapper` (implementada por `AesEncryptionServiceImpl`) evita quebrar fakes de `IEncryptionService`.
7. **UI:** `VaultSecurityBloc` + `VaultSecurityPage` (menu lateral → "Proteção do Caderno"), textos em 18 idiomas (EN como base nos sem tradução própria), com aviso explícito de que a senha esquecida não é recuperável.

## 3. Consequências

- Com senha, nem o operador do backend consegue abrir a chave; sem senha, o nível de proteção segue o do v2 (a política **não** deve alegar sigilo total nesse caso).
- Esquecer a senha impede ler as notas **da nuvem**; as já abertas neste aparelho permanecem na chave local.
- Trocar de senha ainda não é suportado diretamente (remover e definir de novo).

## 4. Pendências

- Atualizar a política de privacidade para descrever a senha opcional.
- Fluxo de recuperação (chave de recuperação impressa) — não incluído.
- Registrar `VAULT_PEPPER` como secret opcional no CI quando desejado.