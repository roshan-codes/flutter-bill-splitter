import 'package:flutter/foundation.dart';
import 'package:flutter_bill_splitter/core/utils/currency_formatter.dart';
import 'package:flutter_bill_splitter/core/utils/split_calculator.dart';

/// Immutable domain model representing monetary value strictly in integer minor units (paise).
/// Prevents floating-point drift across all financial calculations in TTMM Club.
@immutable
class Money implements Comparable<Money> {
  final int paise;

  const Money(this.paise);

  /// Constructs [Money] from Rupee decimal value (e.g. 100.50 -> 10050 paise).
  factory Money.fromRupees(num rupees) => Money(SplitCalculator.toPaise(rupees));

  /// Zero Rupees representation.
  static const Money zero = Money(0);

  /// Value in major unit (Rupees).
  double get inRupees => SplitCalculator.fromPaise(paise);

  /// Formatted string with Rupee symbol and Indian number formatting (rounded).
  String format() => '₹${CurrencyFormatter.format(inRupees)}';

  /// Formatted string strictly with 2 decimal places (e.g. ₹100.50).
  String formatExact() => '₹${inRupees.toStringAsFixed(2)}';

  Money operator +(Money other) => Money(paise + other.paise);
  Money operator -(Money other) => Money(paise - other.paise);
  Money operator -() => Money(-paise);

  bool operator <(Money other) => paise < other.paise;
  bool operator <=(Money other) => paise <= other.paise;
  bool operator >(Money other) => paise > other.paise;
  bool operator >=(Money other) => paise >= other.paise;

  bool get isNegative => paise < 0;
  bool get isZero => paise == 0;
  bool get isPositive => paise > 0;

  @override
  int compareTo(Money other) => paise.compareTo(other.paise);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Money && other.paise == paise);

  @override
  int get hashCode => paise.hashCode;

  @override
  String toString() => format();
}
