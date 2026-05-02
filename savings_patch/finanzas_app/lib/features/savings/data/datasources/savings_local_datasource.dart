import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/income_receipt_model.dart';
import '../models/income_source_model.dart';
import '../models/savings_account_model.dart';
import '../models/savings_movement_model.dart';

/// Persistencia local de cuentas, movimientos, fuentes de ingreso y recibos.
class SavingsLocalDataSource {
  static const String _kAccounts = 'savings_accounts';
  static const String _kMovements = 'savings_movements';
  static const String _kSources = 'income_sources';
  static const String _kReceipts = 'income_receipts';

  final SharedPreferences prefs;
  SavingsLocalDataSource(this.prefs);

  // ============== HELPERS ==============

  Future<List<T>> _readList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    final list = json.decode(raw) as List<dynamic>;
    return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _writeList<T>(
    String key,
    List<T> list,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    final encoded = json.encode(list.map(toJson).toList());
    await prefs.setString(key, encoded);
  }

  // ============== CUENTAS ==============

  Future<List<SavingsAccountModel>> getAccounts() =>
      _readList(_kAccounts, SavingsAccountModel.fromJson);

  Future<SavingsAccountModel> addAccount(SavingsAccountModel a) async {
    final list = await getAccounts();
    list.add(a);
    await _writeList(_kAccounts, list, (m) => m.toJson());
    return a;
  }

  Future<SavingsAccountModel> updateAccount(SavingsAccountModel a) async {
    final list = await getAccounts();
    final i = list.indexWhere((x) => x.id == a.id);
    if (i == -1) {
      list.add(a);
    } else {
      list[i] = a;
    }
    await _writeList(_kAccounts, list, (m) => m.toJson());
    return a;
  }

  Future<void> deleteAccount(String id) async {
    final list = await getAccounts();
    list.removeWhere((a) => a.id == id);
    await _writeList(_kAccounts, list, (m) => m.toJson());
    // También borrar movimientos asociados
    final movs = await getAllMovements();
    movs.removeWhere((m) => m.accountId == id);
    await _writeList(_kMovements, movs, (m) => m.toJson());
  }

  // ============== MOVIMIENTOS ==============

  Future<List<SavingsMovementModel>> getAllMovements() =>
      _readList(_kMovements, SavingsMovementModel.fromJson);

  Future<List<SavingsMovementModel>> getMovementsForAccount(
      String accountId) async {
    final all = await getAllMovements();
    return all.where((m) => m.accountId == accountId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<SavingsMovementModel> addMovement(SavingsMovementModel m) async {
    final list = await getAllMovements();
    list.add(m);
    await _writeList(_kMovements, list, (x) => x.toJson());
    return m;
  }

  // ============== FUENTES DE INGRESO ==============

  Future<List<IncomeSourceModel>> getIncomeSources() =>
      _readList(_kSources, IncomeSourceModel.fromJson);

  Future<IncomeSourceModel> addIncomeSource(IncomeSourceModel s) async {
    final list = await getIncomeSources();
    list.add(s);
    await _writeList(_kSources, list, (x) => x.toJson());
    return s;
  }

  Future<IncomeSourceModel> updateIncomeSource(IncomeSourceModel s) async {
    final list = await getIncomeSources();
    final i = list.indexWhere((x) => x.id == s.id);
    if (i == -1) {
      list.add(s);
    } else {
      list[i] = s;
    }
    await _writeList(_kSources, list, (x) => x.toJson());
    return s;
  }

  Future<void> deleteIncomeSource(String id) async {
    final list = await getIncomeSources();
    list.removeWhere((s) => s.id == id);
    await _writeList(_kSources, list, (x) => x.toJson());
    // También borrar recibos asociados
    final receipts = await getAllReceipts();
    receipts.removeWhere((r) => r.sourceId == id);
    await _writeList(_kReceipts, receipts, (x) => x.toJson());
  }

  // ============== RECIBOS DE INGRESO ==============

  Future<List<IncomeReceiptModel>> getAllReceipts() =>
      _readList(_kReceipts, IncomeReceiptModel.fromJson);

  Future<List<IncomeReceiptModel>> getReceiptsForSource(String sourceId) async {
    final all = await getAllReceipts();
    return all.where((r) => r.sourceId == sourceId).toList()
      ..sort((a, b) => b.receivedDate.compareTo(a.receivedDate));
  }

  Future<IncomeReceiptModel> addReceipt(IncomeReceiptModel r) async {
    final list = await getAllReceipts();
    list.add(r);
    await _writeList(_kReceipts, list, (x) => x.toJson());
    return r;
  }
}
