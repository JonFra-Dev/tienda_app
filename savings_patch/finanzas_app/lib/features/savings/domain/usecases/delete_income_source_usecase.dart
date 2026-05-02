import '../../../../core/utils/result.dart';
import '../repositories/savings_repository.dart';

class DeleteIncomeSourceUseCase {
  final SavingsRepository repository;
  const DeleteIncomeSourceUseCase(this.repository);

  Future<Result<void>> call(String id) => repository.deleteIncomeSource(id);
}
