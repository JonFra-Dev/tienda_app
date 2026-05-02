import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../finanzas/presentation/providers/finanzas_providers.dart';
import '../../data/datasources/debt_local_datasource.dart';
import '../../data/repositories/debt_repository_impl.dart';
import '../../domain/repositories/debt_repository.dart';
import '../../domain/usecases/add_debt_usecase.dart';
import '../../domain/usecases/delete_debt_usecase.dart';
import '../../domain/usecases/get_debts_usecase.dart';
import '../../domain/usecases/make_payment_usecase.dart';
import '../../domain/usecases/snowball_calculator.dart';
import 'debts_notifier.dart';
import 'debts_state.dart';

// Datasource
final debtLocalDataSourceProvider = Provider<DebtLocalDataSource>((ref) {
  return DebtLocalDataSource(ref.watch(sharedPreferencesProvider));
});

// Repository
final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  return DebtRepositoryImpl(ref.watch(debtLocalDataSourceProvider));
});

// Usecases
final getDebtsUseCaseProvider = Provider<GetDebtsUseCase>((ref) {
  return GetDebtsUseCase(ref.watch(debtRepositoryProvider));
});

final addDebtUseCaseProvider = Provider<AddDebtUseCase>((ref) {
  return AddDebtUseCase(ref.watch(debtRepositoryProvider));
});

final deleteDebtUseCaseProvider = Provider<DeleteDebtUseCase>((ref) {
  return DeleteDebtUseCase(ref.watch(debtRepositoryProvider));
});

final makePaymentUseCaseProvider = Provider<MakePaymentUseCase>((ref) {
  return MakePaymentUseCase(ref.watch(debtRepositoryProvider));
});

final snowballCalculatorProvider =
    Provider<SnowballCalculator>((ref) => const SnowballCalculator());

// Notifier — ahora también inyecta el TransactionRepository (cross-feature)
// y un callback para refrescar el feed de transacciones cuando se crea un gasto
// auto-generado al pagar una deuda.
final debtsNotifierProvider =
    StateNotifierProvider<DebtsNotifier, DebtsState>((ref) {
  return DebtsNotifier(
    getDebts: ref.watch(getDebtsUseCaseProvider),
    addDebt: ref.watch(addDebtUseCaseProvider),
    deleteDebt: ref.watch(deleteDebtUseCaseProvider),
    makePayment: ref.watch(makePaymentUseCaseProvider),
    repository: ref.watch(debtRepositoryProvider),
    calculator: ref.watch(snowballCalculatorProvider),
    transactionRepository: ref.watch(transactionRepositoryProvider),
    onTransactionCreated: () =>
        ref.read(transactionsNotifierProvider.notifier).loadAll(),
  );
});
