import '../../../../core/utils/result.dart';
import '../entities/savings_account.dart';
import '../repositories/savings_repository.dart';

class AddAccountUseCase {
  final SavingsRepository repository;
  const AddAccountUseCase(this.repository);

  Future<Result<SavingsAccount>> call(SavingsAccount account) =>
      repository.addAccount(account);
}
