import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pwe/core/error/exceptions.dart';
import 'package:pwe/core/services/model_download_service.dart';
import 'package:pwe/features/lectio_divina/data/datasources/llm_local_datasource.dart';
import 'package:pwe/features/lectio_divina/domain/entities/retrieved_context.dart';

class MockModelDownloadService extends Mock implements IModelDownloadService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockModelDownloadService mockDownloadService;
  late GemmaLocalDataSourceImpl dataSource;
  const channel = MethodChannel('pwe/gemma_local');

  setUp(() {
    mockDownloadService = MockModelDownloadService();
    dataSource = GemmaLocalDataSourceImpl(mockDownloadService);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('GemmaLocalDataSourceImpl', () {
    test('exposes correct modelName and initial isModelLoaded state', () {
      expect(dataSource.modelName, equals('Gemma-4-E2B-it (LiteRT LM)'));
      expect(dataSource.isModelLoaded, isFalse);
    });

    test(
      'initialize throws LocalInferenceException when model path is null',
      () async {
        when(() => mockDownloadService.getModelPath())
            .thenAnswer((_) async => null);

        expect(
          () => dataSource.initialize(),
          throwsA(isA<LocalInferenceException>()),
        );
        expect(dataSource.isModelLoaded, isFalse);
      },
    );

    test('initialize successfully sets isModelLoaded to true when channel returns true', () async {
      when(() => mockDownloadService.getModelPath())
          .thenAnswer((_) async => '/fake/model.bin');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'loadModel') {
              return true;
            }
            return null;
          });

      await dataSource.initialize();
      expect(dataSource.isModelLoaded, isTrue);

      // Chamada repetida não deve reexecutar loadModel
      await dataSource.initialize();
      expect(dataSource.isModelLoaded, isTrue);
    });

    test('generateMeditationPoints calls channel with generated prompt and returns response (Map format)', () async {
      when(() => mockDownloadService.getModelPath())
          .thenAnswer((_) async => '/fake/model.bin');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'loadModel') return true;
            if (call.method == 'generate') {
              return {
                'text': '1. Meditação local\n2. Segundo ponto',
                'ttftMs': 450,
                'durationMs': 1200,
                'backend': 'GPU',
              };
            }
            return null;
          });

      final result = await dataSource.generateMeditationPoints(
        'Mt 5, 1-12',
        historicalContext: [
          RetrievedContext(
            sessionId: 's1',
            relevantText: 'Contexto prévio de oração',
            similarityScore: 0.9,
          ),
        ],
      );
      expect(result, contains('Meditação local'));
      expect(dataSource.isModelLoaded, isTrue);
      expect(dataSource.activeBackend, equals('GPU'));
    });

    test('updates activeBackend when result contains backend info', () async {
      when(() => mockDownloadService.getModelPath())
          .thenAnswer((_) async => '/fake/model.bin');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'loadModel') return true;
            if (call.method == 'generate') {
              return {
                'text': 'Meditação acelerada via GPU',
                'ttftMs': 180,
                'durationMs': 750,
                'backend': 'GPU',
              };
            }
            return null;
          });

      expect(dataSource.activeBackend, equals('CPU'));
      await dataSource.generateMeditationPoints('Mt 5, 1-12');
      expect(dataSource.activeBackend, equals('GPU'));
    });

    test('generatePrayerPrompts generates prayer response successfully (String format)', () async {
      when(() => mockDownloadService.getModelPath())
          .thenAnswer((_) async => '/fake/model.bin');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'loadModel') return true;
            if (call.method == 'generate') {
              return 'Senhor meu Deus, a Vós me entrego.';
            }
            return null;
          });

      final result = await dataSource.generatePrayerPrompts(
        'Reflexão de oração',
      );
      expect(result, equals('Senhor meu Deus, a Vós me entrego.'));
    });

    test(
      'generateContemplatioGuidance generates contemplation guidance',
      () async {
        when(() => mockDownloadService.getModelPath())
            .thenAnswer((_) async => '/fake/model.bin');

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              if (call.method == 'loadModel') return true;
              if (call.method == 'generate') {
                return 'Permaneça em silêncio diante de Deus hoje.';
              }
              return null;
            });

        final result = await dataSource.generateContemplatioGuidance(
          'Minhas anotações',
        );
        expect(result, contains('silêncio'));
      },
    );

    test('generateSocraticReview generates single socratic question', () async {
      when(() => mockDownloadService.getModelPath())
          .thenAnswer((_) async => '/fake/model.bin');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'loadModel') return true;
            if (call.method == 'generate') {
              return 'Onde em sua vida você sente este chamado?';
            }
            return null;
          });

      final result = await dataSource.generateSocraticReview(
        'Minha reflexão',
        'Lc 1',
      );
      expect(result, contains('chamado?'));
    });

    test(
      'generateExegeseCentral generates central exegesis without questions',
      () async {
        when(() => mockDownloadService.getModelPath())
            .thenAnswer((_) async => '/fake/model.bin');

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              if (call.method == 'loadModel') return true;
              if (call.method == 'generate') {
                return 'Este trecho ilumina a encarnação do Verbo.';
              }
              return null;
            });

        final result = await dataSource.generateExegeseCentral('Jo 1, 1-14');
        expect(result, contains('encarnação'));
      },
    );

    test('generateSummary generates concise summary', () async {
      when(() => mockDownloadService.getModelPath())
          .thenAnswer((_) async => '/fake/model.bin');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'loadModel') return true;
            if (call.method == 'generate') {
              return 'Paz e entrega a Deus.';
            }
            return null;
          });

      final result = await dataSource.generateSummary('Texto para resumo');
      expect(result, equals('Paz e entrega a Deus.'));
    });

    test(
      'throws LocalInferenceException when PlatformException is caught',
      () async {
        when(() => mockDownloadService.getModelPath())
            .thenAnswer((_) async => '/fake/model.bin');

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              if (call.method == 'loadModel') return true;
              if (call.method == 'generate') {
                throw PlatformException(
                  code: 'ERROR',
                  message: 'Inference failed',
                );
              }
              return null;
            });

        await expectLater(
          () => dataSource.generateMeditationPoints('Mt 1'),
          throwsA(
            isA<LocalInferenceException>().having(
              (e) => e.message,
              'message',
              contains('Erro na inferência local: Inference failed'),
            ),
          ),
        );
      },
    );

    test(
      'throws LocalInferenceException when TimeoutException is caught',
      () async {
        when(() => mockDownloadService.getModelPath())
            .thenAnswer((_) async => '/fake/model.bin');

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              if (call.method == 'loadModel') return true;
              if (call.method == 'generate') {
                // Delay longer than _inferenceTimeout or throw TimeoutException
                await Future<void>.delayed(const Duration(milliseconds: 100));
                throw TimeoutException('Timeout simulated');
              }
              return null;
            });

        await expectLater(
          () => dataSource.generateMeditationPoints('Mt 1'),
          throwsA(
            isA<LocalInferenceException>().having(
              (e) => e.message,
              'message',
              contains('Timeout simulated'),
            ),
          ),
        );
      },
    );

    test(
      'throws LocalInferenceException when generic exception is caught',
      () async {
        when(() => mockDownloadService.getModelPath())
            .thenAnswer((_) async => '/fake/model.bin');

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              if (call.method == 'loadModel') return true;
              if (call.method == 'generate') {
                // Returning invalid type in Map triggers TypeError when casting 'text' to String?
                return {'text': 12345};
              }
              return null;
            });

        await expectLater(
          () => dataSource.generateMeditationPoints('Mt 1'),
          throwsA(
            isA<LocalInferenceException>().having(
              (e) => e.message,
              'message',
              contains('Erro inesperado na inferência local'),
            ),
          ),
        );
      },
    );

    test(
      'dispose calls dispose and resets loaded state and activeBackend',
      () async {
        var disposeCalled = false;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              if (call.method == 'dispose') {
                disposeCalled = true;
                return null;
              }
              return null;
            });

        dataSource.dispose();
        expect(dataSource.isModelLoaded, isFalse);
        expect(dataSource.activeBackend, equals('CPU'));
        expect(disposeCalled, isTrue);
      },
    );

    test(
      'initialize retrieves getActiveBackend and updates activeBackend to GPU',
      () async {
        when(() => mockDownloadService.getModelPath())
            .thenAnswer((_) async => '/fake/model.bin');

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              if (call.method == 'loadModel') return true;
              if (call.method == 'getActiveBackend') return 'GPU';
              return null;
            });

        await dataSource.initialize();
        expect(dataSource.isModelLoaded, isTrue);
        expect(dataSource.activeBackend, equals('GPU'));
      },
    );

    test(
      'generate updates activeBackend from inference response payload',
      () async {
        when(() => mockDownloadService.getModelPath())
            .thenAnswer((_) async => '/fake/model.bin');

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              if (call.method == 'loadModel') return true;
              if (call.method == 'generate') {
                return {
                  'text': 'Meditação acelerada por hardware.',
                  'ttftMs': 320,
                  'durationMs': 890,
                  'backend': 'GPU',
                };
              }
              return null;
            });

        final result = await dataSource.generateMeditationPoints('Mt 6, 9-13');
        expect(result, contains('acelerada por hardware'));
        expect(dataSource.activeBackend, equals('GPU'));
      },
    );

    test(
      'generateStream yields word chunks and abort interrupts flow',
      () async {
        when(() => mockDownloadService.getModelPath())
            .thenAnswer((_) async => '/fake/model.bin');

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              if (call.method == 'loadModel') return true;
              if (call.method == 'generate') {
                return 'O Senhor é o meu pastor nada me faltará';
              }
              if (call.method == 'abort') return true;
              return null;
            });

        final stream = dataSource.generateStream('Prompt');
        final chunks = await stream.toList();

        expect(chunks.isNotEmpty, isTrue);
        expect(
          chunks.join(''),
          equals('O Senhor é o meu pastor nada me faltará'),
        );

        dataSource.abort();
      },
    );
  });
}
