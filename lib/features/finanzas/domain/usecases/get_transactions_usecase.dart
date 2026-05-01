import '../../../../core/utils/result.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionsUseCase {
  final TransactionRepository repository;
  const GetTransactionsUseCase(this.repository);

  Future<Result<List<Transaction>>> call() => repository.getAll();
}
