import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/savings_movement.dart';
import 'savings_providers.dart';

/// FutureProvider.family que devuelve los movimientos de una cuenta específica.
final savingsMovementsProvider =
    FutureProvider.family<List<SavingsMovement>, String>((ref, accountId) async {
  ref.watch(savingsNotifierProvider);
  final repo = ref.watch(savingsRepositoryProvider);
  final result = await repo.getMovementsForAccount(accountId);
  return result.fold(
    onSuccess: (list) => list,
    onFailure: (f) => throw Exception(f.message),
  );
});
