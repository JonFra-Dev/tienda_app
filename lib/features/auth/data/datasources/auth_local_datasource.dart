import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

/// Datasource local: simula la BD de usuarios en SharedPreferences.
///
/// Cumple con el requisito de "auth simulada con tokens". El "token" es un
/// string aleatorio que se guarda en preferencias junto al usuario activo.
class AuthLocalDataSource {
  static const String _kUsersDb = 'auth_users_db';
  static const String _kCurrentUser = 'auth_current_user';
  static const String _kToken = 'auth_token';

  final SharedPreferences prefs;
  AuthLocalDataSource(this.prefs);

  /// Devuelve el mapa { email -> { user: UserModel, password: hash } }
  Map<String, dynamic> _readUsers() {
    final raw = prefs.getString(_kUsersDb);
    if (raw == null || raw.isEmpty) return <String, dynamic>{};
    return json.decode(raw) as Map<String, dynamic>;
  }

  Future<void> _writeUsers(Map<String, dynamic> users) async {
    await prefs.setString(_kUsersDb, json.encode(users));
  }

  /// Hash trivial (no es seguro, sólo para evitar guardar texto plano).
  String _hash(String pwd) => base64Encode(utf8.encode('finanzas:$pwd'));

  Future<UserModel?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final users = _readUsers();
    if (users.containsKey(email)) return null;
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
    );
    users[email] = {
      'user': user.toJson(),
      'password': _hash(password),
    };
    await _writeUsers(users);
    await _persistSession(user);
    return user;
  }

  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    final users = _readUsers();
    final entry = users[email] as Map<String, dynamic>?;
    if (entry == null) return null;
    if (entry['password'] != _hash(password)) return null;
    final user = UserModel.fromJson(entry['user'] as Map<String, dynamic>);
    await _persistSession(user);
    return user;
  }

  Future<void> _persistSession(UserModel user) async {
    await prefs.setString(_kCurrentUser, user.toJsonString());
    await prefs.setString(
      _kToken,
      base64Encode(utf8.encode('${user.id}:${DateTime.now().toIso8601String()}')),
    );
  }

  Future<void> logout() async {
    await prefs.remove(_kCurrentUser);
    await prefs.remove(_kToken);
  }

  UserModel? getCurrentUser() {
    final raw = prefs.getString(_kCurrentUser);
    if (raw == null || raw.isEmpty) return null;
    return UserModel.fromJsonString(raw);
  }

  String? getToken() => prefs.getString(_kToken);
}
