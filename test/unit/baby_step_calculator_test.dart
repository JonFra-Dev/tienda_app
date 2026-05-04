import 'package:finanzas_app/features/babysteps/domain/entities/baby_step.dart';
import 'package:finanzas_app/features/babysteps/domain/usecases/baby_step_calculator.dart';
import 'package:finanzas_app/features/debts/domain/entities/debt.dart';

import 'package:finanzas_app/features/savings/domain/entities/frequency.dart';
import 'package:finanzas_app/features/savings/domain/entities/income_source.dart';
import 'package:finanzas_app/features/savings/domain/entities/savings_account.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  late BabyStepCalculator calc;

  setUp(() => calc = const BabyStepCalculator(step1Target: 4000000));

  SavingsAccount account({
    required SavingsAccountType type,
    required double balance,
  }) =>
      SavingsAccount(
        id: type.name,
        name: type.label,
        type: type,
        currentBalance: balance,
        createdAt: DateTime(2026, 1, 1),
      );

  Debt debt({
    required String name,
    required double balance,
    double original = 1000000,
  }) =>
      Debt(
        id: name,
        name: name,
        originalAmount: original,
        currentBalance: balance,
        minimumPayment: 50000,
        annualInterestRate: 12,
        createdAt: DateTime(2026, 1, 1),
      );

  IncomeSource income(double monthly) => IncomeSource(
        id: 'salary',
        name: 'Salary',
        expectedAmount: monthly,
        frequency: IncomeFrequency.monthly,
        nextExpectedDate: DateTime(2026, 6, 1),
        createdAt: DateTime(2026, 1, 1),
      );

  group('Step 1: Fondo emergencia inicial', () {
    test('sin nada → Step 1 con progreso 0', () {
      final r = calc.calculate(
        accounts: const [],
        debts: const [],
        incomeSources: const [],
        transactions: const [],
      );
      expect(r.currentStep, BabyStep.step1);
      expect(r.progressToCurrent, 0);
      expect(r.completedSteps, isEmpty);
    });

    test('emergencyFund a la mitad → Step 1 con progreso 0.5', () {
      final r = calc.calculate(
        accounts: [
          account(type: SavingsAccountType.emergencyFund, balance: 2000000),
        ],
        debts: const [],
        incomeSources: const [],
        transactions: const [],
      );
      expect(r.currentStep, BabyStep.step1);
      expect(r.progressToCurrent, closeTo(0.5, 0.01));
    });
  });

  group('Step 2: Snowball deudas', () {
    test('Step 1 completo + deudas activas → Step 2', () {
      final r = calc.calculate(
        accounts: [
          account(type: SavingsAccountType.emergencyFund, balance: 4000000),
        ],
        debts: [
          debt(name: 'Tarjeta', balance: 500000, original: 1000000),
        ],
        incomeSources: const [],
        transactions: const [],
      );
      expect(r.currentStep, BabyStep.step2);
      expect(r.completedSteps, contains(BabyStep.step1));
      // 50% de la deuda original ya pagado
      expect(r.progressToCurrent, closeTo(0.5, 0.01));
    });

    test('hipoteca NO cuenta para Step 2', () {
      final r = calc.calculate(
        accounts: [
          account(type: SavingsAccountType.emergencyFund, balance: 4000000),
        ],
        debts: [
          debt(name: 'Hipoteca apartamento', balance: 50000000),
        ],
        incomeSources: const [],
        transactions: const [],
      );
      // Step 2 done (no debts non-mortgage) → ahora Step 3
      expect(r.completedSteps, contains(BabyStep.step2));
      expect(r.currentStep, isNot(BabyStep.step2));
    });
  });

  group('Step 3: Fondo emergencia completo', () {
    test('sin gastos → fallback usa step1Target * 3', () {
      final r = calc.calculate(
        accounts: [
          account(type: SavingsAccountType.emergencyFund, balance: 5000000),
        ],
        debts: const [],
        incomeSources: const [],
        transactions: const [],
      );
      expect(r.currentStep, BabyStep.step3);
      // target = 4M * 3 = 12M, currentBalance = 5M → 41%
      expect(r.progressToCurrent, closeTo(0.416, 0.01));
    });
  });

  group('Step 4-7: Cuando no aplica algo, no se queda atascado', () {
    test('todo completo → Step 7 (libertad financiera)', () {
      final r = calc.calculate(
        accounts: [
          account(type: SavingsAccountType.emergencyFund, balance: 50000000),
          account(type: SavingsAccountType.retirement, balance: 999999999),
          account(type: SavingsAccountType.education, balance: 999999999),
        ],
        debts: const [],
        incomeSources: [income(3000000)],
        transactions: const [],
      );
      expect(r.currentStep, BabyStep.step7);
      expect(r.isFinanciallyFree, isTrue);
    });
  });
}
