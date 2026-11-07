import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bill_splitter/features/expenses/domain/services/expense_calculator.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';

void main() {
  group('ExpenseCalculator Tests', () {
    const friendA = Friend(name: 'Alice', phone: '+91 90000 00001');
    const friendB = Friend(name: 'Bob', phone: '+91 90000 00002');
    const friendC = Friend(name: 'Charlie', phone: '+91 90000 00003');

    test('calculateTotal sums all paid amounts correctly', () {
      final total = ExpenseCalculator.calculateTotal({
        'Alice': 500,
        'Bob': 300,
        'Charlie': 200,
      });
      expect(total, 1000.0);
    });

    test('calculateSharePerPerson calculates equal split', () {
      expect(ExpenseCalculator.calculateSharePerPerson(1200, 3), 400.0);
      expect(ExpenseCalculator.calculateSharePerPerson(0, 3), 0.0);
      expect(ExpenseCalculator.calculateSharePerPerson(500, 0), 0.0);
    });

    test('calculateSettlements pairs single payer with single debtor', () {
      final members = [friendA, friendB];
      final paid = {'Alice': 600.0, 'Bob': 0.0};

      final settlements = ExpenseCalculator.calculateSettlements(
        members: members,
        paidAmounts: paid,
      );

      expect(settlements.length, 1);
      expect(settlements.first.from.name, 'Bob');
      expect(settlements.first.to.name, 'Alice');
      expect(settlements.first.amount, 300.0);
    });

    test('calculateSettlements returns empty if everyone paid equally', () {
      final members = [friendA, friendB];
      final paid = {'Alice': 250.0, 'Bob': 250.0};

      final settlements = ExpenseCalculator.calculateSettlements(
        members: members,
        paidAmounts: paid,
      );

      expect(settlements, isEmpty);
    });

    test('calculateSettlements returns empty if total expense is zero', () {
      final members = [friendA, friendB];
      final paid = <String, double>{};

      final settlements = ExpenseCalculator.calculateSettlements(
        members: members,
        paidAmounts: paid,
      );

      expect(settlements, isEmpty);
    });

    test('calculateSettlements simplifies 3-way split correctly', () {
      final members = [friendA, friendB, friendC];
      // Total = 900, Share = 300 each
      // Alice paid 900 (net +600)
      // Bob paid 0 (net -300)
      // Charlie paid 0 (net -300)
      final paid = {'Alice': 900.0, 'Bob': 0.0, 'Charlie': 0.0};

      final settlements = ExpenseCalculator.calculateSettlements(
        members: members,
        paidAmounts: paid,
      );

      expect(settlements.length, 2);
      expect(settlements.any((s) => s.from.name == 'Bob' && s.to.name == 'Alice' && s.amount == 300.0), isTrue);
      expect(settlements.any((s) => s.from.name == 'Charlie' && s.to.name == 'Alice' && s.amount == 300.0), isTrue);
    });
  });
}
