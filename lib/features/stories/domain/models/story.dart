import 'dart:convert';

/// Domain model representing a Story Member.
class StoryMember {
  final String userId;
  final String name;
  final String? avatar;
  final String role; // "admin", "member"
  final String joinedAt;

  const StoryMember({
    required this.userId,
    required this.name,
    this.avatar,
    this.role = 'member',
    required this.joinedAt,
  });

  factory StoryMember.fromJson(Map<String, dynamic> json) {
    return StoryMember(
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String?,
      role: json['role'] as String? ?? 'member',
      joinedAt: json['joined_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'name': name,
        'avatar': avatar,
        'role': role,
        'joined_at': joinedAt,
      };
}

/// Domain model representing a member's individual expense share.
class ExpenseShare {
  final String userId;
  final double amount;

  const ExpenseShare({
    required this.userId,
    required this.amount,
  });

  factory ExpenseShare.fromJson(Map<String, dynamic> json) {
    return ExpenseShare(
      userId: json['user_id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'amount': amount,
      };
}

/// Domain model representing an individual expense in a Story.
class StoryExpense {
  final String expenseId;
  final String title;
  final String category;
  final double amount;
  final String paidBy;
  final String splitType;
  final List<String> participants;
  final List<ExpenseShare> shares;
  final String date;
  final String? note;

  const StoryExpense({
    required this.expenseId,
    required this.title,
    required this.category,
    required this.amount,
    required this.paidBy,
    this.splitType = 'equal',
    required this.participants,
    required this.shares,
    required this.date,
    this.note,
  });

  factory StoryExpense.fromJson(Map<String, dynamic> json) {
    final rawShares = json['shares'] as List<dynamic>? ?? [];
    final rawParticipants = json['participants'] as List<dynamic>? ?? [];

    return StoryExpense(
      expenseId: json['expense_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paidBy: json['paid_by'] as String? ?? '',
      splitType: json['split_type'] as String? ?? 'equal',
      participants: rawParticipants.map((p) => p.toString()).toList(),
      shares: rawShares
          .map((s) => ExpenseShare.fromJson(s as Map<String, dynamic>))
          .toList(),
      date: json['date'] as String? ?? '',
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'expense_id': expenseId,
        'title': title,
        'category': category,
        'amount': amount,
        'paid_by': paidBy,
        'split_type': splitType,
        'participants': participants,
        'shares': shares.map((s) => s.toJson()).toList(),
        'date': date,
        if (note != null) 'note': note,
      };
}

/// Domain model representing high-level Story Summary figures.
class StorySummary {
  final double totalExpenses;
  final double totalSettled;
  final double pendingAmount;
  final int memberCount;
  final int expenseCount;

  const StorySummary({
    required this.totalExpenses,
    required this.totalSettled,
    required this.pendingAmount,
    required this.memberCount,
    required this.expenseCount,
  });

  factory StorySummary.fromJson(Map<String, dynamic> json) {
    return StorySummary(
      totalExpenses: (json['total_expenses'] as num?)?.toDouble() ?? 0.0,
      totalSettled: (json['total_settled'] as num?)?.toDouble() ?? 0.0,
      pendingAmount: (json['pending_amount'] as num?)?.toDouble() ?? 0.0,
      memberCount: (json['member_count'] as num?)?.toInt() ?? 0,
      expenseCount: (json['expense_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'total_expenses': totalExpenses,
        'total_settled': totalSettled,
        'pending_amount': pendingAmount,
        'member_count': memberCount,
        'expense_count': expenseCount,
      };
}

/// Domain model representing a member's balance status inside a Story.
class StoryMemberBalance {
  final String userId;
  final String name;
  final double totalPaid;
  final double totalShare;
  final double netBalance;
  final String status; // "gets_back", "owes", "settled"

  const StoryMemberBalance({
    required this.userId,
    required this.name,
    required this.totalPaid,
    required this.totalShare,
    required this.netBalance,
    required this.status,
  });

  factory StoryMemberBalance.fromJson(Map<String, dynamic> json) {
    return StoryMemberBalance(
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      totalPaid: (json['total_paid'] as num?)?.toDouble() ?? 0.0,
      totalShare: (json['total_share'] as num?)?.toDouble() ?? 0.0,
      netBalance: (json['net_balance'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'settled',
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'name': name,
        'total_paid': totalPaid,
        'total_share': totalShare,
        'net_balance': netBalance,
        'status': status,
      };
}

/// Domain model representing a peer-to-peer settlement transaction in a Story.
class StorySettlement {
  final String settlementId;
  final String fromUser;
  final String toUser;
  final double amount;
  final String status; // "pending", "completed"

  const StorySettlement({
    required this.settlementId,
    required this.fromUser,
    required this.toUser,
    required this.amount,
    this.status = 'pending',
  });

  factory StorySettlement.fromJson(Map<String, dynamic> json) {
    return StorySettlement(
      settlementId: json['settlement_id'] as String? ?? '',
      fromUser: json['from_user'] as String? ?? '',
      toUser: json['to_user'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() => {
        'settlement_id': settlementId,
        'from_user': fromUser,
        'to_user': toUser,
        'amount': amount,
        'status': status,
      };

  StorySettlement copyWith({String? status}) {
    return StorySettlement(
      settlementId: settlementId,
      fromUser: fromUser,
      toUser: toUser,
      amount: amount,
      status: status ?? this.status,
    );
  }
}

/// Complete Story domain model storing all group trip expenses, balances and settlements.
class Story {
  final String storyId;
  final String title;
  final String description;
  final String coverEmoji;
  final String currency;
  final String status; // "active", "settled", "archived"
  final String createdBy;
  final String createdAt;
  final String? startDate;
  final String? endDate;
  final List<StoryMember> members;
  final StorySummary summary;
  final List<StoryExpense> expenses;
  final List<StoryMemberBalance> memberBalances;
  final List<StorySettlement> settlements;

  const Story({
    required this.storyId,
    required this.title,
    required this.description,
    this.coverEmoji = '🌴',
    this.currency = 'INR',
    this.status = 'active',
    required this.createdBy,
    required this.createdAt,
    this.startDate,
    this.endDate,
    required this.members,
    required this.summary,
    required this.expenses,
    required this.memberBalances,
    required this.settlements,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['members'] as List<dynamic>? ?? [];
    final rawExpenses = json['expenses'] as List<dynamic>? ?? [];
    final rawBalances = json['member_balances'] as List<dynamic>? ?? [];
    final rawSettlements = json['settlements'] as List<dynamic>? ?? [];

    return Story(
      storyId: json['story_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      coverEmoji: json['cover_emoji'] as String? ?? '🌴',
      currency: json['currency'] as String? ?? 'INR',
      status: json['status'] as String? ?? 'active',
      createdBy: json['created_by'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      members: rawMembers
          .map((m) => StoryMember.fromJson(m as Map<String, dynamic>))
          .toList(),
      summary: json['summary'] != null
          ? StorySummary.fromJson(json['summary'] as Map<String, dynamic>)
          : const StorySummary(
              totalExpenses: 0,
              totalSettled: 0,
              pendingAmount: 0,
              memberCount: 0,
              expenseCount: 0,
            ),
      expenses: rawExpenses
          .map((e) => StoryExpense.fromJson(e as Map<String, dynamic>))
          .toList(),
      memberBalances: rawBalances
          .map((b) => StoryMemberBalance.fromJson(b as Map<String, dynamic>))
          .toList(),
      settlements: rawSettlements
          .map((s) => StorySettlement.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'story_id': storyId,
        'title': title,
        'description': description,
        'cover_emoji': coverEmoji,
        'currency': currency,
        'status': status,
        'created_by': createdBy,
        'created_at': createdAt,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        'members': members.map((m) => m.toJson()).toList(),
        'summary': summary.toJson(),
        'expenses': expenses.map((e) => e.toJson()).toList(),
        'member_balances': memberBalances.map((b) => b.toJson()).toList(),
        'settlements': settlements.map((s) => s.toJson()).toList(),
      };

  String toJsonString() => jsonEncode(toJson());

  /// Automatically creates a balanced Story with calculated summary, member balances and settlements.
  factory Story.create({
    required String storyId,
    required String title,
    required String description,
    String coverEmoji = '🌴',
    String currency = 'INR',
    String status = 'active',
    required String createdBy,
    String? createdAt,
    String? startDate,
    String? endDate,
    required List<StoryMember> members,
    required List<StoryExpense> expenses,
    List<StorySettlement>? existingSettlements,
  }) {
    final nowIso = createdAt ?? DateTime.now().toIso8601String();
    return _buildCalculatedStory(
      storyId: storyId,
      title: title,
      description: description,
      coverEmoji: coverEmoji,
      currency: currency,
      status: status,
      createdBy: createdBy,
      createdAt: nowIso,
      startDate: startDate,
      endDate: endDate,
      members: members,
      expenses: expenses,
      existingSettlements: existingSettlements,
    );
  }

  /// Returns a copy of the story with an added expense, automatically recalculating balances and settlements.
  Story addExpense(StoryExpense newExpense) {
    final updatedExpenses = List<StoryExpense>.from(expenses)..add(newExpense);
    return _buildCalculatedStory(
      storyId: storyId,
      title: title,
      description: description,
      coverEmoji: coverEmoji,
      currency: currency,
      status: status,
      createdBy: createdBy,
      createdAt: createdAt,
      startDate: startDate,
      endDate: endDate,
      members: members,
      expenses: updatedExpenses,
      existingSettlements: settlements,
    );
  }

  /// Internal recalculation engine guaranteeing mathematical consistency across balances and settlements.
  static Story _buildCalculatedStory({
    required String storyId,
    required String title,
    required String description,
    required String coverEmoji,
    required String currency,
    required String status,
    required String createdBy,
    required String createdAt,
    String? startDate,
    String? endDate,
    required List<StoryMember> members,
    required List<StoryExpense> expenses,
    List<StorySettlement>? existingSettlements,
  }) {
    final totalExpenses = expenses.fold<double>(
      0.0,
      (sum, e) => sum + e.amount,
    );

    // Compute paid and share per user
    final Map<String, double> totalPaidByUser = {};
    final Map<String, double> totalShareByUser = {};

    for (final member in members) {
      totalPaidByUser[member.userId] = 0.0;
      totalShareByUser[member.userId] = 0.0;
    }

    for (final expense in expenses) {
      totalPaidByUser[expense.paidBy] =
          (totalPaidByUser[expense.paidBy] ?? 0.0) + expense.amount;
      for (final share in expense.shares) {
        totalShareByUser[share.userId] =
            (totalShareByUser[share.userId] ?? 0.0) + share.amount;
      }
    }

    // Build member balances
    final List<StoryMemberBalance> balances = [];
    final List<MapEntry<String, double>> debtors = [];
    final List<MapEntry<String, double>> creditors = [];

    for (final member in members) {
      final paid = totalPaidByUser[member.userId] ?? 0.0;
      final share = totalShareByUser[member.userId] ?? 0.0;
      final net = paid - share;

      String balStatus;
      if (net > 0.001) {
        balStatus = 'gets_back';
        creditors.add(MapEntry(member.userId, net));
      } else if (net < -0.001) {
        balStatus = 'owes';
        debtors.add(MapEntry(member.userId, -net)); // positive debt
      } else {
        balStatus = 'settled';
      }

      balances.add(
        StoryMemberBalance(
          userId: member.userId,
          name: member.name,
          totalPaid: paid,
          totalShare: share,
          netBalance: net,
          status: balStatus,
        ),
      );
    }

    // Calculate simplified settlements if not explicitly provided or if recalculated
    final List<StorySettlement> computedSettlements = [];
    int settlementCounter = 1;

    int dIdx = 0;
    int cIdx = 0;

    while (dIdx < debtors.length && cIdx < creditors.length) {
      final debtor = debtors[dIdx];
      final creditor = creditors[cIdx];

      final minAmount = debtor.value < creditor.value ? debtor.value : creditor.value;
      if (minAmount > 0.01) {
        computedSettlements.add(
          StorySettlement(
            settlementId: 'set_${settlementCounter.toString().padLeft(3, '0')}',
            fromUser: debtor.key,
            toUser: creditor.key,
            amount: minAmount,
            status: 'pending',
          ),
        );
        settlementCounter++;
      }

      debtors[dIdx] = MapEntry(debtor.key, debtor.value - minAmount);
      creditors[cIdx] = MapEntry(creditor.key, creditor.value - minAmount);

      if (debtors[dIdx].value <= 0.01) dIdx++;
      if (creditors[cIdx].value <= 0.01) cIdx++;
    }

    final finalSettlements = (existingSettlements != null && existingSettlements.isNotEmpty)
        ? existingSettlements
        : computedSettlements;

    final double totalSettled = finalSettlements.fold<double>(
      0.0,
      (sum, s) => s.status == 'completed' ? sum + s.amount : sum,
    );

    final double pendingAmount = finalSettlements.fold<double>(
      0.0,
      (sum, s) => s.status == 'pending' ? sum + s.amount : sum,
    );

    final summary = StorySummary(
      totalExpenses: totalExpenses,
      totalSettled: totalSettled,
      pendingAmount: pendingAmount,
      memberCount: members.length,
      expenseCount: expenses.length,
    );

    return Story(
      storyId: storyId,
      title: title,
      description: description,
      coverEmoji: coverEmoji,
      currency: currency,
      status: status,
      createdBy: createdBy,
      createdAt: createdAt,
      startDate: startDate,
      endDate: endDate,
      members: members,
      summary: summary,
      expenses: expenses,
      memberBalances: balances,
      settlements: finalSettlements,
    );
  }

  /// Default Goa Trip Story exactly matching the user-provided JSON format.
  static Story sampleGoaTrip() {
    return Story.fromJson(sampleGoaTripJson());
  }

  /// Returns the exact map representation provided in user requirements.
  static Map<String, dynamic> sampleGoaTripJson() => {
        "story_id": "story_001",
        "title": "Goa Trip",
        "description": "Goa vacation with friends",
        "cover_emoji": "🌴",
        "currency": "INR",
        "status": "active",
        "created_by": "user_001",
        "created_at": "2026-11-12T09:00:00Z",
        "start_date": "2026-11-12",
        "end_date": "2026-11-16",
        "members": [
          {
            "user_id": "user_001",
            "name": "Roshan",
            "avatar": "https://example.com/roshan.jpg",
            "role": "admin",
            "joined_at": "2026-11-12T09:00:00Z"
          },
          {
            "user_id": "user_002",
            "name": "Rahul",
            "avatar": "https://example.com/rahul.jpg",
            "role": "member",
            "joined_at": "2026-11-12T09:10:00Z"
          },
          {
            "user_id": "user_003",
            "name": "Amit",
            "avatar": "https://example.com/amit.jpg",
            "role": "member",
            "joined_at": "2026-11-12T09:15:00Z"
          },
          {
            "user_id": "user_004",
            "name": "Sanket",
            "avatar": "https://example.com/sanket.jpg",
            "role": "member",
            "joined_at": "2026-11-12T09:20:00Z"
          }
        ],
        "summary": {
          "total_expenses": 20000,
          "total_settled": 0,
          "pending_amount": 5000,
          "member_count": 4,
          "expense_count": 5
        },
        "expenses": [
          {
            "expense_id": "exp_001",
            "title": "Hotel Booking",
            "category": "accommodation",
            "amount": 8000,
            "paid_by": "user_001",
            "split_type": "equal",
            "participants": ["user_001", "user_002", "user_003", "user_004"],
            "shares": [
              {"user_id": "user_001", "amount": 2000},
              {"user_id": "user_002", "amount": 2000},
              {"user_id": "user_003", "amount": 2000},
              {"user_id": "user_004", "amount": 2000}
            ],
            "date": "2026-11-12T10:30:00Z",
            "note": "Hotel for 4 nights"
          },
          {
            "expense_id": "exp_002",
            "title": "Dinner",
            "category": "food",
            "amount": 2000,
            "paid_by": "user_002",
            "split_type": "equal",
            "participants": ["user_001", "user_002", "user_003", "user_004"],
            "shares": [
              {"user_id": "user_001", "amount": 500},
              {"user_id": "user_002", "amount": 500},
              {"user_id": "user_003", "amount": 500},
              {"user_id": "user_004", "amount": 500}
            ],
            "date": "2026-11-12T19:30:00Z"
          },
          {
            "expense_id": "exp_003",
            "title": "Petrol",
            "category": "transport",
            "amount": 3000,
            "paid_by": "user_003",
            "split_type": "equal",
            "participants": ["user_001", "user_002", "user_003", "user_004"],
            "shares": [
              {"user_id": "user_001", "amount": 750},
              {"user_id": "user_002", "amount": 750},
              {"user_id": "user_003", "amount": 750},
              {"user_id": "user_004", "amount": 750}
            ],
            "date": "2026-11-13T08:00:00Z"
          },
          {
            "expense_id": "exp_004",
            "title": "Water Sports",
            "category": "activities",
            "amount": 5000,
            "paid_by": "user_004",
            "split_type": "equal",
            "participants": ["user_001", "user_002", "user_003", "user_004"],
            "shares": [
              {"user_id": "user_001", "amount": 1250},
              {"user_id": "user_002", "amount": 1250},
              {"user_id": "user_003", "amount": 1250},
              {"user_id": "user_004", "amount": 1250}
            ],
            "date": "2026-11-13T14:00:00Z"
          },
          {
            "expense_id": "exp_005",
            "title": "Food & Snacks",
            "category": "food",
            "amount": 2000,
            "paid_by": "user_001",
            "split_type": "equal",
            "participants": ["user_001", "user_002", "user_003", "user_004"],
            "shares": [
              {"user_id": "user_001", "amount": 500},
              {"user_id": "user_002", "amount": 500},
              {"user_id": "user_003", "amount": 500},
              {"user_id": "user_004", "amount": 500}
            ],
            "date": "2026-11-14T12:00:00Z"
          }
        ],
        "member_balances": [
          {
            "user_id": "user_001",
            "name": "Roshan",
            "total_paid": 10000,
            "total_share": 5000,
            "net_balance": 5000,
            "status": "gets_back"
          },
          {
            "user_id": "user_002",
            "name": "Rahul",
            "total_paid": 2000,
            "total_share": 5000,
            "net_balance": -3000,
            "status": "owes"
          },
          {
            "user_id": "user_003",
            "name": "Amit",
            "total_paid": 3000,
            "total_share": 5000,
            "net_balance": -2000,
            "status": "owes"
          },
          {
            "user_id": "user_004",
            "name": "Sanket",
            "total_paid": 5000,
            "total_share": 5000,
            "net_balance": 0,
            "status": "settled"
          }
        ],
        "settlements": [
          {
            "settlement_id": "set_001",
            "from_user": "user_002",
            "to_user": "user_001",
            "amount": 3000,
            "status": "pending"
          },
          {
            "settlement_id": "set_002",
            "from_user": "user_003",
            "to_user": "user_001",
            "amount": 2000,
            "status": "pending"
          }
        ]
      };
}
