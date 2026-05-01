import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/category.dart';
import '../providers/finanzas_providers.dart';
import '../widgets/error_view.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionsNotifierProvider);
    final calculator = ref.watch(budgetCalculatorProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.statistics)),
      body: Builder(
        builder: (_) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorMessage != null) {
            return ErrorView(
              message: state.errorMessage!,
              onRetry: () => ref
                  .read(transactionsNotifierProvider.notifier)
                  .loadAll(),
            );
          }
          final byCat =
              calculator.expenseByCategory(transactions: state.transactions);
          if (byCat.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Aún no hay gastos en este mes para graficar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            );
          }
          return _StatsContent(byCategory: byCat);
        },
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  final Map<String, double> byCategory;
  const _StatsContent({required this.byCategory});

  @override
  Widget build(BuildContext context) {
    final total = byCategory.values.fold<double>(0, (a, b) => a + b);
    final fmt = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    final sections = byCategory.entries.map((e) {
      final cat = TransactionCategory.byId(e.key);
      final pct = (e.value / total) * 100;
      return PieChartSectionData(
        color: cat.color,
        value: e.value,
        title: '${pct.toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    AppStrings.byCategory,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        sections: sections,
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Total: ${fmt.format(total)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...byCategory.entries.map((e) {
            final cat = TransactionCategory.byId(e.key);
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: cat.color.withValues(alpha: 0.18),
                  child: Icon(cat.icon, color: cat.color),
                ),
                title: Text(cat.name),
                trailing: Text(
                  fmt.format(e.value),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
