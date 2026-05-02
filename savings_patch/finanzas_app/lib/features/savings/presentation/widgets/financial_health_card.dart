import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';

/// Tarjeta destacada con la "salud financiera": ahorros + ingreso proyectado.
class FinancialHealthCard extends StatelessWidget {
  final double totalSavings;
  final double projectedMonthlyIncome;
  final String? nextIncomeLabel;
  final DateTime? nextIncomeDate;

  const FinancialHealthCard({
    super.key,
    required this.totalSavings,
    required this.projectedMonthlyIncome,
    this.nextIncomeLabel,
    this.nextIncomeDate,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    final dateFmt = DateFormat('dd MMM', 'es_CO');

    return Card(
      color: AppColors.income,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.health_and_safety,
                    color: AppColors.yellow, size: 26),
                SizedBox(width: 8),
                Text(
                  'Tu salud financiera',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Total en ahorros',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              fmt.format(totalSavings),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ingreso mensual proyectado',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fmt.format(projectedMonthlyIncome),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (nextIncomeLabel != null && nextIncomeDate != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Próximo: $nextIncomeLabel · ${dateFmt.format(nextIncomeDate!)}',
                      style: const TextStyle(
                        color: AppColors.yellow,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
