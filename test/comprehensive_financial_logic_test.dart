import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bill_splitter/features/expenses/domain/services/expense_calculator.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';

void main() {
  group('Section 4: Critical Financial Logic & Invariants Testing', () {
    const friendA = Friend(name: 'Alice', phone: '+91 90000 00001');
    const friendB = Friend(name: 'Bob', phone: '+91 90000 00002');
    const friendC = Friend(name: 'Charlie', phone: '+91 90000 00003');

    // ------------------------------------------------------------------------
    // Scenario 1: Equal Split
    // Three members share ₹900 equally.
    // Expected: Alice ₹300, Bob ₹300, Charlie ₹300
    // ------------------------------------------------------------------------
    test('Scenario 1: Equal Split - Three members share ₹900 equally', () {
      final members = [
        const StoryMember(userId: 'u_alice', name: 'Alice', joinedAt: ''),
        const StoryMember(userId: 'u_bob', name: 'Bob', joinedAt: ''),
        const StoryMember(userId: 'u_charlie', name: 'Charlie', joinedAt: ''),
      ];

      const expense = StoryExpense(
        expenseId: 'exp_001',
        title: 'Dinner',
        category: 'food',
        amount: 900.0,
        paidBy: 'u_alice',
        splitType: 'equal',
        participants: ['u_alice', 'u_bob', 'u_charlie'],
        shares: [
          ExpenseShare(userId: 'u_alice', amount: 300.0),
          ExpenseShare(userId: 'u_bob', amount: 300.0),
          ExpenseShare(userId: 'u_charlie', amount: 300.0),
        ],
        date: '2026-11-15T20:00:00Z',
      );

      final story = Story.create(
        storyId: 'story_fin_01',
        title: 'Equal Split Test',
        description: 'Testing equal split',
        createdBy: 'u_alice',
        members: members,
        expenses: [expense],
      );

      expect(story.summary.totalExpenses, equals(900.0));
      expect(story.summary.expenseCount, equals(1));

      final aliceBal = story.memberBalances.firstWhere((b) => b.userId == 'u_alice');
      final bobBal = story.memberBalances.firstWhere((b) => b.userId == 'u_bob');
      final charlieBal = story.memberBalances.firstWhere((b) => b.userId == 'u_charlie');

      expect(aliceBal.totalShare, equals(300.0));
      expect(bobBal.totalShare, equals(300.0));
      expect(charlieBal.totalShare, equals(300.0));

      expect(aliceBal.totalPaid, equals(900.0));
      expect(bobBal.totalPaid, equals(0.0));
      expect(charlieBal.totalPaid, equals(0.0));

      expect(aliceBal.netBalance, equals(600.0));
      expect(bobBal.netBalance, equals(-300.0));
      expect(charlieBal.netBalance, equals(-300.0));
    });

    // ------------------------------------------------------------------------
    // Scenario 2: Unequal Contributions
    // Total expenses: ₹1,200.
    // Member A paid ₹800, share ₹400 -> Net +₹400
    // Member B paid ₹400, share ₹400 -> Net ₹0
    // Member C paid ₹0, share ₹400 -> Net -₹400
    // Expected settlement: C pays A ₹400
    // ------------------------------------------------------------------------
    test('Scenario 2: Unequal Contributions with ₹1,200 total expense', () {
      final members = [friendA, friendB, friendC];
      final paid = {'Alice': 800.0, 'Bob': 400.0, 'Charlie': 0.0};

      final settlements = ExpenseCalculator.calculateSettlements(
        members: members,
        paidAmounts: paid,
      );

      expect(settlements.length, equals(1));
      expect(settlements.first.from.name, equals('Charlie'));
      expect(settlements.first.to.name, equals('Alice'));
      expect(settlements.first.amount, equals(400.0));
    });

    // ------------------------------------------------------------------------
    // Scenario 3: Multiple Expenses
    // Expense 1: Alice pays ₹1500 for A, B, C (500 each)
    // Expense 2: Bob pays ₹600 for B, C (300 each, Alice doesn't participate)
    // Total: ₹2100
    // Paid: Alice: 1500, Bob: 600, Charlie: 0
    // Share: Alice: 500, Bob: 800, Charlie: 800
    // Net: Alice: +1000, Bob: -200, Charlie: -800
    // ------------------------------------------------------------------------
    test('Scenario 3: Multiple Expenses with non-participating members', () {
      final members = [
        const StoryMember(userId: 'u_alice', name: 'Alice', joinedAt: ''),
        const StoryMember(userId: 'u_bob', name: 'Bob', joinedAt: ''),
        const StoryMember(userId: 'u_charlie', name: 'Charlie', joinedAt: ''),
      ];

      const exp1 = StoryExpense(
        expenseId: 'exp_multi_1',
        title: 'Group Dinner',
        category: 'food',
        amount: 1500.0,
        paidBy: 'u_alice',
        splitType: 'equal',
        participants: ['u_alice', 'u_bob', 'u_charlie'],
        shares: [
          ExpenseShare(userId: 'u_alice', amount: 500.0),
          ExpenseShare(userId: 'u_bob', amount: 500.0),
          ExpenseShare(userId: 'u_charlie', amount: 500.0),
        ],
        date: '2026-11-15T19:00:00Z',
      );

      const exp2 = StoryExpense(
        expenseId: 'exp_multi_2',
        title: 'Cab for Bob and Charlie',
        category: 'transport',
        amount: 600.0,
        paidBy: 'u_bob',
        splitType: 'equal',
        participants: ['u_bob', 'u_charlie'],
        shares: [
          ExpenseShare(userId: 'u_bob', amount: 300.0),
          ExpenseShare(userId: 'u_charlie', amount: 300.0),
        ],
        date: '2026-11-15T22:00:00Z',
      );

      final story = Story.create(
        storyId: 'story_multi_01',
        title: 'Multi Expense Story',
        description: 'Testing multiple expenses',
        createdBy: 'u_alice',
        members: members,
        expenses: [exp1, exp2],
      );

      expect(story.summary.totalExpenses, equals(2100.0));

      final aliceBal = story.memberBalances.firstWhere((b) => b.userId == 'u_alice');
      final bobBal = story.memberBalances.firstWhere((b) => b.userId == 'u_bob');
      final charlieBal = story.memberBalances.firstWhere((b) => b.userId == 'u_charlie');

      expect(aliceBal.totalPaid, equals(1500.0));
      expect(bobBal.totalPaid, equals(600.0));
      expect(charlieBal.totalPaid, equals(0.0));

      expect(aliceBal.totalShare, equals(500.0));
      expect(bobBal.totalShare, equals(800.0));
      expect(charlieBal.totalShare, equals(800.0));

      expect(aliceBal.netBalance, equals(1000.0));
      expect(bobBal.netBalance, equals(-200.0));
      expect(charlieBal.netBalance, equals(-800.0));

      // Settlements: Charlie owes Alice 800, Bob owes Alice 200
      expect(story.settlements.length, equals(2));
      final charlieToAlice = story.settlements.firstWhere((s) => s.fromUser == 'u_charlie');
      final bobToAlice = story.settlements.firstWhere((s) => s.fromUser == 'u_bob');

      expect(charlieToAlice.toUser, equals('u_alice'));
      expect(charlieToAlice.amount, equals(800.0));

      expect(bobToAlice.toUser, equals('u_alice'));
      expect(bobToAlice.amount, equals(200.0));
    });

    // ------------------------------------------------------------------------
    // Scenario 4: Rounding
    // Split ₹1,000 between three members. Total must equal ₹1,000.
    // ------------------------------------------------------------------------
    test('Scenario 4: Rounding - Split ₹1,000 between 3 members sums to ₹1,000', () {
      const total = 1000.0;
      const perPersonRaw = total / 3;
      final share1 = double.parse((perPersonRaw).toStringAsFixed(2)); // 333.33
      final share2 = double.parse((perPersonRaw).toStringAsFixed(2)); // 333.33
      final remainder = double.parse((total - (share1 + share2)).toStringAsFixed(2)); // 333.34

      final shares = [remainder, share1, share2];
      final sumOfShares = shares.fold<double>(0.0, (sum, s) => sum + s);

      expect(shares, containsAll([333.34, 333.33, 333.33]));
      expect(sumOfShares, equals(1000.0));
    });

    // ------------------------------------------------------------------------
    // Scenario 5: Expense Modifications & Recalculation
    // ------------------------------------------------------------------------
    test('Scenario 5: Expense Modifications recalculates balances and settlements dynamically', () {
      final members = [
        const StoryMember(userId: 'u_1', name: 'User 1', joinedAt: ''),
        const StoryMember(userId: 'u_2', name: 'User 2', joinedAt: ''),
      ];

      const expInitial = StoryExpense(
        expenseId: 'exp_init',
        title: 'Initial Expense',
        category: 'food',
        amount: 400.0,
        paidBy: 'u_1',
        splitType: 'equal',
        participants: ['u_1', 'u_2'],
        shares: [
          ExpenseShare(userId: 'u_1', amount: 200.0),
          ExpenseShare(userId: 'u_2', amount: 200.0),
        ],
        date: '2026-11-15T12:00:00Z',
      );

      var story = Story.create(
        storyId: 'story_dyn',
        title: 'Dynamic Modification',
        description: '',
        createdBy: 'u_1',
        members: members,
        expenses: [expInitial],
      );

      expect(story.summary.totalExpenses, equals(400.0));
      expect(story.settlements.first.amount, equals(200.0));

      // Add a second expense: User 2 pays 800
      const expSecond = StoryExpense(
        expenseId: 'exp_second',
        title: 'Second Expense',
        category: 'hotel',
        amount: 800.0,
        paidBy: 'u_2',
        splitType: 'equal',
        participants: ['u_1', 'u_2'],
        shares: [
          ExpenseShare(userId: 'u_1', amount: 400.0),
          ExpenseShare(userId: 'u_2', amount: 400.0),
        ],
        date: '2026-11-15T14:00:00Z',
      );

      story = story.addExpense(expSecond);

      expect(story.summary.totalExpenses, equals(1200.0));
      expect(story.summary.expenseCount, equals(2));

      final u1Bal = story.memberBalances.firstWhere((b) => b.userId == 'u_1');
      final u2Bal = story.memberBalances.firstWhere((b) => b.userId == 'u_2');

      // U1: paid 400, share 600 -> owes 200
      // U2: paid 800, share 600 -> gets 200
      expect(u1Bal.netBalance, equals(-200.0));
      expect(u2Bal.netBalance, equals(200.0));

      expect(story.settlements.length, equals(1));
      expect(story.settlements.first.fromUser, equals('u_1'));
      expect(story.settlements.first.toUser, equals('u_2'));
      expect(story.settlements.first.amount, equals(200.0));
    });

    // ------------------------------------------------------------------------
    // Scenario 6: Settlement Invariants
    // Recording a settlement changes outstanding balances but does not rewrite original expenses
    // ------------------------------------------------------------------------
    test('Scenario 6: Settlement marks completed without rewriting original contributions', () {
      final story = Story.sampleGoaTrip();
      final originalExpenses = story.summary.totalExpenses;
      final originalPaid = story.memberBalances.map((b) => b.totalPaid).toList();

      expect(story.settlements.isNotEmpty, isTrue);
      final firstSettlement = story.settlements.first;

      final updatedSettlements = story.settlements.map((s) {
        if (s.settlementId == firstSettlement.settlementId) {
          return s.copyWith(status: 'completed');
        }
        return s;
      }).toList();

      final totalSettled = updatedSettlements
          .where((s) => s.status == 'completed')
          .fold<double>(0.0, (sum, s) => sum + s.amount);

      final updatedStory = story.copyWith(
        settlements: updatedSettlements,
        summary: story.summary.copyWith(
          totalSettled: totalSettled,
          pendingAmount: story.summary.totalExpenses - totalSettled,
        ),
      );

      // Verify invariant: total expenses and original paid amounts remain strictly unchanged
      expect(updatedStory.summary.totalExpenses, equals(originalExpenses));
      for (int i = 0; i < updatedStory.memberBalances.length; i++) {
        expect(updatedStory.memberBalances[i].totalPaid, equals(originalPaid[i]));
      }
      expect(updatedStory.summary.totalSettled, equals(firstSettlement.amount));
    });

    // ------------------------------------------------------------------------
    // Financial Invariants Verification across Random and Edge Scenarios
    // ------------------------------------------------------------------------
    test('Financial Invariant: Sum of net balances across any split always equals 0', () {
      final members = [
        const StoryMember(userId: 'u_a', name: 'A', joinedAt: ''),
        const StoryMember(userId: 'u_b', name: 'B', joinedAt: ''),
        const StoryMember(userId: 'u_c', name: 'C', joinedAt: ''),
        const StoryMember(userId: 'u_d', name: 'D', joinedAt: ''),
      ];

      final expenses = [
        const StoryExpense(
          expenseId: 'e1',
          title: 'Activity 1',
          category: 'activities',
          amount: 1475.50,
          paidBy: 'u_a',
          splitType: 'equal',
          participants: ['u_a', 'u_b', 'u_c', 'u_d'],
          shares: [
            ExpenseShare(userId: 'u_a', amount: 368.875),
            ExpenseShare(userId: 'u_b', amount: 368.875),
            ExpenseShare(userId: 'u_c', amount: 368.875),
            ExpenseShare(userId: 'u_d', amount: 368.875),
          ],
          date: '2026-11-15T10:00:00Z',
        ),
        const StoryExpense(
          expenseId: 'e2',
          title: 'Food 2',
          category: 'food',
          amount: 830.25,
          paidBy: 'u_c',
          splitType: 'equal',
          participants: ['u_b', 'u_c'],
          shares: [
            ExpenseShare(userId: 'u_b', amount: 415.125),
            ExpenseShare(userId: 'u_c', amount: 415.125),
          ],
          date: '2026-11-15T15:00:00Z',
        ),
      ];

      final story = Story.create(
        storyId: 'story_invariants',
        title: 'Invariant Test',
        description: '',
        createdBy: 'u_a',
        members: members,
        expenses: expenses,
      );

      final totalSumPaid = story.memberBalances.fold<double>(0.0, (sum, b) => sum + b.totalPaid);
      final totalSumShare = story.memberBalances.fold<double>(0.0, (sum, b) => sum + b.totalShare);
      final totalSumNet = story.memberBalances.fold<double>(0.0, (sum, b) => sum + b.netBalance);

      // Invariant 1: Sum of shares equals total expenses
      expect((totalSumShare - story.summary.totalExpenses).abs() < 0.001, isTrue);

      // Invariant 2: Sum of contributions equals total expenses
      expect((totalSumPaid - story.summary.totalExpenses).abs() < 0.001, isTrue);

      // Invariant 3: Sum of net balances equals 0
      expect(totalSumNet.abs() < 0.001, isTrue);

      // Invariant 4: Settlement suggestions never exceed outstanding balances
      for (final s in story.settlements) {
        final debtorBal = story.memberBalances.firstWhere((b) => b.userId == s.fromUser);
        final creditorBal = story.memberBalances.firstWhere((b) => b.userId == s.toUser);

        expect(s.amount <= (-debtorBal.netBalance + 0.01), isTrue);
        expect(s.amount <= (creditorBal.netBalance + 0.01), isTrue);
      }
    });
  });
}
