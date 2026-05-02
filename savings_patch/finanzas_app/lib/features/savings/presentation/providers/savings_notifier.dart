import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../finanzas/domain/entities/category.dart';
import '../../../finanzas/domain/entities/transaction.dart' as fin;
import '../../../finanzas/domain/repositories/transaction_repository.dart';
import '../../domain/entities/income_source.dart';
import '../../domain/entities/savings_account.dart';
import '../../domain/entities/savings_movement.dart';
import '../../domain/repositories/savings_repository.dart';
import '../../domain/usecases/add_account_usecase.dart';
import '../../domain/usecases/add_income_source_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/usecases/delete_income_source_usecase.dart';
import '../../domain/usecases/get_accounts_usecase.dart';
import '../../domain/usecases/get_income_sources_usecase.dart';
import '../../domain/usecases/record_income_usecase.dart';
import '../../domain/usecases/record_movement_usecase.dart';
import 'savings_state.dart';

/// StateNotifier del feature savings.
///
/// Cross-feature: cuando se registra un ingreso real, se crea
/// AUTOMÁTICAMENTE una transacción tipo income en finanzas (categoría salary).
/// Los movimientos a cuentas (deposit/withdraw) NO crean transacciones porque
/// son transferencias entre cuentas propias del usuario.
class SavingsNotifier extends StateNotifier<SavingsState> {
  final GetAccountsUseCase getAccounts;
  final AddAccountUseCase addAccountUC;
  final DeleteAccountUseCase deleteAccountUC;
  final RecordMovementUseCase recordMovementUC;
  final GetIncomeSourcesUseCase getIncomeSources;
  final AddIncomeSourceUseCase addIncomeSourceUC;
  final DeleteIncomeSourceUseCase deleteIncomeSourceUC;
  final RecordIncomeUseCase recordIncomeUC;
  final SavingsRepository repository;

  /// Cross-feature: el repositorio de transacciones para crear el income auto.
  final TransactionRepository transactionRepository;
  final Future<void> Function()? onTransactionCreated;

  SavingsNotifier({
    required this.getAccounts,
    required this.addAccountUC,
    required this.deleteAccountUC,
    required this.recordMovementUC,
    required this.getIncomeSources,
    required this.addIncomeSourceUC,
    required this.deleteIncomeSourceUC,
    required this.recordIncomeUC,
    required this.repository,
    required this.transactionRepository,
    this.onTransactionCreated,
  }) : super(const SavingsState());

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final accountsResult = await getAccounts();
    final sourcesResult = await getIncomeSources();

    final accounts = accountsResult.valueOrNull ?? [];
    final sources = sourcesResult.valueOrNull ?? [];

    String? error;
    if (accountsResult.isFailure) {
      error = accountsResult.failureOrNull!.message;
    } else if (sourcesResult.isFailure) {
      error = sourcesResult.failureOrNull!.message;
    }

    state = state.copyWith(
      isLoading: false,
      accounts: accounts,
      incomeSources: sources,
      errorMessage: error,
    );
  }

  // ============== CUENTAS ==============

  Future<bool> addAccount(SavingsAccount account) async {
    final r = await addAccountUC(account);
    return r.fold(
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

  Future<void> removeAccount(String id) async {
    await deleteAccountUC(id);
    await loadAll();
  }

  Future<bool> recordMovement({
    required SavingsAccount account,
    required double amount,
    required MovementType type,
    String? note,
  }) async {
    final r = await recordMovementUC(
      account: account,
      amount: amount,
      type: type,
      note: note,
    );
    return r.fold(
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

  // ============== INGRESOS ==============

  Future<bool> addIncomeSource(IncomeSource source) async {
    final r = await addIncomeSourceUC(source);
    return r.fold(
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

  Future<void> removeIncomeSource(String id) async {
    await deleteIncomeSourceUC(id);
    await loadAll();
  }

  /// Registra un ingreso REAL recibido. Esto:
  ///   1. Crea el IncomeReceipt
  ///   2. Avanza la próxima fecha esperada (en el use case)
  ///   3. CREA AUTOMÁTICAMENTE una transacción income en finanzas
  Future<bool> recordIncome({
    required IncomeSource source,
    required double actualAmount,
    DateTime? receivedDate,
    String? note,
  }) async {
    final r = await recordIncomeUC(
      source: source,
      actualAmount: actualAmount,
      receivedDate: receivedDate,
      note: note,
    );

    return r.fold(
      onSuccess: (_) async {
        // Crear la transacción income en el feed de finanzas.
        final tx = fin.Transaction(
          id: 'income-${source.id}-${DateTime.now().millisecondsSinceEpoch}',
          amount: actualAmount,
          description: 'Ingreso: ${source.name}',
          categoryId: TransactionCategory.byId('salary').id,
          type: fin.TransactionType.income,
          date: receivedDate ?? DateTime.now(),
        );
        await transactionRepository.add(tx);

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

  void clearError() => state = state.copyWith(clearError: true);
}
