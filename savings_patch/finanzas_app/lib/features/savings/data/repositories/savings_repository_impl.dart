import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/income_receipt.dart';
import '../../domain/entities/income_source.dart';
import '../../domain/entities/savings_account.dart';
import '../../domain/entities/savings_movement.dart';
import '../../domain/repositories/savings_repository.dart';
import '../datasources/savings_local_datasource.dart';
import '../models/income_receipt_model.dart';
import '../models/income_source_model.dart';
import '../models/savings_account_model.dart';
import '../models/savings_movement_model.dart';

class SavingsRepositoryImpl implements SavingsRepository {
  final SavingsLocalDataSource ds;
  SavingsRepositoryImpl(this.ds);

  // ============== CUENTAS ==============

  @override
  Future<Result<List<SavingsAccount>>> getAccounts() async {
    try {
      return Success(await ds.getAccounts());
    } catch (e) {
      return FailureResult(CacheFailure('Error al leer cuentas: $e'));
    }
  }

  @override
  Future<Result<SavingsAccount>> addAccount(SavingsAccount account) async {
    try {
      return Success(
          await ds.addAccount(SavingsAccountModel.fromEntity(account)));
    } catch (e) {
      return FailureResult(CacheFailure('Error al guardar cuenta: $e'));
    }
  }

  @override
  Future<Result<SavingsAccount>> updateAccount(SavingsAccount account) async {
    try {
      return Success(
          await ds.updateAccount(SavingsAccountModel.fromEntity(account)));
    } catch (e) {
      return FailureResult(CacheFailure('Error al actualizar cuenta: $e'));
    }
  }

  @override
  Future<Result<void>> deleteAccount(String id) async {
    try {
      await ds.deleteAccount(id);
      return const Success(null);
    } catch (e) {
      return FailureResult(CacheFailure('Error al eliminar cuenta: $e'));
    }
  }

  // ============== MOVIMIENTOS ==============

  @override
  Future<Result<List<SavingsMovement>>> getMovementsForAccount(
      String accountId) async {
    try {
      return Success(await ds.getMovementsForAccount(accountId));
    } catch (e) {
      return FailureResult(CacheFailure('Error al leer movimientos: $e'));
    }
  }

  @override
  Future<Result<SavingsMovement>> addMovement(SavingsMovement movement) async {
    try {
      return Success(
          await ds.addMovement(SavingsMovementModel.fromEntity(movement)));
    } catch (e) {
      return FailureResult(CacheFailure('Error al guardar movimiento: $e'));
    }
  }

  // ============== INGRESOS ==============

  @override
  Future<Result<List<IncomeSource>>> getIncomeSources() async {
    try {
      return Success(await ds.getIncomeSources());
    } catch (e) {
      return FailureResult(CacheFailure('Error al leer ingresos: $e'));
    }
  }

  @override
  Future<Result<IncomeSource>> addIncomeSource(IncomeSource source) async {
    try {
      return Success(
          await ds.addIncomeSource(IncomeSourceModel.fromEntity(source)));
    } catch (e) {
      return FailureResult(CacheFailure('Error al guardar ingreso: $e'));
    }
  }

  @override
  Future<Result<IncomeSource>> updateIncomeSource(IncomeSource source) async {
    try {
      return Success(
          await ds.updateIncomeSource(IncomeSourceModel.fromEntity(source)));
    } catch (e) {
      return FailureResult(CacheFailure('Error al actualizar ingreso: $e'));
    }
  }

  @override
  Future<Result<void>> deleteIncomeSource(String id) async {
    try {
      await ds.deleteIncomeSource(id);
      return const Success(null);
    } catch (e) {
      return FailureResult(CacheFailure('Error al eliminar ingreso: $e'));
    }
  }

  // ============== RECIBOS ==============

  @override
  Future<Result<List<IncomeReceipt>>> getReceiptsForSource(
      String sourceId) async {
    try {
      return Success(await ds.getReceiptsForSource(sourceId));
    } catch (e) {
      return FailureResult(CacheFailure('Error al leer recibos: $e'));
    }
  }

  @override
  Future<Result<IncomeReceipt>> addReceipt(IncomeReceipt receipt) async {
    try {
      return Success(
          await ds.addReceipt(IncomeReceiptModel.fromEntity(receipt)));
    } catch (e) {
      return FailureResult(CacheFailure('Error al guardar recibo: $e'));
    }
  }
}
