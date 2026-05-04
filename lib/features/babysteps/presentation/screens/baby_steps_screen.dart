import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/baby_step.dart';
import '../providers/babysteps_providers.dart';
import '../widgets/step_card.dart';

class BabyStepsScreen extends ConsumerWidget {
  const BabyStepsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(babyStepsStatusProvider);
    final fmt = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('¿En qué Baby Step estoy?'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ============== Hero card ==============
          Card(
            color: status.isFinanciallyFree
                ? AppColors.income
                : AppColors.purple,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        status.isFinanciallyFree
                            ? Icons.celebration
                            : Icons.flag_outlined,
                        color: AppColors.yellow,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Baby Step ${status.currentStep.number} de 7',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    status.currentStep.shortName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    status.currentStep.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!status.isFinanciallyFree) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: status.progressToCurrent.clamp(0, 1),
                        minHeight: 12,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.yellow,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(status.progressToCurrent * 100).toStringAsFixed(0)}% completado',
                          style: const TextStyle(
                            color: AppColors.yellow,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (status.targetValue > 0 && status.targetValue != 1)
                          Text(
                            '${fmt.format(status.currentValue)} / ${fmt.format(status.targetValue)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline,
                            color: AppColors.yellow, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            status.contextMessage,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // ============== Lista de los 7 pasos ==============
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Tu camino hacia la libertad financiera',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...BabyStep.values.map(
            (step) => StepCard(
              step: step,
              isCompleted: status.isCompleted(step),
              isCurrent: status.currentStep == step,
              progress: status.currentStep == step
                  ? status.progressToCurrent
                  : 0,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.indigo.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppColors.indigo.withValues(alpha: 0.3)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: AppColors.indigo, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '¿Cómo se calcula esto?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.indigo,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Tu paso actual se infiere automáticamente a partir de tus '
                  'cuentas de ahorro, deudas activas e ingresos registrados. '
                  'Los pasos no se pueden saltar — tienes que completar el '
                  'actual antes de avanzar.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
