import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../providers/savings_providers.dart';

class IncomeSourceDetailScreen extends ConsumerStatefulWidget {
  final String sourceId;
  const IncomeSourceDetailScreen({super.key, required this.sourceId});

  @override
  ConsumerState<IncomeSourceDetailScreen> createState() =>
      _IncomeSourceDetailScreenState();
}

class _IncomeSourceDetailScreenState
    extends ConsumerState<IncomeSourceDetailScreen> {
  Future<void> _recordIncome() async {
    final state = ref.read(savingsNotifierProvider);
    final source =
        state.incomeSources.firstWhere((s) => s.id == widget.sourceId);
    final controller =
        TextEditingController(text: source.expectedAmount.toStringAsFixed(0));

    final amount = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Registrar ingreso de ${source.name}'),
        content: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: const InputDecoration(
              prefixText: '\$ ',
              labelText: 'Monto recibido',
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
            child: const Text('Registrar'),
          ),
        ],
      ),
    );

    if (amount != null && amount > 0 && mounted) {
      final ok = await ref
          .read(savingsNotifierProvider.notifier)
          .recordIncome(source: source, actualAmount: amount);
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Ingreso registrado y agregado a tus transacciones'),
            backgroundColor: AppColors.income,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(savingsNotifierProvider);
    final source =
        state.incomeSources.where((s) => s.id == widget.sourceId).firstOrNull;

    if (source == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle')),
        body: const Center(child: Text('Fuente no encontrada')),
      );
    }

    final fmt = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    final dateFmt = DateFormat('dd MMMM yyyy', 'es_CO');
    final days = source.daysUntilNext;

    return Scaffold(
      appBar: AppBar(title: Text(source.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: AppColors.income,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monto esperado',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fmt.format(source.expectedAmount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Mensual proyectado: ${fmt.format(source.monthlyEquivalent)}',
                    style: const TextStyle(color: AppColors.yellow),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.repeat, color: AppColors.indigo),
                  title: const Text('Frecuencia'),
                  trailing: Text(
                    source.frequency.label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.calendar_today_outlined,
                      color: AppColors.purple),
                  title: const Text('Próxima fecha esperada'),
                  subtitle: Text(
                    days < 0
                        ? 'Hace ${-days} días'
                        : days == 0
                            ? 'Hoy'
                            : 'En $days días',
                  ),
                  trailing: Text(
                    dateFmt.format(source.nextExpectedDate),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: Icon(
                    source.isActive
                        ? Icons.check_circle
                        : Icons.pause_circle_outline,
                    color: source.isActive
                        ? AppColors.income
                        : AppColors.textSecondary,
                  ),
                  title: const Text('Estado'),
                  trailing: Text(
                    source.isActive ? 'Activa' : 'Pausada',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _recordIncome,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Registrar ingreso recibido'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.income,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.income.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.income, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Al registrar un ingreso, se crea automáticamente una transacción tipo "ingreso" en tu feed de finanzas y la próxima fecha avanza según la frecuencia.',
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
