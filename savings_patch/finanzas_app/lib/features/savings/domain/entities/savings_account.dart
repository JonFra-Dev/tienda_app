import 'package:equatable/equatable.dart';

/// Tipo de cuenta de ahorro — útil para categorizar y aplicar baby steps.
enum SavingsAccountType {
  /// Fondo de emergencia (Baby Step 1: $1000 inicial; Baby Step 3: 3-6 meses)
  emergencyFund,

  /// Ahorro general / objetivo específico (vacaciones, carro, etc.)
  general,

  /// Inversión a mediano/largo plazo
  investment,

  /// Retiro / pensión
  retirement,

  /// Educación (college fund — Baby Step 5)
  education;

  String get label {
    switch (this) {
      case SavingsAccountType.emergencyFund:
        return 'Fondo de emergencia';
      case SavingsAccountType.general:
        return 'Ahorro general';
      case SavingsAccountType.investment:
        return 'Inversión';
      case SavingsAccountType.retirement:
        return 'Retiro';
      case SavingsAccountType.education:
        return 'Educación';
    }
  }
}

/// Una cuenta de ahorro del usuario.
class SavingsAccount extends Equatable {
  final String id;
  final String name;
  final SavingsAccountType type;
  final double currentBalance;
  final double? goalAmount;
  final DateTime createdAt;
  final String? notes;

  const SavingsAccount({
    required this.id,
    required this.name,
    required this.type,
    required this.currentBalance,
    this.goalAmount,
    required this.createdAt,
    this.notes,
  });

  /// Porcentaje hacia la meta (0-100). Devuelve null si no hay meta definida.
  double? get percentToGoal {
    if (goalAmount == null || goalAmount! <= 0) return null;
    return (currentBalance / goalAmount! * 100).clamp(0, 100);
  }

  bool get hasReachedGoal =>
      goalAmount != null && currentBalance >= goalAmount!;

  SavingsAccount copyWith({
    String? id,
    String? name,
    SavingsAccountType? type,
    double? currentBalance,
    double? goalAmount,
    DateTime? createdAt,
    String? notes,
    bool clearGoal = false,
  }) {
    return SavingsAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      currentBalance: currentBalance ?? this.currentBalance,
      goalAmount: clearGoal ? null : (goalAmount ?? this.goalAmount),
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, type, currentBalance, goalAmount, createdAt, notes];
}
