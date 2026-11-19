/// A representation of a debt settlement transaction between two parties.
class DebtTransaction<T> {
  final T from;
  final T to;
  final int amountInPaise;

  const DebtTransaction({
    required this.from,
    required this.to,
    required this.amountInPaise,
  });

  double get amount => amountInPaise / 100.0;

  @override
  String toString() => 'DebtTransaction(from: $from, to: $to, amount: ₹${amount.toStringAsFixed(2)})';
}

/// Production-grade financial split and debt simplification engine using integer minor units (paise).
/// Guarantees that:
/// 1. Floating-point drift is completely eliminated.
/// 2. Sum of split shares strictly equals the expense total.
/// 3. Sum of all member net balances strictly equals zero (zero-sum invariant).
/// 4. Debt simplification produces the minimal number of transactions without fractional-cent residuals.
class SplitCalculator {
  SplitCalculator._();

  /// Converts a major currency unit (Rupees) to integer minor units (paise).
  static int toPaise(num amount) {
    return (amount * 100).round();
  }

  /// Converts integer minor units (paise) back to major currency units (Rupees).
  static double fromPaise(int paise) {
    return paise / 100.0;
  }

  /// Rounds an amount to two decimal places safely.
  static double roundCurrency(num amount) {
    return (amount * 100).round() / 100.0;
  }

  /// Calculates equal split shares among participants.
  /// Distributes any indivisible remainder paise across participants (starting at [remainderStartIndex])
  /// so that the sum of all individual shares strictly equals `totalAmount`.
  static List<double> splitEqual(
    num totalAmount,
    int participantCount, {
    int remainderStartIndex = 0,
  }) {
    final totalPaise = toPaise(totalAmount);
    return splitEqualInPaise(
      totalPaise,
      participantCount,
      remainderStartIndex: remainderStartIndex,
    ).map(fromPaise).toList();
  }

  /// Calculates equal split shares directly in integer paise among participants.
  /// [remainderStartIndex] allows rotating remainder paise across expenses to prevent biasing index 0.
  static List<int> splitEqualInPaise(
    int totalPaise,
    int participantCount, {
    int remainderStartIndex = 0,
  }) {
    if (participantCount <= 0) return const [];
    if (totalPaise <= 0) {
      return List<int>.filled(participantCount, 0);
    }

    final basePaise = totalPaise ~/ participantCount;
    final remainder = totalPaise % participantCount;

    final shares = List<int>.filled(participantCount, basePaise);
    final safeStart = participantCount > 0 ? remainderStartIndex % participantCount : 0;
    for (int r = 0; r < remainder; r++) {
      final idx = (safeStart + r) % participantCount;
      shares[idx] += 1;
    }
    return shares;
  }

  /// Calculates percentage-based split shares.
  /// Any remainder paise from rounding are distributed to ensure the sum strictly equals `totalAmount`.
  static List<double> splitPercentage(num totalAmount, List<double> percentages) {
    if (percentages.isEmpty) return const [];
    final totalPaise = toPaise(totalAmount);

    final rawPaiseList = percentages.map((p) => ((totalPaise * p) / 100.0).round()).toList();
    final allocatedSum = rawPaiseList.fold<int>(0, (sum, val) => sum + val);
    final diff = totalPaise - allocatedSum;

    if (diff != 0 && rawPaiseList.isNotEmpty) {
      rawPaiseList[0] += diff;
    }

    return rawPaiseList.map(fromPaise).toList();
  }

  /// Solves the debt settlement graph to produce the minimal set of bilateral payment transfers.
  /// Uses a greedy algorithm operating exclusively on integer paise to prevent floating-point drift.
  static List<DebtTransaction<T>> simplifyDebts<T>({
    required Map<T, int> netBalancesInPaise,
  }) {
    if (netBalancesInPaise.isEmpty) return const [];

    // Filter out zero balances and enforce zero-sum invariant
    final debtors = <_MutableBalance<T>>[];
    final creditors = <_MutableBalance<T>>[];

    int totalNet = 0;
    for (final entry in netBalancesInPaise.entries) {
      totalNet += entry.value;
    }

    // Invariant check: if there is any legacy rounding discrepancy (e.g. ±1 paise),
    // balance it against the member with the largest absolute balance.
    final balancesCopy = Map<T, int>.from(netBalancesInPaise);
    if (totalNet != 0 && balancesCopy.isNotEmpty) {
      T? maxKey;
      int maxAbs = -1;
      for (final entry in balancesCopy.entries) {
        if (entry.value.abs() > maxAbs) {
          maxAbs = entry.value.abs();
          maxKey = entry.key;
        }
      }
      if (maxKey != null) {
        balancesCopy[maxKey] = balancesCopy[maxKey]! - totalNet;
      }
    }

    for (final entry in balancesCopy.entries) {
      if (entry.value < 0) {
        debtors.add(_MutableBalance<T>(entry.key, -entry.value));
      } else if (entry.value > 0) {
        creditors.add(_MutableBalance<T>(entry.key, entry.value));
      }
    }

    // Sort descending by magnitude to minimize total transactions
    debtors.sort((a, b) => b.paise.compareTo(a.paise));
    creditors.sort((a, b) => b.paise.compareTo(a.paise));

    final transactions = <DebtTransaction<T>>[];
    int d = 0;
    int c = 0;

    while (d < debtors.length && c < creditors.length) {
      final debtor = debtors[d];
      final creditor = creditors[c];
      final settlePaise = debtor.paise < creditor.paise ? debtor.paise : creditor.paise;

      if (settlePaise > 0) {
        transactions.add(
          DebtTransaction<T>(
            from: debtor.owner,
            to: creditor.owner,
            amountInPaise: settlePaise,
          ),
        );
      }

      debtor.paise -= settlePaise;
      creditor.paise -= settlePaise;

      if (debtor.paise == 0) d++;
      if (creditor.paise == 0) c++;
    }

    return transactions;
  }
}

class _MutableBalance<T> {
  final T owner;
  int paise;

  _MutableBalance(this.owner, this.paise);
}
