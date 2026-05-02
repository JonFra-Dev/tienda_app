import 'package:equatable/equatable.dart';

import '../../domain/entities/income_source.dart';
import '../../domain/entities/savings_account.dart';

class SavingsState extends Equatable {
  final bool isLoading;
  final List<SavingsAccount> accounts;
  final List<IncomeSource> incomeSources;
  final String? errorMessage;

  const SavingsState({
    this.isLoading = false,
    this.accounts = const [],
    this.incomeSources = const [],
    this.errorMessage,
  });

  /// Saldo total de todas las cuentas de ahorro.
  double get totalSavings =>
      accounts.fold(0.0, (s, a) => s + a.currentBalance);

  /// Ingreso mensual proyectado (suma equivalente de fuentes activas).
  double get projectedMonthlyIncome =>
      incomeSources.fold(0.0, (s, i) => s + i.monthlyEquivalent);

  /// Próxima fuente de ingreso esperada.
  IncomeSource? get nextIncome {
    final active = incomeSources.where((i) => i.isActive).toList()
      ..sort((a, b) => a.nextExpectedDate.compareTo(b.nextExpectedDate));
    return active.isEmpty ? null : active.first;
  }

  SavingsState copyWith({
    bool? isLoading,
    List<SavingsAccount>? accounts,
    List<IncomeSource>? incomeSources,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SavingsState(
      isLoading: isLoading ?? this.isLoading,
      accounts: accounts ?? this.accounts,
      incomeSources: incomeSources ?? this.incomeSources,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [isLoading, accounts, incomeSources, errorMessage];
}
