import 'package:shared_preferences/shared_preferences.dart';

/// Persistencia simple del progreso del usuario en baby steps.
/// Solo guarda el último paso celebrado para evitar repetir notificaciones.
class BabyStepProgressLocalDataSource {
  static const String _kLastCelebratedStep = 'babysteps_last_celebrated';
  static const String _kBudgetWarningDismissed = 'budget_warning_dismissed_month';

  final SharedPreferences prefs;
  BabyStepProgressLocalDataSource(this.prefs);

  /// Devuelve el número del último paso celebrado (0 = ninguno).
  int getLastCelebratedStep() => prefs.getInt(_kLastCelebratedStep) ?? 0;

  Future<void> setLastCelebratedStep(int stepNumber) async {
    await prefs.setInt(_kLastCelebratedStep, stepNumber);
  }

  /// Verifica si el warning del 80% del presupuesto ya se mostró este mes.
  /// Esto evita que aparezca cada vez que el usuario abre la app.
  bool isBudgetWarningDismissedThisMonth() {
    final stored = prefs.getString(_kBudgetWarningDismissed);
    if (stored == null) return false;
    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month}';
    return stored == currentMonth;
  }

  Future<void> dismissBudgetWarningForThisMonth() async {
    final now = DateTime.now();
    await prefs.setString(_kBudgetWarningDismissed, '${now.year}-${now.month}');
  }

  Future<void> resetBudgetWarning() async {
    await prefs.remove(_kBudgetWarningDismissed);
  }
}
