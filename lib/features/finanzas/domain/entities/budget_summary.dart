import 'package:equatable/equatable.dart';

/// Cálculo agregado del estado financiero del mes.
class BudgetSummary extends Equatable {
  final double monthlyBudget;
  final double totalIncome;
  final double totalExpense;
  final double balance;

  const BudgetSummary({
    required this.monthlyBudget,
    required this.totalIncome,
    required this.totalExpense,
  }) : balance = totalIncome - totalExpense;

  /// Porcentaje del presupuesto consumido por gastos (0 - 100+).
  double get percentUsed {
    if (monthlyBudget <= 0) return 0;
    return (totalExpense / monthlyBudget) * 100;
  }

  /// Cantidad restante del presupuesto.
  double get remaining => monthlyBudget - totalExpense;

  bool get isOverBudget => totalExpense > monthlyBudget && monthlyBudget > 0;

  @override
  List<Object?> get props => [monthlyBudget, totalIncome, totalExpense];
}
