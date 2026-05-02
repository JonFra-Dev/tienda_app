import 'package:equatable/equatable.dart';

/// Registro REAL de un ingreso recibido (puede diferir del esperado).
/// Se usa para construir el historial y detectar inconsistencias.
class IncomeReceipt extends Equatable {
  final String id;
  final String sourceId;
  final double actualAmount;
  final DateTime receivedDate;
  final String? note;

  const IncomeReceipt({
    required this.id,
    required this.sourceId,
    required this.actualAmount,
    required this.receivedDate,
    this.note,
  });

  @override
  List<Object?> get props => [id, sourceId, actualAmount, receivedDate, note];
}
