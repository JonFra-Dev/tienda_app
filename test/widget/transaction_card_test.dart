import 'package:finanzas_app/core/theme/app_theme.dart';
import 'package:finanzas_app/features/finanzas/domain/entities/transaction.dart';
import 'package:finanzas_app/features/finanzas/presentation/widgets/transaction_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es_CO');
  });

  testWidgets('TransactionCard pinta descripción, monto y categoría',
      (tester) async {
    final tx = Transaction(
      id: 't1',
      amount: 12500,
      description: 'Almuerzo',
      categoryId: 'food',
      type: TransactionType.expense,
      date: DateTime(2026, 4, 15),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(body: TransactionCard(transaction: tx)),
      ),
    );

    expect(find.text('Almuerzo'), findsOneWidget);
    // Categoría comida
    expect(find.textContaining('Comida'), findsOneWidget);
    // El signo "-" precede el monto en gastos
    expect(find.textContaining('-'), findsWidgets);
  });
}
