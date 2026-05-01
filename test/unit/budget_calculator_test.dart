import 'package:finanzas_app/features/finanzas/domain/entities/transaction.dart';
import 'package:finanzas_app/features/finanzas/domain/usecases/budget_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late BudgetCalculator calc;
  final ref = DateTime(2026, 4, 15);

  setUp(() => calc = const BudgetCalculator());

  Transaction tx({
    required double amount,
    required TransactionType type,
    String categoryId = 'food',
    DateTime? date,
  }) =>
      Transaction(
        id: '${amount}_${type.name}',
        amount: amount,
        description: 'd',
        categoryId: categoryId,
        type: type,
        date: date ?? ref,
      );

  group('BudgetCalculator.calculate', () {
    test('suma correctamente ingresos y gastos del mes', () {
      final txs = [
        tx(amount: 1000, type: TransactionType.income),
        tx(amount: 200, type: TransactionType.expense),
        tx(amount: 50, type: TransactionType.expense),
      ];
      final summary = calc.calculate(
        transactions: txs,
        monthlyBudget: 500,
        referenceDate: ref,
      );
      expect(summary.totalIncome, 1000);
      expect(summary.totalExpense, 250);
      expect(summary.balance, 750);
      expect(summary.percentUsed, closeTo(50, 0.01));
      expect(summary.isOverBudget, isFalse);
    });

    test('marca isOverBudget cuando los gastos superan el presupuesto', () {
      final txs = [tx(amount: 600, type: TransactionType.expense)];
      final s = calc.calculate(
        transactions: txs,
        monthlyBudget: 500,
        referenceDate: ref,
      );
      expect(s.isOverBudget, isTrue);
      expect(s.percentUsed, greaterThan(100));
      expect(s.remaining, lessThan(0));
    });

    test('ignora transacciones de meses distintos', () {
      final txs = [
        tx(amount: 100, type: TransactionType.expense, date: DateTime(2026, 1, 1)),
        tx(amount: 200, type: TransactionType.expense, date: ref),
      ];
      final s = calc.calculate(
        transactions: txs,
        monthlyBudget: 500,
        referenceDate: ref,
      );
      expect(s.totalExpense, 200);
    });
  });

  group('BudgetCalculator.expenseByCategory', () {
    test('agrupa gastos del mes por categoryId', () {
      final txs = [
        tx(amount: 100, type: TransactionType.expense, categoryId: 'food'),
        tx(amount: 50, type: TransactionType.expense, categoryId: 'food'),
        tx(amount: 30, type: TransactionType.expense, categoryId: 'transport'),
        tx(amount: 999, type: TransactionType.income, categoryId: 'salary'),
      ];
      final r = calc.expenseByCategory(transactions: txs, referenceDate: ref);
      expect(r['food'], 150);
      expect(r['transport'], 30);
      expect(r.containsKey('salary'), isFalse);
    });
  });
}
