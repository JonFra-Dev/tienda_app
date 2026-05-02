import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/income_source.dart';
import '../providers/savings_providers.dart';
import '../widgets/account_card.dart';
import '../widgets/financial_health_card.dart';
import '../widgets/income_source_card.dart';

class SavingsDashboardScreen extends ConsumerStatefulWidget {
  const SavingsDashboardScreen({super.key});

  @override
  ConsumerState<SavingsDashboardScreen> createState() =>
      _SavingsDashboardScreenState();
}

class _SavingsDashboardScreenState extends ConsumerState<SavingsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(savingsNotifierProvider.notifier).loadAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _quickRecordIncome(IncomeSource source) async {
    final controller =
        TextEditingController(text: source.expectedAmount.toStringAsFixed(0));

    final amount = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Recibí ingreso de ${source.name}'),
        content: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: const InputDecoration(
              prefixText: '\$ ',
              labelText: 'Monto recibido',
              helperText: 'Puede ser distinto al esperado',
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ahorros e ingresos'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.yellow,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.savings_outlined), text: 'Cuentas'),
            Tab(icon: Icon(Icons.attach_money), text: 'Ingresos'),
          ],
        ),
      ),
      body: state.isLoading &&
              state.accounts.isEmpty &&
              state.incomeSources.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  child: FinancialHealthCard(
                    totalSavings: state.totalSavings,
                    projectedMonthlyIncome: state.projectedMonthlyIncome,
                    nextIncomeLabel: state.nextIncome?.name,
                    nextIncomeDate: state.nextIncome?.nextExpectedDate,
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAccountsTab(state),
                      _buildIncomeTab(state),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (_, __) => FloatingActionButton.extended(
          onPressed: () {
            if (_tabController.index == 0) {
              context.push('/savings/account/add');
            } else {
              context.push('/savings/income/add');
            }
          },
          icon: const Icon(Icons.add),
          label: Text(_tabController.index == 0 ? 'Nueva cuenta' : 'Nuevo ingreso'),
        ),
      ),
    );
  }

  Widget _buildAccountsTab(state) {
    if (state.accounts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.savings_outlined,
                  size: 64, color: AppColors.textHint),
              SizedBox(height: 12),
              Text(
                'Aún no tienes cuentas de ahorro.\nAgrega una con el botón "Nueva cuenta".',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: state.accounts
          .map<Widget>((a) => AccountCard(
                account: a,
                onTap: () => context.push('/savings/account/${a.id}'),
                onDelete: () => ref
                    .read(savingsNotifierProvider.notifier)
                    .removeAccount(a.id),
              ))
          .toList(),
    );
  }

  Widget _buildIncomeTab(state) {
    if (state.incomeSources.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.attach_money,
                  size: 64, color: AppColors.textHint),
              SizedBox(height: 12),
              Text(
                'Aún no registras fuentes de ingreso.\nAgrega una con el botón "Nuevo ingreso".',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: state.incomeSources
          .map<Widget>((s) => IncomeSourceCard(
                source: s,
                onTap: () => context.push('/savings/income/${s.id}'),
                onRecordIncome: () => _quickRecordIncome(s),
                onDelete: () => ref
                    .read(savingsNotifierProvider.notifier)
                    .removeIncomeSource(s.id),
              ))
          .toList(),
    );
  }
}
