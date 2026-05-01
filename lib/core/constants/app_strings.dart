/// Strings centralizados (i18n-ready).
class AppStrings {
  AppStrings._();

  static const String appName = 'Finanzas App';

  // Auth
  static const String login = 'Iniciar sesión';
  static const String register = 'Registrarse';
  static const String logout = 'Cerrar sesión';
  static const String email = 'Correo electrónico';
  static const String password = 'Contraseña';
  static const String name = 'Nombre';
  static const String dontHaveAccount = '¿No tienes cuenta? Regístrate';
  static const String alreadyHaveAccount = '¿Ya tienes cuenta? Inicia sesión';

  // Home
  static const String home = 'Inicio';
  static const String balance = 'Balance';
  static const String income = 'Ingresos';
  static const String expense = 'Gastos';
  static const String budget = 'Presupuesto';
  static const String monthlyBudget = 'Presupuesto mensual';
  static const String recentTransactions = 'Transacciones recientes';

  // Add Transaction
  static const String addTransaction = 'Agregar transacción';
  static const String amount = 'Monto';
  static const String description = 'Descripción';
  static const String category = 'Categoría';
  static const String type = 'Tipo';
  static const String date = 'Fecha';
  static const String save = 'Guardar';

  // Stats
  static const String statistics = 'Estadísticas';
  static const String byCategory = 'Por categoría';

  // Profile
  static const String profile = 'Perfil';
  static const String exchangeRate = 'Tasa de cambio (USD)';
  static const String notifications = 'Notificaciones';

  // Errors
  static const String requiredField = 'Campo obligatorio';
  static const String invalidEmail = 'Correo no válido';
  static const String shortPassword = 'Mínimo 6 caracteres';
  static const String genericError = 'Algo salió mal. Intenta de nuevo.';
  static const String networkError = 'Sin conexión a internet';
  static const String invalidCredentials = 'Credenciales incorrectas';
}
