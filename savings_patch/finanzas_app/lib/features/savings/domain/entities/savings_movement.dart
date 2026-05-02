import 'package:equatable/equatable.dart';

enum MovementType { deposit, withdrawal }

/// Movimiento (depósito o retiro) sobre una cuenta de ahorro.
class SavingsMovement extends Equatable {
  final String id;
  final String accountId;
  final double amount;
  final MovementType type;
  final DateTime date;
  final String? note;

  const SavingsMovement({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
  });

  bool get isDeposit => type == MovementType.deposit;
  bool get isWithdrawal => type == MovementType.withdrawal;

  /// Monto signado: positivo si depósito, negativo si retiro.
  double get signedAmount => isDeposit ? amount : -amount;

  @override
  List<Object?> get props => [id, accountId, amount, type, date, note];
}
