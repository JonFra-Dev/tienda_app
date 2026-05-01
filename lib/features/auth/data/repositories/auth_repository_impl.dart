import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  AuthRepositoryImpl(this.localDataSource);

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await localDataSource.login(email: email, password: password);
      if (user == null) {
        return const FailureResult(AuthFailure('Credenciales incorrectas'));
      }
      return Success(user);
    } catch (e) {
      return FailureResult(CacheFailure('Error al iniciar sesión: $e'));
    }
  }

  @override
  Future<Result<User>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final user = await localDataSource.register(
        name: name,
        email: email,
        password: password,
      );
      if (user == null) {
        return const FailureResult(
          AuthFailure('Ya existe un usuario con ese correo'),
        );
      }
      return Success(user);
    } catch (e) {
      return FailureResult(CacheFailure('Error al registrar: $e'));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await localDataSource.logout();
      return const Success(null);
    } catch (e) {
      return FailureResult(CacheFailure('Error al cerrar sesión: $e'));
    }
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      return Success(localDataSource.getCurrentUser());
    } catch (e) {
      return FailureResult(CacheFailure('Error al leer sesión: $e'));
    }
  }
}
