import 'package:equatable/equatable.dart';

import 'baby_step.dart';

/// Estado actual del usuario en los baby steps.
class BabyStepsStatus extends Equatable {
  /// El paso en el que el usuario se encuentra actualmente.
  final BabyStep currentStep;

  /// Progreso hacia completar el paso actual (0.0 a 1.0).
  final double progressToCurrent;

  /// Pasos ya completados.
  final Set<BabyStep> completedSteps;

  /// Valor actual relevante para el paso (ej: balance de fondo emergencia).
  final double currentValue;

  /// Valor objetivo del paso actual (ej: \$4M para Step 1).
  final double targetValue;

  /// Mensaje contextual para el usuario.
  final String contextMessage;

  const BabyStepsStatus({
    required this.currentStep,
    required this.progressToCurrent,
    required this.completedSteps,
    required this.currentValue,
    required this.targetValue,
    required this.contextMessage,
  });

  bool isCompleted(BabyStep step) => completedSteps.contains(step);

  /// Cuánto falta para completar el paso actual.
  double get remainingAmount =>
      (targetValue - currentValue).clamp(0, double.infinity);

  /// El usuario alcanzó la libertad financiera (Step 7).
  bool get isFinanciallyFree =>
      currentStep == BabyStep.step7 && progressToCurrent >= 1.0;

  @override
  List<Object?> get props => [
        currentStep,
        progressToCurrent,
        completedSteps,
        currentValue,
        targetValue,
        contextMessage,
      ];
}
