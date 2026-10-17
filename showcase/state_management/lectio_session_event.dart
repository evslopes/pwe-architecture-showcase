import 'package:equatable/equatable.dart';

import 'package:pwe/features/lectio_divina/domain/entities/gota_contexto_entity.dart';
import 'package:pwe/features/profile/domain/entities/lectio_maturity_level.dart';

abstract class LectioSessionEvent extends Equatable {
  const LectioSessionEvent();

  @override
  List<Object?> get props => [];
}

class StartSessionEvent extends LectioSessionEvent {
  final String emotion;
  final LectioMaturityLevel? maturityLevel;
  const StartSessionEvent(this.emotion, {this.maturityLevel});
  @override
  List<Object?> get props => [emotion, maturityLevel];
}

class StartFreePassageSessionEvent extends LectioSessionEvent {
  final String? passageReference;
  final String? passageText;
  final String? initialEmotion;
  final LectioMaturityLevel? maturityLevel;

  const StartFreePassageSessionEvent({
    this.passageReference,
    this.passageText,
    this.initialEmotion,
    this.maturityLevel,
  });

  @override
  List<Object?> get props => [
    passageReference,
    passageText,
    initialEmotion,
    maturityLevel,
  ];
}

class StartLiturgicalSessionEvent extends LectioSessionEvent {
  final String readingReference;
  final String readingText;
  final String? initialEmotion;
  final String? language;
  final String? precomputedExegese;
  final List<GotaContextoEntity>? precomputedDrops;
  final Map<String, dynamic>? precomputedMeditatioMap;
  final String? precomputedMeditatioText;
  final List<String>? precomputedOratioPrompts;
  final LectioMaturityLevel? maturityLevel;

  const StartLiturgicalSessionEvent({
    required this.readingReference,
    required this.readingText,
    this.initialEmotion,
    this.language,
    this.precomputedExegese,
    this.precomputedDrops,
    this.precomputedMeditatioMap,
    this.precomputedMeditatioText,
    this.precomputedOratioPrompts,
    this.maturityLevel,
  });

  @override
  List<Object?> get props => [
    readingReference,
    readingText,
    initialEmotion,
    language,
    precomputedExegese,
    precomputedDrops,
    precomputedMeditatioMap,
    precomputedMeditatioText,
    precomputedOratioPrompts,
    maturityLevel,
  ];
}

class SaveMeditatioEvent extends LectioSessionEvent {
  final String meditatioNotes;
  const SaveMeditatioEvent(this.meditatioNotes);
  @override
  List<Object?> get props => [meditatioNotes];
}

class SaveOratioEvent extends LectioSessionEvent {
  final String oratioNotes;
  const SaveOratioEvent(this.oratioNotes);
  @override
  List<Object?> get props => [oratioNotes];
}

class CompleteSessionEvent extends LectioSessionEvent {
  final String contemplatioAction;
  final String? spiritualFruit;
  const CompleteSessionEvent(this.contemplatioAction, {this.spiritualFruit});
  @override
  List<Object?> get props => [contemplatioAction, spiritualFruit];
}

class AdvanceToStepEvent extends LectioSessionEvent {
  final int stepIndex;
  const AdvanceToStepEvent(this.stepIndex);
  @override
  List<Object?> get props => [stepIndex];
}

class ScrollReachedEndEvent extends LectioSessionEvent {}

class DismissMaturityCelebrationEvent extends LectioSessionEvent {}

class ResetSessionEvent extends LectioSessionEvent {}
