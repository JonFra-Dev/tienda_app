import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/transaction.dart';
import '../providers/finanzas_providers.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String _categoryId = TransactionCategory.all.first.id;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final tx = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: double.parse(_amountCtrl.text.replaceAll(',', '.')),
      description: _descCtrl.text.trim(),
      categoryId: _categoryId,
      type: _type,
      date: _date,
    );

    final ok =
        await ref.read(transactionsNotifierProvider.notifier).add(tx);

    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transacción guardada'),
          backgroundColor: AppColors.income,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.addTransaction)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text(AppStrings.expense),
                      icon: Icon(Icons.arrow_upward),
                    ),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text(AppStrings.income),
                      icon: Icon(Icons.arrow_downward),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (set) =>
                      setState(() => _type = set.first),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: AppStrings.amount,
                    prefixText: '\$ ',
                  ),
                  validator: Validators.amount,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: AppStrings.description,
                    prefixIcon: Icon(Icons.notes),
                  ),
                  validator: Validators.required,
                ),
                const SizedBox(height: 16),
                _CategoryPicker(
                  selectedId: _categoryId,
                  onChanged: (id) => setState(() => _categoryId = id),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text(AppStrings.date),
                  subtitle: Text(DateFormat('dd MMMM yyyy').format(_date)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 24),
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
                      : const Text(AppStrings.save),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  final String selectedId;
  final ValueChanged<String> onChanged;

  const _CategoryPicker({
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(AppStrings.category,
              style: TextStyle(color: AppColors.textSecondary)),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TransactionCategory.all.map((c) {
            final selected = c.id == selectedId;
            return ChoiceChip(
              label: Text(c.name),
              avatar: Icon(c.icon, size: 18, color: c.color),
              selected: selected,
              onSelected: (_) => onChanged(c.id),
              selectedColor: c.color.withValues(alpha: 0.2),
            );
          }).toList(),
        ),
      ],
    );
  }
}
