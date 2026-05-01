import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/notification_service.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/add_transaction_usecase.dart';
import '../../domain/usecases/budget_calculator.dart';
import '../../domain/usecases/delete_transaction_usecase.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import 'transactions_state.dart';

class TransactionsNotifier extends StateNotifier<TransactionsState> {
  final GetTransactionsUseCase getTransactions;
  final AddTransactionUseCase addTransaction;
  final DeleteTransactionUseCase deleteTransaction;
  final TransactionRepository repository;
  final BudgetCalculator calculator;
  final NotificationService notificationService;

  TransactionsNotifier({
    required this.getTransactions,
    required this.addTransaction,
    required this.deleteTransaction,
    required this.repository,
    required this.calculator,
    required this.notificationService,
  }) : super(const TransactionsState());

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await getTransactions();
    final budgetResult = await repository.getMonthlyBudget();

    result.fold(
      onSuccess: (txs) {
        final budget = budgetResult.valueOrNull ?? 0;
        state = state.copyWith(
          isLoading: false,
          transactions: txs,
          summary: calculator.calculate(
            transactions: txs,
            monthlyBudget: budget,
          ),
        );
      },
      onFailure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  Future<bool> add(Transaction t) async {
    final result = await addTransaction(t);
    final ok = result.fold(
      onSuccess: (_) => true,
      onFailure: (f) {
        state = state.copyWith(errorMessage: f.message);
        return false;
      },
    );
    if (ok) {
      await loadAll();
      _checkBudgetAlert();
    }
    return ok;
  }

  Future<void> remove(String id) async {
    final result = await deleteTransaction(id);
    result.fold(
      onSuccess: (_) async => loadAll(),
      onFailure: (f) =>
          state = state.copyWith(errorMessage: f.message),
    );
  }

  Future<void> setMonthlyBudget(double amount) async {
    await repository.setMonthlyBudget(amount);
    await loadAll();
  }

  void _checkBudgetAlert() {
    final summary = state.summary;
    if (summary == null || summary.monthlyBudget <= 0) return;
    if (summary.percentUsed >= 80) {
      notificationService.showBudgetAlert(
        percentUsed: summary.percentUsed,
        remaining: summary.remaining,
      );
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}
