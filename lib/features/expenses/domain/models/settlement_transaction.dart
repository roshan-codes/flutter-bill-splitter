import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';

/// Represents a single settlement payment between two friends.
class SettlementTransaction {
  final Friend from;
  final Friend to;
  final double amount;

  const SettlementTransaction({
    required this.from,
    required this.to,
    required this.amount,
  });
}

