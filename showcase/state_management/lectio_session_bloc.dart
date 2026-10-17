import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:pwe/core/services/analytics_service.dart';
import 'package:pwe/core/usecases/usecase.dart';
import 'package:pwe/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:pwe/features/profile/domain/entities/lectio_maturity_level.dart';
import 'package:pwe/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:pwe/features/profile/domain/usecases/update_streak_usecase.dart';
import 'package:pwe/features/lectio_divina/domain/entities/biblical_passage.dart';
import 'package:pwe/features/lectio_divina/domain/entities/gota_contexto_entity.dart';
import 'package:pwe/features/lectio_divina/domain/entities/lectio_session.dart';
import 'package:pwe/features/lectio_divina/domain/repositories/llm_repository.dart';
import 'package:pwe/features/lectio_divina/domain/usecases/save_session_usecase.dart';
import 'package:pwe/features/lectio_divina/presentation/bloc/lectio_session/lectio_session_event.dart';
import 'package:pwe/features/lectio_divina/presentation/bloc/lectio_session/lectio_session_state.dart';

/// Orchestrates the Lectio Divina session lifecycle.
class LectioSessionBloc extends Bloc<LectioSessionEvent, LectioSessionState> {
  final SaveSessionUseCase saveSession;
  final GetCurrentUserUseCase getCurrentUser;
  final GetProfileUseCase getProfile;
  final UpdateStreakUseCase updateStreak;
  final ILlmRepository llmRepository;
  final SharedPreferences sharedPreferences;
  final AnalyticsService? analyticsService;
  final Uuid uuid = const Uuid();
  DateTime? _lastStepTransitionTime;

  LectioSessionBloc({
    required this.saveSession,
    required this.getCurrentUser,
    required this.getProfile,
    required this.updateStreak,
    required this.llmRepository,
    required this.sharedPreferences,
    this.analyticsService,
  }) : super(LectioSessionInitial()) {
    on<StartSessionEvent>(_onStartSession);
    on<StartFreePassageSessionEvent>(_onStartFreePassageSession);
    on<StartLiturgicalSessionEvent>(_onStartLiturgicalSession);
    on<SaveMeditatioEvent>(_onSaveMeditatio);
    on<SaveOratioEvent>(_onSaveOratio);
    on<CompleteSessionEvent>(_onCompleteSession);
    on<AdvanceToStepEvent>(_onAdvanceToStep);
    on<ScrollReachedEndEvent>(_onScrollReachedEnd);
    on<DismissMaturityCelebrationEvent>(_onDismissMaturityCelebration);
    on<ResetSessionEvent>(_onResetSession);
  }

  void _onResetSession(
    ResetSessionEvent event,
    Emitter<LectioSessionState> emit,
  ) {
    llmRepository.resetSession();
    emit(LectioSessionInitial());
  }

  Future<void> _onStartSession(
    StartSessionEvent event,
    Emitter<LectioSessionState> emit,
  ) async {
    if (state is LectioSessionInProgress) {
      emit(_copyWithState(state as LectioSessionInProgress, isLoading: true));
    } else {
      emit(const LectioSessionInitial(isLoading: true));
    }

    llmRepository.resetSession();
    LectioMaturityLevel maturityLevel =
        event.maturityLevel ?? LectioMaturityLevel.beginner;

    if (event.maturityLevel == null) {
      final userRes = await getCurrentUser(NoParams());
      final user = userRes.getOrElse(() => null);

      if (user != null) {
        final profileRes = await getProfile(user.id);
        final profile = profileRes.getOrElse(() => null);
        if (profile != null) {
          maturityLevel = profile.maturityLevel;
        }
      }
    }

    final lastNotifiedStr = sharedPreferences.getString(
      'last_notified_maturity',
    );
    bool showCelebration = false;

    if (lastNotifiedStr != null) {
      final lastNotifiedVal = LectioMaturityLevel.values.firstWhere(
        (e) => e.toString() == lastNotifiedStr,
        orElse: () => LectioMaturityLevel.beginner,
      );

      if (maturityLevel.index > lastNotifiedVal.index) {
        showCelebration = true;
      }
    }

    await sharedPreferences.setString(
      'last_notified_maturity',
      maturityLevel.toString(),
    );

    final session = LectioSession(
      id: uuid.v4(),
      date: DateTime.now(),
      emotion: event.emotion,
    );

    dev.log(
      '✠ [LectioJourney] Iniciando Sessão Livre: Emoção "${event.emotion}" | Maturidade: ${maturityLevel.name}',
    );

    unawaited(
      analyticsService?.logLectioStarted(
        readingType: 'emotional_session',
        maturityLevel: maturityLevel.name,
        isFromBff: false,
      ),
    );

    await llmRepository.startSession(event.emotion);

    emit(
      LectioSessionInProgress(
        session: session,
        maturityLevel: maturityLevel,
        showMaturityCelebration: showCelebration,
        isLoading: false,
      ),
    );
  }

  Future<void> _onStartFreePassageSession(
    StartFreePassageSessionEvent event,
    Emitter<LectioSessionState> emit,
  ) async {
    emit(const LectioSessionInitial(isLoading: true));

    llmRepository.resetSession();

    LectioMaturityLevel maturityLevel =
        event.maturityLevel ?? LectioMaturityLevel.beginner;

    if (event.maturityLevel == null) {
      final userRes = await getCurrentUser(NoParams());
      final user = userRes.getOrElse(() => null);

      if (user != null) {
        final profileRes = await getProfile(user.id);
        final profile = profileRes.getOrElse(() => null);
        if (profile != null) {
          maturityLevel = profile.maturityLevel;
        }
      }
    }

    final passage =
        (event.passageText != null && event.passageText!.trim().isNotEmpty)
        ? BiblicalPassage(
            reference: event.passageReference?.trim().isNotEmpty == true
                ? event.passageReference!.trim()
                : 'Passagem Livre',
            text: event.passageText!.trim(),
          )
        : null;

    final session = LectioSession(
      id: uuid.v4(),
      date: DateTime.now(),
      emotion: event.initialEmotion ?? 'Passagem Livre',
      passage: passage,
    );

    dev.log(
      '✠ [LectioJourney] Iniciando Sessão de Passagem Livre | Ref: "${passage?.reference ?? 'Sem ref'}" | Emoção: "${session.emotion}" | Maturidade: ${maturityLevel.name}',
    );

    unawaited(
      analyticsService?.logLectioStarted(
        readingType: 'free_passage',
        maturityLevel: maturityLevel.name,
        isFromBff: false,
      ),
    );

    if (event.initialEmotion != null && event.initialEmotion!.isNotEmpty) {
      await llmRepository.startSession(event.initialEmotion!);
    }

    emit(
      LectioSessionInProgress(
        session: session,
        currentStep: ImmersiveStep.lectio,
        maturityLevel: maturityLevel,
        isLoading: false,
      ),
    );
  }

  Future<void> _onStartLiturgicalSession(
    StartLiturgicalSessionEvent event,
    Emitter<LectioSessionState> emit,
  ) async {
    if (state is LectioSessionInProgress) {
      emit(_copyWithState(state as LectioSessionInProgress, isLoading: true));
    } else {
      emit(const LectioSessionInitial(isLoading: true));
    }

    llmRepository.resetSession();
    LectioMaturityLevel maturityLevel =
        event.maturityLevel ?? LectioMaturityLevel.beginner;

    if (event.maturityLevel == null) {
      final userRes = await getCurrentUser(NoParams());
      final user = userRes.getOrElse(() => null);

      if (user != null) {
        final profileRes = await getProfile(user.id);
        final profile = profileRes.getOrElse(() => null);
        if (profile != null) {
          maturityLevel = profile.maturityLevel;
        }
      }
    }

    final initialEmotion = event.initialEmotion ?? 'Liturgia do Dia';
    final session = LectioSession(
      id: uuid.v4(),
      date: DateTime.now(),
      emotion: initialEmotion,
      passage: BiblicalPassage(
        reference: event.readingReference,
        text: event.readingText,
      ),
    );

    dev.log(
      '✠ [LectioJourney] Iniciando Lectio Litúrgica: "${event.readingReference}" | Maturidade: ${maturityLevel.name}',
    );

    final isFromBff =
        event.precomputedMeditatioText != null ||
        event.precomputedMeditatioMap != null;

    unawaited(
      analyticsService?.logLectioStarted(
        readingType: 'daily_liturgy',
        maturityLevel: maturityLevel.name,
        isFromBff: isFromBff,
      ),
    );

    emit(
      LectioSessionInProgress(
        session: session,
        maturityLevel: maturityLevel,
        precomputedMeditatioText: event.precomputedMeditatioText,
        precomputedMeditatioMap: event.precomputedMeditatioMap,
        precomputedOratioPrompts: event.precomputedOratioPrompts,
        precomputedExegese: event.precomputedExegese,
        precomputedDrops: event.precomputedDrops,
        isLoading: false,
      ),
    );
  }

  void _onSaveMeditatio(
    SaveMeditatioEvent event,
    Emitter<LectioSessionState> emit,
  ) {
    if (state is LectioSessionInProgress) {
      final currentState = state as LectioSessionInProgress;
      dev.log(
        '✍️ [LectioJourney] Reflexão da Meditatio registrada (${event.meditatioNotes.length} caracteres)',
      );
      emit(
        _copyWithState(
          currentState,
          session: currentState.session.copyWith(
            meditatioNotes: event.meditatioNotes,
          ),
        ),
      );
    }
  }

  void _onSaveOratio(SaveOratioEvent event, Emitter<LectioSessionState> emit) {
    if (state is LectioSessionInProgress) {
      final currentState = state as LectioSessionInProgress;
      dev.log(
        '✍️ [LectioJourney] Oração pessoal da Oratio registrada (${event.oratioNotes.length} caracteres)',
      );
      emit(
        _copyWithState(
          currentState,
          session: currentState.session.copyWith(
            oratioNotes: event.oratioNotes,
          ),
        ),
      );
    }
  }

  Future<void> _onCompleteSession(
    CompleteSessionEvent event,
    Emitter<LectioSessionState> emit,
  ) async {
    if (state is LectioSessionInProgress) {
      final currentState = state as LectioSessionInProgress;
      // BLINDAGEM DE CONCORRÊNCIA: evita duplo salvamento acidental
      if (currentState.isLoading) {
        dev.log(
          '⚠️ [LectioJourney] CompleteSessionEvent ignorado: salvamento já em andamento.',
        );
        return;
      }
      emit(_copyWithState(currentState, isLoading: true));

      final finalSession = currentState.session.copyWith(
        contemplatioAction: event.contemplatioAction,
        spiritualFruit: event.spiritualFruit,
      );

      final duration = DateTime.now()
          .difference(currentState.session.date)
          .inSeconds;
      dev.log(
        '💾 [LectioJourney] Persistindo sessão da Lectio Divina (Duração: ${duration}s | Ação: ${event.contemplatioAction.isNotEmpty})',
      );

      final result = await saveSession(finalSession);

      llmRepository.resetSession();

      if (result.isLeft()) {
        emit(
          const LectioSessionError('Falha ao salvar sessão.', isLoading: false),
        );
        return;
      }

      dev.log(
        '✅ [LectioJourney] Sessão concluída com êxito! Fruto espiritual preservado no Caderno Espiritual.',
      );

      final hasPersonalReflection =
          (finalSession.meditatioNotes?.trim().isNotEmpty ?? false) ||
          (finalSession.oratioNotes?.trim().isNotEmpty ?? false) ||
          (finalSession.contemplatioAction?.trim().isNotEmpty ?? false) ||
          (finalSession.spiritualFruit?.trim().isNotEmpty ?? false);

      unawaited(
        analyticsService?.logLectioCompleted(
          durationSeconds: duration,
          hasPersonalReflection: hasPersonalReflection,
        ),
      );

      final userResult = await getCurrentUser(NoParams());
      final user = userResult.getOrElse(() => null);
      if (user != null) {
        await updateStreak(user.id);
      }

      emit(const LectioSessionCompleted(isLoading: false));
    }
  }

  void _onAdvanceToStep(
    AdvanceToStepEvent event,
    Emitter<LectioSessionState> emit,
  ) {
    if (state is LectioSessionInProgress) {
      final currentState = state as LectioSessionInProgress;
      final steps = ImmersiveStep.values;
      if (event.stepIndex >= 0 && event.stepIndex < steps.length) {
        final targetStep = steps[event.stepIndex];
        dev.log(
          '🕊️ [LectioJourney] Avançando para etapa: ${targetStep.name.toUpperCase()}',
        );
        unawaited(
          analyticsService?.logLectioStepAdvanced(
            stepName: targetStep.name,
            maturityLevel: currentState.maturityLevel.name,
          ),
        );
        emit(_copyWithState(currentState, currentStep: targetStep));
      }
    }
  }

  void _onScrollReachedEnd(
    ScrollReachedEndEvent event,
    Emitter<LectioSessionState> emit,
  ) {
    if (state is LectioSessionInProgress) {
      final currentState = state as LectioSessionInProgress;

      // BLINDAGEM DE CONCORRÊNCIA: debounce temporal (400ms) para evitar saltos múltiplos em rajada de scroll
      final now = DateTime.now();
      if (_lastStepTransitionTime != null &&
          now.difference(_lastStepTransitionTime!).inMilliseconds < 400) {
        dev.log(
          '⚠️ [LectioJourney] ScrollReachedEndEvent ignorado por debounce temporal.',
        );
        return;
      }
      _lastStepTransitionTime = now;

      switch (currentState.currentStep) {
        case ImmersiveStep.lectio:
          dev.log('📖 ➔ 🕊️ [LectioJourney] Transição para MEDITATIO');
          unawaited(
            analyticsService?.logLectioStepAdvanced(
              stepName: ImmersiveStep.meditatio.name,
              maturityLevel: currentState.maturityLevel.name,
            ),
          );
          emit(
            _copyWithState(currentState, currentStep: ImmersiveStep.meditatio),
          );
          break;
        case ImmersiveStep.meditatio:
          dev.log('🕊️ ➔ 🙏 [LectioJourney] Transição para ORATIO');
          unawaited(
            analyticsService?.logLectioStepAdvanced(
              stepName: ImmersiveStep.oratio.name,
              maturityLevel: currentState.maturityLevel.name,
            ),
          );
          emit(_copyWithState(currentState, currentStep: ImmersiveStep.oratio));
          break;
        case ImmersiveStep.oratio:
          dev.log('🙏 ➔ ☀️ [LectioJourney] Transição para CONTEMPLATIO');
          unawaited(
            analyticsService?.logLectioStepAdvanced(
              stepName: ImmersiveStep.contemplatio.name,
              maturityLevel: currentState.maturityLevel.name,
            ),
          );
          emit(
            _copyWithState(
              currentState,
              currentStep: ImmersiveStep.contemplatio,
            ),
          );
          break;
        case ImmersiveStep.contemplatio:
          break;
      }
    }
  }

  void _onDismissMaturityCelebration(
    DismissMaturityCelebrationEvent event,
    Emitter<LectioSessionState> emit,
  ) {
    if (state is LectioSessionInProgress) {
      final currentState = state as LectioSessionInProgress;
      emit(_copyWithState(currentState, showMaturityCelebration: false));
    }
  }

  LectioSessionInProgress _copyWithState(
    LectioSessionInProgress state, {
    LectioSession? session,
    ImmersiveStep? currentStep,
    LectioMaturityLevel? maturityLevel,
    bool? showMaturityCelebration,
    String? precomputedMeditatioText,
    Map<String, dynamic>? precomputedMeditatioMap,
    List<String>? precomputedOratioPrompts,
    String? precomputedExegese,
    List<GotaContextoEntity>? precomputedDrops,
    bool? isLoading,
  }) {
    return LectioSessionInProgress(
      session: session ?? state.session,
      currentStep: currentStep ?? state.currentStep,
      maturityLevel: maturityLevel ?? state.maturityLevel,
      showMaturityCelebration:
          showMaturityCelebration ?? state.showMaturityCelebration,
      precomputedMeditatioText:
          precomputedMeditatioText ?? state.precomputedMeditatioText,
      precomputedMeditatioMap:
          precomputedMeditatioMap ?? state.precomputedMeditatioMap,
      precomputedOratioPrompts:
          precomputedOratioPrompts ?? state.precomputedOratioPrompts,
      precomputedExegese: precomputedExegese ?? state.precomputedExegese,
      precomputedDrops: precomputedDrops ?? state.precomputedDrops,
      isLoading: isLoading ?? state.isLoading,
    );
  }
}
