import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../../core/services/notification_service.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/exchange_rate_remote_datasource.dart';
import '../../data/datasources/transaction_local_datasource.dart';
import '../../data/repositories/exchange_rate_repository_impl.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/repositories/exchange_rate_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/add_transaction_usecase.dart';
import '../../domain/usecases/budget_calculator.dart';
import '../../domain/usecases/delete_transaction_usecase.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import 'transactions_notifier.dart';
import 'transactions_state.dart';

// HTTP client
final httpClientProvider = Provider<http.Client>((ref) => http.Client());

// Datasources
final transactionLocalDataSourceProvider =
    Provider<TransactionLocalDataSource>((ref) {
  return TransactionLocalDataSource(ref.watch(sharedPreferencesProvider));
});

final exchangeRateRemoteDataSourceProvider =
    Provider<ExchangeRateRemoteDataSource>((ref) {
  return ExchangeRateRemoteDataSource(ref.watch(httpClientProvider));
});

// Repositories
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(
    ref.watch(transactionLocalDataSourceProvider),
  );
});

final exchangeRateRepositoryProvider = Provider<ExchangeRateRepository>((ref) {
  return ExchangeRateRepositoryImpl(
    ref.watch(exchangeRateRemoteDataSourceProvider),
  );
});

// Usecases
final getTransactionsUseCaseProvider = Provider<GetTransactionsUseCase>((ref) {
  return GetTransactionsUseCase(ref.watch(transactionRepositoryProvider));
});

final addTransactionUseCaseProvider = Provider<AddTransactionUseCase>((ref) {
  return AddTransactionUseCase(ref.watch(transactionRepositoryProvider));
});

final deleteTransactionUseCaseProvider =
    Provider<DeleteTransactionUseCase>((ref) {
  return DeleteTransactionUseCase(ref.watch(transactionRepositoryProvider));
});

final budgetCalculatorProvider =
    Provider<BudgetCalculator>((ref) => const BudgetCalculator());

// Notifier
final transactionsNotifierProvider =
    StateNotifierProvider<TransactionsNotifier, TransactionsState>((ref) {
  return TransactionsNotifier(
    getTransactions: ref.watch(getTransactionsUseCaseProvider),
    addTransaction: ref.watch(addTransactionUseCaseProvider),
    deleteTransaction: ref.watch(deleteTransactionUseCaseProvider),
    repository: ref.watch(transactionRepositoryProvider),
    calculator: ref.watch(budgetCalculatorProvider),
    notificationService: NotificationService.instance,
  );
});

// Exchange rate (FutureProvider para refrescar al pull-to-refresh)
final exchangeRateProvider = FutureProvider.autoDispose<double>((ref) async {
  final repo = ref.watch(exchangeRateRepositoryProvider);
  final result = await repo.getUsdRate(baseCurrency: 'COP');
  return result.fold(
    onSuccess: (rate) => rate,
    onFailure: (f) => throw Exception(f.message),
  );
});
