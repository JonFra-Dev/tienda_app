import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/debts/presentation/screens/add_debt_screen.dart';
import '../../features/debts/presentation/screens/debt_detail_screen.dart';
import '../../features/debts/presentation/screens/debts_list_screen.dart';
import '../../features/debts/presentation/screens/snowball_plan_screen.dart';
import '../../features/finanzas/presentation/screens/add_transaction_screen.dart';
import '../../features/finanzas/presentation/screens/home_screen.dart';
import '../../features/finanzas/presentation/screens/profile_screen.dart';
import '../../features/finanzas/presentation/screens/statistics_screen.dart';
import '../../features/savings/presentation/screens/account_detail_screen.dart';
import '../../features/savings/presentation/screens/add_account_screen.dart';
import '../../features/savings/presentation/screens/add_income_source_screen.dart';
import '../../features/savings/presentation/screens/income_source_detail_screen.dart';
import '../../features/savings/presentation/screens/savings_dashboard_screen.dart';

/// go_router con redirect basado en el estado de autenticación.
final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ValueNotifier(0);
  ref.listen(authNotifierProvider, (_, __) => notifier.value++);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (context, gstate) {
      final auth = ref.read(authNotifierProvider);
      final loggedIn = auth.isAuthenticated;
      final loggingIn = gstate.matchedLocation == '/login' ||
          gstate.matchedLocation == '/register';

      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/add-transaction',
        name: 'add-transaction',
        builder: (_, __) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: '/stats',
        name: 'stats',
        builder: (_, __) => const StatisticsScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (_, __) => const ProfileScreen(),
      ),
      // ============== DEBTS ==============
      GoRoute(
        path: '/debts',
        name: 'debts',
        builder: (_, __) => const DebtsListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            name: 'debt-add',
            builder: (_, __) => const AddDebtScreen(),
          ),
          GoRoute(
            path: 'plan',
            name: 'snowball-plan',
            builder: (_, __) => const SnowballPlanScreen(),
          ),
          GoRoute(
            path: ':id',
            name: 'debt-detail',
            builder: (_, state) =>
                DebtDetailScreen(debtId: state.pathParameters['id']!),
          ),
        ],
      ),
      // ============== SAVINGS ==============
      GoRoute(
        path: '/savings',
        name: 'savings',
        builder: (_, __) => const SavingsDashboardScreen(),
        routes: [
          GoRoute(
            path: 'account/add',
            name: 'savings-account-add',
            builder: (_, __) => const AddAccountScreen(),
          ),
          GoRoute(
            path: 'account/:id',
            name: 'savings-account-detail',
            builder: (_, state) => AccountDetailScreen(
              accountId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: 'income/add',
            name: 'savings-income-add',
            builder: (_, __) => const AddIncomeSourceScreen(),
          ),
          GoRoute(
            path: 'income/:id',
            name: 'savings-income-detail',
            builder: (_, state) => IncomeSourceDetailScreen(
              sourceId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Ruta no encontrada: ${state.uri}')),
    ),
  );
});
