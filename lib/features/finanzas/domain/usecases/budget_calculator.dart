import '../entities/budget_summary.dart';
import '../entities/transaction.dart';

/// Lógica de negocio pura para calcular el resumen del mes en curso.
/// Probada en `test/unit/budget_calculator_test.dart`.
class BudgetCalculator {
  const BudgetCalculator();

  BudgetSummary calculate({
    required List<Transaction> transactions,
    required double monthlyBudget,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final inMonth = transactions.where(
      (t) => t.date.year == now.year && t.date.month == now.month,
    );

    double income = 0;
    double expense = 0;
    for (final t in inMonth) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }

    return BudgetSummary(
      monthlyBudget: monthlyBudget,
      totalIncome: income,
      totalExpense: expense,
    );
  }

  /// Suma de gastos por categoría (en el mes en curso).
  Map<String, double> expenseByCategory({
    required List<Transaction> transactions,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final result = <String, double>{};
    for (final t in transactions) {
      if (t.type != TransactionType.expense) continue;
      if (t.date.year != now.year || t.date.month != now.month) continue;
      result.update(t.categoryId, (v) => v + t.amount, ifAbsent: () => t.amount);
    }
    return result;
  }
}
