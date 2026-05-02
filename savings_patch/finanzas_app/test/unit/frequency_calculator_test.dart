import 'package:finanzas_app/features/savings/domain/entities/frequency.dart';
import 'package:finanzas_app/features/savings/domain/usecases/frequency_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FrequencyCalculator calc;

  setUp(() => calc = const FrequencyCalculator());

  group('nextDate', () {
    test('weekly suma 7 días', () {
      final r = calc.nextDate(
        from: DateTime(2026, 5, 1),
        frequency: IncomeFrequency.weekly,
      );
      expect(r, DateTime(2026, 5, 8));
    });

    test('biweekly suma 14 días', () {
      final r = calc.nextDate(
        from: DateTime(2026, 5, 1),
        frequency: IncomeFrequency.biweekly,
      );
      expect(r, DateTime(2026, 5, 15));
    });

    test('monthly avanza un mes preservando el día', () {
      final r = calc.nextDate(
        from: DateTime(2026, 5, 15),
        frequency: IncomeFrequency.monthly,
      );
      expect(r, DateTime(2026, 6, 15));
    });

    test('monthly del 31 ajusta al último día del mes destino (febrero)', () {
      final r = calc.nextDate(
        from: DateTime(2026, 1, 31),
        frequency: IncomeFrequency.monthly,
      );
      expect(r, DateTime(2026, 2, 28)); // febrero 2026 (no bisiesto)
    });

    test('semimonthly: día 1 → siguiente es día 15 del mismo mes', () {
      final r = calc.nextDate(
        from: DateTime(2026, 5, 1),
        frequency: IncomeFrequency.semimonthly,
      );
      expect(r, DateTime(2026, 5, 15));
    });

    test('semimonthly: día 15 → siguiente es último día del mes', () {
      final r = calc.nextDate(
        from: DateTime(2026, 5, 15),
        frequency: IncomeFrequency.semimonthly,
      );
      expect(r, DateTime(2026, 5, 31));
    });

    test('semimonthly: último día → siguiente es día 15 del mes siguiente', () {
      final r = calc.nextDate(
        from: DateTime(2026, 5, 31),
        frequency: IncomeFrequency.semimonthly,
      );
      expect(r, DateTime(2026, 6, 15));
    });

    test('bimonthly suma 2 meses', () {
      final r = calc.nextDate(
        from: DateTime(2026, 1, 10),
        frequency: IncomeFrequency.bimonthly,
      );
      expect(r, DateTime(2026, 3, 10));
    });

    test('oneTime e irregular devuelven la misma fecha (no recurrente)', () {
      final base = DateTime(2026, 5, 1);
      expect(
        calc.nextDate(from: base, frequency: IncomeFrequency.oneTime),
        base,
      );
      expect(
        calc.nextDate(from: base, frequency: IncomeFrequency.irregular),
        base,
      );
    });
  });

  group('monthlyMultiplier', () {
    test('valores estándar de cada frecuencia', () {
      expect(IncomeFrequency.monthly.monthlyMultiplier, 1);
      expect(IncomeFrequency.semimonthly.monthlyMultiplier, 2);
      expect(IncomeFrequency.bimonthly.monthlyMultiplier, 0.5);
      expect(IncomeFrequency.oneTime.monthlyMultiplier, 0);
    });
  });
}
