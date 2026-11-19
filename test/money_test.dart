import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bill_splitter/core/models/money.dart';

void main() {
  group('Money Domain Model Tests', () {
    test('Constructs from Rupees accurately in minor units (paise)', () {
      final m1 = Money.fromRupees(100.50);
      expect(m1.paise, 10050);
      expect(m1.inRupees, 100.50);
      expect(m1.formatExact(), '₹100.50');
      expect(m1.format(), '₹101');
    });

    test('Addition and subtraction strictly prevent floating drift', () {
      final a = Money.fromRupees(0.1);
      final b = Money.fromRupees(0.2);
      final sum = a + b;
      expect(sum.paise, 30);
      expect(sum.inRupees, 0.3);

      final diff = sum - a;
      expect(diff.paise, 20);
      expect(diff.inRupees, 0.2);
    });

    test('Comparison and equality work accurately', () {
      final m1 = Money.fromRupees(500);
      final m2 = Money.fromRupees(500);
      final m3 = Money.fromRupees(750);

      expect(m1 == m2, isTrue);
      expect(m1 < m3, isTrue);
      expect(m3 > m1, isTrue);
    });
  });
}
