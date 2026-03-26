import 'package:flutter/material.dart';

class ExpenseCategory {
  final String name;
  final IconData icon;
  final Color color;

  const ExpenseCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
}

abstract final class AppCategories {
  static const List<ExpenseCategory> all = [
    ExpenseCategory(
      name: 'Food & Dining',
      icon: Icons.restaurant,
      color: Color(0xFFE57373),
    ),
    ExpenseCategory(
      name: 'Transportation',
      icon: Icons.directions_car,
      color: Color(0xFF64B5F6),
    ),
    ExpenseCategory(
      name: 'Shopping',
      icon: Icons.shopping_bag,
      color: Color(0xFFBA68C8),
    ),
    ExpenseCategory(
      name: 'Entertainment',
      icon: Icons.movie,
      color: Color(0xFFFFB74D),
    ),
    ExpenseCategory(
      name: 'Bills & Utilities',
      icon: Icons.receipt_long,
      color: Color(0xFF4DB6AC),
    ),
    ExpenseCategory(
      name: 'Health',
      icon: Icons.favorite,
      color: Color(0xFFEF5350),
    ),
    ExpenseCategory(
      name: 'Education',
      icon: Icons.school,
      color: Color(0xFF7986CB),
    ),
    ExpenseCategory(
      name: 'Other',
      icon: Icons.more_horiz,
      color: Color(0xFF90A4AE),
    ),
  ];

  static ExpenseCategory fromName(String name) {
    return all.firstWhere(
      (c) => c.name == name,
      orElse: () => all.last,
    );
  }
}
