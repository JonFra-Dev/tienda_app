import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/debt_payment.dart';
import 'debts_providers.dart';

/// FutureProvider.family que devuelve los pagos de una deuda específica.
/// Se invalida automáticamente cuando se hace un nuevo pago, leyendo desde
/// el repositorio cada vez.
final debtPaymentsProvider =
    FutureProvider.family<List<DebtPayment>, String>((ref, debtId) async {
  // Refrescar cuando cambien las deudas (después de un pago, loadAll() se llama).
  ref.watch(debtsNotifierProvider);
  final repo = ref.watch(debtRepositoryProvider);
  final result = await repo.getPaymentsForDebt(debtId);
  return result.fold(
    onSuccess: (list) => list,
    onFailure: (f) => throw Exception(f.message),
  );
});
