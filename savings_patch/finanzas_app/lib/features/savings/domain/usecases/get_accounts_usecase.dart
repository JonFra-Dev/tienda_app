import '../../../../core/utils/result.dart';
import '../entities/savings_account.dart';
import '../repositories/savings_repository.dart';

class GetAccountsUseCase {
  final SavingsRepository repository;
  const GetAccountsUseCase(this.repository);

  Future<Result<List<SavingsAccount>>> call() => repository.getAccounts();
}
