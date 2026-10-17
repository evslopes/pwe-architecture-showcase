# ADR 0018 — Precedência Litúrgica Dominical Canônica, Omissão de Memórias e Unificação do Ciclo Bíblico

**Data:** 27 de Setembro de 2026  
**Status:** 🟢 Aceito e Homologado  
**Autores:** Arquiteto de Software Principal, Especialista `theologian`, Especialista `engineer`, Especialista `flutter-ui`, Especialista `qa`  
**Branch Relacionada:** `liturgical_sunday_precedence`  

---

## 1. Contexto & Problema

O **pwE (Pray With Me)** é um aplicativo de oração e Lectio Divina estritamente fiel ao Magistério da Igreja Católica Apostólica Romana. Na arquitetura litúrgica do aplicativo, os dados do dia são consumidos a partir da API oficial da CNBB (com contingência em HTML/Canção Nova) e enriquecidos pelo worker noturno na nuvem.

Durante a homologação orante do **26º Domingo do Tempo Comum (27 de Setembro de 2026)**, identificou-se um conflito litúrgico grave na interface:
1. **Eclipsamento do Domingo por Memória de Santo:** A API da CNBB ou o scraper retornava o título do dia como *"São Vicente de Paulo, presbítero, Memória"*, suprimindo visualmente o Domingo. A interface apresentava o retábulo sacro e o ícone dedicados a um santo/mártir, relegando o Dia do Senhor a segundo plano.
2. **Violação das Normas Universais do Calendário Romano:** Segundo a *Tabela dos Dias Litúrgicos dispostos segundo a sua ordem de precedência* (n. 59 das Normas Universais sobre o Ano Litúrgico):
   - Os Domingos do Tempo Comum possuem **Grau 6** de precedência.
   - Festas de Santos possuem **Grau 7**, Memórias Obrigatórias possuem **Grau 10** e Memórias Facultativas possuem **Grau 12**.
   - Logo, **o Domingo tem estrita precedência** sobre festas e memórias de santos. No Domingo do Tempo Comum, a memória de São Vicente de Paulo deve ser **totalmente omitida** da celebração da Missa e do Ofício.
   - Apenas **Solenidades** (Grau 3) e **Festas do Senhor** (Grau 5, ex: *Exaltação da Santa Cruz*) prevalecem sobre um Domingo do Tempo Comum.
   - Em Tempos Fortes (Advento, Quaresma e Páscoa - Grau 2), os Domingos prevalecem inclusive sobre Solenidades.
3. **Inconsistência do Ciclo Anual (Ciclo Ferial vs. Ciclo Dominical):** A desserialização em `DailyLiturgyModel` atribuía automaticamente aos domingos o ciclo ferial bienal (*Ano Par (II)* / *Ano Ímpar (I)*) em vez do ciclo trienal dominical (*Ano A*, *Ano B*, *Ano C*), provocando incongruência nas leituras bíblicas.
4. **Ausência de Informação Pastoral sobre a Omissão:** O fiel acostumado à memória do santo do dia precisa de uma notificação discreta e canonicamente correta explicando que a memória foi omitida por ser Domingo.

---

## 2. Decisão Arquitetural

Decidiu-se pela implementação integral da governança litúrgica canônica de precedência dominical em todas as camadas da aplicação, governada pelas seguintes decisões:

### A. Tabela Canônica de Precedência no Core (`LiturgicalDateFormatter`)
- Implementação de métodos canônicos puros em `lib/core/utils/liturgical_date_formatter.dart`:
  - `getOrdinaryTimeWeekNumber(DateTime date)`: cálculo dinâmico da semana do Tempo Comum (1ª a 34ª) através da data da Páscoa e de Pentecostes.
  - `getSundayCelebration(DateTime date, {String language})`: provê a denominação canônica do Domingo nos idiomas do sistema (ex: *"26º Domingo do Tempo Comum"*, *"26th Sunday in Ordinary Time"*, *"Dominica XXVI per Annum"*).
  - `celebrationPrevailsOverSunday(String celebrationTitle, {required bool isOrdinaryTime})`: avalia se uma celebração externa possui grau canônico superior ao Domingo (Solenidades e Festas do Senhor no Tempo Comum; nenhuma em Tempos Fortes).
  - `getOmittedCelebration(DateTime date, ...)`: identifica celebrações fixas de santos que coincidem com o Domingo e são omitidas.
  - Blindagem do ciclo dominical: domingos recebem exclusivamente `getDominicalCycle(year)` (*Ano A/B/C*).

### B. Camada de Domínio Imutável (`DailyLiturgy`)
- Extensão da entidade de domínio `DailyLiturgy` com o campo:
  ```dart
  final String? omittedCelebration;
  ```
- O getter `displayCelebration` passa a garantir a primazia do Domingo: caso o dia da semana seja Domingo (`weekday == DateTime.sunday`) e a celebração externa não seja de grau superior, o título é forçado para o nome solene do Domingo.
- O getter `displayYear` assegura a exibição do ciclo dominical trienal aos domingos.
- Adição do getter `displayOmittedCelebration` para consumo na UI.

### C. Camada de Dados, Parsers e Ingestão Cloud
- Atualização de `DailyLiturgyModel` com suporte a `omittedCelebration` em `fromJson`, `toJson` e `fromFirestore`.
- Atualização de `CnbbLiturgyParser` e `HtmlLiturgyParser` para detectar coincidências dominicais, aplicar o título do Domingo e registrar a memória em `omittedCelebration`.
- Atualização do script `daily_liturgy_worker.dart` no Cloud Run Job para persistir os documentos canônicos com a precedência resolvida e o campo `omittedCelebration` gravado no Firestore.

### D. Camada de Apresentação & Design System Sacro
- **Nota Litúrgica de Omissão:** Em `SacredIconAltarpieceCard` e `LiturgicalManuscriptCard`, quando `displayOmittedCelebration` não for nulo, exibe-se uma nota tipográfica sutil:
  ```dart
  Text(
    context.l10n.omittedCelebrationNotice(omitted),
    style: TextStyle(
      color: context.sacred.softText,
      fontSize: 11,
      fontStyle: FontStyle.italic,
    ),
  );
  ```
- **Hierarquia do Retábulo:** Aos domingos, o título principal permanece sendo a celebração dominical (ex: *"26º DOMINGO DO TEMPO COMUM, ANO A"*), garantindo que o seletor de ícone canônico (`CanonicalIconCatalog`) classifique a celebração como Domingo e exiba a iconografia de *Cristo Pantocrator*.

### E. Internacionalização Quádrupla Obrigatória (`l10n/`)
- Registro obrigatório da chave parametrizada `omittedCelebrationNotice` em todos os catálogos ARB:
  - `pt`: `"Hoje, omite-se a {celebration}"`
  - `en`: `"Today, {celebration} is omitted"`
  - `es`: `"Hoy se omite la {celebration}"`
  - `la`: `"Hodie omittitur {celebration}"`
  - Suporte estendido a `de`, `fr`, `it` e demais catálogos gerados.

---

## 3. Consequências

### Positivas
- **Fidelidade Canônica Inviolável:** O aplicativo reflete com perfeição as rubricas e normas do Missal Romano e da Liturgia das Horas da Igreja Católica.
- **Transparência Pastoral:** O fiel compreende com clareza o motivo pelo qual o santo tradicional do dia civil não é celebrado liturgicamente naquele domingo.
- **Correção Teológica da Iconografia:** Evita a exibição indevida de ícones de santos individuais no Dia do Senhor, honrando a centralidade do Mistério Pascal de Cristo.
- **Integridade da Camada de Apresentação:** Zero strings hardcoded em widgets, tipagem estrita no Dart Analyzer e cobertura de testes automatizados expandida (testes de utilitário, modelo, entidade e widgets 100% verdes).

### Negativas / Mitigações
- **Variações de Nomenclatura em Fontes de Contingência:** A API da CNBB e o portal Canção Nova frequentemente utilizam strings não-padronizadas (ex: *"S. Vicente de Paulo"*, *"Memória de São..."*). Mitigado pela sanitização via regex e mapeamento de palavras-chave canônicas (`Solenidade`, `Festa do Senhor`).
