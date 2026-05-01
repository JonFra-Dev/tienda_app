import '../constants/app_strings.dart';

/// Validadores reutilizables para Forms.
class Validators {
  Validators._();

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }
    return null;
  }

  static String? email(String? value) {
    final r = required(value);
    if (r != null) return r;
    final regex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\-\.]+$');
    if (!regex.hasMatch(value!.trim())) return AppStrings.invalidEmail;
    return null;
  }

  static String? password(String? value) {
    final r = required(value);
    if (r != null) return r;
    if (value!.length < 6) return AppStrings.shortPassword;
    return null;
  }

  static String? amount(String? value) {
    final r = required(value);
    if (r != null) return r;
    final parsed = double.tryParse(value!.replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) {
      return 'Monto inválido';
    }
    return null;
  }
}
