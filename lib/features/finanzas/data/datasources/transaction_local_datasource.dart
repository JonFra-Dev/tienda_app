import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction_model.dart';

/// Persistencia local con SharedPreferences (cumple requisito de persistencia
/// local). Almacena las transacciones como una lista JSON.
class TransactionLocalDataSource {
  static const String _kTransactions = 'finanzas_transactions';
  static const String _kBudget = 'finanzas_monthly_budget';

  final SharedPreferences prefs;
  TransactionLocalDataSource(this.prefs);

  Future<List<TransactionModel>> getAll() async {
    final raw = prefs.getString(_kTransactions);
    if (raw == null || raw.isEmpty) return [];
    final list = json.decode(raw) as List<dynamic>;
    return list
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _writeAll(List<TransactionModel> list) async {
    final encoded = json.encode(list.map((t) => t.toJson()).toList());
    await prefs.setString(_kTransactions, encoded);
  }

  Future<TransactionModel> add(TransactionModel t) async {
    final list = await getAll();
    list.add(t);
    await _writeAll(list);
    return t;
  }

  Future<void> delete(String id) async {
    final list = await getAll();
    list.removeWhere((t) => t.id == id);
    await _writeAll(list);
  }

  Future<void> setMonthlyBudget(double amount) async {
    await prefs.setDouble(_kBudget, amount);
  }

  double getMonthlyBudget() => prefs.getDouble(_kBudget) ?? 0;
}
