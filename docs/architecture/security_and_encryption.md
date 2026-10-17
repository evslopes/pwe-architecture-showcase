# Segurança & Criptografia Simétrica de Ponta a Ponta

Este documento descreve a estratégia de proteção e integridade de dados espirituais no aplicativo pwE, assegurando que as anotações do Caderno Espiritual e orações íntimas dos fiéis permaneçam absolutamente invioláveis tanto em trânsito quanto em repouso (ADRs 0010, 0026 e 0029).

---

## 1. Ciclo de Vida da Criptografia (AES-256-GCM, Cofre com Senha e Hive Cifrado)

```mermaid
sequenceDiagram
    autonumber
    actor U as Fiel Católico
    participant UI as ImmersiveReadingPage / QuillEditor
    participant SessionBloc as LectioSessionBloc
    participant VaultBloc as VaultSecurityBloc
    participant Enc as AesEncryptionServiceImpl
    participant KeyVault as UserKeyVaultServiceImpl
    participant Local as EncryptedHiveBoxOpener (Caixa Hive Cifrada)
    participant Cloud as Cloud Firestore (users/{uid}/sessions)

    Note over U,Enc: Gravação da Sessão (Contemplatio)
    U->>UI: Redige oração íntima e resolução
    UI->>SessionBloc: CompleteSessionEvent(contemplatioAction, spiritualFruit)
    
    SessionBloc->>Enc: encrypt(plaintextNotes)
    Enc->>Enc: Gera IV aleatório (12 bytes CSPRNG) + Tag de Autenticação (128 bits)
    Enc-->>SessionBloc: EncryptedPayload (ciphertext + iv + authTag)
    
    SessionBloc->>Local: Grava sessão na caixa Hive criptografada em repouso (ADR 0029)
    SessionBloc->>Cloud: Sincroniza documento criptografado no Firestore
    
    Note over Cloud: No Firestore o documento armazena apenas dados cifrados:
    Note over Cloud: {"notes": "e8a9f...c3", "iv": "1f2d...", "tag": "4b9..."}
    
    Note over U,VaultBloc: Gestão Opcional de Senha do Cofre (ADR 0026)
    opt Fiel ativa Senha do Cofre (/vault_security)
        U->>VaultBloc: SetVaultPassphraseEvent(passphrase)
        VaultBloc->>KeyVault: wrapMasterKey(passphrase)
        KeyVault->>Cloud: Grava cofre com formato wrapped:v3
        Note over Cloud: Sem a senha do cofre, nem o serviço nem terceiros podem decifrar.
    end

    Note over U,Enc: Leitura no Caderno Espiritual (/history/detail)
    U->>UI: Abre detalhe da sessão anterior
    Local-->>UI: Retorna registro cifrado da caixa Hive
    UI->>Enc: decrypt(encryptedData)
    Enc->>Enc: Valida AuthTag e Descriptografa com KEK derivada
    Enc-->>UI: Plaintext Markdown Notes
    UI->>U: Renderiza texto rico formatado
```

---

## 2. Pilares de Segurança

1. **Algoritmo Padrão da Indústria**: Uso estrito do algoritmo **AES-256-GCM (Galois/Counter Mode)**, garantindo confidencialidade e autenticação de integridade contra adulterações.
2. **Vetores de Inicialização Únicos**: Cada operação gera um `IV` de 12 bytes aleatório via gerador criptográfico seguro (`Random.secure()`). É proibida a reutilização de IVs (`RN-SEC-090`).
3. **Cofre com Senha Opcional (`wrapped:v3` — ADR 0026)**:
   - *Com senha do cofre:* isolamento criptográfico integral. Nem administradores nem o provedor possuem acesso à chave.
   - *Sem senha do cofre:* a segurança é garantida pelo Keystore do Android / Keychain do iOS e controles de infraestrutura.
4. **Cifra em Repouso no Hive (ADR 0029)**: A caixa física de sessões locais no disco do aparelho é aberta via `EncryptedHiveBoxOpener`, impedindo inspeções forenses de arquivos locais.
5. **Proteção Visual contra Capturas (`RN-SEC-092`)**: Ativação nativa de `FLAG_SECURE` no Android e proteção de prévia no iOS contra prints e gravações acidentais da intimidade orante.
