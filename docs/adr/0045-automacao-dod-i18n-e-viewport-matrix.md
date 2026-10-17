# ADR 0045: Automação do Rito DoD, Sincronizador i18n de 18 ARBs e Matriz de Viewports

- **Status:** Aceito
- **Data:** 16 de Outubro de 2026
- **Decisores:** Arquiteto de Software Principal, Agentes `devops`, `qa`, `design-a11y`, `task-finisher`

## Contexto e Problema

A evolução contínua do **pwE (Pray With Me)** evidenciou quatro gargalos operacionais recorrentes nas interações de engenharia:
1. O Rito Mandatório de Finalização (DoD) exigia múltiplas edições manuais (`pubspec.yaml`, espelhamento `CHANGELOG.md` $\leftrightarrow$ `docs/releases/CHANGELOG.md`, validação de notas pastorais `whatsnew` $\le 500$ chars e execução encadeada de format/analyze/test).
2. A manutenção simultânea de **18 catálogos ARB** (`ar`, `de`, `en`, `es`, `fr`, `hi`, `it`, `ja`, `ko`, `la`, `nl`, `pl`, `pt`, `sw`, `tl`, `uk`, `vi`, `zh`) estava sujeita a vazamento acidental de `@metadados` fora do template `app_pt.arb` ou divergência de placeholders ICU.
3. A verificação de saúde da infraestrutura de nuvem (FinOps Free Tier, cabeçalhos CORS dos Ícones Sagrados no GCS e disponibilidade da janela litúrgica de 7 dias) dependia de scripts avulsos.
4. Ajustes de responsividade precisavam ser validados sistematicamente em 6 resoluções canônicas com `TextScaler` de `1.0x` e `2.0x`.

## Decisão

1. **CLI de Release e DoD (`tool/pwe_release.dart`):** Automatiza o bump monotônico (`--bump=patch|minor|major`), sincroniza `CHANGELOG.md` e `docs/releases/CHANGELOG.md`, valida limites e ausência de termos técnicos em `whatsnew/` e executa `dart format`, `flutter analyze --no-fatal-infos` e `flutter test`.
2. **CLI de Governança i18n (`tool/i18n_sync.dart`):** Audita paridade de chaves, tipos/nomes de placeholders ICU e exclusividade de `@metadados` em `app_pt.arb`, além de permitir injeção atômica em lote (`--inject=<json>`) nos 18 ARBs com regeneração automática (`flutter gen-l10n`).
3. **Orquestrador de Saúde (`scripts/pwe_doctor.dart`):** Unifica auditoria FinOps, diagnóstico CORS da JSON API do GCS e verificação da janela litúrgica com suporte a `--auto-heal`.
4. **Matriz de Viewports e Invariantes Visuais (`test/helpers/viewport_matrix_helper.dart` & `test/core/architecture/ui_invariants_test.dart`):** Valida 6 viewports (`360x640`, `390x844`, `844x390`, `768x1024`, `1366x768`, `1920x1080`) com `TextScaler` `1.0x` e `2.0x` e garante ausência de `CircularProgressIndicator` e `IntrinsicHeight` inseguros.

## Consequências

- **Positivas:** Redução drástica de retrabalho manual, zero regressões de chaves/placeholders ARB nos 18 idiomas e proteção preventiva contra *RenderFlex overflow* em celulares, tablets e desktops.
- **Negativas / Trade-offs:** Pequeno acréscimo (~2 segundos) na suíte de testes de arquitetura para validar os invariantes estáticos e a matriz de viewports.
