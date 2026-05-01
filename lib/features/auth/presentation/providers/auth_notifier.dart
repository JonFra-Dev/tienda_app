import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_state.dart';

/// StateNotifier que orquesta los casos de uso del feature Auth.
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final AuthRepository repository;

  AuthNotifier({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.repository,
  }) : super(const AuthState.initial()) {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final result = await repository.getCurrentUser();
    result.fold(
      onSuccess: (user) {
        if (user != null) state = AuthState.authenticated(user);
      },
      onFailure: (_) {},
    );
  }

  Future<bool> login({required String email, required String password}) async {
    state = const AuthState.loading();
    final result = await loginUseCase(email: email, password: password);
    return result.fold(
      onSuccess: (user) {
        state = AuthState.authenticated(user);
        return true;
      },
      onFailure: (failure) {
        state = AuthState.error(failure.message);
        return false;
      },
    );
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    final result = await registerUseCase(
      name: name,
      email: email,
      password: password,
    );
    return result.fold(
      onSuccess: (user) {
        state = AuthState.authenticated(user);
        return true;
      },
      onFailure: (failure) {
        state = AuthState.error(failure.message);
        return false;
      },
    );
  }

  Future<void> logout() async {
    state = const AuthState.loading();
    await logoutUseCase();
    state = const AuthState.initial();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
