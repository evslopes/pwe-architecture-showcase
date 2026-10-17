# ADR 0001 — Gerência de estado

## Status
Aceito (Revisado em 2026-04-02 para refletir a Stack Obrigatória)

## Contexto
O app **pwE (Pray With Me)** exige um padrão de gerência de estado que sustente a jornada da Lectio Divina (Input → Lectio → Meditatio → Oratio → Contemplatio) com os seguintes requisitos:
- **Separação por camadas**: Seguindo Clean Architecture e Domain-Driven Design (DDD).
- **Imersão Espiritual**: A navegação deve ser fluida e o estado deve ser preservado para evitar variações nas respostas da IA durante a mesma sessão.
- **Tratamento de Erros Robusto**: Uso de lógica funcional para lidar com falhas de API (Gemini/Firebase).
- **Injeção de Dependência**: Integração nativa com `GetIt`.

## Decisão
Adotar o **Bloc (Business Logic Component)** como o padrão oficial de gerência de estado utilizando o pacote `flutter_bloc`.

## Racional
- **Preditividade**: O fluxo unidirecional de dados (Event -> Bloc -> State) facilita a depuração de fluxos complexos como a Lectio Divina.
- **Isolamento da UI**: Garante que a lógica de negócio e as chamadas de IA (Gemini) fiquem totalmente separadas da camada de apresentação, permitindo uma interface "limpa" para a oração.
- **Padronização do Projeto**: Alinhamento com a diretriz `RULE[user_global]`, garantindo consistência em toda a base de código.
- **Session Cache Pattern**: O Bloc é o local ideal para armazenar em memória (no `InProgressState`) as respostas da IA, servindo como um "smart cache" que evita chamadas redundantes e economiza cota de API.

## Padrões de Implementação (Modern Bloc)
1. **Tríade Obrigatória**: Cada funcionalidade deve implementar as classes `Bloc`, `Event` e `State`.
2. **Either Type (Dartz)**: Repositórios e Use Cases devem retornar `Either<Failure, Type>`. O Bloc é responsável por mapear esses resultados para estados de sucesso ou erro na UI.
3. **CopyWith Mechanism**: Utilização do método `copyWith` nos estados para atualização incremental do progresso da sessão de oração.

## Consequências
- **Aumento de Boilerplate**: Aceito em troca de maior manutenibilidade e facilidade de testes unitários do domínio.
- **Independência de Framework**: O domínio permanece puro, enquanto o Bloc atua na camada de Apresentação orquestrando a lógica de aplicação.
- **Configuração Global**: O `main.dart` fornecerá os Blocs necessários através do `BlocProvider` nos pontos de entrada das features.

## Exemplo de Referência (Lectio Divina)

```dart
// Eventos claros e semânticos
abstract class LectioEvent {}
class RequestGuidedMeditationEvent extends LectioEvent {}

// Estados imutáveis com cache de sessão
class LectioInProgress extends LectioState {
  final LectioSession session;
  final String? guidingPrompt; // In-memory cache da IA
  final bool isLoading;
  
  // ... copyWith implementation
}
```

## Links
- Épico: #1
- Decisão Original: #2 (Migrado de Riverpod para Bloc em 2026-04-02)
- Documentação: [flutter_bloc](https://pub.dev/packages/flutter_bloc)
