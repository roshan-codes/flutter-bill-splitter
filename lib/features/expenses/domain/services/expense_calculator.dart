import 'package:flutter_bill_splitter/core/utils/split_calculator.dart';
import 'package:flutter_bill_splitter/features/expenses/domain/models/settlement_transaction.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';

/// Service that computes equal split shares and simplified debt settlements
/// using integer paise precision.
class ExpenseCalculator {
  ExpenseCalculator._();

  /// Calculates total expense across all members.
  static double calculateTotal(Map<String, double> paidAmounts) {
    int totalPaise = 0;
    for (final val in paidAmounts.values) {
      totalPaise += SplitCalculator.toPaise(val);
    }
    return SplitCalculator.fromPaise(totalPaise);
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
    if (members.isEmpty) return const [];

    final total = calculateTotal(paidAmounts);
    if (total <= 0) return const [];

    final equalShares = SplitCalculator.splitEqual(total, members.length);

    final Map<String, double> netBalances = {};
    for (int i = 0; i < members.length; i++) {
      final member = members[i];
      final paid = paidAmounts[member.name] ?? 0.0;
      final share = equalShares[i];
      netBalances[member.name] = paid - share;
    }

    return calculateSettlementsFromNetBalances(
      members: members,
      netBalances: netBalances,
    );
  }

  /// Computes the minimal list of settlement transactions directly from net balances.
  static List<SettlementTransaction> calculateSettlementsFromNetBalances({
    required List<Friend> members,
    required Map<String, double> netBalances,
  }) {
    if (members.isEmpty) return const [];

    // Map netBalances to Friend keys using integer paise
    final Map<Friend, int> paiseMap = {};
    for (final member in members) {
      double net = 0.0;
      for (final entry in netBalances.entries) {
        if (_isNameMatch(entry.key, member.name)) {
          net = entry.value;
          break;
        }
      }
      final paise = SplitCalculator.toPaise(net);
      if (paise != 0) {
        paiseMap[member] = paise;
      }
    }

    final debts = SplitCalculator.simplifyDebts<Friend>(netBalancesInPaise: paiseMap);
    return debts
        .map(
          (d) => SettlementTransaction(
            from: d.from,
            to: d.to,
            amount: d.amount,
          ),
        )
        .toList();
  }

  static bool _isNameMatch(String a, String b) {
    final cleanA = a
        .replaceAll(RegExp(r'\s*\(you\)\s*$', caseSensitive: false), '')
        .toLowerCase()
        .trim();
    final cleanB = b
        .replaceAll(RegExp(r'\s*\(you\)\s*$', caseSensitive: false), '')
        .toLowerCase()
        .trim();
    if (cleanA.isEmpty || cleanB.isEmpty) return false;
    return cleanA == cleanB;
  }
}
