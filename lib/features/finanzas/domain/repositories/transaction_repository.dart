import '../../../../core/utils/result.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<Result<List<Transaction>>> getAll();
  Future<Result<Transaction>> add(Transaction transaction);
  Future<Result<void>> delete(String id);
  Future<Result<void>> setMonthlyBudget(double amount);
  Future<Result<double>> getMonthlyBudget();
}
