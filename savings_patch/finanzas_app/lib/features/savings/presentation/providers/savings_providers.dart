import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../finanzas/presentation/providers/finanzas_providers.dart';
import '../../data/datasources/savings_local_datasource.dart';
import '../../data/repositories/savings_repository_impl.dart';
import '../../domain/repositories/savings_repository.dart';
import '../../domain/usecases/add_account_usecase.dart';
import '../../domain/usecases/add_income_source_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/usecases/delete_income_source_usecase.dart';
import '../../domain/usecases/frequency_calculator.dart';
import '../../domain/usecases/get_accounts_usecase.dart';
import '../../domain/usecases/get_income_sources_usecase.dart';
import '../../domain/usecases/record_income_usecase.dart';
import '../../domain/usecases/record_movement_usecase.dart';
import 'savings_notifier.dart';
import 'savings_state.dart';

// Datasource
final savingsLocalDataSourceProvider = Provider<SavingsLocalDataSource>((ref) {
  return SavingsLocalDataSource(ref.watch(sharedPreferencesProvider));
});

// Repository
final savingsRepositoryProvider = Provider<SavingsRepository>((ref) {
  return SavingsRepositoryImpl(ref.watch(savingsLocalDataSourceProvider));
});

// Calculadora de frecuencia (lógica pura)
final frequencyCalculatorProvider =
    Provider<FrequencyCalculator>((ref) => const FrequencyCalculator());

// Usecases
final getAccountsUseCaseProvider = Provider<GetAccountsUseCase>((ref) {
  return GetAccountsUseCase(ref.watch(savingsRepositoryProvider));
});

final addAccountUseCaseProvider = Provider<AddAccountUseCase>((ref) {
  return AddAccountUseCase(ref.watch(savingsRepositoryProvider));
});

final deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>((ref) {
  return DeleteAccountUseCase(ref.watch(savingsRepositoryProvider));
});

final recordMovementUseCaseProvider = Provider<RecordMovementUseCase>((ref) {
  return RecordMovementUseCase(ref.watch(savingsRepositoryProvider));
});

final getIncomeSourcesUseCaseProvider =
    Provider<GetIncomeSourcesUseCase>((ref) {
  return GetIncomeSourcesUseCase(ref.watch(savingsRepositoryProvider));
});

final addIncomeSourceUseCaseProvider =
    Provider<AddIncomeSourceUseCase>((ref) {
  return AddIncomeSourceUseCase(ref.watch(savingsRepositoryProvider));
});

final deleteIncomeSourceUseCaseProvider =
    Provider<DeleteIncomeSourceUseCase>((ref) {
  return DeleteIncomeSourceUseCase(ref.watch(savingsRepositoryProvider));
});

final recordIncomeUseCaseProvider = Provider<RecordIncomeUseCase>((ref) {
  return RecordIncomeUseCase(
    repository: ref.watch(savingsRepositoryProvider),
    frequencyCalculator: ref.watch(frequencyCalculatorProvider),
  );
});

// Notifier
final savingsNotifierProvider =
    StateNotifierProvider<SavingsNotifier, SavingsState>((ref) {
  return SavingsNotifier(
    getAccounts: ref.watch(getAccountsUseCaseProvider),
    addAccountUC: ref.watch(addAccountUseCaseProvider),
    deleteAccountUC: ref.watch(deleteAccountUseCaseProvider),
    recordMovementUC: ref.watch(recordMovementUseCaseProvider),
    getIncomeSources: ref.watch(getIncomeSourcesUseCaseProvider),
    addIncomeSourceUC: ref.watch(addIncomeSourceUseCaseProvider),
    deleteIncomeSourceUC: ref.watch(deleteIncomeSourceUseCaseProvider),
    recordIncomeUC: ref.watch(recordIncomeUseCaseProvider),
    repository: ref.watch(savingsRepositoryProvider),
    transactionRepository: ref.watch(transactionRepositoryProvider),
    onTransactionCreated: () =>
        ref.read(transactionsNotifierProvider.notifier).loadAll(),
  );
});
