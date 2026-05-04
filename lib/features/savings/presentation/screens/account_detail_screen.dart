import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/savings_movement.dart';
import '../providers/savings_movements_provider.dart';
import '../providers/savings_providers.dart';

class AccountDetailScreen extends ConsumerStatefulWidget {
  final String accountId;
  const AccountDetailScreen({super.key, required this.accountId});

  @override
  ConsumerState<AccountDetailScreen> createState() =>
      _AccountDetailScreenState();
}

class _AccountDetailScreenState extends ConsumerState<AccountDetailScreen> {
  Future<void> _showMovementDialog(MovementType type) async {
    final state = ref.read(savingsNotifierProvider);
    final account = state.accounts.firstWhere((a) => a.id == widget.accountId);
    final controller = TextEditingController();

    final amount = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(type == MovementType.deposit ? 'Depositar' : 'Retirar'),
        content: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: InputDecoration(
              prefixText: '\$ ',
              labelText: 'Monto',
              helperText: type == MovementType.withdrawal
                  ? 'Saldo actual: ${NumberFormat.currency(locale: "es_CO", symbol: "\$", decimalDigits: 0).format(account.currentBalance)}'
                  : null,
            ),
            validator: Validators.amount,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final v = double.tryParse(controller.text.replaceAll(',', '.'));
              Navigator.pop(ctx, v);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (amount != null && amount > 0 && mounted) {
      final ok = await ref
          .read(savingsNotifierProvider.notifier)
          .recordMovement(account: account, amount: amount, type: type);
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(type == MovementType.deposit
                ? 'Depósito registrado'
                : 'Retiro registrado'),
            backgroundColor: AppColors.income,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(savingsNotifierProvider);
    final account =
        state.accounts.where((a) => a.id == widget.accountId).firstOrNull;

    if (account == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle')),
        body: const Center(child: Text('Cuenta no encontrada')),
      );
    }

    final movementsAsync = ref.watch(savingsMovementsProvider(widget.accountId));
    final fmt = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    final dateFmt = DateFormat('dd MMM, HH:mm', 'es_CO');

    return Scaffold(
      appBar: AppBar(title: Text(account.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saldo actual',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fmt.format(account.currentBalance),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.income,
                    ),
                  ),
                  if (account.goalAmount != null) ...[
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: ((account.percentToGoal ?? 0) / 100).clamp(0, 1),
                        minHeight: 10,
                        backgroundColor: AppColors.cardLight,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          account.hasReachedGoal
                              ? AppColors.income
                              : AppColors.indigo,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      account.hasReachedGoal
                          ? '🎉 Meta alcanzada: ${fmt.format(account.goalAmount!)}'
                          : '${account.percentToGoal!.toStringAsFixed(1)}% de la meta de ${fmt.format(account.goalAmount!)}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.category_outlined,
                      color: AppColors.purple),
                  title: const Text('Tipo de cuenta'),
                  trailing: Text(
                    account.type.label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showMovementDialog(MovementType.deposit),
                  icon: const Icon(Icons.arrow_downward),
                  label: const Text('Depositar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.income,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showMovementDialog(MovementType.withdrawal),
                  icon: const Icon(Icons.arrow_upward),
                  label: const Text('Retirar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.expense,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
          // ============== HISTORIAL DE MOVIMIENTOS ==============
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.history, color: AppColors.indigo),
                SizedBox(width: 8),
                Text(
                  'Historial de movimientos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          movementsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Card(
              color: AppColors.expense.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error al cargar: $e'),
              ),
            ),
            data: (movements) {
              if (movements.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(Icons.receipt_long_outlined,
                            size: 48, color: AppColors.textHint),
                        const SizedBox(height: 8),
                        Text(
                          'Aún no hay movimientos en esta cuenta.',
                          style: TextStyle(
                            color: AppColors.textSecondary.withValues(alpha: 0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Card(
                child: Column(
                  children: movements.asMap().entries.map((entry) {
                    final i = entry.key;
                    final m = entry.value;
                    final color = m.isDeposit
                        ? AppColors.income
                        : AppColors.expense;
                    return Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: color.withValues(alpha: 0.18),
                            child: Icon(
                              m.isDeposit
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: color,
                            ),
                          ),
                          title: Text(
                            '${m.isDeposit ? "+" : "-"}${fmt.format(m.amount)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          subtitle: Text(
                              '${m.isDeposit ? "Depósito" : "Retiro"} · ${dateFmt.format(m.date)}'),
                          trailing: m.note != null && m.note!.isNotEmpty
                              ? Tooltip(
                                  message: m.note!,
                                  child: const Icon(Icons.note_outlined,
                                      size: 16),
                                )
                              : null,
                        ),
                        if (i < movements.length - 1)
                          const Divider(height: 0, indent: 72),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.indigo.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.indigo, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Los movimientos en cuentas son transferencias de tu propio dinero — no aparecen como ingresos/gastos.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
