import 'package:equatable/equatable.dart';

import '../../domain/entities/budget_summary.dart';
import '../../domain/entities/transaction.dart';

class TransactionsState extends Equatable {
  final bool isLoading;
  final List<Transaction> transactions;
  final BudgetSummary? summary;
  final String? errorMessage;

  const TransactionsState({
    this.isLoading = false,
    this.transactions = const [],
    this.summary,
    this.errorMessage,
  });

  TransactionsState copyWith({
    bool? isLoading,
    List<Transaction>? transactions,
    BudgetSummary? summary,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TransactionsState(
      isLoading: isLoading ?? this.isLoading,
      transactions: transactions ?? this.transactions,
      summary: summary ?? this.summary,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [isLoading, transactions, summary, errorMessage];
}
