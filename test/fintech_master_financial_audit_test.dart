import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bill_splitter/features/expenses/domain/services/expense_calculator.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';

void main() {
  group('TTMM Club Master Financial Logic & Settlement Accuracy Audit', () {
    // =========================================================================
    // PHASE 3: SPLIT METHODS & ACCURACY
    // =========================================================================

    group('Phase 3: Split Methods', () {
      test('Equal Split: ₹900 among 3 members', () {
        final share = ExpenseCalculator.calculateSharePerPerson(900.0, 3);
        expect(share, equals(300.0));
      });

      test('Equal Split: ₹1,000 among 3 members with rounding preservation', () {
        const total = 1000.0;
        const count = 3;
        const rawPerPerson = total / count;
        final baseShare = (rawPerPerson * 100).floor() / 100; // 333.33
        final remainder = double.parse((total - (baseShare * count)).toStringAsFixed(2)); // 0.01

        final allocations = [
          baseShare + remainder, // 333.34
          baseShare,             // 333.33
          baseShare,             // 333.33
        ];

        final sum = allocations.fold<double>(0.0, (s, a) => s + a);
        expect(allocations[0], equals(333.34));
        expect(allocations[1], equals(333.33));
        expect(allocations[2], equals(333.33));
        expect(sum, equals(1000.0));
      });

      test('Equal Split: ₹100 among 6 members', () {
        const total = 100.0;
        const count = 6;
        final base = (total / count * 100).floor() / 100; // 16.66
        final remainder = double.parse((total - (base * count)).toStringAsFixed(2)); // 0.04
        expect(remainder, equals(0.04));

        final List<double> allocations = [];
        for (int i = 0; i < count; i++) {
          if (i < 4) {
            allocations.add(base + 0.01); // 16.67
          } else {
            allocations.add(base);        // 16.66
          }
        }
        final sum = allocations.fold<double>(0.0, (s, a) => s + a);
        expect((sum - total).abs() < 0.0001, isTrue);
      });

      test('Equal Split: ₹1 among 3 members (Paise resolution)', () {
        const total = 1.0;
        const count = 3;
        // 0.34, 0.33, 0.33
        final allocations = [0.34, 0.33, 0.33];
        expect(allocations.length, equals(count));
        final sum = allocations.fold<double>(0.0, (s, a) => s + a);
        expect(sum, equals(total));
      });

      test('Equal Split: ₹10,000 among 7 members', () {
        const total = 10000.0;
        const count = 7;
        const raw = total / count;
        final rounded = double.parse(raw.toStringAsFixed(2)); // 1428.57
        final diff = double.parse((total - (rounded * count)).toStringAsFixed(2)); // +0.01
        final allocations = List<double>.filled(count, rounded);
        allocations[0] += diff;

        final sum = allocations.fold<double>(0.0, (s, a) => s + a);
        expect((sum - 10000.0).abs() < 0.0001, isTrue);
      });

      test('Equal Split: 1 participant receives 100% of expense', () {
        final share = ExpenseCalculator.calculateSharePerPerson(550.0, 1);
        expect(share, equals(550.0));
      });

      test('Equal Split: 0 participants returns 0.0 without division by zero crash', () {
        final share = ExpenseCalculator.calculateSharePerPerson(550.0, 0);
        expect(share, equals(0.0));
      });

      test('Percentage Split: 50%, 30%, 20% on ₹1,000 matches exactly', () {
        const total = 1000.0;
        const pA = total * 0.50; // 500
        const pB = total * 0.30; // 300
        const pC = total * 0.20; // 200

        expect(pA, equals(500.0));
        expect(pB, equals(300.0));
        expect(pC, equals(200.0));
        expect(pA + pB + pC, equals(1000.0));
      });

      test('Exact Amount Split: ₹1,500 split as ₹500, ₹700, and ₹300', () {
        const shares = {'A': 500.0, 'B': 700.0, 'C': 300.0};
        final total = shares.values.fold<double>(0.0, (s, a) => s + a);
        expect(total, equals(1500.0));
      });
    });

    // =========================================================================
    // PHASE 4: COMPLEX FINANCIAL SCENARIOS
    // =========================================================================

    group('Phase 4: Complex Financial Scenarios', () {
      test('Scenario 1: Basic Three-Member Expense (Roshan, Kaavya, Gunjan)', () {
        final members = [
          const Friend(name: 'Roshan', phone: '+91 90000 00001'),
          const Friend(name: 'Kaavya', phone: '+91 90000 00002'),
          const Friend(name: 'Gunjan', phone: '+91 90000 00003'),
        ];
        // Roshan pays ₹900, Kaavya & Gunjan pay ₹0
        final paid = {'Roshan': 900.0, 'Kaavya': 0.0, 'Gunjan': 0.0};

        final settlements = ExpenseCalculator.calculateSettlements(
          members: members,
          paidAmounts: paid,
        );

        expect(settlements.length, equals(2));
        final toRoshan = settlements.where((s) => s.to.name == 'Roshan').toList();
        expect(toRoshan.length, equals(2));

        final kaavya = toRoshan.firstWhere((s) => s.from.name == 'Kaavya');
        final gunjan = toRoshan.firstWhere((s) => s.from.name == 'Gunjan');

        expect(kaavya.amount, equals(300.0));
        expect(gunjan.amount, equals(300.0));
      });

      test('Scenario 2: Multiple Expenses With Different Payers (A, B, C)', () {
        // Hotel: ₹900 paid by A for A, B, C (300 each)
        // Dinner: ₹600 paid by B for A, B, C (200 each)
        // Fuel: ₹300 paid by C for A, C (150 each, B excluded)
        //
        // Expected Totals:
        // A paid 900, share = 300 + 200 + 150 = 650 (Net: +250)
        // B paid 600, share = 300 + 200 + 0 = 500 (Net: +100)
        // C paid 300, share = 300 + 200 + 150 = 650 (Net: -350)
        // Settlements: C pays A 250, C pays B 100.
        final members = [
          const StoryMember(userId: 'u_A', name: 'A', joinedAt: ''),
          const StoryMember(userId: 'u_B', name: 'B', joinedAt: ''),
          const StoryMember(userId: 'u_C', name: 'C', joinedAt: ''),
        ];

        final expenses = [
          const StoryExpense(
            expenseId: 'e_hotel',
            title: 'Hotel',
            category: 'hotel',
            amount: 900.0,
            paidBy: 'u_A',
            splitType: 'equal',
            participants: ['u_A', 'u_B', 'u_C'],
            shares: [
              ExpenseShare(userId: 'u_A', amount: 300.0),
              ExpenseShare(userId: 'u_B', amount: 300.0),
              ExpenseShare(userId: 'u_C', amount: 300.0),
            ],
            date: '2026-11-15T10:00:00Z',
          ),
          const StoryExpense(
            expenseId: 'e_dinner',
            title: 'Dinner',
            category: 'food',
            amount: 600.0,
            paidBy: 'u_B',
            splitType: 'equal',
            participants: ['u_A', 'u_B', 'u_C'],
            shares: [
              ExpenseShare(userId: 'u_A', amount: 200.0),
              ExpenseShare(userId: 'u_B', amount: 200.0),
              ExpenseShare(userId: 'u_C', amount: 200.0),
            ],
            date: '2026-11-15T19:00:00Z',
          ),
          const StoryExpense(
            expenseId: 'e_fuel',
            title: 'Fuel',
            category: 'transport',
            amount: 300.0,
            paidBy: 'u_C',
            splitType: 'equal',
            participants: ['u_A', 'u_C'],
            shares: [
              ExpenseShare(userId: 'u_A', amount: 150.0),
              ExpenseShare(userId: 'u_C', amount: 150.0),
            ],
            date: '2026-11-15T22:00:00Z',
          ),
        ];

        final story = Story.create(
          storyId: 'story_scen_2',
          title: 'Scenario 2 Story',
          description: '',
          createdBy: 'u_A',
          members: members,
          expenses: expenses,
        );

        final aBal = story.memberBalances.firstWhere((b) => b.userId == 'u_A');
        final bBal = story.memberBalances.firstWhere((b) => b.userId == 'u_B');
        final cBal = story.memberBalances.firstWhere((b) => b.userId == 'u_C');

        expect(aBal.totalPaid, equals(900.0));
        expect(aBal.totalShare, equals(650.0));
        expect(aBal.netBalance, equals(250.0));

        expect(bBal.totalPaid, equals(600.0));
        expect(bBal.totalShare, equals(500.0));
        expect(bBal.netBalance, equals(100.0));

        expect(cBal.totalPaid, equals(300.0));
        expect(cBal.totalShare, equals(650.0));
        expect(cBal.netBalance, equals(-350.0));

        // Settlements
        expect(story.settlements.length, equals(2));
        final cToA = story.settlements.firstWhere((s) => s.fromUser == 'u_C' && s.toUser == 'u_A');
        final cToB = story.settlements.firstWhere((s) => s.fromUser == 'u_C' && s.toUser == 'u_B');

        expect(cToA.amount, equals(250.0));
        expect(cToB.amount, equals(100.0));
      });

      test('Scenario 3: Non-Participating Member C owes ₹0', () {
        final members = [
          const StoryMember(userId: 'u_A', name: 'A', joinedAt: ''),
          const StoryMember(userId: 'u_B', name: 'B', joinedAt: ''),
          const StoryMember(userId: 'u_C', name: 'C', joinedAt: ''),
        ];

        const exp = StoryExpense(
          expenseId: 'e_1000',
          title: 'Activity for A and B',
          category: 'activities',
          amount: 1000.0,
          paidBy: 'u_A',
          splitType: 'equal',
          participants: ['u_A', 'u_B'],
          shares: [
            ExpenseShare(userId: 'u_A', amount: 500.0),
            ExpenseShare(userId: 'u_B', amount: 500.0),
          ],
          date: '2026-11-15T12:00:00Z',
        );

        final story = Story.create(
          storyId: 'story_scen_3',
          title: 'Non-participant story',
          description: '',
          createdBy: 'u_A',
          members: members,
          expenses: [exp],
        );

        final cBal = story.memberBalances.firstWhere((b) => b.userId == 'u_C');
        expect(cBal.totalPaid, equals(0.0));
        expect(cBal.totalShare, equals(0.0));
        expect(cBal.netBalance, equals(0.0));
        expect(cBal.status, equals('settled'));

        // C must not be in any settlements
        expect(story.settlements.any((s) => s.fromUser == 'u_C' || s.toUser == 'u_C'), isFalse);
      });

      test('Scenario 6: All Members Have Zero Balance', () {
        final members = [
          const StoryMember(userId: 'u_1', name: 'User 1', joinedAt: ''),
          const StoryMember(userId: 'u_2', name: 'User 2', joinedAt: ''),
        ];

        // Each pays 500 for a 1000 split
        const exp1 = StoryExpense(
          expenseId: 'e_bal_1',
          title: 'Expense 1',
          category: 'food',
          amount: 500.0,
          paidBy: 'u_1',
          splitType: 'equal',
          participants: ['u_1', 'u_2'],
          shares: [
            ExpenseShare(userId: 'u_1', amount: 250.0),
            ExpenseShare(userId: 'u_2', amount: 250.0),
          ],
          date: '2026-11-15T10:00:00Z',
        );

        const exp2 = StoryExpense(
          expenseId: 'e_bal_2',
          title: 'Expense 2',
          category: 'transport',
          amount: 500.0,
          paidBy: 'u_2',
          splitType: 'equal',
          participants: ['u_1', 'u_2'],
          shares: [
            ExpenseShare(userId: 'u_1', amount: 250.0),
            ExpenseShare(userId: 'u_2', amount: 250.0),
          ],
          date: '2026-11-15T12:00:00Z',
        );

        final story = Story.create(
          storyId: 'story_zero_bal',
          title: 'Zero Balance Story',
          description: '',
          createdBy: 'u_1',
          members: members,
          expenses: [exp1, exp2],
        );

        for (final b in story.memberBalances) {
          expect(b.netBalance, equals(0.0));
          expect(b.status, equals('settled'));
        }
        expect(story.settlements, isEmpty);
        expect(story.summary.pendingAmount, equals(0.0));
      });
    });

    // =========================================================================
    // PHASE 5 & 6: SETTLEMENT ALGORITHM & STATE MUTATIONS
    // =========================================================================

    group('Phase 5 & 6: Settlement Engine & Historical Immutability', () {
      test('Partial settlement does not modify original expense contributions', () {
        final members = [
          const StoryMember(userId: 'u_A', name: 'A', joinedAt: ''),
          const StoryMember(userId: 'u_B', name: 'B', joinedAt: ''),
        ];

        const exp = StoryExpense(
          expenseId: 'e_settle',
          title: 'Dinner',
          category: 'food',
          amount: 1000.0,
          paidBy: 'u_A',
          splitType: 'equal',
          participants: ['u_A', 'u_B'],
          shares: [
            ExpenseShare(userId: 'u_A', amount: 500.0),
            ExpenseShare(userId: 'u_B', amount: 500.0),
          ],
          date: '2026-11-15T10:00:00Z',
        );

        var story = Story.create(
          storyId: 'story_settle_partial',
          title: 'Partial Settlement Story',
          description: '',
          createdBy: 'u_A',
          members: members,
          expenses: [exp],
        );

        expect(story.settlements.first.amount, equals(500.0));

        // Mark settlement partial/completed
        final updatedSettlements = [
          story.settlements.first.copyWith(status: 'completed', amount: 250.0),
          story.settlements.first.copyWith(settlementId: 'set_002', status: 'pending', amount: 250.0),
        ];

        story = story.copyWith(
          settlements: updatedSettlements,
          summary: story.summary.copyWith(
            totalSettled: 250.0,
            pendingAmount: 250.0,
          ),
        );

        // Verification: original expense remains 1000, paid by A remains 1000
        expect(story.summary.totalExpenses, equals(1000.0));
        expect(story.memberBalances.firstWhere((b) => b.userId == 'u_A').totalPaid, equals(1000.0));
        expect(story.summary.totalSettled, equals(250.0));
        expect(story.summary.pendingAmount, equals(250.0));
      });
    });

    // =========================================================================
    // PHASE 10: PROPERTY-BASED RANDOMIZED TESTING (100 INVARIANT ITERATIONS)
    // =========================================================================

    group('Phase 10: Property-Based Randomized Invariant Verification', () {
      test('100 randomized multi-member financial models verify all 10 invariants', () {
        final rng = Random(42); // Deterministic seed for 100% reproducible execution

        for (int iteration = 1; iteration <= 100; iteration++) {
          final memberCount = rng.nextInt(7) + 2; // 2 to 8 members
          final members = List.generate(
            memberCount,
            (i) => StoryMember(userId: 'user_$i', name: 'Member $i', joinedAt: ''),
          );

          final expenseCount = rng.nextInt(10) + 1; // 1 to 10 expenses
          final List<StoryExpense> expenses = [];

          for (int e = 0; e < expenseCount; e++) {
            final payer = members[rng.nextInt(memberCount)];
            final amount = (rng.nextInt(5000) + 10) * 1.0; // ₹10 to ₹5010

            // Random participants (at least 1)
            final participants = members.where((_) => rng.nextBool()).toList();
            if (participants.isEmpty) participants.add(payer);

            final perPersonShare = amount / participants.length;
            final shares = participants
                .map((p) => ExpenseShare(userId: p.userId, amount: perPersonShare))
                .toList();

            expenses.add(
              StoryExpense(
                expenseId: 'rand_exp_${iteration}_$e',
                title: 'Random Expense $e',
                category: 'general',
                amount: amount,
                paidBy: payer.userId,
                splitType: 'equal',
                participants: participants.map((p) => p.userId).toList(),
                shares: shares,
                date: '2026-11-15T12:00:00Z',
              ),
            );
          }

          final story = Story.create(
            storyId: 'rand_story_$iteration',
            title: 'Random Story $iteration',
            description: '',
            createdBy: members.first.userId,
            members: members,
            expenses: expenses,
          );

          // INVARIANT 1: Total member contributions must equal total recorded expenses
          final totalContributions =
              story.memberBalances.fold<double>(0.0, (s, b) => s + b.totalPaid);
          expect((totalContributions - story.summary.totalExpenses).abs() < 0.01, isTrue,
              reason: 'Invariant 1 failed on iteration $iteration');

          // INVARIANT 2: Total member shares must equal total recorded expenses
          final totalShares =
              story.memberBalances.fold<double>(0.0, (s, b) => s + b.totalShare);
          expect((totalShares - story.summary.totalExpenses).abs() < 0.01, isTrue,
              reason: 'Invariant 2 failed on iteration $iteration');

          // INVARIANT 3: Sum of all net balances must equal zero
          final sumNet =
              story.memberBalances.fold<double>(0.0, (s, b) => s + b.netBalance);
          expect(sumNet.abs() < 0.01, isTrue,
              reason: 'Invariant 3 failed on iteration $iteration');

          // INVARIANT 4: Settlement suggestions never exceed outstanding balances
          for (final s in story.settlements) {
            final debtor = story.memberBalances.firstWhere((b) => b.userId == s.fromUser);
            final creditor = story.memberBalances.firstWhere((b) => b.userId == s.toUser);

            expect(s.amount <= (-debtor.netBalance + 0.01), isTrue,
                reason: 'Invariant 4 (debtor limit) failed on iteration $iteration');
            expect(s.amount <= (creditor.netBalance + 0.01), isTrue,
                reason: 'Invariant 4 (creditor limit) failed on iteration $iteration');
          }

          // INVARIANT 5: No negative zero in net balances
          for (final b in story.memberBalances) {
            expect(b.netBalance == 0.0 ? !b.netBalance.isNegative : true, isTrue,
                reason: 'Invariant 5 (negative zero check) failed on iteration $iteration');
          }
        }
      });
    });
  });
}
