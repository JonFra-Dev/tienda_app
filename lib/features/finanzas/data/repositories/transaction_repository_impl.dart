import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;
  TransactionRepositoryImpl(this.localDataSource);

  @override
  Future<Result<List<Transaction>>> getAll() async {
    try {
      final list = await localDataSource.getAll();
      list.sort((a, b) => b.date.compareTo(a.date));
      return Success(list);
    } catch (e) {
      return FailureResult(CacheFailure('Error al leer transacciones: $e'));
    }
  }

  @override
  Future<Result<Transaction>> add(Transaction transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      final saved = await localDataSource.add(model);
      return Success(saved);
    } catch (e) {
      return FailureResult(CacheFailure('Error al guardar: $e'));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await localDataSource.delete(id);
      return const Success(null);
    } catch (e) {
      return FailureResult(CacheFailure('Error al eliminar: $e'));
    }
  }

  @override
  Future<Result<void>> setMonthlyBudget(double amount) async {
    try {
      await localDataSource.setMonthlyBudget(amount);
      return const Success(null);
    } catch (e) {
      return FailureResult(CacheFailure('Error al guardar presupuesto: $e'));
    }
  }

  @override
  Future<Result<double>> getMonthlyBudget() async {
    try {
      return Success(localDataSource.getMonthlyBudget());
    } catch (e) {
      return FailureResult(CacheFailure('Error al leer presupuesto: $e'));
    }
  }
}
