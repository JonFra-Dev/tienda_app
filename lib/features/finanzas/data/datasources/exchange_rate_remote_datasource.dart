import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Datasource remoto: consume la API REST de open.er-api.com.
/// Endpoint público sin API key. Cumple el requisito de "consumo de al menos
/// una API REST".
class ExchangeRateRemoteDataSource {
  final http.Client client;
  ExchangeRateRemoteDataSource(this.client);

  static const String _baseUrl = 'https://open.er-api.com/v6/latest/USD';

  Future<double> getUsdRate(String baseCurrency) async {
    try {
      final response = await client
          .get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw HttpException('Error HTTP ${response.statusCode}');
      }
      final data = json.decode(response.body) as Map<String, dynamic>;
      final rates = data['rates'] as Map<String, dynamic>?;
      final rate = rates?[baseCurrency];
      if (rate == null) {
        throw const FormatException('Moneda no soportada por la API');
      }
      return (rate as num).toDouble();
    } on TimeoutException {
      throw const SocketException('Tiempo de espera agotado');
    }
  }
}
