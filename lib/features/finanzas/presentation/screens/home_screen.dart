import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../providers/finanzas_providers.dart';
import '../widgets/budget_card.dart';
import '../widgets/error_view.dart';
import '../widgets/transaction_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionsNotifierProvider.notifier).loadAll();
    });
  }

  Future<void> _editBudget() async {
    final controller = TextEditingController();
    final amount = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.monthlyBudget),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(
            prefixText: '\$ ',
            labelText: AppStrings.amount,
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
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
    if (amount != null && amount >= 0) {
      await ref
          .read(transactionsNotifierProvider.notifier)
          .setMonthlyBudget(amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: AppStrings.statistics,
            onPressed: () => context.push('/stats'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: AppStrings.profile,
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(transactionsNotifierProvider.notifier)
            .loadAll(),
        child: _buildBody(state),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-transaction'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
      ),
    );
  }

  Widget _buildBody(state) {
    if (state.isLoading && state.transactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null && state.transactions.isEmpty) {
      return ErrorView(
        message: state.errorMessage!,
        onRetry: () =>
            ref.read(transactionsNotifierProvider.notifier).loadAll(),
      );
    }
    final summary = state.summary;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100, top: 8),
      children: [
        if (summary != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: BudgetCard(summary: summary, onEditBudget: _editBudget),
          ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Text(
            AppStrings.recentTransactions,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (state.transactions.isEmpty)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Column(
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 64, color: AppColors.textHint),
                SizedBox(height: 12),
                Text(
                  'Aún no tienes transacciones.\nUsa el botón "Nueva" para empezar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          )
        else
          ...state.transactions.map(
            (t) => TransactionCard(
              transaction: t,
              onDelete: () => ref
                  .read(transactionsNotifierProvider.notifier)
                  .remove(t.id),
            ),
          ),
      ],
    );
  }
}
