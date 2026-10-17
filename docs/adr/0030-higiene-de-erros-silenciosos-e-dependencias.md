# ADR 0030 — Higiene de Erros Silenciosos e de Dependências

**Data:** 04 de Outubro de 2026  
**Status:** 🟢 Aceito  
**Autores:** Arquiteto de Software Principal  

---

## 1. Contexto

A auditoria encontrou 47 blocos `catch (_) {}` vazios em `lib/` e dependências desatualizadas ou mal classificadas.

## 2. Decisão

- Novo `logSwallowedError` (`lib/core/utils/swallowed_error_logger.dart`): os 47 `catch (_) {}` agora registram, **somente em debug**, o tipo da exceção e o stack trace (sem dados do usuário). O comportamento best-effort (ignorar a falha) é mantido; a falha deixa de ser invisível durante o desenvolvimento.
- Atualizações de patch seguras: `package_info_plus` (10.2.2). `wakelock_plus` 1.8.1 não resolveu com as restrições atuais.
- `marionette_flutter` **permanece em `dependencies`**: `lib/main.dart` o importa e só o inicializa sob `kDebugMode`; movê-lo para `dev_dependencies` quebraria o build de release (import não resolvido). Um futuro `main_debug.dart` separado permitiria a mudança.

## 3. Pendências (adiadas de propósito)

- `google_sign_in` 6→7 (API quebrada, exige revalidação do login em aparelho), `image_cropper` 9→12, `google_fonts` 9, `equatable` 3 (travado por dependências), `cupertino_icons` 2: majors a avaliar em ondas próprias.
- `purchases_flutter` 10.14: aguardar as contas de loja para validar compras.
- Override de `pointycastle` 4.0.0: mantido (já é a última versão).
- `model.tflite` (~21,7 MB) segue nos assets: impacto de tamanho documentado; avaliar download sob demanda.