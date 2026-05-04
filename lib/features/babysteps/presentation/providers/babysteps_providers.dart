import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../debts/presentation/providers/debts_providers.dart';
import '../../../finanzas/presentation/providers/finanzas_providers.dart';
import '../../../savings/presentation/providers/savings_providers.dart';
import '../../domain/entities/baby_steps_status.dart';
import '../../domain/usecases/baby_step_calculator.dart';

/// Provider de la calculadora pura.
final babyStepCalculatorProvider =
    Provider<BabyStepCalculator>((ref) => const BabyStepCalculator());

/// Provider que combina los 3 features y devuelve el estado actual de baby
/// steps. Se actualiza automáticamente cuando cualquier dato relevante cambia.
final babyStepsStatusProvider = Provider<BabyStepsStatus>((ref) {
  final savingsState = ref.watch(savingsNotifierProvider);
  final debtsState = ref.watch(debtsNotifierProvider);
  final transactionsState = ref.watch(transactionsNotifierProvider);
  final calculator = ref.watch(babyStepCalculatorProvider);

  return calculator.calculate(
    accounts: savingsState.accounts,
    debts: debtsState.debts,
    incomeSources: savingsState.incomeSources,
    transactions: transactionsState.transactions,
  );
});
