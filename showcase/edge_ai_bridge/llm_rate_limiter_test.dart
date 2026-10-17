import 'package:flutter_test/flutter_test.dart';
import 'package:pwe/core/security/llm_rate_limiter.dart';

void main() {
  group('LlmRateLimiter', () {
    late LlmRateLimiter limiter;

    setUp(() {
      limiter = LlmRateLimiter(
        maxRequestsPerMinute: 3,
        minIntervalBetweenRequests: const Duration(milliseconds: 100),
      );
    });

    test('deve permitir requisições dentro do limite normal', () {
      expect(limiter.canProceed(), isTrue);
      expect(() => limiter.checkAndRecord(), returnsNormally);
      expect(limiter.activeRequestsCount, equals(1));
    });

    test(
      'deve bloquear requisições consecutivas muito rápidas (anti-burst)',
      () {
        limiter.checkAndRecord();
        expect(
          () => limiter.checkAndRecord(),
          throwsA(isA<RateLimitExceededException>()),
        );
      },
    );

    test('deve permitir requisição após o intervalo mínimo', () async {
      limiter.checkAndRecord();
      await Future<void>.delayed(const Duration(milliseconds: 110));
      expect(() => limiter.checkAndRecord(), returnsNormally);
      expect(limiter.activeRequestsCount, equals(2));
    });

    test(
      'deve lançar RateLimitExceededException ao estourar maxRequestsPerMinute',
      () async {
        for (int i = 0; i < 3; i++) {
          limiter.checkAndRecord();
          await Future<void>.delayed(const Duration(milliseconds: 110));
        }

        expect(limiter.activeRequestsCount, equals(3));
        expect(limiter.canProceed(), isFalse);
        expect(
          () => limiter.checkAndRecord(),
          throwsA(isA<RateLimitExceededException>()),
        );
      },
    );

    test('reset deve limpar histórico e permitir novas chamadas', () {
      limiter.checkAndRecord();
      expect(limiter.activeRequestsCount, equals(1));
      limiter.reset();
      expect(limiter.canProceed(), isTrue);
    });

    test(
      'deve permitir operações distintas em paralelo sem bloqueio anti-burst',
      () {
        expect(
          () => limiter.checkAndRecord('generateMeditationPoints'),
          returnsNormally,
        );
        expect(
          () => limiter.checkAndRecord('generateExegeseCentral'),
          returnsNormally,
        );
        expect(
          () => limiter.checkAndRecord('generateContextDrops'),
          returnsNormally,
        );
        expect(limiter.activeRequestsCount, equals(3));

        // Mesma operação repetida imediatamente ainda sofre anti-burst
        final limiterHighQuota = LlmRateLimiter(
          maxRequestsPerMinute: 10,
          minIntervalBetweenRequests: const Duration(milliseconds: 100),
        );
        limiterHighQuota.checkAndRecord('generateContextDrops');
        expect(
          () => limiterHighQuota.checkAndRecord('generateContextDrops'),
          throwsA(isA<RateLimitExceededException>()),
        );
      },
    );
  });
}
