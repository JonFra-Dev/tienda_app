import '../../../../core/utils/result.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class AddTransactionUseCase {
  final TransactionRepository repository;
  const AddTransactionUseCase(this.repository);

  Future<Result<Transaction>> call(Transaction t) => repository.add(t);
}
