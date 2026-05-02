import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../finanzas/domain/entities/category.dart';
import '../../../finanzas/domain/entities/transaction.dart' as fin;
import '../../../finanzas/domain/repositories/transaction_repository.dart';
import '../../domain/entities/debt.dart';
import '../../domain/repositories/debt_repository.dart';
import '../../domain/usecases/add_debt_usecase.dart';
import '../../domain/usecases/delete_debt_usecase.dart';
import '../../domain/usecases/get_debts_usecase.dart';
import '../../domain/usecases/make_payment_usecase.dart';
import '../../domain/usecases/snowball_calculator.dart';
import 'debts_state.dart';

/// StateNotifier del feature debts.
///
/// Importante: este notifier orquesta DOS features (debts + finanzas) en la
/// capa de presentación, lo cual es válido. La regla de Clean Architecture es
/// que la capa de DOMINIO no se cruce — y en domain ambos features siguen
/// totalmente independientes.
class DebtsNotifier extends StateNotifier<DebtsState> {
  final GetDebtsUseCase getDebts;
  final AddDebtUseCase addDebt;
  final DeleteDebtUseCase deleteDebt;
  final MakePaymentUseCase makePayment;
  final DebtRepository repository;
  final SnowballCalculator calculator;

  /// Repositorio de transacciones para crear el gasto auto al pagar deudas.
  final TransactionRepository transactionRepository;

  /// Callback opcional para refrescar el feed de transacciones del Home.
  /// Se inyecta desde el provider para no acoplar este notifier al
  /// transactionsNotifierProvider directamente.
  final Future<void> Function()? onTransactionCreated;

  DebtsNotifier({
    required this.getDebts,
    required this.addDebt,
    required this.deleteDebt,
    required this.makePayment,
    required this.repository,
    required this.calculator,
    required this.transactionRepository,
    this.onTransactionCreated,
  }) : super(const DebtsState());

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final debtsResult = await getDebts();
    final extraResult = await repository.getMonthlyExtra();

    debtsResult.fold(
      onSuccess: (debts) {
        final extra = extraResult.valueOrNull ?? 0;
        final plan = calculator.calculate(
          debts: debts,
          monthlyExtra: extra,
        );
        state = state.copyWith(
          isLoading: false,
          debts: debts,
          monthlyExtra: extra,
          plan: plan,
        );
      },
      onFailure: (f) {
        state = state.copyWith(isLoading: false, errorMessage: f.message);
      },
    );
  }

  Future<bool> add(Debt debt) async {
    final result = await addDebt(debt);
    return result.fold(
      onSuccess: (_) async {
        await loadAll();
        return true;
      },
      onFailure: (f) {
        state = state.copyWith(errorMessage: f.message);
        return false;
      },
    );
  }

  Future<void> remove(String id) async {
    await deleteDebt(id);
    await loadAll();
  }

  /// Registra un pago a una deuda y AUTOMÁTICAMENTE crea un gasto en
  /// transacciones (categoría 'debts'). Así el balance del mes y las
  /// estadísticas reflejan la realidad sin que el usuario tenga que
  /// registrar el mismo monto dos veces.
  Future<bool> registerPayment({
    required Debt debt,
    required double amount,
    String? note,
  }) async {
    // 1. Aplicar el pago a la deuda (use case puro).
    final result = await makePayment(debt: debt, amount: amount, note: note);

    return result.fold(
      onSuccess: (updatedDebt) async {
        // 2. Crear el gasto vinculado en finanzas.
        final applied =
            amount > debt.currentBalance ? debt.currentBalance : amount;
        final tx = fin.Transaction(
          id: 'debt-${debt.id}-${DateTime.now().millisecondsSinceEpoch}',
          amount: applied,
          description: 'Pago: ${debt.name}',
          categoryId: TransactionCategory.debtsCategoryId,
          type: fin.TransactionType.expense,
          date: DateTime.now(),
        );
        await transactionRepository.add(tx);

        // 3. Refrescar deudas y el feed de transacciones.
        await loadAll();
        if (onTransactionCreated != null) {
          await onTransactionCreated!();
        }
        return true;
      },
      onFailure: (f) {
        state = state.copyWith(errorMessage: f.message);
        return false;
      },
    );
  }

  Future<void> setMonthlyExtra(double amount) async {
    await repository.setMonthlyExtra(amount);
    await loadAll();
  }

  void clearError() => state = state.copyWith(clearError: true);
}
