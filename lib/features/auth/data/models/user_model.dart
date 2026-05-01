import 'dart:convert';

import '../../domain/entities/user.dart';

/// Modelo de la capa data: serializable a/desde JSON.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String,
      );

  factory UserModel.fromJsonString(String jsonString) =>
      UserModel.fromJson(json.decode(jsonString) as Map<String, dynamic>);

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
      };

  String toJsonString() => json.encode(toJson());
}
