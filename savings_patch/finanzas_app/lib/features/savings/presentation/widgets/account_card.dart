import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/savings_account.dart';

class AccountCard extends StatelessWidget {
  final SavingsAccount account;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const AccountCard({
    super.key,
    required this.account,
    this.onTap,
    this.onDelete,
  });

  IconData _iconForType(SavingsAccountType type) {
    switch (type) {
      case SavingsAccountType.emergencyFund:
        return Icons.local_hospital_outlined;
      case SavingsAccountType.general:
        return Icons.savings_outlined;
      case SavingsAccountType.investment:
        return Icons.trending_up;
      case SavingsAccountType.retirement:
        return Icons.elderly;
      case SavingsAccountType.education:
        return Icons.school_outlined;
    }
  }

  Color _colorForType(SavingsAccountType type) {
    switch (type) {
      case SavingsAccountType.emergencyFund:
        return AppColors.expense;
      case SavingsAccountType.general:
        return AppColors.indigo;
      case SavingsAccountType.investment:
        return AppColors.income;
      case SavingsAccountType.retirement:
        return AppColors.purple;
      case SavingsAccountType.education:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    final progress = account.percentToGoal != null
        ? (account.percentToGoal! / 100).clamp(0.0, 1.0)
        : null;
    final color = _colorForType(account.type);

    return Dismissible(
      key: ValueKey('account-${account.id}'),
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
                      backgroundColor: color.withValues(alpha: 0.18),
                      child: Icon(_iconForType(account.type), color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            account.type.label,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      fmt.format(account.currentBalance),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                if (progress != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: AppColors.cardLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        account.hasReachedGoal ? AppColors.income : color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    account.hasReachedGoal
                        ? '🎉 Meta alcanzada: ${fmt.format(account.goalAmount!)}'
                        : '${account.percentToGoal!.toStringAsFixed(0)}% de meta · ${fmt.format(account.goalAmount!)}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
