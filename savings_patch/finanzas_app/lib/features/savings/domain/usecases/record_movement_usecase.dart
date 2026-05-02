import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/savings_account.dart';
import '../entities/savings_movement.dart';
import '../repositories/savings_repository.dart';

/// Registra un movimiento (depósito o retiro) y actualiza el saldo de la cuenta.
///
/// Importante: NO crea transacciones en el feed de finanzas, porque transferir
/// dinero entre tus propias cuentas no es un gasto/ingreso real — es contabilidad.
class RecordMovementUseCase {
  final SavingsRepository repository;
  const RecordMovementUseCase(this.repository);

  Future<Result<SavingsAccount>> call({
    required SavingsAccount account,
    required double amount,
    required MovementType type,
    String? note,
  }) async {
    if (amount <= 0) {
      return const FailureResult(
        ValidationFailure('El monto debe ser positivo'),
      );
    }

    if (type == MovementType.withdrawal && amount > account.currentBalance) {
      return const FailureResult(
        ValidationFailure('Saldo insuficiente para el retiro'),
      );
    }

    final movement = SavingsMovement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      accountId: account.id,
      amount: amount,
      type: type,
      date: DateTime.now(),
      note: note,
    );

    final movResult = await repository.addMovement(movement);
    if (movResult.isFailure) {
      return FailureResult(movResult.failureOrNull!);
    }

    final newBalance = account.currentBalance + movement.signedAmount;
    final updated = account.copyWith(currentBalance: newBalance);
    return repository.updateAccount(updated);
  }
}
