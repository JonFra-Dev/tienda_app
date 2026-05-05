import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/baby_step_progress_local_datasource.dart';
import '../../domain/entities/baby_step.dart';

/// Provider del datasource de progreso (last celebrated step + dismissals).
final babyStepProgressDataSourceProvider =
    Provider<BabyStepProgressLocalDataSource>((ref) {
  return BabyStepProgressLocalDataSource(ref.watch(sharedPreferencesProvider));
});

/// Notifier que maneja la lógica de celebraciones:
///   - Detecta cuando el usuario completa un nuevo step
///   - Solo emite UNA celebración por step (idempotente)
///   - Persiste el último step celebrado en SharedPreferences
class CelebrationsNotifier extends StateNotifier<BabyStep?> {
  final BabyStepProgressLocalDataSource dataSource;

  CelebrationsNotifier(this.dataSource) : super(null);

  /// Llamar cada vez que cambia el BabyStepsStatus para revisar si hay
  /// un nuevo paso completado que debería celebrarse.
  ///
  /// [completedStepNumbers] = lista de números de pasos completados
  /// (ej: [1, 2] si completó Step 1 y Step 2).
  void checkForNewCompletion(Iterable<int> completedStepNumbers) {
    if (completedStepNumbers.isEmpty) return;

    final maxCompleted =
        completedStepNumbers.reduce((a, b) => a > b ? a : b);
    final lastCelebrated = dataSource.getLastCelebratedStep();

    if (maxCompleted > lastCelebrated) {
      // ¡Nuevo paso completado! Emite la celebración.
      state = BabyStep.values[maxCompleted - 1];
    }
  }

  /// Llamar después de mostrar el dialog de celebración para que no
  /// vuelva a aparecer.
  Future<void> acknowledgeCelebration() async {
    final celebrated = state;
    if (celebrated != null) {
      await dataSource.setLastCelebratedStep(celebrated.number);
      state = null;
    }
  }

  /// Resetear (útil para testing o "celebrar todo de nuevo")
  Future<void> reset() async {
    await dataSource.setLastCelebratedStep(0);
    state = null;
  }
}

final celebrationsProvider =
    StateNotifierProvider<CelebrationsNotifier, BabyStep?>((ref) {
  return CelebrationsNotifier(ref.watch(babyStepProgressDataSourceProvider));
});
