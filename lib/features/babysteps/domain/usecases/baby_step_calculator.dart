import '../../../debts/domain/entities/debt.dart';
import '../../../finanzas/domain/entities/transaction.dart';
import '../../../savings/domain/entities/income_source.dart';
import '../../../savings/domain/entities/savings_account.dart';
import '../entities/baby_step.dart';
import '../entities/baby_steps_status.dart';

/// Calculadora de baby steps — lógica pura sin dependencias de Flutter.
///
/// Combina datos de los 3 features (savings, debts, finanzas) para inferir
/// en qué paso está el usuario AHORA y cuánto le falta para el siguiente.
///
/// REGLA CLAVE: el "paso actual" es el primero que NO está completo. No se
/// pueden saltar pasos — Ramsey es muy estricto en esto.
///
/// Probado en `test/unit/baby_step_calculator_test.dart`.
class BabyStepCalculator {
  /// Meta del Step 1: ~\$1000 USD ≈ \$4.000.000 COP (configurable).
  final double step1Target;

  /// Múltiplo de gastos mensuales para Step 3 (3-6 meses).
  /// Por defecto usamos 3 (mínimo Ramsey).
  final int step3MonthsMultiplier;

  /// Porcentaje del ingreso esperado para invertir en retiro (Step 4).
  final double step4PercentOfIncome;

  const BabyStepCalculator({
    this.step1Target = 4000000,
    this.step3MonthsMultiplier = 3,
    this.step4PercentOfIncome = 0.15,
  });

  BabyStepsStatus calculate({
    required List<SavingsAccount> accounts,
    required List<Debt> debts,
    required List<IncomeSource> incomeSources,
    required List<Transaction> transactions,
  }) {
    // ============== Métricas ==============
    final emergencyFundBalance = _sumByType(
      accounts,
      SavingsAccountType.emergencyFund,
    );
    final retirementBalance = _sumByType(
      accounts,
      SavingsAccountType.retirement,
    );
    final educationBalance = _sumByType(
      accounts,
      SavingsAccountType.education,
    );

    final activeDebts = debts.where((d) => !d.isPaidOff).toList();
    final mortgageDebts =
        activeDebts.where(_isMortgage).toList();
    final nonMortgageDebts =
        activeDebts.where((d) => !_isMortgage(d)).toList();

    final nonMortgageDebtTotal =
        nonMortgageDebts.fold(0.0, (s, d) => s + d.currentBalance);
    final mortgageDebtTotal =
        mortgageDebts.fold(0.0, (s, d) => s + d.currentBalance);

    final monthlyExpenses = _averageMonthlyExpenses(transactions);
    final monthlyIncomeProjected = incomeSources
        .where((s) => s.isActive)
        .fold(0.0, (s, src) => s + src.monthlyEquivalent);

    // Pasos completados (acumulativo)
    final completed = <BabyStep>{};

    // ============== Step 1: Fondo emergencia inicial ==============
    if (emergencyFundBalance < step1Target) {
      return BabyStepsStatus(
        currentStep: BabyStep.step1,
        progressToCurrent: emergencyFundBalance / step1Target,
        completedSteps: completed,
        currentValue: emergencyFundBalance,
        targetValue: step1Target,
        contextMessage: emergencyFundBalance == 0
            ? 'Crea una cuenta de tipo "Fondo de emergencia" en Ahorros y empieza a aportar.'
            : 'Te faltan \$${(step1Target - emergencyFundBalance).toStringAsFixed(0)} para llegar a tu fondo inicial.',
      );
    }
    completed.add(BabyStep.step1);

    // ============== Step 2: Pagar deudas (excepto hipoteca) ==============
    if (nonMortgageDebts.isNotEmpty) {
      final originalTotal = nonMortgageDebts.fold(
        0.0,
        (s, d) => s + d.originalAmount,
      );
      final paid = originalTotal - nonMortgageDebtTotal;
      final progress =
          originalTotal > 0 ? paid / originalTotal : 0.0;

      return BabyStepsStatus(
        currentStep: BabyStep.step2,
        progressToCurrent: progress.clamp(0, 1),
        completedSteps: completed,
        currentValue: paid,
        targetValue: originalTotal,
        contextMessage:
            'Te quedan ${nonMortgageDebts.length} deuda(s) por pagar (\$${nonMortgageDebtTotal.toStringAsFixed(0)} en total). Usa el plan Snowball.',
      );
    }
    completed.add(BabyStep.step2);

    // ============== Step 3: Fondo emergencia completo (3-6 meses) ==============
    final step3Target = monthlyExpenses > 0
        ? monthlyExpenses * step3MonthsMultiplier
        : step1Target * 3; // fallback si no hay datos de gastos

    if (emergencyFundBalance < step3Target) {
      return BabyStepsStatus(
        currentStep: BabyStep.step3,
        progressToCurrent: emergencyFundBalance / step3Target,
        completedSteps: completed,
        currentValue: emergencyFundBalance,
        targetValue: step3Target,
        contextMessage: monthlyExpenses > 0
            ? 'Apunta a \$${step3Target.toStringAsFixed(0)} ($step3MonthsMultiplier meses de tus gastos promedio).'
            : 'Aún no tenemos suficientes datos de tus gastos. Sigue agregando transacciones.',
      );
    }
    completed.add(BabyStep.step3);

    // ============== Step 4: Retiro (15% del ingreso anual) ==============
    final step4AnnualTarget =
        monthlyIncomeProjected * 12 * step4PercentOfIncome;

    if (retirementBalance < step4AnnualTarget) {
      return BabyStepsStatus(
        currentStep: BabyStep.step4,
        progressToCurrent: step4AnnualTarget > 0
            ? (retirementBalance / step4AnnualTarget).clamp(0, 1)
            : 0,
        completedSteps: completed,
        currentValue: retirementBalance,
        targetValue: step4AnnualTarget,
        contextMessage: monthlyIncomeProjected > 0
            ? 'Apunta a invertir \$${(monthlyIncomeProjected * step4PercentOfIncome).toStringAsFixed(0)} cada mes en cuentas tipo "Retiro".'
            : 'Registra tus fuentes de ingreso para calcular tu meta del 15% al retiro.',
      );
    }
    completed.add(BabyStep.step4);

    // ============== Step 5: Educación hijos ==============
    // Como no sabemos si tiene hijos, asumimos completado si ya tiene
    // alguna cuenta de educación con saldo, o lo marcamos pendiente.
    if (educationBalance == 0) {
      return BabyStepsStatus(
        currentStep: BabyStep.step5,
        progressToCurrent: 0,
        completedSteps: completed,
        currentValue: 0,
        targetValue: monthlyIncomeProjected * 12,
        contextMessage:
            'Si tienes hijos, abre una cuenta tipo "Educación". Si no aplica, este paso lo puedes saltar mentalmente.',
      );
    }
    completed.add(BabyStep.step5);

    // ============== Step 6: Hipoteca ==============
    if (mortgageDebtTotal > 0) {
      final originalMortgage = mortgageDebts.fold(
        0.0,
        (s, d) => s + d.originalAmount,
      );
      final paidMortgage = originalMortgage - mortgageDebtTotal;
      return BabyStepsStatus(
        currentStep: BabyStep.step6,
        progressToCurrent: originalMortgage > 0
            ? (paidMortgage / originalMortgage).clamp(0, 1)
            : 0,
        completedSteps: completed,
        currentValue: paidMortgage,
        targetValue: originalMortgage,
        contextMessage:
            'Acelera los pagos de tu hipoteca. Cada peso extra reduce años de intereses.',
      );
    }
    completed.add(BabyStep.step6);

    // ============== Step 7: ¡Libertad financiera! ==============
    return BabyStepsStatus(
      currentStep: BabyStep.step7,
      progressToCurrent: 1.0,
      completedSteps: completed,
      currentValue: 1,
      targetValue: 1,
      contextMessage:
          '¡Felicitaciones! Has alcanzado la libertad financiera. Construye riqueza y comparte con generosidad.',
    );
  }

  // ============== Helpers ==============

  double _sumByType(List<SavingsAccount> accounts, SavingsAccountType type) {
    return accounts
        .where((a) => a.type == type)
        .fold(0.0, (s, a) => s + a.currentBalance);
  }

  bool _isMortgage(Debt d) {
    final n = d.name.toLowerCase();
    return n.contains('hipoteca') ||
        n.contains('mortgage') ||
        n.contains('vivienda');
  }

  /// Promedio de gastos en los últimos 3 meses (excluyendo el mes actual).
  double _averageMonthlyExpenses(List<Transaction> transactions) {
    if (transactions.isEmpty) return 0;

    final now = DateTime.now();
    final threeMonthsAgo = DateTime(now.year, now.month - 3, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 0);

    final relevantTxs = transactions.where((t) =>
        t.type == TransactionType.expense &&
        t.date.isAfter(threeMonthsAgo) &&
        t.date.isBefore(lastMonthEnd));

    if (relevantTxs.isEmpty) return 0;

    // Agrupa por (year, month) y promedia.
    final byMonth = <String, double>{};
    for (final t in relevantTxs) {
      final key = '${t.date.year}-${t.date.month}';
      byMonth.update(key, (v) => v + t.amount, ifAbsent: () => t.amount);
    }
    final total = byMonth.values.fold(0.0, (s, v) => s + v);
    return total / byMonth.length;
  }
}
