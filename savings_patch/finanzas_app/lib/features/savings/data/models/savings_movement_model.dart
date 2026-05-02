import '../../domain/entities/savings_movement.dart';

class SavingsMovementModel extends SavingsMovement {
  const SavingsMovementModel({
    required super.id,
    required super.accountId,
    required super.amount,
    required super.type,
    required super.date,
    super.note,
  });

  factory SavingsMovementModel.fromJson(Map<String, dynamic> json) {
    return SavingsMovementModel(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: MovementType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => MovementType.deposit,
      ),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
    );
  }

  factory SavingsMovementModel.fromEntity(SavingsMovement m) =>
      SavingsMovementModel(
        id: m.id,
        accountId: m.accountId,
        amount: m.amount,
        type: m.type,
        date: m.date,
        note: m.note,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'accountId': accountId,
        'amount': amount,
        'type': type.name,
        'date': date.toIso8601String(),
        'note': note,
      };
}
