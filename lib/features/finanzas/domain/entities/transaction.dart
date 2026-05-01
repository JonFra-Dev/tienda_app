import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

/// Entidad de dominio: una transacción financiera del usuario.
class Transaction extends Equatable {
  final String id;
  final double amount;
  final String description;
  final String categoryId;
  final TransactionType type;
  final DateTime date;

  const Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.type,
    required this.date,
  });

  @override
  List<Object?> get props => [id, amount, description, categoryId, type, date];

  Transaction copyWith({
    String? id,
    double? amount,
    String? description,
    String? categoryId,
    TransactionType? type,
    DateTime? date,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      date: date ?? this.date,
    );
  }
}
