import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';

/// Helper to dynamically resolve category icon and background colors from expense titles.
class ExpenseIconResolver {
  static IconData resolveIcon(String title, [String? category]) {
    final lower = '${title.toLowerCase()} ${category?.toLowerCase() ?? ''}';

    if (lower.contains('food') ||
        lower.contains('dinner') ||
        lower.contains('lunch') ||
        lower.contains('breakfast') ||
        lower.contains('cafe') ||
        lower.contains('coffee') ||
        lower.contains('snack') ||
        lower.contains('pizza') ||
        lower.contains('burger') ||
        lower.contains('dhaba') ||
        lower.contains('restaurant') ||
        lower.contains('meal')) {
      return Icons.restaurant_rounded;
    }

    if (lower.contains('fuel') ||
        lower.contains('petrol') ||
        lower.contains('diesel') ||
        lower.contains('gas')) {
      return Icons.local_gas_station_rounded;
    }

    if (lower.contains('cab') ||
        lower.contains('taxi') ||
        lower.contains('uber') ||
        lower.contains('ola') ||
        lower.contains('auto') ||
        lower.contains('travel') ||
        lower.contains('flight') ||
        lower.contains('train') ||
        lower.contains('bus') ||
        lower.contains('toll')) {
      return Icons.directions_car_rounded;
    }

    if (lower.contains('hotel') ||
        lower.contains('stay') ||
        lower.contains('room') ||
        lower.contains('rent') ||
        lower.contains('airbnb') ||
        lower.contains('resort') ||
        lower.contains('villa')) {
      return Icons.hotel_rounded;
    }

    if (lower.contains('drink') ||
        lower.contains('beer') ||
        lower.contains('party') ||
        lower.contains('bar') ||
        lower.contains('pub') ||
        lower.contains('cocktail')) {
      return Icons.sports_bar_rounded;
    }

    if (lower.contains('grocer') ||
        lower.contains('market') ||
        lower.contains('shop') ||
        lower.contains('supermarket') ||
        lower.contains('mart')) {
      return Icons.shopping_bag_outlined;
    }

    if (lower.contains('movie') ||
        lower.contains('cinema') ||
        lower.contains('ticket') ||
        lower.contains('show') ||
        lower.contains('netflix')) {
      return Icons.movie_outlined;
    }

    return Icons.receipt_long_rounded;
  }

  static Color resolveBgColor(IconData icon) {
    if (icon == Icons.restaurant_rounded) return const Color(0xFFFFF3E0); // soft orange
    if (icon == Icons.local_gas_station_rounded) return const Color(0xFFFFF8E1); // soft amber
    if (icon == Icons.directions_car_rounded) return const Color(0xFFE8F0FE); // soft blue
    if (icon == Icons.hotel_rounded) return const Color(0xFFF3E8FF); // soft purple
    if (icon == Icons.sports_bar_rounded) return const Color(0xFFFFEBEE); // soft red
    if (icon == Icons.shopping_bag_outlined) return const Color(0xFFE0F2F1); // soft teal
    if (icon == Icons.movie_outlined) return const Color(0xFFFCE4EC); // soft pink
    return AppColors.successSoft; // soft green
  }

  static Color resolveIconColor(IconData icon) {
    if (icon == Icons.restaurant_rounded) return const Color(0xFFE65100);
    if (icon == Icons.local_gas_station_rounded) return const Color(0xFFF57F17);
    if (icon == Icons.directions_car_rounded) return const Color(0xFF1967D2);
    if (icon == Icons.hotel_rounded) return const Color(0xFF7B1FA2);
    if (icon == Icons.sports_bar_rounded) return const Color(0xFFC62828);
    if (icon == Icons.shopping_bag_outlined) return const Color(0xFF00695C);
    if (icon == Icons.movie_outlined) return const Color(0xFFAD1457);
    return AppColors.success;
  }
}
