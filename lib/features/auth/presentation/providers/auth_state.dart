import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

/// Estado inmutable del feature Auth.
class AuthState extends Equatable {
  final bool isLoading;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;

  const AuthState.initial() : this();
  const AuthState.loading() : this(isLoading: true);
  const AuthState.authenticated(User user) : this(user: user);
  const AuthState.error(String message) : this(errorMessage: message);

  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? errorMessage,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [isLoading, user, errorMessage];
}
