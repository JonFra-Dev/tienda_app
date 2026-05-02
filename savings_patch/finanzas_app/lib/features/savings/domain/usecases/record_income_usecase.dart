import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/income_receipt.dart';
import '../entities/income_source.dart';
import '../repositories/savings_repository.dart';
import 'frequency_calculator.dart';

/// Registra un ingreso real recibido. Esto:
///   1. Crea un IncomeReceipt (historial).
///   2. Avanza la `nextExpectedDate` de la fuente según su frecuencia.
///
/// La creación de la transacción asociada (que sí va al feed de finanzas)
/// se orquesta en el SavingsNotifier (cross-feature en presentación).
class RecordIncomeUseCase {
  final SavingsRepository repository;
  final FrequencyCalculator frequencyCalculator;

  const RecordIncomeUseCase({
    required this.repository,
    required this.frequencyCalculator,
  });

  Future<Result<IncomeReceipt>> call({
    required IncomeSource source,
    required double actualAmount,
    DateTime? receivedDate,
    String? note,
  }) async {
    if (actualAmount <= 0) {
      return const FailureResult(
        ValidationFailure('El monto debe ser positivo'),
      );
    }

    final receipt = IncomeReceipt(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sourceId: source.id,
      actualAmount: actualAmount,
      receivedDate: receivedDate ?? DateTime.now(),
      note: note,
    );

    final receiptResult = await repository.addReceipt(receipt);
    if (receiptResult.isFailure) {
      return FailureResult(receiptResult.failureOrNull!);
    }

    // Avanzar la próxima fecha esperada
    final nextDate = frequencyCalculator.nextDate(
      from: source.nextExpectedDate,
      frequency: source.frequency,
    );
    final updatedSource = source.copyWith(nextExpectedDate: nextDate);
    await repository.updateIncomeSource(updatedSource);

    return Success(receipt);
  }
}
