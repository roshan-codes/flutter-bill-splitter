import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bill_splitter/core/utils/split_calculator.dart';

void main() {
  group('SplitCalculator Mathematical Precision Tests', () {
    test('splitEqual eliminates cent loss and sums strictly to totalAmount', () {
      // ₹100.00 divided by 3: classically 33.333333333333336 which loses 1 paisa (99.99).
      final shares = SplitCalculator.splitEqual(100.0, 3);
      expect(shares.length, 3);
      expect(shares[0], 33.34);
      expect(shares[1], 33.33);
      expect(shares[2], 33.33);

      final totalSum = shares.fold<double>(0.0, (sum, val) => sum + val);
      expect(SplitCalculator.roundCurrency(totalSum), equals(100.00));
    });

    test('splitEqual rotates remainder distribution across expenses to prevent biasing first user', () {
      final sharesExp0 = SplitCalculator.splitEqual(100.0, 3, remainderStartIndex: 0);
      final sharesExp1 = SplitCalculator.splitEqual(100.0, 3, remainderStartIndex: 1);
      final sharesExp2 = SplitCalculator.splitEqual(100.0, 3, remainderStartIndex: 2);

      expect(sharesExp0, [33.34, 33.33, 33.33]);
      expect(sharesExp1, [33.33, 33.34, 33.33]);
      expect(sharesExp2, [33.33, 33.33, 33.34]);

      final user0Sum = sharesExp0[0] + sharesExp1[0] + sharesExp2[0];
      final user1Sum = sharesExp0[1] + sharesExp1[1] + sharesExp2[1];
      final user2Sum = sharesExp0[2] + sharesExp1[2] + sharesExp2[2];

      expect(SplitCalculator.roundCurrency(user0Sum), equals(100.00));
      expect(SplitCalculator.roundCurrency(user1Sum), equals(100.00));
      expect(SplitCalculator.roundCurrency(user2Sum), equals(100.00));
    });

    test('simplifyDebts guarantees zero-sum invariant and minimal transactions', () {
      // User A paid 1545 for group with User B (0 paid).
      // Suppose after expenses:
      // A gets 273 (net +27300 paise)
      // B owes 273 (net -27300 paise)
      final netBalances = {
        'user_a': 27300,
        'user_b': -27300,
      };

      final transactions = SplitCalculator.simplifyDebts(netBalancesInPaise: netBalances);
      expect(transactions.length, 1);
      expect(transactions[0].from, 'user_b');
      expect(transactions[0].to, 'user_a');
      expect(transactions[0].amount, 273.0);

      // Verify algebraic sum is strictly zero
      final sumNet = netBalances.values.fold<int>(0, (s, v) => s + v);
      expect(sumNet, 0);
    });

    test('simplifyDebts solves complex 4-party cyclic debt with zero floating drift', () {
      // Sum: 5000 + 3000 - 6000 - 2000 = 0
      final netBalances = {
        'A': 500000,
        'B': 300000,
        'C': -600000,
        'D': -200000,
      };

      final txs = SplitCalculator.simplifyDebts(netBalancesInPaise: netBalances);
      expect(txs.isNotEmpty, isTrue);

      final totalTransferred = txs.fold<int>(0, (s, t) => s + t.amountInPaise);
      expect(totalTransferred, equals(800000)); // Exactly ₹8,000 transferred to satisfy all debts
    });
  });
}
