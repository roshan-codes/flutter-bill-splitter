import 'package:flutter_bill_splitter/core/constants/app_constants.dart';

/// Centralized Indian numbering system currency formatter for TTMM.
/// Formats numbers according to Indian grouping (e.g., 1,00,000 for 1 lakh).
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Formats an integer or double [value] into an Indian formatted number string.
  /// If [includeSymbol] is true, prefixes with the ₹ symbol.
  static String format(num value, {bool includeSymbol = false}) {
    final integerPart = value.round();
    final str = integerPart.abs().toString();
    final String formatted;

    if (str.length <= 3) {
      formatted = (value < 0 ? '-' : '') + str;
    } else {
      final lastThree = str.substring(str.length - 3);
      final otherDigits = str.substring(0, str.length - 3);
      final formattedOther = otherDigits.replaceAllMapped(
        RegExp(r'(\d)(?=(\d\d)+$)'),
        (m) => '${m[1]},',
      );
      formatted = '${value < 0 ? '-' : ''}$formattedOther,$lastThree';
    }

    return includeSymbol ? '${AppConstants.currencySymbol}$formatted' : formatted;
  }
}
