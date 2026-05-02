import 'package:equatable/equatable.dart';

import 'frequency.dart';

/// Fuente de ingreso recurrente del usuario (salario, freelance, alquiler, etc.).
class IncomeSource extends Equatable {
  final String id;
  final String name;
  final double expectedAmount;
  final IncomeFrequency frequency;
  final DateTime nextExpectedDate;
  final bool isActive;
  final DateTime createdAt;
  final String? notes;

  const IncomeSource({
    required this.id,
    required this.name,
    required this.expectedAmount,
    required this.frequency,
    required this.nextExpectedDate,
    this.isActive = true,
    required this.createdAt,
    this.notes,
  });

  /// Días hasta la próxima fecha esperada (negativo si ya pasó).
  int get daysUntilNext {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final next = DateTime(
      nextExpectedDate.year,
      nextExpectedDate.month,
      nextExpectedDate.day,
    );
    return next.difference(today).inDays;
  }

  /// Monto equivalente mensual (para proyecciones).
  double get monthlyEquivalent =>
      isActive ? expectedAmount * frequency.monthlyMultiplier : 0;

  IncomeSource copyWith({
    String? id,
    String? name,
    double? expectedAmount,
    IncomeFrequency? frequency,
    DateTime? nextExpectedDate,
    bool? isActive,
    DateTime? createdAt,
    String? notes,
  }) {
    return IncomeSource(
      id: id ?? this.id,
      name: name ?? this.name,
      expectedAmount: expectedAmount ?? this.expectedAmount,
      frequency: frequency ?? this.frequency,
      nextExpectedDate: nextExpectedDate ?? this.nextExpectedDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        expectedAmount,
        frequency,
        nextExpectedDate,
        isActive,
        createdAt,
        notes,
      ];
}
