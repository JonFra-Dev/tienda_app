import 'package:finanzas_app/core/utils/result.dart';
import 'package:finanzas_app/features/savings/data/datasources/savings_local_datasource.dart';
import 'package:finanzas_app/features/savings/data/repositories/savings_repository_impl.dart';
import 'package:finanzas_app/features/savings/domain/entities/frequency.dart';
import 'package:finanzas_app/features/savings/domain/entities/income_receipt.dart';
import 'package:finanzas_app/features/savings/domain/entities/income_source.dart';
import 'package:finanzas_app/features/savings/domain/entities/savings_account.dart';
import 'package:finanzas_app/features/savings/domain/entities/savings_movement.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SavingsRepositoryImpl repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repo = SavingsRepositoryImpl(SavingsLocalDataSource(prefs));
  });

  SavingsAccount buildAccount(String id, double balance) => SavingsAccount(
        id: id,
        name: 'Acc $id',
        type: SavingsAccountType.general,
        currentBalance: balance,
        createdAt: DateTime(2026, 5, 1),
      );

  IncomeSource buildSource(String id) => IncomeSource(
        id: id,
        name: 'Source $id',
        expectedAmount: 1000,
        frequency: IncomeFrequency.monthly,
        nextExpectedDate: DateTime(2026, 6, 1),
        createdAt: DateTime(2026, 5, 1),
      );

  group('Cuentas', () {
    test('add y getAccounts persisten/leen', () async {
      await repo.addAccount(buildAccount('1', 500));
      await repo.addAccount(buildAccount('2', 1000));
      final r = await repo.getAccounts();
      expect(r, isA<Success>());
      expect(r.valueOrNull!.length, 2);
    });

    test('updateAccount cambia el saldo', () async {
      await repo.addAccount(buildAccount('1', 500));
      await repo.updateAccount(buildAccount('1', 500).copyWith(
        currentBalance: 750,
      ));
      final list = (await repo.getAccounts()).valueOrNull!;
      expect(list.first.currentBalance, 750);
    });

    test('deleteAccount remueve cuenta y movimientos asociados', () async {
      await repo.addAccount(buildAccount('1', 500));
      await repo.addMovement(SavingsMovement(
        id: 'm1',
        accountId: '1',
        amount: 100,
        type: MovementType.deposit,
        date: DateTime.now(),
      ));
      await repo.deleteAccount('1');
      expect((await repo.getAccounts()).valueOrNull, isEmpty);
      expect((await repo.getMovementsForAccount('1')).valueOrNull, isEmpty);
    });
  });

  group('Movimientos', () {
    test('addMovement guarda y getMovementsForAccount filtra', () async {
      await repo.addAccount(buildAccount('1', 500));
      await repo.addMovement(SavingsMovement(
        id: 'm1',
        accountId: '1',
        amount: 100,
        type: MovementType.deposit,
        date: DateTime(2026, 5, 10),
      ));
      await repo.addMovement(SavingsMovement(
        id: 'm2',
        accountId: '1',
        amount: 50,
        type: MovementType.withdrawal,
        date: DateTime(2026, 5, 11),
      ));
      final movs = (await repo.getMovementsForAccount('1')).valueOrNull!;
      expect(movs.length, 2);
    });
  });

  group('Fuentes de ingreso', () {
    test('addIncomeSource y getIncomeSources persisten/leen', () async {
      await repo.addIncomeSource(buildSource('s1'));
      final r = await repo.getIncomeSources();
      expect(r, isA<Success>());
      expect(r.valueOrNull!.length, 1);
      expect(r.valueOrNull!.first.frequency, IncomeFrequency.monthly);
    });

    test('addReceipt guarda recibos vinculados a la fuente', () async {
      await repo.addIncomeSource(buildSource('s1'));
      await repo.addReceipt(IncomeReceipt(
        id: 'r1',
        sourceId: 's1',
        actualAmount: 950,
        receivedDate: DateTime(2026, 6, 1),
      ));
      final receipts = (await repo.getReceiptsForSource('s1')).valueOrNull!;
      expect(receipts.length, 1);
      expect(receipts.first.actualAmount, 950);
    });

    test('deleteIncomeSource borra fuente y recibos en cascada', () async {
      await repo.addIncomeSource(buildSource('s1'));
      await repo.addReceipt(IncomeReceipt(
        id: 'r1',
        sourceId: 's1',
        actualAmount: 950,
        receivedDate: DateTime(2026, 6, 1),
      ));
      await repo.deleteIncomeSource('s1');
      expect((await repo.getIncomeSources()).valueOrNull, isEmpty);
      expect((await repo.getReceiptsForSource('s1')).valueOrNull, isEmpty);
    });
  });
}
