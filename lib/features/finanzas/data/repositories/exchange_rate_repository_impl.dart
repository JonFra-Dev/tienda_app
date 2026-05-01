import 'dart:io';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/exchange_rate_repository.dart';
import '../datasources/exchange_rate_remote_datasource.dart';

class ExchangeRateRepositoryImpl implements ExchangeRateRepository {
  final ExchangeRateRemoteDataSource remoteDataSource;
  ExchangeRateRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<double>> getUsdRate({String baseCurrency = 'COP'}) async {
    try {
      final rate = await remoteDataSource.getUsdRate(baseCurrency);
      return Success(rate);
    } on SocketException catch (e) {
      return FailureResult(NetworkFailure('Sin conexión: ${e.message}'));
    } catch (e) {
      return FailureResult(ServerFailure('Error API: $e'));
    }
  }
}
