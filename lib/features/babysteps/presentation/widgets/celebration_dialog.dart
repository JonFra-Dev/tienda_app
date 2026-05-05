import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/baby_step.dart';

/// Diálogo celebratorio que aparece cuando el usuario completa un Baby Step.
class CelebrationDialog extends StatelessWidget {
  final BabyStep completedStep;
  final VoidCallback? onContinue;
  final VoidCallback? onSeePlan;

  const CelebrationDialog({
    super.key,
    required this.completedStep,
    this.onContinue,
    this.onSeePlan,
  });

  /// Helper para mostrar el diálogo desde cualquier pantalla.
  static Future<void> show(
    BuildContext context, {
    required BabyStep step,
    VoidCallback? onSeePlan,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CelebrationDialog(
        completedStep: step,
        onContinue: () => Navigator.of(ctx).pop(),
        onSeePlan: onSeePlan,
      ),
    );
  }

  String get _emoji {
    switch (completedStep) {
      case BabyStep.step1:
        return '🎯';
      case BabyStep.step2:
        return '🔥';
      case BabyStep.step3:
        return '🛡️';
      case BabyStep.step4:
        return '📈';
      case BabyStep.step5:
        return '🎓';
      case BabyStep.step6:
        return '🏠';
      case BabyStep.step7:
        return '🏆';
    }
  }

  String get _celebrationMessage {
    switch (completedStep) {
      case BabyStep.step1:
        return '¡Tienes tu fondo de emergencia inicial! Ya no estás a una sola crisis de quedar peor que antes.';
      case BabyStep.step2:
        return '¡Estás libre de deudas (excepto hipoteca)! Es uno de los logros financieros más grandes que existen.';
      case BabyStep.step3:
        return '¡Tu fondo de emergencia completo está listo! Ahora puedes dormir tranquilo aunque pase lo peor.';
      case BabyStep.step4:
        return '¡Estás invirtiendo el 15% al retiro! Tu yo del futuro te va a agradecer.';
      case BabyStep.step5:
        return '¡La educación de tus hijos está asegurada! Eso es un regalo para toda la vida.';
      case BabyStep.step6:
        return '¡Tu hipoteca está pagada! Tu casa es 100% tuya. Esto es libertad real.';
      case BabyStep.step7:
        return '¡Eres LIBRE! Construye riqueza, disfruta tu vida y sé generoso con otros.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.purple, AppColors.indigo],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _emoji,
              style: const TextStyle(fontSize: 72),
            ),
            const SizedBox(height: 8),
            const Text(
              '¡Felicitaciones!',
              style: TextStyle(
                color: AppColors.yellow,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Completaste ${completedStep.title}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              completedStep.shortName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _celebrationMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            if (onSeePlan != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    onContinue?.call();
                    onSeePlan!();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow,
                    foregroundColor: AppColors.indigo,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Ver mi plan completo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            TextButton(
              onPressed: onContinue,
              child: const Text(
                'Seguir adelante',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
