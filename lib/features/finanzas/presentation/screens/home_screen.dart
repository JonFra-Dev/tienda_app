import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/notification_service.dart';
import '../../../babysteps/presentation/providers/babysteps_providers.dart';
import '../../../babysteps/presentation/providers/celebrations_provider.dart';
import '../../../babysteps/presentation/widgets/celebration_dialog.dart';
import '../../../debts/presentation/providers/debts_providers.dart';
import '../../../savings/presentation/providers/savings_providers.dart';
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
  bool _budgetWarningDismissedThisSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(transactionsNotifierProvider.notifier).loadAll();
      await ref.read(debtsNotifierProvider.notifier).loadAll();
      await ref.read(savingsNotifierProvider.notifier).loadAll();
      await ref.read(savingsNotifierProvider.notifier).rebuildAllReminders();

      // Verificar si hay celebraciones pendientes (en caso de que se haya
      // completado un step entre sesiones).
      final status = ref.read(babyStepsStatusProvider);
      ref
          .read(celebrationsProvider.notifier)
          .checkForNewCompletion(status.completedSteps.map((s) => s.number));
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
    final debtsState = ref.watch(debtsNotifierProvider);
    final savingsState = ref.watch(savingsNotifierProvider);
    final babySteps = ref.watch(babyStepsStatusProvider);
    final fmt = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    // ============== Listener de celebraciones ==============
    // Cada vez que el babyStepsStatus cambia, revisar si hay nueva celebración
    ref.listen(babyStepsStatusProvider, (_, next) {
      ref
          .read(celebrationsProvider.notifier)
          .checkForNewCompletion(next.completedSteps.map((s) => s.number));
    });

    // Cuando hay un step pendiente de celebrar, mostrar el dialog
    ref.listen(celebrationsProvider, (_, step) {
      if (step != null && mounted) {
        // Push notification además del dialog
        NotificationService.instance.showCelebration(
          stepNumber: step.number,
          stepName: step.shortName,
        );
        // Dialog visual
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          CelebrationDialog.show(
            context,
            step: step,
            onSeePlan: () => context.push('/babysteps'),
          ).then((_) {
            ref.read(celebrationsProvider.notifier).acknowledgeCelebration();
          });
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            tooltip: 'Mis Baby Steps',
            onPressed: () => context.push('/babysteps'),
          ),
          IconButton(
            icon: const Icon(Icons.savings_outlined),
            tooltip: 'Ahorros e ingresos',
            onPressed: () => context.push('/savings'),
          ),
          IconButton(
            icon: const Icon(Icons.ac_unit),
            tooltip: 'Mis deudas',
            onPressed: () => context.push('/debts'),
          ),
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
        onRefresh: () async {
          await ref.read(transactionsNotifierProvider.notifier).loadAll();
          await ref.read(debtsNotifierProvider.notifier).loadAll();
          await ref.read(savingsNotifierProvider.notifier).loadAll();
        },
        child: _buildBody(state, debtsState, savingsState, babySteps, fmt),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-transaction'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
      ),
    );
  }

  Widget _buildBody(
      state, debtsState, savingsState, babySteps, NumberFormat fmt) {
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
    final showBudgetWarning = summary != null &&
        summary.percentUsed >= 80 &&
        !_budgetWarningDismissedThisSession;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100, top: 8),
      children: [
        // ============== BANNER 80% PRESUPUESTO ==============
        if (showBudgetWarning)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: _BudgetWarningBanner(
              percentUsed: summary.percentUsed,
              remaining: summary.remaining,
              isOver: summary.isOverBudget,
              onDismiss: () => setState(
                  () => _budgetWarningDismissedThisSession = true),
            ),
          ),
        // ============== TARJETA BABY STEP ACTUAL ==============
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Card(
            color: AppColors.purple,
            child: InkWell(
              onTap: () => context.push('/babysteps'),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.yellow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${babySteps.currentStep.number}',
                          style: const TextStyle(
                            color: AppColors.purple,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estás en Baby Step',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            babySteps.currentStep.shortName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: babySteps.progressToCurrent.clamp(0, 1),
                              minHeight: 4,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.yellow,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (summary != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: BudgetCard(summary: summary, onEditBudget: _editBudget),
          ),
        if (savingsState.accounts.isNotEmpty ||
            savingsState.incomeSources.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Card(
              color: AppColors.income,
              child: InkWell(
                onTap: () => context.push('/savings'),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.savings_outlined,
                          color: AppColors.yellow, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total en ahorros',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              fmt.format(savingsState.totalSavings),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (savingsState.nextIncome != null)
                              Text(
                                'Próximo ingreso: ${savingsState.nextIncome!.name} en ${savingsState.nextIncome!.daysUntilNext} días',
                                style: const TextStyle(
                                  color: AppColors.yellow,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (debtsState.debts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Card(
              color: AppColors.indigo,
              child: InkWell(
                onTap: () => context.push('/debts'),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.ac_unit,
                          color: AppColors.yellow, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total en deudas',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              fmt.format(debtsState.totalBalance),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (debtsState.nextTarget != null)
                              Text(
                                'Próximo objetivo: ${debtsState.nextTarget!.name}',
                                style: const TextStyle(
                                  color: AppColors.yellow,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
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

/// Banner amarillo/rojo de aviso cuando el presupuesto pasa el 80%.
class _BudgetWarningBanner extends StatelessWidget {
  final double percentUsed;
  final double remaining;
  final bool isOver;
  final VoidCallback onDismiss;

  const _BudgetWarningBanner({
    required this.percentUsed,
    required this.remaining,
    required this.isOver,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final color = isOver ? AppColors.expense : AppColors.warning;
    final fmt = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(
            isOver ? Icons.error_outline : Icons.warning_amber_rounded,
            color: color,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOver
                      ? '¡Presupuesto excedido!'
                      : 'Cuidado: presupuesto al ${percentUsed.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isOver
                      ? 'Te has pasado del presupuesto mensual. Revisa tus gastos y considera ajustar.'
                      : 'Te quedan ${fmt.format(remaining)} este mes. Cuida cada gasto desde ahora.',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: onDismiss,
            tooltip: 'Ocultar',
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
