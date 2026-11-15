import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bill_splitter/core/utils/currency_formatter.dart';
import 'package:flutter_bill_splitter/core/utils/date_formatter.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('formats zero correctly', () {
      expect(CurrencyFormatter.format(0), '0');
      expect(CurrencyFormatter.format(0, includeSymbol: true), '₹0');
    });

    test('formats numbers below 1000 without commas', () {
      expect(CurrencyFormatter.format(450), '450');
      expect(CurrencyFormatter.format(450, includeSymbol: true), '₹450');
    });

    test('formats standard Indian thousands (e.g. 1,200)', () {
      expect(CurrencyFormatter.format(1200), '1,200');
      expect(CurrencyFormatter.format(1200, includeSymbol: true), '₹1,200');
    });

    test('formats Indian lakhs (e.g. 1,00,000 and 12,34,567)', () {
      expect(CurrencyFormatter.format(100000), '1,00,000');
      expect(CurrencyFormatter.format(1234567, includeSymbol: true), '₹12,34,567');
    });

    test('rounds double values to nearest whole number', () {
      expect(CurrencyFormatter.format(1250.75), '1,251');
      expect(CurrencyFormatter.format(1250.25), '1,250');
    });

    test('handles negative amounts', () {
      expect(CurrencyFormatter.format(-500), '-500');
      expect(CurrencyFormatter.format(-1500, includeSymbol: true), '₹-1,500');
    });
  });

  group('DateFormatter Tests', () {
    test('formatDisplayDate formats valid DateTime correctly', () {
      expect(
        DateFormatter.formatDisplayDate(DateTime(2026, 11, 15)),
        '15 Nov 2026',
      );
    });

    test('formatStoryDateSubtitle formats member count and date ranges', () {
      expect(
        DateFormatter.formatStoryDateSubtitle(3, null, null),
        '3 members',
      );
      expect(
        DateFormatter.formatStoryDateSubtitle(4, '2026-11-01', '2026-11-05'),
        '4 members · Nov 1 – 5',
      );
      expect(
        DateFormatter.formatStoryDateSubtitle(1, null, null),
        '1 member',
      );
    });
  });
}
