import 'package:flutter_bill_splitter/features/expenses/domain/models/settlement_transaction.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';

class _BalanceEntry {
  final Friend friend;
  double amount;

  _BalanceEntry(this.friend, this.amount);
}

/// Service that computes equal split shares and simplified debt settlements.
class ExpenseCalculator {
  ExpenseCalculator._();

  /// Calculates total expense across all members.
  static double calculateTotal(Map<String, double> paidAmounts) {
    return paidAmounts.values.fold(0.0, (sum, val) => sum + val);
  }

  /// Calculates equal share per person.
  static double calculateSharePerPerson(double total, int memberCount) {
    if (memberCount <= 0) return 0.0;
    return total / memberCount;
  }

  /// Computes the minimal list of settlement transactions so all balances become zero.
  static List<SettlementTransaction> calculateSettlements({
    required List<Friend> members,
    required Map<String, double> paidAmounts,
  }) {
    if (members.isEmpty) return [];

    final total = calculateTotal(paidAmounts);
    if (total <= 0) return [];

    final sharePerPerson = calculateSharePerPerson(total, members.length);

    final List<_BalanceEntry> debtors = [];
    final List<_BalanceEntry> creditors = [];

    for (final member in members) {
      final paid = paidAmounts[member.name] ?? 0.0;
      final net = paid - sharePerPerson;
      if (net < -0.01) {
        debtors.add(_BalanceEntry(member, -net)); // owes money
      } else if (net > 0.01) {
        creditors.add(_BalanceEntry(member, net)); // is owed money
      }
    }

    // Sort descending by magnitude to minimize transactions
    debtors.sort((a, b) => b.amount.compareTo(a.amount));
    creditors.sort((a, b) => b.amount.compareTo(a.amount));

    final List<SettlementTransaction> transactions = [];
    int d = 0;
    int c = 0;

    while (d < debtors.length && c < creditors.length) {
      final debtor = debtors[d];
      final creditor = creditors[c];
      final settleAmount = debtor.amount < creditor.amount ? debtor.amount : creditor.amount;

      if (settleAmount > 0.01) {
        transactions.add(
          SettlementTransaction(
            from: debtor.friend,
            to: creditor.friend,
            amount: settleAmount,
          ),
        );
      }

      debtor.amount -= settleAmount;
      creditor.amount -= settleAmount;

      if (debtor.amount <= 0.01) d++;
      if (creditor.amount <= 0.01) c++;
    }

    return transactions;
  }
}
