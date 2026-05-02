import '../../../../core/utils/result.dart';
import '../entities/income_source.dart';
import '../repositories/savings_repository.dart';

class AddIncomeSourceUseCase {
  final SavingsRepository repository;
  const AddIncomeSourceUseCase(this.repository);

  Future<Result<IncomeSource>> call(IncomeSource source) =>
      repository.addIncomeSource(source);
}
