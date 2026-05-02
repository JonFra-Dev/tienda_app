/// Frecuencias soportadas para fuentes de ingreso recurrentes.
///
/// La lógica de cálculo de "próxima fecha" vive en `FrequencyCalculator`
/// (use case puro) — esta enumeración es solo el "qué", no el "cómo".
enum IncomeFrequency {
  /// Una vez (no recurrente)
  oneTime,

  /// Cada semana
  weekly,

  /// Cada dos semanas (catorcenal)
  biweekly,

  /// Quincenal: día 15 y último día del mes
  semimonthly,

  /// Mensual (mismo día de cada mes)
  monthly,

  /// Bimensual (cada 2 meses)
  bimonthly,

  /// Sin frecuencia fija (freelance, bonos)
  irregular;

  String get label {
    switch (this) {
      case IncomeFrequency.oneTime:
        return 'Una sola vez';
      case IncomeFrequency.weekly:
        return 'Semanal';
      case IncomeFrequency.biweekly:
        return 'Catorcenal (cada 2 semanas)';
      case IncomeFrequency.semimonthly:
        return 'Quincenal (15 y fin de mes)';
      case IncomeFrequency.monthly:
        return 'Mensual';
      case IncomeFrequency.bimonthly:
        return 'Bimensual (cada 2 meses)';
      case IncomeFrequency.irregular:
        return 'Irregular';
    }
  }

  /// Multiplicador para convertir un monto a equivalente mensual.
  /// Útil para calcular "ingreso mensual proyectado".
  double get monthlyMultiplier {
    switch (this) {
      case IncomeFrequency.oneTime:
        return 0;
      case IncomeFrequency.weekly:
        return 4.33; // 52 / 12
      case IncomeFrequency.biweekly:
        return 2.17; // 26 / 12
      case IncomeFrequency.semimonthly:
        return 2;
      case IncomeFrequency.monthly:
        return 1;
      case IncomeFrequency.bimonthly:
        return 0.5;
      case IncomeFrequency.irregular:
        return 1; // Asume mensual como aproximación
    }
  }
}
