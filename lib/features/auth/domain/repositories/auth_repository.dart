import '../../../../core/utils/result.dart';
import '../entities/user.dart';

/// Contrato del repositorio (la capa de dominio NO depende de la implementación).
abstract class AuthRepository {
  Future<Result<User>> login({required String email, required String password});
  Future<Result<User>> register({
    required String name,
    required String email,
    required String password,
  });
  Future<Result<void>> logout();
  Future<Result<User?>> getCurrentUser();
}
