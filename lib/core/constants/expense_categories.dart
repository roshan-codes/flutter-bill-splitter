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
      case 'advance':
        return Icons.currency_exchange_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  /// Automatically infers the category keyword based on words in the title.
  static String inferCategoryFromTitle(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('food') ||
        lowerTitle.contains('dinner') ||
        lowerTitle.contains('lunch') ||
        lowerTitle.contains('breakfast') ||
        lowerTitle.contains('drink') ||
        lowerTitle.contains('coffee') ||
        lowerTitle.contains('tea') ||
        lowerTitle.contains('cafe') ||
        lowerTitle.contains('snack') ||
        lowerTitle.contains('pizza') ||
        lowerTitle.contains('burger') ||
        lowerTitle.contains('grocer') ||
        lowerTitle.contains('restaurant')) {
      return 'food';
    } else if (lowerTitle.contains('hotel') ||
        lowerTitle.contains('stay') ||
        lowerTitle.contains('resort') ||
        lowerTitle.contains('villa') ||
        lowerTitle.contains('airbnb') ||
        lowerTitle.contains('room')) {
      return 'stay';
    } else if (lowerTitle.contains('cab') ||
        lowerTitle.contains('uber') ||
        lowerTitle.contains('ola') ||
        lowerTitle.contains('flight') ||
        lowerTitle.contains('petrol') ||
        lowerTitle.contains('fuel') ||
        lowerTitle.contains('diesel') ||
        lowerTitle.contains('train') ||
        lowerTitle.contains('travel') ||
        lowerTitle.contains('toll') ||
        lowerTitle.contains('bus') ||
        lowerTitle.contains('taxi') ||
        lowerTitle.contains('auto') ||
        lowerTitle.contains('metro')) {
      return 'transport';
    } else if (lowerTitle.contains('scuba') ||
        lowerTitle.contains('surf') ||
        lowerTitle.contains('ticket') ||
        lowerTitle.contains('movie') ||
        lowerTitle.contains('entry') ||
        lowerTitle.contains('museum') ||
        lowerTitle.contains('park') ||
        lowerTitle.contains('trek') ||
        lowerTitle.contains('game')) {
      return 'activities';
    } else if (lowerTitle.contains('shop') ||
        lowerTitle.contains('mall') ||
        lowerTitle.contains('cloth') ||
        lowerTitle.contains('souvenir')) {
      return 'shopping';
    }
    return 'general';
  }
}
