import '../../../../core/utils/result.dart';

/// Contrato del repositorio de tasas de cambio (REST API externa).
abstract class ExchangeRateRepository {
  /// Devuelve la tasa USD -> baseCurrency.
  Future<Result<double>> getUsdRate({String baseCurrency = 'COP'});
}
