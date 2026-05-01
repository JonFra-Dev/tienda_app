import 'package:finanzas_app/core/utils/result.dart';
import 'package:finanzas_app/features/finanzas/data/datasources/transaction_local_datasource.dart';
import 'package:finanzas_app/features/finanzas/data/repositories/transaction_repository_impl.dart';
import 'package:finanzas_app/features/finanzas/domain/entities/transaction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late TransactionRepositoryImpl repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repo = TransactionRepositoryImpl(TransactionLocalDataSource(prefs));
  });

  Transaction build(String id, double amount) => Transaction(
        id: id,
        amount: amount,
        description: 'tx-$id',
        categoryId: 'food',
        type: TransactionType.expense,
        date: DateTime(2026, 4, 15),
      );

  test('add y getAll: persiste y recupera transacciones', () async {
    await repo.add(build('1', 100));
    await repo.add(build('2', 50));
    final r = await repo.getAll();
    expect(r, isA<Success>());
    final list = r.valueOrNull!;
    expect(list.length, 2);
    expect(list.map((t) => t.id), containsAll(['1', '2']));
  });

  test('delete remueve la transacción correcta', () async {
    await repo.add(build('1', 100));
    await repo.add(build('2', 200));
    await repo.delete('1');
    final list = (await repo.getAll()).valueOrNull!;
    expect(list.length, 1);
    expect(list.first.id, '2');
  });

  test('setMonthlyBudget y getMonthlyBudget guardan/leen valor', () async {
    expect((await repo.getMonthlyBudget()).valueOrNull, 0);
    await repo.setMonthlyBudget(1500);
    expect((await repo.getMonthlyBudget()).valueOrNull, 1500);
  });
}
