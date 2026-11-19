import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';

void main() {
  group('Option 1: Retroactive Equal Split (Trip Pool Model)', () {
    test('Adding a 3rd member (Sanjiv) to a 2-member equal split story divides past group expenses', () {
      const m1 = StoryMember(
        userId: 'u_roshan',
        name: 'Roshan',
        role: 'admin',
        joinedAt: '2026-11-19T09:00:00Z',
      );
      const m2 = StoryMember(
        userId: 'u_golya',
        name: 'Golya',
        role: 'member',
        joinedAt: '2026-11-19T09:00:00Z',
      );

      // Expense 1: Stay ₹200 paid by Golya
      const exp1 = StoryExpense(
        expenseId: 'exp_1',
        title: 'Stay',
        category: 'accommodation',
        amount: 200.0,
        paidBy: 'u_golya',
        splitType: 'equal',
        participants: ['u_golya', 'u_roshan'],
        shares: [
          ExpenseShare(userId: 'u_golya', amount: 100.0),
          ExpenseShare(userId: 'u_roshan', amount: 100.0),
        ],
        date: '2026-11-19T10:00:00Z',
      );

      // Expense 2: Hotel Booking ₹100 paid by Roshan
      const exp2 = StoryExpense(
        expenseId: 'exp_2',
        title: 'Hotel Booking',
        category: 'accommodation',
        amount: 100.0,
        paidBy: 'u_roshan',
        splitType: 'equal',
        participants: ['u_roshan', 'u_golya'],
        shares: [
          ExpenseShare(userId: 'u_roshan', amount: 50.0),
          ExpenseShare(userId: 'u_golya', amount: 50.0),
        ],
        date: '2026-11-19T10:05:00Z',
      );

      // 1. Initial 2-member story
      final story2 = Story.create(
        storyId: 'story_goa',
        title: 'Goa',
        description: 'Goa vacation',
        currency: 'INR',
        status: 'active',
        createdBy: 'u_roshan',
        createdAt: '2026-11-19T09:00:00Z',
        members: [m1, m2],
        expenses: [exp1, exp2],
      );

      expect(story2.summary.totalExpenses, equals(300.0));
      expect(story2.memberBalances.firstWhere((b) => b.userId == 'u_golya').netBalance, equals(50.0));
      expect(story2.memberBalances.firstWhere((b) => b.userId == 'u_roshan').netBalance, equals(-50.0));

      // 2. Add Sanjiv (Option 1 recalibration)
      const m3 = StoryMember(
        userId: 'u_sanjiv',
        name: 'Sanjiv',
        role: 'member',
        joinedAt: '2026-11-19T11:00:00Z',
      );

      final previousMembers = story2.members;
      final previousMemberCount = previousMembers.length;
      final updatedMembers = [...story2.members, m3];

      final updatedExpenses = story2.expenses.map((expense) {
        final isEqual = expense.splitType == 'equal';
        if (!isEqual) return expense;

        final isGroupWide = expense.participants.isEmpty ||
            expense.participants.length >= previousMemberCount ||
            previousMembers.every((pm) => expense.participants.any(
                (p) =>
                    p == pm.userId ||
                    p.toLowerCase().trim() == pm.userId.toLowerCase().trim() ||
                    p.toLowerCase().trim() == pm.name.toLowerCase().trim()));

        if (isGroupWide) {
          final newParticipants = {
            ...expense.participants,
            m3.userId,
          }.toList();
          return expense.copyWith(participants: newParticipants);
        }
        return expense;
      }).toList();

      final story3 = Story.create(
        storyId: story2.storyId,
        title: story2.title,
        description: story2.description,
        currency: 'INR',
        status: 'active',
        createdBy: story2.createdBy,
        createdAt: story2.createdAt,
        members: updatedMembers,
        expenses: updatedExpenses,
      );

      // Total expenses should still be ₹300
      expect(story3.summary.totalExpenses, equals(300.0));
      expect(story3.members.length, equals(3));

      final roshan = story3.memberBalances.firstWhere((b) => b.userId == 'u_roshan');
      final golya = story3.memberBalances.firstWhere((b) => b.userId == 'u_golya');
      final sanjiv = story3.memberBalances.firstWhere((b) => b.userId == 'u_sanjiv');

      // Each person's share should now be ₹100
      expect(roshan.totalShare, equals(100.0));
      expect(golya.totalShare, equals(100.0));
      expect(sanjiv.totalShare, equals(100.0));

      // Golya: paid 200, share 100 -> gets 100
      expect(golya.totalPaid, equals(200.0));
      expect(golya.netBalance, equals(100.0));
      expect(golya.status, equals('gets_back'));

      // Roshan: paid 100, share 100 -> settled (0)
      expect(roshan.totalPaid, equals(100.0));
      expect(roshan.netBalance, equals(0.0));
      expect(roshan.status, equals('settled'));

      // Sanjiv: paid 0, share 100 -> owes 100
      expect(sanjiv.totalPaid, equals(0.0));
      expect(sanjiv.netBalance, equals(-100.0));
      expect(sanjiv.status, equals('owes'));

      // Settlement: Sanjiv pays ₹100 to Golya
      expect(story3.settlements.length, equals(1));
      expect(story3.settlements.first.fromUser, equals('u_sanjiv'));
      expect(story3.settlements.first.toUser, equals('u_golya'));
      expect(story3.settlements.first.amount, equals(100.0));

      // Strict Zero-sum verification
      final totalNet = roshan.netBalance + golya.netBalance + sanjiv.netBalance;
      expect(totalNet.abs(), lessThan(0.001));
    });
  });
}
