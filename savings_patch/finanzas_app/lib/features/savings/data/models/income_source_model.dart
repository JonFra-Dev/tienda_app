import '../../domain/entities/frequency.dart';
import '../../domain/entities/income_source.dart';

class IncomeSourceModel extends IncomeSource {
  const IncomeSourceModel({
    required super.id,
    required super.name,
    required super.expectedAmount,
    required super.frequency,
    required super.nextExpectedDate,
    super.isActive,
    required super.createdAt,
    super.notes,
  });

  factory IncomeSourceModel.fromJson(Map<String, dynamic> json) {
    return IncomeSourceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      expectedAmount: (json['expectedAmount'] as num).toDouble(),
      frequency: IncomeFrequency.values.firstWhere(
        (f) => f.name == json['frequency'],
        orElse: () => IncomeFrequency.monthly,
      ),
      nextExpectedDate: DateTime.parse(json['nextExpectedDate'] as String),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      notes: json['notes'] as String?,
    );
  }

  factory IncomeSourceModel.fromEntity(IncomeSource s) => IncomeSourceModel(
        id: s.id,
        name: s.name,
        expectedAmount: s.expectedAmount,
        frequency: s.frequency,
        nextExpectedDate: s.nextExpectedDate,
        isActive: s.isActive,
        createdAt: s.createdAt,
        notes: s.notes,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'expectedAmount': expectedAmount,
        'frequency': frequency.name,
        'nextExpectedDate': nextExpectedDate.toIso8601String(),
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'notes': notes,
      };
}
