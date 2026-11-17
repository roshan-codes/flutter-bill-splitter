import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bill_splitter/features/expenses/domain/services/expense_calculator.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';
import 'package:flutter_bill_splitter/core/utils/currency_formatter.dart';

StoryExpense createExpense({
  required String id,
  required String title,
  required String category,
  required double amount,
  required String paidBy,
  String splitType = 'equal',
  List<String> participants = const [],
  List<ExpenseShare> shares = const [],
  String date = '2026-11-17',
  String? note,
}) {
  return StoryExpense(
    expenseId: id,
    title: title,
    category: category,
    amount: amount,
    paidBy: paidBy,
    splitType: splitType,
    participants: participants,
    shares: shares,
    date: date,
    note: note,
  );
}

Story buildStory({
  required String id,
  required String title,
  String description = 'Test Description',
  required String createdBy,
  required List<StoryMember> members,
  required List<StoryExpense> expenses,
  List<StorySettlement>? existingSettlements,
}) {
  return Story.create(
    storyId: id,
    title: title,
    description: description,
    createdBy: createdBy,
    members: members,
    expenses: expenses,
    existingSettlements: existingSettlements,
  );
}

void main() {
  group('Comprehensive App Calculation Tests', () {
    const friendAlice = Friend(name: 'Alice', phone: '+91 90000 00001');
    const friendBob = Friend(name: 'Bob', phone: '+91 90000 00002');
    const friendCharlie = Friend(name: 'Charlie', phone: '+91 90000 00003');

    const memberAlice = StoryMember(userId: 'u_alice', name: 'Alice', role: 'admin', joinedAt: '2026-11-17');
    const memberBob = StoryMember(userId: 'u_bob', name: 'Bob', role: 'member', joinedAt: '2026-11-17');
    const memberCharlie = StoryMember(userId: 'u_charlie', name: 'Charlie', role: 'member', joinedAt: '2026-11-17');
    const memberDave = StoryMember(userId: 'u_dave', name: 'Dave', role: 'member', joinedAt: '2026-11-17');

    // =========================================================================
    // 1. ExpenseCalculator Unit Calculations
    // =========================================================================
    group('1. ExpenseCalculator Unit Calculations', () {
      test('calculateTotal correctly sums non-negative numbers', () {
        expect(ExpenseCalculator.calculateTotal({'A': 100.0, 'B': 250.50, 'C': 49.50}), 400.0);
        expect(ExpenseCalculator.calculateTotal({}), 0.0);
        expect(ExpenseCalculator.calculateTotal({'Single': 999.0}), 999.0);
      });

      test('calculateSharePerPerson handles standard and edge-case divisions', () {
        // Standard split
        expect(ExpenseCalculator.calculateSharePerPerson(1500.0, 3), 500.0);
        // Decimal repeating split
        expect(ExpenseCalculator.calculateSharePerPerson(100.0, 3), closeTo(33.333, 0.001));
        // Zero members should return 0.0 without divide-by-zero crash
        expect(ExpenseCalculator.calculateSharePerPerson(100.0, 0), 0.0);
        expect(ExpenseCalculator.calculateSharePerPerson(100.0, -2), 0.0);
        // Zero total
        expect(ExpenseCalculator.calculateSharePerPerson(0.0, 5), 0.0);
      });

      test('calculateSettlements produces minimal debt clearance transactions', () {
        // Case: 2 people, Alice pays ₹1000, Bob pays 0
        final members2 = [friendAlice, friendBob];
        final settlements2 = ExpenseCalculator.calculateSettlements(
          members: members2,
          paidAmounts: {'Alice': 1000.0, 'Bob': 0.0},
        );
        expect(settlements2.length, 1);
        expect(settlements2.first.from.name, 'Bob');
        expect(settlements2.first.to.name, 'Alice');
        expect(settlements2.first.amount, 500.0);

        // Case: Everyone paid exactly their equal share -> 0 transactions
        final settlementsEqual = ExpenseCalculator.calculateSettlements(
          members: members2,
          paidAmounts: {'Alice': 500.0, 'Bob': 500.0},
        );
        expect(settlementsEqual, isEmpty);

        // Case: 3 people (Alice paid ₹900, Bob paid ₹0, Charlie paid ₹0)
        final members3 = [friendAlice, friendBob, friendCharlie];
        final settlements3 = ExpenseCalculator.calculateSettlements(
          members: members3,
          paidAmounts: {'Alice': 900.0, 'Bob': 0.0, 'Charlie': 0.0},
        );
        // Expected: Bob pays Alice ₹300, Charlie pays Alice ₹300 (Total = 2 transactions)
        expect(settlements3.length, 2);
        final totalSettled = settlements3.fold<double>(0.0, (sum, s) => sum + s.amount);
        expect(totalSettled, 600.0);
        expect(settlements3.every((s) => s.to.name == 'Alice'), isTrue);
      });

      test('calculateSettlements simplifies circular multi-party debts', () {
        // Alice paid ₹1200, Bob paid ₹600, Charlie paid ₹0 (Total: ₹1800, Share: ₹600 each)
        // Alice net: +600, Bob net: 0, Charlie net: -600
        // Optimal settlement: Charlie pays Alice ₹600 (only 1 transaction instead of circular transfers)
        final members = [friendAlice, friendBob, friendCharlie];
        final settlements = ExpenseCalculator.calculateSettlements(
          members: members,
          paidAmounts: {'Alice': 1200.0, 'Bob': 600.0, 'Charlie': 0.0},
        );
        expect(settlements.length, 1);
        expect(settlements.first.from.name, 'Charlie');
        expect(settlements.first.to.name, 'Alice');
        expect(settlements.first.amount, 600.0);
      });
    });

    // =========================================================================
    // 2. Total Expenses & Non-Expense Categories Filtering
    // =========================================================================
    group('2. Total Expenses & Transfer Filtering Calculations', () {
      test('totalExpenses excludes reimbursement, settlement, and advance transfers', () {
        final expenses = [
          createExpense(
            id: 'e1',
            title: 'Hotel Stay',
            category: 'stay',
            amount: 8000.0,
            paidBy: 'u_alice',
          ),
          createExpense(
            id: 'e2',
            title: 'Dinner',
            category: 'food',
            amount: 3000.0,
            paidBy: 'u_bob',
          ),
          // Advance payment: NOT a trip expense
          createExpense(
            id: 'e_adv',
            title: 'Advance for cab',
            category: 'advance',
            amount: 1500.0,
            paidBy: 'u_bob',
            participants: ['u_alice'],
          ),
          // Reimbursement transfer: NOT a trip expense
          createExpense(
            id: 'e_reimb',
            title: 'Reimbursement to Alice by Charlie',
            category: 'reimbursement',
            amount: 2000.0,
            paidBy: 'u_charlie',
            participants: ['u_alice'],
          ),
          // Completed settlement: NOT a trip expense
          createExpense(
            id: 'e_set',
            title: 'Settlement transfer',
            category: 'settlement',
            amount: 500.0,
            paidBy: 'u_dave',
            participants: ['u_bob'],
          ),
        ];

        final story = buildStory(
          id: 'story_calc_01',
          title: 'Trip Expenses',
          createdBy: 'u_alice',
          members: [memberAlice, memberBob, memberCharlie, memberDave],
          expenses: expenses,
        );

        // Only Hotel Stay (8000) + Dinner (3000) = 11000
        expect(story.summary.totalExpenses, equals(11000.0));
      });
    });

    // =========================================================================
    // 3. Equal and Unequal/Exact Share Calculations
    // =========================================================================
    group('3. Share Distribution Calculations', () {
      test('Equal split divides expense equally among all members', () {
        final expense = createExpense(
          id: 'e1',
          title: 'Adventure Tour',
          category: 'entertainment',
          amount: 6000.0,
          paidBy: 'u_alice',
        );

        final story = buildStory(
          id: 'story_calc_02',
          title: 'Tour',
          createdBy: 'u_alice',
          members: [memberAlice, memberBob, memberCharlie],
          expenses: [expense],
        );

        expect(story.summary.totalExpenses, 6000.0);
        // Each of 3 members should have share = 2000.0
        for (final b in story.memberBalances) {
          expect(b.totalShare, 2000.0);
        }
      });

      test('Custom exact shares allocate specified amounts per member', () {
        const customShares = [
          ExpenseShare(userId: 'u_alice', amount: 1500.0),
          ExpenseShare(userId: 'u_bob', amount: 2500.0),
          ExpenseShare(userId: 'u_charlie', amount: 1000.0),
        ];

        final expense = createExpense(
          id: 'e_custom',
          title: 'Unequal Food Order',
          category: 'food',
          amount: 5000.0,
          paidBy: 'u_alice',
          splitType: 'exact',
          participants: ['u_alice', 'u_bob', 'u_charlie'],
          shares: customShares,
        );

        final story = buildStory(
          id: 'story_calc_03',
          title: 'Unequal Split',
          createdBy: 'u_alice',
          members: [memberAlice, memberBob, memberCharlie],
          expenses: [expense],
        );

        final aliceBal = story.memberBalances.firstWhere((b) => b.userId == 'u_alice');
        final bobBal = story.memberBalances.firstWhere((b) => b.userId == 'u_bob');
        final charlieBal = story.memberBalances.firstWhere((b) => b.userId == 'u_charlie');

        expect(aliceBal.totalShare, 1500.0);
        expect(bobBal.totalShare, 2500.0);
        expect(charlieBal.totalShare, 1000.0);

        // Alice paid 5000, share 1500 -> Net +3500
        expect(aliceBal.totalPaid, 5000.0);
        expect(aliceBal.netBalance, 3500.0);
        expect(aliceBal.status, 'gets_back');

        // Bob paid 0, share 2500 -> Net -2500
        expect(bobBal.totalPaid, 0.0);
        expect(bobBal.netBalance, -2500.0);
        expect(bobBal.status, 'owes');

        // Charlie paid 0, share 1000 -> Net -1000
        expect(charlieBal.totalPaid, 0.0);
        expect(charlieBal.netBalance, -1000.0);
        expect(charlieBal.status, 'owes');
      });
    });

    // =========================================================================
    // 4. Financial Invariants: Zero-Sum Conservation & Net Balances
    // =========================================================================
    group('4. Zero-Sum Balance Invariants', () {
      test('Algebraic sum of all member net balances strictly equals 0.0', () {
        // 4 members, various expenses with multiple payers and uneven shares
        final expenses = [
          createExpense(
            id: 'e1',
            title: 'Flight',
            category: 'travel',
            amount: 14000.0,
            paidBy: 'u_alice',
          ),
          createExpense(
            id: 'e2',
            title: 'Resort Stay',
            category: 'stay',
            amount: 9000.0,
            paidBy: 'u_bob',
          ),
          createExpense(
            id: 'e3',
            title: 'Dinner & Drinks',
            category: 'food',
            amount: 3600.0,
            paidBy: 'u_charlie',
          ),
          createExpense(
            id: 'e4',
            title: 'Groceries',
            category: 'general',
            amount: 1400.0,
            paidBy: 'u_dave',
          ),
        ];

        final story = buildStory(
          id: 'story_calc_04',
          title: 'Goa Holiday',
          createdBy: 'u_alice',
          members: [memberAlice, memberBob, memberCharlie, memberDave],
          expenses: expenses,
        );

        final totalTripExpenses = story.summary.totalExpenses;
        expect(totalTripExpenses, 14000 + 9000 + 3600 + 1400); // 28000.0
        expect(totalTripExpenses / 4, 7000.0); // 7000 each

        double sumOfNets = 0.0;
        for (final b in story.memberBalances) {
          sumOfNets += b.netBalance;
        }

        // Must conserve exactly 0.0 (tolerance for 64-bit IEEE-754 precision)
        expect(sumOfNets.abs(), lessThan(1e-9));

        // Alice: paid 14000, share 7000 -> +7000
        expect(story.memberBalances.firstWhere((b) => b.userId == 'u_alice').netBalance, 7000.0);
        // Bob: paid 9000, share 7000 -> +2000
        expect(story.memberBalances.firstWhere((b) => b.userId == 'u_bob').netBalance, 2000.0);
        // Charlie: paid 3600, share 7000 -> -3400
        expect(story.memberBalances.firstWhere((b) => b.userId == 'u_charlie').netBalance, -3400.0);
        // Dave: paid 1400, share 7000 -> -5600
        expect(story.memberBalances.firstWhere((b) => b.userId == 'u_dave').netBalance, -5600.0);
      });
    });

    // =========================================================================
    // 5. Advance Payment & Transfer Calculations
    // =========================================================================
    group('5. Advance Payment & Settlement Impact Calculations', () {
      test('Advance payment transfers money without changing total trip expenses', () {
        // Charlie owes Alice ₹1000 from an earlier expense of ₹2000
        final initialExpense = createExpense(
          id: 'e_init',
          title: 'Car Rental',
          category: 'travel',
          amount: 2000.0,
          paidBy: 'u_alice',
        );

        // Charlie pays ₹600 in advance to Alice
        final advanceTransfer = createExpense(
          id: 'e_advance',
          title: 'Advance to Alice by Charlie',
          category: 'advance',
          amount: 600.0,
          paidBy: 'u_charlie',
          participants: ['u_alice'],
        );

        final story = buildStory(
          id: 'story_calc_05',
          title: 'Advance Test',
          createdBy: 'u_alice',
          members: [memberAlice, memberCharlie],
          expenses: [initialExpense, advanceTransfer],
        );

        // Total expenses MUST remain only ₹2,000 (advance is not a trip expense)
        expect(story.summary.totalExpenses, 2000.0);

        final aliceBal = story.memberBalances.firstWhere((b) => b.userId == 'u_alice');
        final charlieBal = story.memberBalances.firstWhere((b) => b.userId == 'u_charlie');

        // Without advance: Alice was owed 1000, Charlie owed 1000
        // With advance of 600:
        // Alice net = (2000 - 1000) - 600 received = +400 (gets back)
        // Charlie net = (0 - 1000) + 600 sent = -400 (owes)
        expect(aliceBal.netBalance, 400.0);
        expect(aliceBal.status, 'gets_back');

        expect(charlieBal.netBalance, -400.0);
        expect(charlieBal.status, 'owes');

        // Check computed settlement reflects the reduced debt of ₹400
        expect(story.settlements.length, 1);
        expect(story.settlements.first.fromUser, 'u_charlie');
        expect(story.settlements.first.toUser, 'u_alice');
        expect(story.settlements.first.amount, 400.0);
      });

      test('Full reimbursement settles debt completely to 0.0', () {
        final expense = createExpense(
          id: 'e1',
          title: 'Dinner',
          category: 'food',
          amount: 1000.0,
          paidBy: 'u_alice',
        );

        // Bob owes ₹500, and pays full ₹500 reimbursement
        final fullReimbursement = createExpense(
          id: 'e_reimb_full',
          title: 'Reimbursement to Alice by Bob',
          category: 'reimbursement',
          amount: 500.0,
          paidBy: 'u_bob',
          participants: ['u_alice'],
        );

        final story = buildStory(
          id: 'story_calc_06',
          title: 'Full Settle Test',
          createdBy: 'u_alice',
          members: [memberAlice, memberBob],
          expenses: [expense, fullReimbursement],
        );

        final aliceBal = story.memberBalances.firstWhere((b) => b.userId == 'u_alice');
        final bobBal = story.memberBalances.firstWhere((b) => b.userId == 'u_bob');

        expect(aliceBal.netBalance, 0.0);
        expect(aliceBal.status, 'settled');

        expect(bobBal.netBalance, 0.0);
        expect(bobBal.status, 'settled');

        // No pending settlements should remain
        expect(story.settlements.where((s) => s.status == 'pending'), isEmpty);
      });
    });

    // =========================================================================
    // 6. Member Deduplication Impact on Calculation
    // =========================================================================
    group('6. Deduplication Impact on Calculations', () {
      test('Deduplicating duplicate member correctly recalibrates per-person share', () {
        // Reproduce issue reported by user:
        // A story has 3 real friends, but "You" and "Roshan Badwaik" both appear (making 4 members)
        // Total expense: ₹11,100
        // Before deduplication: 11100 / 4 = 2775
        // After deduplication: 11100 / 3 = 3700
        final rawMembers = [
          const StoryMember(userId: 'user_you', name: 'You', role: 'admin', joinedAt: '2026-11-17'),
          const StoryMember(userId: 'user_kumar', name: 'Kumar', role: 'member', joinedAt: '2026-11-17'),
          const StoryMember(userId: 'user_golya', name: 'Golya', role: 'member', joinedAt: '2026-11-17'),
          const StoryMember(userId: 'user_roshan_badwaik', name: 'Roshan Badwaik', role: 'member', joinedAt: '2026-11-17'),
        ];

        final deduplicatedMembers = Story.deduplicateMembers(
          rawMembers,
          currentUserName: 'Roshan Badwaik',
        );

        expect(deduplicatedMembers.length, 3);

        final stayExpense = createExpense(
          id: 'e_stay',
          title: 'Stay',
          category: 'stay',
          amount: 7000.0,
          paidBy: 'user_you',
        );

        final kumarExpense = createExpense(
          id: 'e_kumar',
          title: 'Food',
          category: 'food',
          amount: 3400.0,
          paidBy: 'user_kumar',
        );

        final golyaExpense = createExpense(
          id: 'e_golya',
          title: 'Snacks',
          category: 'food',
          amount: 700.0,
          paidBy: 'user_golya',
        );

        final story = buildStory(
          id: 'story_dedup_calc',
          title: 'Party',
          createdBy: 'user_you',
          members: deduplicatedMembers,
          expenses: [stayExpense, kumarExpense, golyaExpense],
        );

        expect(story.summary.totalExpenses, 11100.0);
        final perPerson = story.summary.totalExpenses / story.members.length;
        expect(perPerson, closeTo(3700.0, 0.01)); // Exact ₹3,700 rather than erroneous ₹2,775

        final youBal = story.memberBalances.firstWhere((b) => b.name == 'You' || b.name == 'Roshan Badwaik');
        final kumarBal = story.memberBalances.firstWhere((b) => b.name == 'Kumar');
        final golyaBal = story.memberBalances.firstWhere((b) => b.name == 'Golya');

        expect(youBal.totalPaid, 7000.0);
        expect(kumarBal.totalPaid, 3400.0);
        expect(golyaBal.totalPaid, 700.0);

        expect(youBal.totalShare, closeTo(3700.0, 0.01));
        expect(kumarBal.totalShare, closeTo(3700.0, 0.01));
        expect(golyaBal.totalShare, closeTo(3700.0, 0.01));

        // You gets back: 7000 - 3700 = +3300
        expect(youBal.netBalance, closeTo(3300.0, 0.01));
        // Kumar owes: 3400 - 3700 = -300
        expect(kumarBal.netBalance, closeTo(-300.0, 0.01));
        // Golya owes: 700 - 3700 = -3000
        expect(golyaBal.netBalance, closeTo(-3000.0, 0.01));
      });
    });

    // =========================================================================
    // 7. Payer Resolution & Creator Identifier Calculations
    // =========================================================================
    group('7. Payer ID Resolution Calculations', () {
      test('Expenses with user_creator_... correctly map paid amount to story creator', () {
        // Flight expense has paidBy: 'user_creator_1794930501042'
        final flightExpense = createExpense(
          id: 'e_flight',
          title: 'Flight',
          category: 'travel',
          amount: 5000.0,
          paidBy: 'user_creator_1794930501042',
        );

        final story = buildStory(
          id: 'story_creator_resolve',
          title: 'Trip',
          createdBy: 'user_creator_1794930501042',
          members: [memberAlice, memberBob],
          expenses: [flightExpense],
        );

        // Alice is the admin/creator member, so the flight expense must credit Alice
        final aliceBal = story.memberBalances.firstWhere((b) => b.userId == 'u_alice');
        expect(aliceBal.totalPaid, 5000.0);
        expect(aliceBal.totalShare, 2500.0);
        expect(aliceBal.netBalance, 2500.0);
      });
    });

    // =========================================================================
    // 8. Currency Formatting Calculations
    // =========================================================================
    group('8. Currency Formatter Calculations', () {
      test('CurrencyFormatter correctly formats integers with Indian comma grouping', () {
        expect(CurrencyFormatter.format(0), '0');
        expect(CurrencyFormatter.format(500), '500');
        expect(CurrencyFormatter.format(1000), '1,000');
        expect(CurrencyFormatter.format(12000), '12,000');
        expect(CurrencyFormatter.format(100000), '1,00,000');
        expect(CurrencyFormatter.format(15800), '15,800');
      });

      test('CurrencyFormatter rounds decimals to nearest integer and handles symbols', () {
        expect(CurrencyFormatter.format(1234.50), '1,235');
        expect(CurrencyFormatter.format(99.99), '100');
        expect(CurrencyFormatter.format(7000.0), '7,000');
        expect(CurrencyFormatter.format(15800, includeSymbol: true), '₹15,800');
      });
    });
  });
}
