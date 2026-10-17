# ADR 0007: Mudança de Paradigma na Meditatio - De Passiva para Protagonista Ativa

## Status
Aceito (Sprint 9)

## Contexto
O aplicativo pwE (Pray With Me) foi construído inicialmente com um fluxo muito guiado, no qual a IA conduzia a oração do usuário quase integralmente. O usuário se comportava de forma passiva, consumindo o conteúdo gerado em cada etapa (Lectio, Meditatio, Oratio, Contemplatio).
Apesar do recurso de "Níveis de Maturidade" ter sido introduzido para mitigar a dependência, percebemos que a própria interface mantinha o fiel numa postura receptiva. Para um verdadeiro processo de Lectio Divina (Leitura Orante), a Igreja recomenda que o fiel seja o *protagonista* do seu encontro com a Palavra, utilizando ferramentas auxiliares apenas sob demanda.

## Decisão
Decidimos reformular totalmente a interface da etapa de Meditatio (e a arquitetura que a suporta), adotando a abordagem "IA como co-piloto":
1. **Exegese Central**: Ao iniciar a Meditatio, o fiel recebe um único parágrafo central e reflexivo ("Exegese Central") para ancorar o entendimento do texto.
2. **Gotas de Contexto (Context Drops)**: Aprofundamentos teológicos, históricos, filológicos e sociais deixam de ser empurrados ao usuário e passam a estar disponíveis apenas sob demanda, no formato de "gotas" (via FAB - Floating Action Button).
3. **Socratic Review**: A IA passará a analisar as anotações do fiel na etapa de Meditatio não para criar a oração por ele, mas para devolver perguntas socráticas, forçando a interiorização.

## Consequências
- **Positivas**: O usuário ganha protagonismo; a interface fica mais limpa (clean UI); a experiência de oração fica mais focada no silêncio e menos na leitura de textos extensos.
- **Negativas**: O desenvolvimento dessa interface exigiu a criação de novos UseCases paralelos (`GenerateExegeseUseCase`, `GenerateContextDropsUseCase`) e novos endpoints (`generateExegeseCentral`, `generateContextDrops`), aumentando a complexidade da camada de Data e Domain e requerendo chamadas independentes ao LLM.
- **Risco**: Usuários acostumados ao modelo passivo podem sentir que o aplicativo perdeu funcionalidades. É preciso garantir que o Fading Scaffolding e o tutorial introduzam corretamente a nova mecânica de "puxar o conteúdo" (pull) em vez de "receber o conteúdo" (push).
