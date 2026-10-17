/// Exceção lançada quando o limite de requisições à IA é excedido.
class RateLimitExceededException implements Exception {
  final String message;
  final Duration retryAfter;

  const RateLimitExceededException({
    this.message = 'Muitas reflexões solicitadas em um curto intervalo. Permaneça em oração e silêncio por alguns instantes antes de tentar novamente.',
    this.retryAfter = const Duration(seconds: 15),
  });

  @override
  String toString() =>
      'RateLimitExceededException: $message (tente em ${retryAfter.inSeconds}s)';
}

/// Mecanismo de Rate Limiting para proteger a API do LLM contra esgotamento de cotas,
/// rajadas acidentais de cliques múltiplos e abusos.
class LlmRateLimiter {
  final int maxRequestsPerMinute;
  final Duration minIntervalBetweenRequests;

  final List<DateTime> _requestTimestamps = [];
  final Map<String, DateTime> _lastRequestTimeByOperation = {};
  DateTime? _lastRequestTime;

  LlmRateLimiter({
    this.maxRequestsPerMinute = 15,
    this.minIntervalBetweenRequests = const Duration(milliseconds: 1000),
  });

  /// Verifica se a requisição é permitida e registra o timestamp.
  /// Lança [RateLimitExceededException] se o limite for ultrapassado.
  ///
  /// Quando [operationKey] é informado, o controle anti-burst de intervalo mínimo
  /// é avaliado por tipo de operação, evitando que chamadas paralelas legítimas
  /// de etapas distintas (ex: `startSpiritualSession`, `generateMeditationPoints`,
  /// `generateExegeseCentral`, `generateContextDrops`) bloqueiem umas às outras,
  /// enquanto o limite global de [maxRequestsPerMinute] permanece compartilhado.
  void checkAndRecord([String? operationKey]) {
    final now = DateTime.now();

    // 1. Verificação de intervalo mínimo entre requisições consecutivas (anti-burst)
    final relevantLastTime = operationKey != null
        ? _lastRequestTimeByOperation[operationKey]
        : _lastRequestTime;
    if (relevantLastTime != null) {
      final elapsed = now.difference(relevantLastTime);
      if (elapsed < minIntervalBetweenRequests) {
        final waitTime = minIntervalBetweenRequests - elapsed;
        throw RateLimitExceededException(
          message:
              'Aguarde um instante antes de solicitar nova meditação à IA.',
          retryAfter: waitTime,
        );
      }
    }

    // 2. Limpeza de timestamps fora da janela deslizante de 1 minuto
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
    _requestTimestamps.removeWhere((t) => t.isBefore(oneMinuteAgo));

    // 3. Verificação de quota por minuto
    if (_requestTimestamps.length >= maxRequestsPerMinute) {
      final oldestInWindow = _requestTimestamps.first;
      final retryAfter = oldestInWindow
          .add(const Duration(minutes: 1))
          .difference(now);
      throw RateLimitExceededException(
        retryAfter: retryAfter.isNegative
            ? const Duration(seconds: 5)
            : retryAfter,
      );
    }

    // 4. Registro bem-sucedido
    _requestTimestamps.add(now);
    _lastRequestTime = now;
    if (operationKey != null) {
      _lastRequestTimeByOperation[operationKey] = now;
    }
  }

  /// Retorna se uma requisição pode ser realizada no momento sem lançar exceção.
  bool canProceed([String? operationKey]) {
    try {
      final now = DateTime.now();
      final relevantLastTime = operationKey != null
          ? _lastRequestTimeByOperation[operationKey]
          : _lastRequestTime;
      if (relevantLastTime != null &&
          now.difference(relevantLastTime) < minIntervalBetweenRequests) {
        return false;
      }
      final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
      final recentCount = _requestTimestamps
          .where((t) => t.isAfter(oneMinuteAgo))
          .length;
      return recentCount < maxRequestsPerMinute;
    } catch (_) {
      return false;
    }
  }

  /// Quantidade de requisições registradas na janela ativa.
  int get activeRequestsCount {
    final oneMinuteAgo = DateTime.now().subtract(const Duration(minutes: 1));
    return _requestTimestamps.where((t) => t.isAfter(oneMinuteAgo)).length;
  }

  /// Limpa o histórico de requisições (útil para testes).
  void reset() {
    _requestTimestamps.clear();
    _lastRequestTimeByOperation.clear();
    _lastRequestTime = null;
  }
}
