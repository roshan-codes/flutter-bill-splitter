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
  final String? expenseTitle;
  final String type; // 'expense' or 'settlement'

  const SplitActivity({
    required this.id,
    required this.groupName,
    required this.totalAmount,
    required this.sharePerPerson,
    required this.members,
    required this.memberExpenses,
    required this.settlements,
    required this.timestamp,
    this.expenseTitle,
    this.type = 'expense',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'groupName': groupName,
        'expenseTitle': expenseTitle,
        'type': type,
        'totalAmount': totalAmount,
        'sharePerPerson': sharePerPerson,
        'members': members.map((m) => m.toJson()).toList(),
        'memberExpenses': memberExpenses,
        'settlements': settlements.map((s) => s.toJson()).toList(),
        'timestamp': timestamp.toIso8601String(),
      };

  factory SplitActivity.fromJson(Map<String, dynamic> json) {
    final rawSettlements = (json['settlements'] as List<dynamic>? ?? [])
        .map((s) => SettlementTransaction.fromJson(
            Map<String, dynamic>.from(s as Map)))
        .toList();
    final typeVal = json['type'] as String? ??
        (rawSettlements.isNotEmpty ? 'settlement' : 'expense');
    return SplitActivity(
      id: json['id'] as String? ?? '',
      groupName: json['groupName'] as String? ?? '',
      expenseTitle: json['expenseTitle'] as String? ??
          json['expense_title'] as String?,
      type: typeVal,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      sharePerPerson: (json['sharePerPerson'] as num?)?.toDouble() ?? 0.0,
      members: (json['members'] as List<dynamic>? ?? [])
          .map((m) => Friend.fromJson(Map<String, dynamic>.from(m as Map)))
          .toList(),
      memberExpenses: (json['memberExpenses'] as Map<dynamic, dynamic>? ?? {})
          .map((k, v) => MapEntry(k.toString(), (v as num).toDouble())),
      settlements: rawSettlements,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
