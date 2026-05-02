import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/income_source.dart';

class IncomeSourceCard extends StatelessWidget {
  final IncomeSource source;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onRecordIncome;

  const IncomeSourceCard({
    super.key,
    required this.source,
    this.onTap,
    this.onDelete,
    this.onRecordIncome,
  });

  String _daysLabel(int days) {
    if (days < 0) return 'Hace ${-days} días (esperado)';
    if (days == 0) return 'Hoy';
    if (days == 1) return 'Mañana';
    return 'En $days días';
  }

  Color _statusColor(int days) {
    if (days < 0) return AppColors.warning;
    if (days <= 3) return AppColors.income;
    return AppColors.indigo;
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    final dateFmt = DateFormat('dd MMM', 'es_CO');
    final days = source.daysUntilNext;
    final statusColor = _statusColor(days);

    return Dismissible(
      key: ValueKey('source-${source.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.expense,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          AppColors.income.withValues(alpha: 0.18),
                      child: const Icon(Icons.attach_money,
                          color: AppColors.income),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            source.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            source.frequency.label,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          fmt.format(source.expectedAmount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.income,
                          ),
                        ),
                        Text(
                          dateFmt.format(source.nextExpectedDate),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _daysLabel(days),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (onRecordIncome != null)
                      TextButton.icon(
                        onPressed: onRecordIncome,
                        icon: const Icon(Icons.add_circle_outline, size: 18),
                        label: const Text('Recibí',
                            style: TextStyle(fontSize: 13)),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.income,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
