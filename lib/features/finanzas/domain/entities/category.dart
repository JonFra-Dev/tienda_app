import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Categorías predefinidas (entidad de dominio).
class TransactionCategory extends Equatable {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const TransactionCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  @override
  List<Object?> get props => [id, name];

  static const List<TransactionCategory> all = [
    TransactionCategory(
      id: 'food',
      name: 'Comida',
      icon: Icons.restaurant,
      color: Color(0xFFEF5350),
    ),
    TransactionCategory(
      id: 'transport',
      name: 'Transporte',
      icon: Icons.directions_bus,
      color: Color(0xFF42A5F5),
    ),
    TransactionCategory(
      id: 'entertainment',
      name: 'Entretenimiento',
      icon: Icons.movie_outlined,
      color: Color(0xFFAB47BC),
    ),
    TransactionCategory(
      id: 'health',
      name: 'Salud',
      icon: Icons.local_hospital_outlined,
      color: Color(0xFF66BB6A),
    ),
    TransactionCategory(
      id: 'home',
      name: 'Hogar',
      icon: Icons.home_outlined,
      color: Color(0xFFFFA726),
    ),
    TransactionCategory(
      id: 'shopping',
      name: 'Compras',
      icon: Icons.shopping_bag_outlined,
      color: Color(0xFFEC407A),
    ),
    TransactionCategory(
      id: 'salary',
      name: 'Salario',
      icon: Icons.attach_money,
      color: Color(0xFF26A69A),
    ),
    TransactionCategory(
      id: 'other',
      name: 'Otros',
      icon: Icons.more_horiz,
      color: Color(0xFF78909C),
    ),
  ];

  static TransactionCategory byId(String id) =>
      all.firstWhere((c) => c.id == id, orElse: () => all.last);
}
