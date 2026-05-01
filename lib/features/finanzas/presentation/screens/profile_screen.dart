import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/finanzas_providers.dart';
import '../widgets/error_view.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    final rateAsync = ref.watch(exchangeRateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profile)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.indigo,
                    child: Text(
                      (user?.name.isNotEmpty ?? false)
                          ? user!.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? '—',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '—',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.public, color: AppColors.purple),
                      SizedBox(width: 8),
                      Text(
                        AppStrings.exchangeRate,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  rateAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (e, _) => ErrorView(
                      message: 'No se pudo cargar la tasa: $e',
                      onRetry: () => ref.refresh(exchangeRateProvider),
                    ),
                    data: (rate) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '1 USD = ${NumberFormat('#,###.##', 'es_CO').format(rate)} COP',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.indigo,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => ref.refresh(exchangeRateProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Actualizar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_outlined,
                      color: AppColors.purple),
                  title: const Text(AppStrings.notifications),
                  subtitle: const Text(
                      'Recibir alertas cuando el presupuesto esté al 80%'),
                  trailing: const Icon(Icons.check_circle,
                      color: AppColors.income),
                ),
                const Divider(height: 0),
                ListTile(
                  leading:
                      const Icon(Icons.logout, color: AppColors.expense),
                  title: const Text(AppStrings.logout),
                  onTap: () =>
                      ref.read(authNotifierProvider.notifier).logout(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
