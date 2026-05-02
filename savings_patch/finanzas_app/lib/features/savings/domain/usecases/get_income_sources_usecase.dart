import '../../../../core/utils/result.dart';
import '../entities/income_source.dart';
import '../repositories/savings_repository.dart';

class GetIncomeSourcesUseCase {
  final SavingsRepository repository;
  const GetIncomeSourcesUseCase(this.repository);

  /// Devuelve fuentes ordenadas por fecha próxima (más cercanas primero).
  Future<Result<List<IncomeSource>>> call() async {
    final result = await repository.getIncomeSources();
    return result.fold(
      onSuccess: (list) {
        final sorted = [...list]
          ..sort((a, b) => a.nextExpectedDate.compareTo(b.nextExpectedDate));
        return Success(sorted);
      },
      onFailure: (f) => FailureResult<List<IncomeSource>>(f),
    );
  }
}
