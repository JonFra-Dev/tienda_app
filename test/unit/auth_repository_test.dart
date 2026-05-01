import 'package:finanzas_app/core/utils/result.dart';
import 'package:finanzas_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:finanzas_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AuthRepositoryImpl repo;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repo = AuthRepositoryImpl(AuthLocalDataSource(prefs));
  });

  test('register crea usuario y retorna Success con sesión activa', () async {
    final r = await repo.register(
      name: 'Jonfra',
      email: 'jon@test.com',
      password: 'secret123',
    );
    expect(r, isA<Success>());
    final user = r.valueOrNull!;
    expect(user.email, 'jon@test.com');
    expect(user.name, 'Jonfra');

    final current = await repo.getCurrentUser();
    expect(current.valueOrNull?.email, 'jon@test.com');
  });

  test('register falla si el email ya existe', () async {
    await repo.register(name: 'A', email: 'a@a.com', password: '123456');
    final r2 = await repo.register(
      name: 'B',
      email: 'a@a.com',
      password: '654321',
    );
    expect(r2, isA<FailureResult>());
  });

  test('login retorna Failure con credenciales incorrectas', () async {
    await repo.register(name: 'A', email: 'a@a.com', password: '123456');
    await repo.logout();
    final bad = await repo.login(email: 'a@a.com', password: 'wrong!');
    expect(bad, isA<FailureResult>());

    final ok = await repo.login(email: 'a@a.com', password: '123456');
    expect(ok, isA<Success>());
  });

  test('logout limpia la sesión actual', () async {
    await repo.register(name: 'A', email: 'a@a.com', password: '123456');
    expect((await repo.getCurrentUser()).valueOrNull, isNotNull);
    await repo.logout();
    expect((await repo.getCurrentUser()).valueOrNull, isNull);
  });
}
