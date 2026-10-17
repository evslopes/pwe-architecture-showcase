import 'package:equatable/equatable.dart';

import 'package:pwe/features/lectio_divina/domain/entities/gota_contexto_entity.dart';
import 'package:pwe/features/lectio_divina/domain/entities/lectio_session.dart';
import 'package:pwe/features/lectio_divina/domain/enums/immersive_step.dart';
import 'package:pwe/features/profile/domain/entities/lectio_maturity_level.dart';

export 'package:pwe/features/lectio_divina/domain/enums/immersive_step.dart';

abstract class LectioSessionState extends Equatable {
  final bool isLoading;

  const LectioSessionState({this.isLoading = false});

  @override
  List<Object?> get props => [isLoading];
}

class LectioSessionInitial extends LectioSessionState {
  const LectioSessionInitial({super.isLoading = false});
}

class LectioSessionInProgress extends LectioSessionState {
  final LectioSession session;
  final ImmersiveStep currentStep;
  final LectioMaturityLevel maturityLevel;
  final bool showMaturityCelebration;
  final String? precomputedMeditatioText;
  final Map<String, dynamic>? precomputedMeditatioMap;
  final List<String>? precomputedOratioPrompts;
  final String? precomputedExegese;
  final List<GotaContextoEntity>? precomputedDrops;

  const LectioSessionInProgress({
    required this.session,
    this.currentStep = ImmersiveStep.lectio,
    this.maturityLevel = LectioMaturityLevel.beginner,
    this.showMaturityCelebration = false,
    this.precomputedMeditatioText,
    this.precomputedMeditatioMap,
    this.precomputedOratioPrompts,
    this.precomputedExegese,
    this.precomputedDrops,
    super.isLoading = false,
  });

  /// Retorna o prompt de meditação resolvido a partir dos dados pré-computados
  /// do Firestore ou nulo se não houver dados pré-computados.
  String? get resolvedMeditatioPrompt {
    String? meditatioByMaturity;
    if (precomputedMeditatioMap != null &&
        precomputedMeditatioMap!.isNotEmpty) {
      meditatioByMaturity = switch (maturityLevel) {
        LectioMaturityLevel.beginner =>
          precomputedMeditatioMap!['beginner'] as String? ??
              precomputedMeditatioMap!['iniciante'] as String?,
        LectioMaturityLevel.practitioner =>
          precomputedMeditatioMap!['practitioner'] as String? ??
              precomputedMeditatioMap!['intermediate'] as String? ??
              precomputedMeditatioMap!['praticante'] as String?,
        LectioMaturityLevel.contemplative =>
          precomputedMeditatioMap!['contemplative'] as String? ??
              precomputedMeditatioMap!['advanced'] as String? ??
              precomputedMeditatioMap!['contemplativo'] as String?,
      };
      meditatioByMaturity ??=
          precomputedMeditatioMap![maturityLevel.name] as String? ??
          precomputedMeditatioMap!['beginner'] as String? ??
          precomputedMeditatioMap!.values.firstOrNull?.toString();
    }

    if (precomputedMeditatioText != null &&
        precomputedMeditatioText!.trim().isNotEmpty) {
      final baseText = precomputedMeditatioText!.trim();
      if (meditatioByMaturity != null &&
          meditatioByMaturity.trim().isNotEmpty) {
        return '$baseText\n\n$meditatioByMaturity';
      }
      return baseText;
    }

    return meditatioByMaturity;
  }

  @override
  List<Object?> get props => [
    session,
    currentStep,
    maturityLevel,
    showMaturityCelebration,
    precomputedMeditatioText,
    precomputedMeditatioMap,
    precomputedOratioPrompts,
    precomputedExegese,
    precomputedDrops,
    isLoading,
  ];
}

class LectioSessionCompleted extends LectioSessionState {
  const LectioSessionCompleted({super.isLoading = false});
}

class LectioSessionError extends LectioSessionState {
  final String message;

  const LectioSessionError(this.message, {super.isLoading = false});

  @override
  List<Object?> get props => [message, isLoading];
}
