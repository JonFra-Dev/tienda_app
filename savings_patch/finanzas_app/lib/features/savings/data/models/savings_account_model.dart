import '../../domain/entities/savings_account.dart';

class SavingsAccountModel extends SavingsAccount {
  const SavingsAccountModel({
    required super.id,
    required super.name,
    required super.type,
    required super.currentBalance,
    super.goalAmount,
    required super.createdAt,
    super.notes,
  });

  factory SavingsAccountModel.fromJson(Map<String, dynamic> json) {
    return SavingsAccountModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: SavingsAccountType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => SavingsAccountType.general,
      ),
      currentBalance: (json['currentBalance'] as num).toDouble(),
      goalAmount: (json['goalAmount'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      notes: json['notes'] as String?,
    );
  }

  factory SavingsAccountModel.fromEntity(SavingsAccount a) =>
      SavingsAccountModel(
        id: a.id,
        name: a.name,
        type: a.type,
        currentBalance: a.currentBalance,
        goalAmount: a.goalAmount,
        createdAt: a.createdAt,
        notes: a.notes,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'currentBalance': currentBalance,
        'goalAmount': goalAmount,
        'createdAt': createdAt.toIso8601String(),
        'notes': notes,
      };
}
