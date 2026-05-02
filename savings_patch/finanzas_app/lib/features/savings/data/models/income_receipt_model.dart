import '../../domain/entities/income_receipt.dart';

class IncomeReceiptModel extends IncomeReceipt {
  const IncomeReceiptModel({
    required super.id,
    required super.sourceId,
    required super.actualAmount,
    required super.receivedDate,
    super.note,
  });

  factory IncomeReceiptModel.fromJson(Map<String, dynamic> json) {
    return IncomeReceiptModel(
      id: json['id'] as String,
      sourceId: json['sourceId'] as String,
      actualAmount: (json['actualAmount'] as num).toDouble(),
      receivedDate: DateTime.parse(json['receivedDate'] as String),
      note: json['note'] as String?,
    );
  }

  factory IncomeReceiptModel.fromEntity(IncomeReceipt r) => IncomeReceiptModel(
        id: r.id,
        sourceId: r.sourceId,
        actualAmount: r.actualAmount,
        receivedDate: r.receivedDate,
        note: r.note,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceId': sourceId,
        'actualAmount': actualAmount,
        'receivedDate': receivedDate.toIso8601String(),
        'note': note,
      };
}
