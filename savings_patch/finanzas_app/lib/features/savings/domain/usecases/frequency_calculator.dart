import '../entities/frequency.dart';

/// Lógica pura para calcular la próxima fecha esperada según frecuencia.
///
/// Probada en `test/unit/frequency_calculator_test.dart`.
class FrequencyCalculator {
  const FrequencyCalculator();

  /// Devuelve la siguiente fecha esperada después de [from] según [frequency].
  DateTime nextDate({
    required DateTime from,
    required IncomeFrequency frequency,
  }) {
    switch (frequency) {
      case IncomeFrequency.oneTime:
      case IncomeFrequency.irregular:
        // No hay "próxima" fija; devuelve el mismo día (el usuario actualiza manual).
        return from;
      case IncomeFrequency.weekly:
        return from.add(const Duration(days: 7));
      case IncomeFrequency.biweekly:
        return from.add(const Duration(days: 14));
      case IncomeFrequency.semimonthly:
        return _nextSemimonthly(from);
      case IncomeFrequency.monthly:
        return _addMonths(from, 1);
      case IncomeFrequency.bimonthly:
        return _addMonths(from, 2);
    }
  }

  /// Quincenal: si estamos antes del 15, próxima es el 15.
  /// Si estamos entre el 15 y el último día, próxima es el último.
  /// Si estamos en el último día, próxima es el 15 del mes siguiente.
  DateTime _nextSemimonthly(DateTime from) {
    if (from.day < 15) {
      return DateTime(from.year, from.month, 15);
    }
    final lastDayOfMonth = DateTime(from.year, from.month + 1, 0).day;
    if (from.day < lastDayOfMonth) {
      return DateTime(from.year, from.month, lastDayOfMonth);
    }
    return DateTime(from.year, from.month + 1, 15);
  }

  /// Suma N meses preservando el día (ajustando si el mes destino tiene menos días).
  DateTime _addMonths(DateTime from, int months) {
    final newMonth = from.month + months;
    final newYear = from.year + (newMonth - 1) ~/ 12;
    final adjustedMonth = ((newMonth - 1) % 12) + 1;
    final lastDay = DateTime(newYear, adjustedMonth + 1, 0).day;
    final day = from.day > lastDay ? lastDay : from.day;
    return DateTime(newYear, adjustedMonth, day);
  }
}
