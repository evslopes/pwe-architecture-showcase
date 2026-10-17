# ADR 0041: Estratégia Cache-First para Liturgia Diária e Persistência em Disco de Ícones Sacros

- **Status:** Implementado
- **Data:** 12 de Outubro de 2026
- **Autores:** Arquiteto de Software Principal & Engenheiro de Dados pwE
- **Contexto:** Auditoria de performance, tráfego de rede e reinicialização do aplicativo (Issues de re-download de ícones e leituras)

---

## 1. Contexto e Diagnóstico

Durante a auditoria operacional do aplicativo pwE, foi identificada uma ineficiência crítica de rede e consumo desnecessário de cotas na inicialização do aplicativo:

1. **Re-download de Leituras Litúrgicas a Cada Reinício:**
   - O repositório `DailyLiturgyRepositoryImpl` adotava uma política estritamente *Remote-First*. Toda chamada a `getDailyLiturgy()` realizava primeiro uma requisição HTTP ou consulta ao Cloud Firestore (`daily_liturgies/{date}_{lang}`). O cache local persistido em disco via Hive (`liturgyBox`) funcionava exclusivamente como *fallback* secundário em caso de falha de conexão (`ServerException`).
   - Havia ainda uma divergência de formato de chave entre o parser de HTML (`DD/MM/YYYY`) e o buscador do cache (`YYYY-MM-DD`), fazendo com que qualquer dado salvo por raspagem web nunca fosse localizado pelo Hive.
   - Logs de telemetria do GCP (`firestore.googleapis.com/document/read_count`) confirmaram operações `LOOKUP` redundantes do mesmo documento a cada inicialização da aplicação por usuário.

2. **Re-download e Harmonização Redundante do Ícone Sacro:**
   - O componente `SacredIconHarmonizer` utilizava `Image.network` e realizava requisição `http.get` para obter a imagem remota do Google Cloud Storage (`storage.googleapis.com/<REDACTED_GCS_CDN_BUCKET>/icons/...`) a cada ciclo de vida do widget, pois o `SacredIconPixelHarmonizer` mantinha apenas um cache volátil em memória RAM (`ui.Image`).
   - Ao reiniciar o aplicativo ou alternar telas após limpeza de memória pelo sistema operacional, os bytes da imagem eram baixados novamente, gerando atraso visual perceptível (flicker) e tráfego contínuo no bucket do GCP.

---

## 2. Decisão Arquitetural

Implementou-se uma reformulação completa da política de cache das leituras e imagens sacras no domínio `lectio_divina`:

### 2.1. Estratégia Cache-First Canônica no Repositório de Liturgia
- **Política de Consulta:** `DailyLiturgyRepositoryImpl.getDailyLiturgy()` agora opera prioritariamente em modo **Cache-First**. Se `forceRefresh` for `false` (padrão) e houver registro válido na caixa local do Hive, a entidade `DailyLiturgy` é retornada instantaneamente em 0ms (`Right(cachedLiturgy)`), sem efetuar nenhuma requisição de rede ou leitura no Cloud Firestore.
- **Forçar Atualização (`forceRefresh`):** Adicionou-se o parâmetro `bool forceRefresh = false` ao contrato `DailyLiturgyRepository`, ao UseCase `GetDailyLiturgyParams` e ao evento `LoadDailyLiturgyEvent`, permitindo que mecanismos de pull-to-refresh ou ações explícitas do usuário requisitem dados novos quando necessário.
- **Fallback Resiliente:** Caso `forceRefresh == true` seja acionado e a rede falhe, o repositório recupera a versão em cache local de forma transparente.

### 2.2. Normalização Universal das Chaves de Cache
- O parser `HtmlLiturgyParser` foi atualizado para emitir datas padronizadas em ISO 8601 (`YYYY-MM-DD` com padding de zeros).
- O `DailyLiturgyLocalDataSourceImpl` foi blindado com o utilitário `LiturgicalDateFormatter.parseDateString()`, garantindo que datas em formato brasileiro (`DD/MM/YYYY`) e ISO sejam convertidas para a chave canônica `YYYY-MM-DD_{lang}`, além de normalizar variantes de idioma (`pt-BR` -> `pt`) e incluir suporte retrocompatível para chaves legadas.

### 2.3. Persistência em Disco para Ícones Sacros (`ISacredIconCacheService`)
- Criou-se o contrato `ISacredIconCacheService` no domínio da Leitura Orante, com métodos para recuperação (`getCachedIconBytes`), salvamento (`cacheIconBytes`) e limpeza (`clearCache`).
- Implementou-se `SacredIconCacheServiceImpl` com suporte nativo IO (Android, iOS, Desktop) utilizando o diretório de suporte da aplicação (`getApplicationSupportDirectory() + '/sacred_icons_cache/'`) e endereçamento por hash criptográfico SHA-256 da URL do ativo sagrado.
- O widget `SacredIconHarmonizer` foi refatorado para consultar o cache persistente em disco antes de disparar requisições HTTP. Uma vez salvo, o ícone é carregado imediatamente do armazenamento flash do dispositivo via `Image.memory` e harmonizado sem requisições de rede adicionais.
- Para ambiente Web, proveu-se implementação em memória compatível com o padrão de export condicional.

---

## 3. Consequências

### Positivas
- **Latência Zero na Abertura:** A Liturgia Diária e o Ícone Sacro do dia são renderizados instantaneamente ao reabrir o aplicativo.
- **Eficiência FinOps:** Erradicação de leituras repetidas de documentos idênticos no Cloud Firestore e supressão de tráfego de saída (egress) no Cloud Storage para os ícones sacros já visualizados.
- **Resiliência Offline Plena:** O usuário pode desligar a conexão ou entrar em áreas sem sinal de internet e continuar sua Leitura Orante com os textos sagrados e imagens já visualizados.
- **Desacoplamento e Testabilidade:** O serviço de cache de ícones é injetado via GetIt e testável isoladamente através de mocks da interface de plataforma.

### Considerações e Mitigações
- **Invalidação de Cache:** Entradas com mais de 7 dias são descartadas automaticamente pelo método `evictExpiredEntries()` da fonte local do Hive na gravação de novas liturgias.
- **Atualização de Conteúdo Corrigido:** Caso uma liturgia seja editada no painel administrativo, o usuário pode puxar a tela para atualizar (`forceRefresh: true`), sobrepondo o cache local.
