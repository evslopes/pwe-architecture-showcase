# ADR 0002: Adoção do Padrão "Seamless Scroll" e Estados Cumulativos na Camada de Apresentação

## Status
Aceite (Accepted)

## Data
8 de Abril de 2026

## Contexto
Atualmente, o fluxo principal de leitura e interação da aplicação obriga o utilizador a navegar através de quatro ecrãs literais e distintos, separados por interações de toque em botões de avanço.
[Inference] O diagnóstico de engenharia e *design* de interface (UX) apontou que este modelo mecânico pode causar interrupções cognitivas, resultando em fadiga visual e num aumento da taxa de abandono do fluxo. E uma nota de que este é o comportamento esperado para interfaces excessivamente paginadas, não garantido em todos os cenários.
Precisávamos de uma solução que mantivesse o rigor arquitetural e a separação de responsabilidades do padrão BLoC, mas que modernizasse a interface de utilizador.

## Decisão
Decidimos refatorar a camada de apresentação (Presentation) para adotar um padrão de "Scroll Contínuo Dinâmico" (Seamless Scroll) com revelação progressiva de texto.
1. A navegação entre as quatro etapas será unificada numa única `CustomScrollView`.
2. O `Bloc` principal deixará de emitir estados de roteamento (navegação) e passará a emitir estados cumulativos. Utilizaremos o método `.copyWith` no estado para anexar os dados de cada nova etapa processada ao ecrã existente.
3. Transições de etapa serão acionadas por eventos de deslocamento (*scroll*) ou gestos de pressão contínua (*hold-to-complete*), reduzindo a dependência de botões padrão.

## Consequências

### Positivas
* **Fluidez:** A transição entre o carregamento de dados remotos e a interface torna-se orgânica.
* **Manutenibilidade:** Menos rotas e dependências de navegação no `AppRouter`.
* **Retenção:** A interface contínua promove um maior tempo de permanência no ecrã.

### Negativas (Trade-offs)
* **Complexidade de Estado:** O objeto de estado do BLoC torna-se maior, pois tem de guardar em memória os textos e variáveis de todas as etapas processadas simultaneamente no mesmo ecrã.
* **Gestão de Memória:** Como todos os componentes visuais residem na mesma árvore de *widgets* (`SliverList`), será exigida uma gestão mais cuidadosa do `ScrollController` e da destruição (*dispose*) de animações para não impactar a *Main Thread* (referência à falha de *frames skipped* identificada em *logs* anteriores).
