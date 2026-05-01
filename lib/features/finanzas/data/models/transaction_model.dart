import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.amount,
    required super.description,
    required super.categoryId,
    required super.type,
    required super.date,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      categoryId: json['categoryId'] as String,
      type: TransactionType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      date: DateTime.parse(json['date'] as String),
    );
  }

  factory TransactionModel.fromEntity(Transaction t) => TransactionModel(
        id: t.id,
        amount: t.amount,
        description: t.description,
        categoryId: t.categoryId,
        type: t.type,
        date: t.date,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'description': description,
        'categoryId': categoryId,
        'type': type.name,
        'date': date.toIso8601String(),
      };
}
