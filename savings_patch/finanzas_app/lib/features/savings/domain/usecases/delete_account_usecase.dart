import '../../../../core/utils/result.dart';
import '../repositories/savings_repository.dart';

class DeleteAccountUseCase {
  final SavingsRepository repository;
  const DeleteAccountUseCase(this.repository);

  Future<Result<void>> call(String id) => repository.deleteAccount(id);
}
