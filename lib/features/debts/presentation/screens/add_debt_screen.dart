import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../savings/domain/entities/savings_account.dart';
import '../../../savings/presentation/providers/savings_providers.dart';
import '../../domain/entities/debt.dart';
import '../providers/debts_providers.dart';

class AddDebtScreen extends ConsumerStatefulWidget {
  const AddDebtScreen({super.key});

  @override
  ConsumerState<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends ConsumerState<AddDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController();
  final _minCtrl = TextEditingController();
  final _rateCtrl = TextEditingController(text: '0');
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    _minCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  /// Detecta el saldo total del fondo de emergencia.
  double _emergencyFundBalance() {
    final state = ref.read(savingsNotifierProvider);
    return state.accounts
        .where((a) => a.type == SavingsAccountType.emergencyFund)
        .fold(0.0, (s, a) => s + a.currentBalance);
  }

  /// Mostrar diálogo Ramsey-style ANTES de aceptar la deuda.
  /// Retorna true si el usuario confirma agregar la deuda igual.
  Future<bool> _showRamseyWarning(double newDebtAmount) async {
    final emergencyFund = _emergencyFundBalance();
    final fmt = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    final hasEnoughFund = emergencyFund >= newDebtAmount;
    final hasMinFund = emergencyFund > 0;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: AppColors.warning, size: 28),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Antes de endeudarte…',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasEnoughFund) ...[
              Text(
                'Tu fondo de emergencia tiene ${fmt.format(emergencyFund)}.',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Es suficiente para cubrir esta deuda de ${fmt.format(newDebtAmount)}. ¿Por qué no usar el fondo en lugar de pagar intereses?',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ] else if (hasMinFund) ...[
              Text(
                'Tienes ${fmt.format(emergencyFund)} en tu fondo de emergencia.',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Text(
                'Considera usar parte de ese dinero antes de endeudarte. Cada peso que evites pagar en intereses es un peso que se queda contigo.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ] else ...[
              const Text(
                'Aún no tienes fondo de emergencia (Baby Step 1).',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Text(
                'Antes de aceptar nuevas deudas, intenta ahorrar al menos \$4.000.000 como colchón. Sin fondo, cada imprevisto se convierte en más deuda.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.purple.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.purple.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline,
                      color: AppColors.purple, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Dave Ramsey: "La deuda no es una herramienta, es un riesgo."',
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: AppColors.purple,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar y revisar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('Agregar deuda igual'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final balance = double.parse(_balanceCtrl.text.replaceAll(',', '.'));

    // Mostrar warning Ramsey antes de proceder
    final confirmed = await _showRamseyWarning(balance);
    if (!confirmed || !mounted) return;

    setState(() => _saving = true);

    final debt = Debt(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      originalAmount: balance,
      currentBalance: balance,
      minimumPayment: double.parse(_minCtrl.text.replaceAll(',', '.')),
      annualInterestRate:
          double.parse(_rateCtrl.text.replaceAll(',', '.').isEmpty
              ? '0'
              : _rateCtrl.text.replaceAll(',', '.')),
      createdAt: DateTime.now(),
    );

    final ok = await ref.read(debtsNotifierProvider.notifier).add(debt);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deuda registrada'),
          backgroundColor: AppColors.income,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva deuda')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    hintText: 'Tarjeta Bancolombia, Préstamo carro...',
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                  validator: Validators.required,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _balanceCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Saldo actual',
                    prefixText: '\$ ',
                  ),
                  validator: Validators.amount,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _minCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Pago mínimo mensual',
                    prefixText: '\$ ',
                  ),
                  validator: Validators.amount,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _rateCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Tasa de interés anual (%)',
                    helperText: 'Si no la conoces, deja en 0',
                    suffixText: '%',
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text('Guardar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
