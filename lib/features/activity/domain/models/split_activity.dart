import 'package:flutter_bill_splitter/features/expenses/domain/models/settlement_transaction.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';

/// Domain model representing a confirmed split expense activity record.
class SplitActivity {
  final String id;
  final String groupName;
  final double totalAmount;
  final double sharePerPerson;
  final List<Friend> members;
  final Map<String, double> memberExpenses;
  final List<SettlementTransaction> settlements;
  final DateTime timestamp;

  const SplitActivity({
    required this.id,
    required this.groupName,
    required this.totalAmount,
    required this.sharePerPerson,
    required this.members,
    required this.memberExpenses,
    required this.settlements,
    required this.timestamp,
  });
}
