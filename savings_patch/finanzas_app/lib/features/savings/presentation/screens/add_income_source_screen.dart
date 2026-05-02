import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/frequency.dart';
import '../../domain/entities/income_source.dart';
import '../providers/savings_providers.dart';

class AddIncomeSourceScreen extends ConsumerStatefulWidget {
  const AddIncomeSourceScreen({super.key});

  @override
  ConsumerState<AddIncomeSourceScreen> createState() =>
      _AddIncomeSourceScreenState();
}

class _AddIncomeSourceScreenState extends ConsumerState<AddIncomeSourceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  IncomeFrequency _frequency = IncomeFrequency.monthly;
  DateTime _nextDate = DateTime.now().add(const Duration(days: 7));
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _nextDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final source = IncomeSource(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      expectedAmount: double.parse(_amountCtrl.text.replaceAll(',', '.')),
      frequency: _frequency,
      nextExpectedDate: _nextDate,
      createdAt: DateTime.now(),
    );

    final ok = await ref
        .read(savingsNotifierProvider.notifier)
        .addIncomeSource(source);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fuente de ingreso registrada'),
          backgroundColor: AppColors.income,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMMM yyyy', 'es_CO');

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva fuente de ingreso')),
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
                    hintText: 'Salario, Freelance, Renta...',
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                  validator: Validators.required,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Monto esperado',
                    prefixText: '\$ ',
                  ),
                  validator: Validators.amount,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<IncomeFrequency>(
                  initialValue: _frequency,
                  decoration: const InputDecoration(
                    labelText: 'Frecuencia',
                    prefixIcon: Icon(Icons.repeat),
                  ),
                  items: IncomeFrequency.values
                      .map((f) => DropdownMenuItem(
                            value: f,
                            child: Text(f.label),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _frequency = v!),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text('Próxima fecha esperada'),
                  subtitle: Text(dateFmt.format(_nextDate)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _pickDate,
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
