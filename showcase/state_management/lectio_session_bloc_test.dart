import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pwe/core/error/failures.dart';
import 'package:pwe/core/services/analytics_service.dart';
import 'package:pwe/core/usecases/usecase.dart';
import 'package:pwe/features/auth/domain/entities/user_auth.dart';
import 'package:pwe/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:pwe/features/lectio_divina/domain/entities/biblical_passage.dart';
import 'package:pwe/features/lectio_divina/domain/entities/lectio_session.dart';
import 'package:pwe/features/lectio_divina/domain/repositories/llm_repository.dart';
import 'package:pwe/features/lectio_divina/domain/usecases/save_session_usecase.dart';
import 'package:pwe/features/lectio_divina/presentation/bloc/lectio_session/lectio_session_bloc.dart';
import 'package:pwe/features/lectio_divina/presentation/bloc/lectio_session/lectio_session_event.dart';
import 'package:pwe/features/lectio_divina/presentation/bloc/lectio_session/lectio_session_state.dart';
import 'package:pwe/features/profile/domain/entities/lectio_maturity_level.dart';
import 'package:pwe/features/profile/domain/entities/user_profile.dart';
import 'package:pwe/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:pwe/features/profile/domain/usecases/update_streak_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSaveSessionUseCase extends Mock implements SaveSessionUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

class MockUpdateStreakUseCase extends Mock implements UpdateStreakUseCase {}

class MockILlmRepository extends Mock implements ILlmRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSaveSessionUseCase mockSaveSession;
  late MockGetCurrentUserUseCase mockGetCurrentUser;
  late MockGetProfileUseCase mockGetProfile;
  late MockUpdateStreakUseCase mockUpdateStreak;
  late MockILlmRepository mockLlmRepository;
  late MockSharedPreferences mockPrefs;
  late LectioSessionBloc bloc;

  setUpAll(() {
    registerFallbackValue(NoParams());
    registerFallbackValue(LectioSession(id: 'dummy', date: DateTime.now()));
  });

  setUp(() {
    mockSaveSession = MockSaveSessionUseCase();
    mockGetCurrentUser = MockGetCurrentUserUseCase();
    mockGetProfile = MockGetProfileUseCase();
    mockUpdateStreak = MockUpdateStreakUseCase();
    mockLlmRepository = MockILlmRepository();
    mockPrefs = MockSharedPreferences();

    when(() => mockLlmRepository.resetSession()).thenReturn(null);
    when(() => mockLlmRepository.startSession(any()))
        .thenAnswer((_) async => right<Failure, void>(null));
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

    bloc = LectioSessionBloc(
      saveSession: mockSaveSession,
      getCurrentUser: mockGetCurrentUser,
      getProfile: mockGetProfile,
      updateStreak: mockUpdateStreak,
      llmRepository: mockLlmRepository,
      sharedPreferences: mockPrefs,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('LectioSessionBloc', () {
    test('initial state is LectioSessionInitial', () {
      expect(bloc.state, const LectioSessionInitial());
    });

    blocTest<LectioSessionBloc, LectioSessionState>(
      'ResetSessionEvent reseta o estado para LectioSessionInitial e chama resetSession no repositório',
      build: () => bloc,
      seed: () => LectioSessionInProgress(
        session: LectioSession(id: '1', date: DateTime.now()),
      ),
      act: (bloc) => bloc.add(ResetSessionEvent()),
      expect: () => [const LectioSessionInitial()],
      verify: (_) => verify(() => mockLlmRepository.resetSession()).called(1),
    );

    blocTest<LectioSessionBloc, LectioSessionState>(
      'emits [LectioSessionInitial(true), LectioSessionInProgress] on StartSessionEvent and triggers showMaturityCelebration when level increases',
      build: () {
        when(() => mockPrefs.getString('last_notified_maturity'))
            .thenReturn(LectioMaturityLevel.beginner.toString());
        when(() => mockGetCurrentUser(any())).thenAnswer(
          (_) async => const Right(
            UserAuth(id: 'user_1', email: 'a@a.com', displayName: 'A'),
          ),
        );
        when(() => mockGetProfile(any())).thenAnswer(
          (_) async => const Right(
            UserProfile(
              uid: 'user_1',
              age: 30,
              gender: 'male',
              prayerIntentions: '',
              highestStreak: 10,
            ),
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const StartSessionEvent('paz')),
      expect: () => [
        const LectioSessionInitial(isLoading: true),
        isA<LectioSessionInProgress>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.showMaturityCelebration, 'showCelebration', true)
            .having(
              (s) => s.maturityLevel,
              'maturityLevel',
              LectioMaturityLevel.practitioner,
            ),
      ],
    );

    blocTest<LectioSessionBloc, LectioSessionState>(
      'StartSessionEvent preserva LectioSessionInProgress durante loading quando já em progresso',
      build: () => bloc,
      seed: () => LectioSessionInProgress(
        session: LectioSession(id: '1', date: DateTime.now()),
      ),
      act: (bloc) => bloc.add(
        const StartSessionEvent(
          'alegria',
          maturityLevel: LectioMaturityLevel.contemplative,
        ),
      ),
      expect: () => [
        isA<LectioSessionInProgress>().having(
          (s) => s.isLoading,
          'isLoading',
          true,
        ),
        isA<LectioSessionInProgress>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.session.emotion, 'emotion', 'alegria'),
      ],
    );

    blocTest<LectioSessionBloc, LectioSessionState>(
      'emits [LectioSessionInitial(true), LectioSessionInProgress] with clean state and passage on StartFreePassageSessionEvent',
      build: () => bloc,
      seed: () => LectioSessionInProgress(
        session: LectioSession(
          id: 'liturgical_session',
          date: DateTime.now(),
          emotion: 'Liturgia do Dia',
          passage: const BiblicalPassage(
            reference: 'Evangelho • Mt 5, 1-12',
            text: 'Texto anterior do Evangelho',
          ),
        ),
        currentStep: ImmersiveStep.oratio,
        precomputedMeditatioText: 'Meditação litúrgica prévia',
        precomputedOratioPrompts: const ['Oração prévia'],
      ),
      act: (bloc) => bloc.add(
        const StartFreePassageSessionEvent(
          passageReference: 'Sl 23',
          passageText: 'O Senhor é meu pastor, nada me faltará.',
          initialEmotion: 'Confiança',
          maturityLevel: LectioMaturityLevel.beginner,
        ),
      ),
      expect: () => [
        const LectioSessionInitial(isLoading: true),
        isA<LectioSessionInProgress>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.currentStep, 'currentStep', ImmersiveStep.lectio)
            .having((s) => s.session.passage?.reference, 'reference', 'Sl 23')
            .having(
              (s) => s.session.passage?.text,
              'text',
              'O Senhor é meu pastor, nada me faltará.',
            )
            .having((s) => s.session.emotion, 'emotion', 'Confiança')
            .having(
              (s) => s.precomputedMeditatioText,
              'precomputedMeditatioText',
              isNull,
            )
            .having(
              (s) => s.precomputedOratioPrompts,
              'precomputedOratioPrompts',
              isNull,
            ),
      ],
    );

    blocTest<LectioSessionBloc, LectioSessionState>(
      'StartFreePassageSessionEvent busca maturidade do perfil quando não informada',
      build: () {
        when(() => mockGetCurrentUser(any())).thenAnswer(
          (_) async => const Right(
            UserAuth(id: 'u1', email: 'u@u.com', displayName: 'U'),
          ),
        );
        when(() => mockGetProfile(any())).thenAnswer(
          (_) async => const Right(
            UserProfile(
              uid: 'u1',
              age: 25,
              gender: 'female',
              prayerIntentions: '',
              highestStreak: 30,
            ),
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(
        const StartFreePassageSessionEvent(
          passageText: 'Texto sem referência explícita',
        ),
      ),
      expect: () => [
        const LectioSessionInitial(isLoading: true),
        isA<LectioSessionInProgress>()
            .having(
              (s) => s.session.passage?.reference,
              'reference',
              'Passagem Livre',
            )
            .having(
              (s) => s.maturityLevel,
              'maturityLevel',
              LectioMaturityLevel.contemplative,
            ),
      ],
    );

    blocTest<LectioSessionBloc, LectioSessionState>(
      'StartLiturgicalSessionEvent inicia sessão com textos pré-computados da Liturgia Diária',
      build: () {
        when(() => mockGetCurrentUser(any())).thenAnswer(
          (_) async => const Right(
            UserAuth(id: 'u1', email: 'u@u.com', displayName: 'U'),
          ),
        );
        when(() => mockGetProfile(any())).thenAnswer(
          (_) async => const Right(
            UserProfile(
              uid: 'u1',
              age: 25,
              gender: 'female',
              prayerIntentions: '',
              highestStreak: 2,
            ),
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(
        const StartLiturgicalSessionEvent(
          readingReference: 'Jo 1, 1-14',
          readingText: 'E o Verbo se fez carne.',
          precomputedMeditatioText: 'Meditação oficial',
          precomputedOratioPrompts: ['Oração 1'],
          precomputedExegese: 'Exegese central',
        ),
      ),
      expect: () => [
        const LectioSessionInitial(isLoading: true),
        isA<LectioSessionInProgress>()
            .having((s) => s.session.passage?.reference, 'ref', 'Jo 1, 1-14')
            .having(
              (s) => s.precomputedMeditatioText,
              'meditatio',
              'Meditação oficial',
            )
            .having((s) => s.precomputedExegese, 'exegese', 'Exegese central'),
      ],
    );

    blocTest<LectioSessionBloc, LectioSessionState>(
      'emits [LectioSessionInProgress] with updated notes on SaveMeditatioEvent and SaveOratioEvent',
      build: () => bloc,
      seed: () => LectioSessionInProgress(
        session: LectioSession(id: '1', date: DateTime.now()),
        showMaturityCelebration: true,
      ),
      act: (bloc) => bloc
        ..add(const SaveMeditatioEvent('Minha meditação'))
        ..add(const SaveOratioEvent('Minha oração'))
        ..add(const AdvanceToStepEvent(2))
        ..add(DismissMaturityCelebrationEvent()),
      expect: () => [
        isA<LectioSessionInProgress>().having(
          (s) => s.session.meditatioNotes,
          'meditatioNotes',
          'Minha meditação',
        ),
        isA<LectioSessionInProgress>().having(
          (s) => s.session.oratioNotes,
          'oratioNotes',
          'Minha oração',
        ),
        isA<LectioSessionInProgress>().having(
          (s) => s.currentStep,
          'currentStep',
          ImmersiveStep.oratio,
        ),
        isA<LectioSessionInProgress>().having(
          (s) => s.showMaturityCelebration,
          'showMaturityCelebration',
          false,
        ),
      ],
    );

    blocTest<LectioSessionBloc, LectioSessionState>(
      'emits [LectioSessionInProgress(true), LectioSessionCompleted] on CompleteSessionEvent success and updates streak for authenticated user',
      build: () {
        when(() => mockSaveSession(any()))
            .thenAnswer((_) async => right<Failure, void>(null));
        when(() => mockGetCurrentUser(any())).thenAnswer(
          (_) async => const Right(
            UserAuth(id: 'user_1', email: 'a@a.com', displayName: 'A'),
          ),
        );
        when(() => mockUpdateStreak(any())).thenAnswer(
          (_) async => const Right(
            UserProfile(
              uid: 'user_1',
              age: 30,
              gender: 'male',
              prayerIntentions: '',
              highestStreak: 5,
            ),
          ),
        );
        return bloc;
      },
      seed: () => LectioSessionInProgress(
        session: LectioSession(id: '1', date: DateTime.now()),
      ),
      act: (bloc) => bloc.add(const CompleteSessionEvent('Ação')),
      expect: () => [
        isA<LectioSessionInProgress>().having(
          (s) => s.isLoading,
          'isLoading',
          true,
        ),
        const LectioSessionCompleted(isLoading: false),
      ],
      verify: (_) => verify(() => mockUpdateStreak('user_1')).called(1),
    );

    blocTest<LectioSessionBloc, LectioSessionState>(
      'emits [LectioSessionInProgress(true), LectioSessionError] on CompleteSessionEvent failure',
      build: () {
        when(() => mockSaveSession(any()))
            .thenAnswer((_) async => const Left(ServerFailure('Erro')));
        return bloc;
      },
      seed: () => LectioSessionInProgress(
        session: LectioSession(id: '1', date: DateTime.now()),
      ),
      act: (bloc) => bloc.add(const CompleteSessionEvent('Ação')),
      expect: () => [
        isA<LectioSessionInProgress>().having(
          (s) => s.isLoading,
          'isLoading',
          true,
        ),
        const LectioSessionError('Falha ao salvar sessão.', isLoading: false),
      ],
    );

    blocTest<LectioSessionBloc, LectioSessionState>(
      'ignores concurrent CompleteSessionEvent if already isLoading',
      build: () => bloc,
      seed: () => LectioSessionInProgress(
        session: LectioSession(id: '1', date: DateTime.now()),
        isLoading: true,
      ),
      act: (bloc) => bloc.add(const CompleteSessionEvent('Ação')),
      expect: () => <LectioSessionState>[],
      verify: (_) {
        verifyNever(() => mockSaveSession(any()));
      },
    );

    blocTest<LectioSessionBloc, LectioSessionState>(
      'debounces rapid ScrollReachedEndEvent to avoid skipping steps',
      build: () => bloc,
      seed: () => LectioSessionInProgress(
        session: LectioSession(id: '1', date: DateTime.now()),
        currentStep: ImmersiveStep.lectio,
      ),
      act: (bloc) {
        bloc.add(ScrollReachedEndEvent());
        // Disparo imediato em rajada (< 400ms)
        bloc.add(ScrollReachedEndEvent());
      },
      expect: () => [
        // Apenas uma transição deve ocorrer (de lectio para meditatio)
        isA<LectioSessionInProgress>().having(
          (s) => s.currentStep,
          'currentStep',
          ImmersiveStep.meditatio,
        ),
      ],
    );

    blocTest<LectioSessionBloc, LectioSessionState>(
      'ScrollReachedEndEvent transiciona meditatio -> oratio e oratio -> contemplatio após debounce',
      build: () => bloc,
      seed: () => LectioSessionInProgress(
        session: LectioSession(id: '1', date: DateTime.now()),
        currentStep: ImmersiveStep.meditatio,
      ),
      act: (bloc) async {
        bloc.add(ScrollReachedEndEvent());
        await Future<void>.delayed(const Duration(milliseconds: 450));
        bloc.add(ScrollReachedEndEvent());
        await Future<void>.delayed(const Duration(milliseconds: 450));
        bloc.add(ScrollReachedEndEvent()); // em contemplatio é no-op
      },
      expect: () => [
        isA<LectioSessionInProgress>().having(
          (s) => s.currentStep,
          'currentStep',
          ImmersiveStep.oratio,
        ),
        isA<LectioSessionInProgress>().having(
          (s) => s.currentStep,
          'currentStep',
          ImmersiveStep.contemplatio,
        ),
      ],
    );

    blocTest<LectioSessionBloc, LectioSessionState>(
      'invoca AnalyticsService (logLectioStarted, logLectioStepAdvanced, logLectioCompleted) durante o ciclo da sessão',
      build: () {
        final mockAnalytics = _MockAnalyticsService();
        when(
          () => mockAnalytics.logLectioStarted(
            readingType: any(named: 'readingType'),
            maturityLevel: any(named: 'maturityLevel'),
            isFromBff: any(named: 'isFromBff'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockAnalytics.logLectioStepAdvanced(
            stepName: any(named: 'stepName'),
            maturityLevel: any(named: 'maturityLevel'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockAnalytics.logLectioCompleted(
            durationSeconds: any(named: 'durationSeconds'),
            hasPersonalReflection: any(named: 'hasPersonalReflection'),
          ),
        ).thenAnswer((_) async {});
        when(() => mockSaveSession(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetCurrentUser(any()))
            .thenAnswer((_) async => const Right(null));

        return LectioSessionBloc(
          saveSession: mockSaveSession,
          getCurrentUser: mockGetCurrentUser,
          getProfile: mockGetProfile,
          updateStreak: mockUpdateStreak,
          llmRepository: mockLlmRepository,
          sharedPreferences: mockPrefs,
          analyticsService: mockAnalytics,
        );
      },
      act: (bloc) async {
        bloc.add(
          const StartLiturgicalSessionEvent(
            readingReference: 'Jo 1,1-5',
            readingText: 'No princípio era o Verbo',
            precomputedMeditatioText: 'Meditação BFF',
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));
        bloc.add(const AdvanceToStepEvent(1));
        await Future<void>.delayed(const Duration(milliseconds: 20));
        bloc.add(const CompleteSessionEvent('Praticar a caridade'));
      },
      verify: (bloc) {
        final analytics = bloc.analyticsService!;
        verify(
          () => analytics.logLectioStarted(
            readingType: 'daily_liturgy',
            maturityLevel: 'beginner',
            isFromBff: true,
          ),
        ).called(1);
        verify(
          () => analytics.logLectioStepAdvanced(
            stepName: 'meditatio',
            maturityLevel: 'beginner',
          ),
        ).called(1);
        verify(
          () => analytics.logLectioCompleted(
            durationSeconds: any(named: 'durationSeconds'),
            hasPersonalReflection: true,
          ),
        ).called(1);
      },
    );
  });
}

class _MockAnalyticsService extends Mock implements AnalyticsService {}
