import 'package:flutter/material.dart';

/// Domain model representing a recent expense item on the Home screen.
class RecentExpense {
  final String id;
  final String title;
  final String category;
  final int memberCount;
  final double amount;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  const RecentExpense({
    required this.id,
    required this.title,
    required this.category,
    required this.memberCount,
    required this.amount,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });
}
