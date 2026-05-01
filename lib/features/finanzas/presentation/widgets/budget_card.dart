import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/budget_summary.dart';

class BudgetCard extends StatelessWidget {
  final BudgetSummary summary;
  final VoidCallback onEditBudget;

  const BudgetCard({
    super.key,
    required this.summary,
    required this.onEditBudget,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    final progress = summary.monthlyBudget > 0
        ? (summary.totalExpense / summary.monthlyBudget).clamp(0.0, 1.0)
        : 0.0;

    final progressColor = summary.percentUsed >= 100
        ? AppColors.expense
        : summary.percentUsed >= 80
            ? AppColors.warning
            : AppColors.income;

    return Card(
      color: AppColors.indigo,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Balance del mes',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                IconButton(
                  icon: const Icon(Icons.tune, color: Colors.white),
                  onPressed: onEditBudget,
                  tooltip: 'Configurar presupuesto',
                ),
              ],
            ),
            Text(
              fmt.format(summary.balance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _MiniStat(
                  icon: Icons.arrow_downward,
                  label: 'Ingresos',
                  value: fmt.format(summary.totalIncome),
                  color: AppColors.yellow,
                ),
                const SizedBox(width: 16),
                _MiniStat(
                  icon: Icons.arrow_upward,
                  label: 'Gastos',
                  value: fmt.format(summary.totalExpense),
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (summary.monthlyBudget > 0) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Presupuesto: ${fmt.format(summary.monthlyBudget)} · '
                '${summary.percentUsed.toStringAsFixed(0)}% usado',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ] else
              TextButton.icon(
                onPressed: onEditBudget,
                icon: const Icon(Icons.add, color: AppColors.yellow),
                label: const Text(
                  'Definir presupuesto mensual',
                  style: TextStyle(color: AppColors.yellow),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 14),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(color: color, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
