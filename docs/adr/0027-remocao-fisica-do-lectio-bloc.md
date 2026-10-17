# ADR 0027 — Remoção Física do `LectioBloc`

**Data:** 04 de Outubro de 2026  
**Status:** 🟢 Aceito  
**Autores:** Arquiteto de Software Principal, Especialista `engineer`  

---

## 1. Contexto

O ADR 0024 retirou o `LectioBloc` (1.245 linhas, 15 dependências) do bootstrap, mas deixou a classe, o `LectioEvent` e o registro no DI. O fluxo da Lectio já é conduzido por blocs focados (`LectioSessionBloc`, `DailyLiturgyBloc`, `ExegesisBloc`, `PassageDiscoveryBloc`, `SacredIconBloc`, `SpiritualGuidanceBloc`). Nenhum código de `lib/` instanciava o `LectioBloc`; apenas o DI e testes.

## 2. Decisão

- Remover `lectio_bloc.dart`, `lectio_event.dart` e o `registerFactory(LectioBloc)`.
- **Manter** `lectio_state.dart` (`LectioState`/`LectioInitial`…), reutilizado por `LectioSessionState`.
- Excluir os testes que exercitavam só o bloc removido: `lectio_bloc_test`, `lectio_event_test`, `immersive_flow_test`, `liturgical_flow_integration_test`.
- Nos testes de página/drawer, o `MockLectioBloc` virou um mock de `MockBloc<Object, LectioState>` sem relação com a classe removida (as páginas não leem `LectioBloc`).

## 3. Consequências

- −1.245 linhas de código morto e uma dependência cruzada a menos no DI.
- A cobertura dos fluxos da Lectio passa a depender dos testes dos blocs focados; lacunas conhecidas seguem na lista de dívida (cobertura de `llm_repository_impl`).