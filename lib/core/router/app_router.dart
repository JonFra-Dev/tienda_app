import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/finanzas/presentation/screens/add_transaction_screen.dart';
import '../../features/finanzas/presentation/screens/home_screen.dart';
import '../../features/finanzas/presentation/screens/profile_screen.dart';
import '../../features/finanzas/presentation/screens/statistics_screen.dart';

/// go_router con redirect basado en el estado de autenticación.
final goRouterProvider = Provider<GoRouter>((ref) {
  // Listener que invalida el router cuando cambia el auth state.
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
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Ruta no encontrada: ${state.uri}')),
    ),
  );
});
