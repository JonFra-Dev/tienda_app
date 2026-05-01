import '../../../../core/utils/result.dart';
import '../repositories/transaction_repository.dart';

class DeleteTransactionUseCase {
  final TransactionRepository repository;
  const DeleteTransactionUseCase(this.repository);

  Future<Result<void>> call(String id) => repository.delete(id);
}
