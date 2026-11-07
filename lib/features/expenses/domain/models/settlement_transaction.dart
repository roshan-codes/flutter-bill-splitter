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

  Map<String, dynamic> toJson() => {
        'from': from.toJson(),
        'to': to.toJson(),
        'amount': amount,
      };

  factory SettlementTransaction.fromJson(Map<String, dynamic> json) =>
      SettlementTransaction(
        from: Friend.fromJson(Map<String, dynamic>.from(json['from'] as Map)),
        to: Friend.fromJson(Map<String, dynamic>.from(json['to'] as Map)),
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      );
}
