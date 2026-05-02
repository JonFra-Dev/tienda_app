import '../../../../core/utils/result.dart';
import '../entities/income_receipt.dart';
import '../entities/income_source.dart';
import '../entities/savings_account.dart';
import '../entities/savings_movement.dart';

abstract class SavingsRepository {
  // ============== CUENTAS ==============
  Future<Result<List<SavingsAccount>>> getAccounts();
  Future<Result<SavingsAccount>> addAccount(SavingsAccount account);
  Future<Result<SavingsAccount>> updateAccount(SavingsAccount account);
  Future<Result<void>> deleteAccount(String id);

  // ============== MOVIMIENTOS ==============
  Future<Result<List<SavingsMovement>>> getMovementsForAccount(String accountId);
  Future<Result<SavingsMovement>> addMovement(SavingsMovement movement);

  // ============== INGRESOS ==============
  Future<Result<List<IncomeSource>>> getIncomeSources();
  Future<Result<IncomeSource>> addIncomeSource(IncomeSource source);
  Future<Result<IncomeSource>> updateIncomeSource(IncomeSource source);
  Future<Result<void>> deleteIncomeSource(String id);

  // ============== RECIBOS DE INGRESO ==============
  Future<Result<List<IncomeReceipt>>> getReceiptsForSource(String sourceId);
  Future<Result<IncomeReceipt>> addReceipt(IncomeReceipt receipt);
}
