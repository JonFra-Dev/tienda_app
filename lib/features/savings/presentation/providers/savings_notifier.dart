import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/notification_service.dart';
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
/// Cross-feature:
///   - Cuando se registra un ingreso → crea Transaction tipo income en finanzas
///   - Cuando se agrega/actualiza una fuente → programa notificación
///   - Cuando se borra una fuente → cancela notificación
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
  final TransactionRepository transactionRepository;
  final Future<void> Function()? onTransactionCreated;
  final NotificationService notificationService;

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
    required this.notificationService,
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

  /// Re-programa todas las notificaciones de ingresos. Útil al iniciar la app.
  Future<void> rebuildAllReminders() async {
    await notificationService.cancelAllIncomeReminders();
    for (final source in state.incomeSources.where((s) => s.isActive)) {
      await notificationService.scheduleIncomeReminder(
        sourceId: source.id,
        sourceName: source.name,
        expectedAmount: source.expectedAmount,
        nextExpectedDate: source.nextExpectedDate,
      );
    }
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
      onSuccess: (saved) async {
        // Programar notificación
        await notificationService.scheduleIncomeReminder(
          sourceId: saved.id,
          sourceName: saved.name,
          expectedAmount: saved.expectedAmount,
          nextExpectedDate: saved.nextExpectedDate,
        );
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
    await notificationService.cancelIncomeReminder(id);
    await deleteIncomeSourceUC(id);
    await loadAll();
  }

  /// Registra un ingreso REAL recibido. Esto:
  ///   1. Crea el IncomeReceipt
  ///   2. Avanza la próxima fecha esperada
  ///   3. CREA una transacción income en finanzas
  ///   4. RE-PROGRAMA la notificación para la nueva fecha
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

        // Re-programar la notificación para la nueva nextExpectedDate
        final updated = state.incomeSources.firstWhere(
          (s) => s.id == source.id,
          orElse: () => source,
        );
        await notificationService.scheduleIncomeReminder(
          sourceId: updated.id,
          sourceName: updated.name,
          expectedAmount: updated.expectedAmount,
          nextExpectedDate: updated.nextExpectedDate,
        );

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
