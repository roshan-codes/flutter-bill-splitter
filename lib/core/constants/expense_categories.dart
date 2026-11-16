import 'package:flutter/material.dart';

/// Centralized category definitions and icons for TTMM expenses.
class ExpenseCategories {
  ExpenseCategories._();

  static const String general = 'general';
  static const String food = 'food';
  static const String travel = 'travel';
  static const String stay = 'stay';
  static const String shopping = 'shopping';
  static const String entertainment = 'entertainment';

  /// Resolves an appropriate Material icon for a given expense category string.
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase().trim()) {
      case 'food':
      case 'dining':
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'travel':
      case 'transport':
      case 'flight':
      case 'cab':
        return Icons.directions_car_rounded;
      case 'stay':
      case 'hotel':
      case 'accommodation':
        return Icons.hotel_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'activities':
        return Icons.waves_rounded;
      case 'entertainment':
      case 'movies':
        return Icons.movie_rounded;
      case 'reimbursement':
      case 'settlement':
        return Icons.currency_exchange_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }
}
