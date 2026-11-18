import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/split_summary_screen.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/stories/data/repositories/story_repository.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
  });

  testWidgets(
      'SplitSummaryScreen settlement plan and member breakdown are mathematically synced',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    const you = Friend(name: 'You', phone: '+91 98765 11111');
    const kumar = Friend(name: 'Kumar', phone: '+91 98765 22222');
    const golya = Friend(name: 'Golya', phone: '+91 98765 33333');

    // Simulate story with unequal expenses matching user scenario (Total: ₹15,800)
    final story = Story.create(
      storyId: 'story_party_sync_test',
      title: 'Party',
      description: 'Party trip',
      createdBy: 'user_you',
      members: [
        StoryMember(
          userId: 'user_you',
          name: 'You',
          role: 'admin',
          joinedAt: DateTime.now().toIso8601String(),
        ),
        StoryMember(
          userId: 'user_kumar',
          name: 'Kumar',
          role: 'member',
          joinedAt: DateTime.now().toIso8601String(),
        ),
        StoryMember(
          userId: 'user_golya',
          name: 'Golya',
          role: 'member',
          joinedAt: DateTime.now().toIso8601String(),
        ),
      ],
      expenses: [
        StoryExpense(
          expenseId: 'exp_001',
          title: 'Stay',
          category: 'stay',
          amount: 8367.0,
          paidBy: 'user_you',
          splitType: 'equal',
          participants: ['user_you', 'user_kumar', 'user_golya'],
          shares: const [
            ExpenseShare(userId: 'user_you', amount: 2789.0),
            ExpenseShare(userId: 'user_kumar', amount: 2789.0),
            ExpenseShare(userId: 'user_golya', amount: 2789.0),
          ],
          date: DateTime.now().toIso8601String(),
        ),
        StoryExpense(
          expenseId: 'exp_002',
          title: 'Food',
          category: 'food',
          amount: 5733.0,
          paidBy: 'user_kumar',
          splitType: 'equal',
          participants: ['user_you', 'user_kumar', 'user_golya'],
          shares: const [
            ExpenseShare(userId: 'user_you', amount: 1911.0),
            ExpenseShare(userId: 'user_kumar', amount: 1911.0),
            ExpenseShare(userId: 'user_golya', amount: 1911.0),
          ],
          date: DateTime.now().toIso8601String(),
        ),
        StoryExpense(
          expenseId: 'exp_003',
          title: 'Snacks',
          category: 'food',
          amount: 1700.0,
          paidBy: 'user_golya',
          splitType: 'equal',
          participants: ['user_you', 'user_kumar', 'user_golya'],
          shares: const [
            ExpenseShare(userId: 'user_you', amount: 566.67),
            ExpenseShare(userId: 'user_kumar', amount: 566.67),
            ExpenseShare(userId: 'user_golya', amount: 566.67),
          ],
          date: DateTime.now().toIso8601String(),
        ),
      ],
    );

    await StoryRepository.instance.addStory(story);

    await tester.pumpWidget(
      MaterialApp(
        home: SplitSummaryScreen(
          groupName: 'Party',
          members: const [you, kumar, golya],
          memberExpenses: const {
            'You': 8367.0,
            'Kumar': 5733.0,
            'Golya': 1700.0,
          },
          storyId: story.storyId,
          existingStory: story,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Total expense and title
    expect(find.text('Party'), findsOneWidget);
    expect(find.text('₹15,800'), findsOneWidget);

    // 2. Member breakdown verification
    // You: Gets ₹3,100
    expect(find.text('Gets ₹3,100'), findsOneWidget);
    // Kumar: Gets ₹467 (or ₹466 based on rounding)
    expect(find.byWidgetPredicate((w) =>
        w is Text &&
        (w.data == 'Gets ₹467' || w.data == 'Gets ₹466')), findsOneWidget);
    // Golya: Owes ₹3,567
    expect(find.text('Owes ₹3,567'), findsOneWidget);

    // 3. Settlement plan verification:
    // Should have 2 payments (Golya to You, Golya to Kumar)
    expect(find.text('2 payments'), findsOneWidget);
    // Golya pays You (3,100)
    expect(find.text('Golya'), findsWidgets);
    expect(find.text('Pays ₹3,100'), findsOneWidget);
    // Golya pays Kumar (467 or 466)
    expect(find.byWidgetPredicate((w) =>
        w is Text &&
        (w.data == 'Pays ₹467' || w.data == 'Pays ₹466')), findsOneWidget);
  });

  testWidgets(
      'Mark as paid updates member breakdown without old data and shows check mark emoji as paid',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    const you = Friend(name: 'You', phone: '+91 98765 11111');
    const gunjan = Friend(name: 'Gunjan', phone: '+91 98765 22222');
    const kaavya = Friend(name: 'Kaavya', phone: '+91 98765 33333');

    // Runway scenario from user screenshot:
    // Total expense: ₹1,000. You: ₹600, Gunjan: ₹400, Kaavya: ₹0.
    final story = Story.create(
      storyId: 'story_runway_sync_test',
      title: 'Runway',
      description: 'Runway trip',
      createdBy: 'user_you',
      members: [
        StoryMember(
          userId: 'user_you',
          name: 'You',
          role: 'admin',
          joinedAt: DateTime.now().toIso8601String(),
        ),
        StoryMember(
          userId: 'user_gunjan',
          name: 'Gunjan',
          role: 'member',
          joinedAt: DateTime.now().toIso8601String(),
        ),
        StoryMember(
          userId: 'user_kaavya',
          name: 'Kaavya',
          role: 'member',
          joinedAt: DateTime.now().toIso8601String(),
        ),
      ],
      expenses: [
        StoryExpense(
          expenseId: 'exp_r1',
          title: 'Outfit',
          category: 'general',
          amount: 600.0,
          paidBy: 'user_you',
          splitType: 'equal',
          participants: ['user_you', 'user_gunjan', 'user_kaavya'],
          shares: const [
            ExpenseShare(userId: 'user_you', amount: 200.0),
            ExpenseShare(userId: 'user_gunjan', amount: 200.0),
            ExpenseShare(userId: 'user_kaavya', amount: 200.0),
          ],
          date: DateTime.now().toIso8601String(),
        ),
        StoryExpense(
          expenseId: 'exp_r2',
          title: 'Makeup',
          category: 'general',
          amount: 400.0,
          paidBy: 'user_gunjan',
          splitType: 'equal',
          participants: ['user_you', 'user_gunjan', 'user_kaavya'],
          shares: const [
            ExpenseShare(userId: 'user_you', amount: 133.33),
            ExpenseShare(userId: 'user_gunjan', amount: 133.33),
            ExpenseShare(userId: 'user_kaavya', amount: 133.33),
          ],
          date: DateTime.now().toIso8601String(),
        ),
      ],
    );

    await StoryRepository.instance.addStory(story);

    await tester.pumpWidget(
      MaterialApp(
        home: SplitSummaryScreen(
          groupName: 'Runway',
          members: const [you, gunjan, kaavya],
          memberExpenses: const {
            'You': 600.0,
            'Gunjan': 400.0,
            'Kaavya': 0.0,
          },
          storyId: story.storyId,
          existingStory: story,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Initial check:
    // Gunjan gets ₹67, Kaavya owes ₹333
    expect(find.text('Gets ₹67'), findsOneWidget);
    expect(find.text('Owes ₹333'), findsOneWidget);
    expect(find.text('2 payments'), findsOneWidget);

    // Tap "Mark as paid" on Kaavya pays Gunjan (the second transaction)
    final markAsPaidButtons =
        find.widgetWithText(OutlinedButton, 'Mark as paid');
    expect(markAsPaidButtons, findsNWidgets(2));
    await tester.tap(markAsPaidButtons.last);
    await tester.pumpAndSettle();

    // 1. Pending settlement updates from 2 payments to 1 payment
    expect(find.text('1 payment'), findsOneWidget);

    // 2. Gunjan is now fully settled and shows "✓ Paid" in member breakdown
    expect(find.text('✓ Paid'), findsOneWidget);
    expect(find.text('Gets ₹67'), findsNothing);

    // 3. Kaavya's owe amount is updated from old ₹333 to new ₹267
    expect(find.text('Owes ₹267'), findsOneWidget);
    expect(find.text('Owes ₹333'), findsNothing);

    // 4. You still gets ₹267
    expect(find.text('Gets ₹267'), findsOneWidget);
  });

  test('Story status evaluates to active when pending debts exist and only settled when all zero', () {
    // 1. Story with pending balance should never be 'settled' even if created with status 'settled'
    final unsettledStory = Story.create(
      storyId: 'story_unsettled_status_test',
      title: 'Runway',
      description: 'Runway test',
      status: 'settled', // Attempt to mark as settled while debts exist
      createdBy: 'user_you',
      members: [
        StoryMember(
          userId: 'user_you',
          name: 'You',
          role: 'admin',
          joinedAt: DateTime.now().toIso8601String(),
        ),
        StoryMember(
          userId: 'user_gunjan',
          name: 'Gunjan',
          role: 'member',
          joinedAt: DateTime.now().toIso8601String(),
        ),
        StoryMember(
          userId: 'user_kaavya',
          name: 'Kaavya',
          role: 'member',
          joinedAt: DateTime.now().toIso8601String(),
        ),
      ],
      expenses: [
        StoryExpense(
          expenseId: 'exp_r1',
          title: 'Outfit',
          category: 'general',
          amount: 600.0,
          paidBy: 'user_you',
          splitType: 'equal',
          participants: ['user_you', 'user_gunjan', 'user_kaavya'],
          shares: const [],
          date: DateTime.now().toIso8601String(),
        ),
        StoryExpense(
          expenseId: 'exp_r2',
          title: 'Makeup',
          category: 'general',
          amount: 400.0,
          paidBy: 'user_gunjan',
          splitType: 'equal',
          participants: ['user_you', 'user_gunjan', 'user_kaavya'],
          shares: const [],
          date: DateTime.now().toIso8601String(),
        ),
      ],
    );

    // Debts remain (You gets ₹267, Gunjan gets ₹67, Kaavya owes ₹333)
    expect(unsettledStory.status, equals('active'));
    expect(unsettledStory.summary.pendingAmount, greaterThan(0.01));

    // 2. Deserializing a story with "status": "settled" from JSON must auto-correct to 'active' if debts exist
    final jsonWithStaleSettled = {
      'story_id': 'story_json_test',
      'title': 'Runway',
      'status': 'settled',
      'created_by': 'user_you',
      'created_at': DateTime.now().toIso8601String(),
      'members': [
        {'user_id': 'user_you', 'name': 'You', 'role': 'admin'},
        {'user_id': 'user_gunjan', 'name': 'Gunjan', 'role': 'member'},
        {'user_id': 'user_kaavya', 'name': 'Kaavya', 'role': 'member'},
      ],
      'member_balances': [
        {
          'user_id': 'user_you',
          'name': 'You',
          'total_paid': 600.0,
          'total_share': 333.33,
          'net_balance': 266.67,
          'status': 'gets_back',
        },
        {
          'user_id': 'user_gunjan',
          'name': 'Gunjan',
          'total_paid': 400.0,
          'total_share': 333.33,
          'net_balance': 66.67,
          'status': 'gets_back',
        },
        {
          'user_id': 'user_kaavya',
          'name': 'Kaavya',
          'total_paid': 0.0,
          'total_share': 333.33,
          'net_balance': -333.34,
          'status': 'owes',
        },
      ],
      'summary': {
        'total_expenses': 1000.0,
        'total_settled': 0.0,
        'pending_amount': 333.34,
        'member_count': 3,
        'expense_count': 2,
      },
    };

    final parsedStory = Story.fromJson(jsonWithStaleSettled);
    expect(parsedStory.status, equals('active'));

    // 3. Fully settled story (all balances 0 and pending amount 0) should evaluate to 'settled'
    final settledStory = Story.create(
      storyId: 'story_fully_settled',
      title: 'Runway Done',
      description: 'Fully settled test',
      createdBy: 'user_you',
      members: [
        StoryMember(
          userId: 'user_you',
          name: 'You',
          role: 'admin',
          joinedAt: DateTime.now().toIso8601String(),
        ),
        StoryMember(
          userId: 'user_gunjan',
          name: 'Gunjan',
          role: 'member',
          joinedAt: DateTime.now().toIso8601String(),
        ),
      ],
      expenses: [
        // Member 1 paid ₹500
        StoryExpense(
          expenseId: 'exp_s1',
          title: 'Lunch',
          category: 'food',
          amount: 500.0,
          paidBy: 'user_you',
          splitType: 'equal',
          participants: ['user_you', 'user_gunjan'],
          shares: const [],
          date: DateTime.now().toIso8601String(),
        ),
        // Member 2 reimbursed ₹250
        StoryExpense(
          expenseId: 'exp_reimb1',
          title: 'Reimbursement transfer to You by Gunjan',
          category: 'reimbursement',
          amount: 250.0,
          paidBy: 'user_gunjan',
          splitType: 'equal',
          participants: ['user_you'],
          shares: const [],
          date: DateTime.now().toIso8601String(),
        ),
      ],
    );

    expect(settledStory.summary.pendingAmount, lessThanOrEqualTo(0.01));
    expect(settledStory.memberBalances.every((b) => b.netBalance.abs() <= 0.01), isTrue);
    expect(settledStory.status, equals('settled'));
  });

  test('Reimbursement transfers to You and between members resolve properly and net balances sum to zero', () {
    final story = Story.create(
      storyId: 'story_party_reimb_test',
      title: 'Party',
      description: 'Party trip',
      createdBy: 'user_you',
      members: [
        StoryMember(
          userId: 'user_you',
          name: 'You',
          role: 'admin',
          joinedAt: DateTime.now().toIso8601String(),
        ),
        StoryMember(
          userId: 'user_kumar',
          name: 'Kumar',
          role: 'member',
          joinedAt: DateTime.now().toIso8601String(),
        ),
        StoryMember(
          userId: 'user_golya',
          name: 'Golya',
          role: 'member',
          joinedAt: DateTime.now().toIso8601String(),
        ),
      ],
      expenses: [
        // Actual expenses: ₹16,100 total (You: 12,000, Kumar: 3,400, Golya: 700)
        StoryExpense(
          expenseId: 'e1',
          title: 'Flight',
          category: 'travel',
          amount: 5000.0,
          paidBy: 'user_you',
          participants: ['user_you', 'user_kumar', 'user_golya'],
          shares: const [],
          date: DateTime.now().toIso8601String(),
        ),
        StoryExpense(
          expenseId: 'e2',
          title: 'Stay',
          category: 'stay',
          amount: 7000.0,
          paidBy: 'user_you',
          participants: ['user_you', 'user_kumar', 'user_golya'],
          shares: const [],
          date: DateTime.now().toIso8601String(),
        ),
        StoryExpense(
          expenseId: 'e3',
          title: 'Stay',
          category: 'stay',
          amount: 3000.0,
          paidBy: 'user_kumar',
          participants: ['user_you', 'user_kumar', 'user_golya'],
          shares: const [],
          date: DateTime.now().toIso8601String(),
        ),
        StoryExpense(
          expenseId: 'e4',
          title: 'Food',
          category: 'food',
          amount: 400.0,
          paidBy: 'user_kumar',
          participants: ['user_you', 'user_kumar', 'user_golya'],
          shares: const [],
          date: DateTime.now().toIso8601String(),
        ),
        StoryExpense(
          expenseId: 'e5',
          title: 'Activities',
          category: 'general',
          amount: 700.0,
          paidBy: 'user_golya',
          participants: ['user_you', 'user_kumar', 'user_golya'],
          shares: const [],
          date: DateTime.now().toIso8601String(),
        ),
        // Reimbursements
        StoryExpense(
          expenseId: 'r1',
          title: 'Reimbursement transfer to You by Kumar',
          category: 'reimbursement',
          amount: 2333.0,
          paidBy: 'user_kumar',
          participants: ['user_you'],
          shares: const [],
          date: DateTime.now().toIso8601String(),
        ),
        StoryExpense(
          expenseId: 'r2',
          title: 'Reimbursement transfer to Kumar by Golya',
          category: 'reimbursement',
          amount: 1000.0,
          paidBy: 'user_golya',
          participants: ['user_kumar'],
          shares: const [],
          date: DateTime.now().toIso8601String(),
        ),
        StoryExpense(
          expenseId: 'r3',
          title: 'Reimbursement transfer to Kumar by You',
          category: 'reimbursement',
          amount: 1000.0,
          paidBy: 'user_you',
          participants: ['user_kumar'],
          shares: const [],
          date: DateTime.now().toIso8601String(),
        ),
        StoryExpense(
          expenseId: 'r4',
          title: 'Reimbursement transfer to Kumar by You',
          category: 'reimbursement',
          amount: 33.0,
          paidBy: 'user_you',
          participants: ['user_kumar'],
          shares: const [],
          date: DateTime.now().toIso8601String(),
        ),
        StoryExpense(
          expenseId: 'r5',
          title: 'Reimbursement transfer to Golya by You',
          category: 'reimbursement',
          amount: 333.0,
          paidBy: 'user_you',
          participants: ['user_golya'],
          shares: const [],
          date: DateTime.now().toIso8601String(),
        ),
      ],
    );

    // Total expenses should exclude reimbursements: 5000 + 7000 + 3000 + 400 + 700 = 16,100
    expect(story.summary.totalExpenses, equals(16100.0));
    expect(story.summary.expenseCount, equals(5));

    // Sum of net balances must equal 0
    final netSum = story.memberBalances.fold<double>(0.0, (sum, b) => sum + b.netBalance);
    expect(netSum.abs(), lessThan(0.01));
  });

  testWidgets(
      'Settlement plan and Member breakdown are 100% consistent when story has persisted member balances (User screenshot scenario: Gets ₹267, Owes ₹74, Owes ₹193)',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    const you = Friend(name: 'You', phone: '+91 98765 11111');
    const gunjan = Friend(name: 'Gunjan', phone: '+91 98765 22222');
    const kaavya = Friend(name: 'Kaavya', phone: '+91 98765 33333');

    // Simulate story matching user's exact screenshot where member balances are:
    // You: Gets ₹267, Gunjan: Owes ₹74, Kaavya: Owes ₹193
    final story = Story(
      storyId: 'story_runway_screenshot_match',
      title: 'Runway',
      description: 'Runway trip',
      coverEmoji: '🌴',
      currency: 'INR',
      status: 'active',
      splitMethod: 'equal',
      createdBy: 'user_you',
      createdAt: DateTime.now().toIso8601String(),
      members: [
        StoryMember(
          userId: 'user_you',
          name: 'You',
          role: 'admin',
          joinedAt: DateTime.now().toIso8601String(),
        ),
        StoryMember(
          userId: 'user_gunjan',
          name: 'Gunjan',
          role: 'member',
          joinedAt: DateTime.now().toIso8601String(),
        ),
        StoryMember(
          userId: 'user_kaavya',
          name: 'Kaavya',
          role: 'member',
          joinedAt: DateTime.now().toIso8601String(),
        ),
      ],
      summary: const StorySummary(
        totalExpenses: 1111.0,
        totalSettled: 111.0,
        pendingAmount: 267.0,
        memberCount: 3,
        expenseCount: 3,
      ),
      expenses: const [],
      memberBalances: const [
        StoryMemberBalance(
          userId: 'user_you',
          name: 'You',
          totalPaid: 600.0,
          totalShare: 370.0,
          netBalance: 267.0,
          status: 'gets_back',
        ),
        StoryMemberBalance(
          userId: 'user_gunjan',
          name: 'Gunjan',
          totalPaid: 400.0,
          totalShare: 370.0,
          netBalance: -74.0,
          status: 'owes',
        ),
        StoryMemberBalance(
          userId: 'user_kaavya',
          name: 'Kaavya',
          totalPaid: 111.0,
          totalShare: 370.0,
          netBalance: -193.0,
          status: 'owes',
        ),
      ],
      settlements: const [],
    );

    await StoryRepository.instance.addStory(story);

    await tester.pumpWidget(
      MaterialApp(
        home: SplitSummaryScreen(
          groupName: 'Runway',
          members: const [you, gunjan, kaavya],
          memberExpenses: const {
            'You': 600.0,
            'Gunjan': 400.0,
            'Kaavya': 111.0,
          },
          storyId: story.storyId,
          existingStory: story,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Total expense
    expect(find.text('₹1,111'), findsOneWidget);

    // 2. Member breakdown matches the persisted balances:
    expect(find.text('Gets ₹267'), findsOneWidget);
    expect(find.text('Owes ₹74'), findsOneWidget);
    expect(find.text('Owes ₹193'), findsOneWidget);

    // 3. Settlement plan MUST match Member breakdown (74 + 193 = 267):
    // Gunjan pays You ₹74, Kaavya pays You ₹193
    // It should NEVER show the stale/unsynced 'Pays ₹230'
    expect(find.text('Pays ₹230'), findsNothing);
    expect(find.text('Pays ₹74'), findsOneWidget);
    expect(find.text('Pays ₹193'), findsOneWidget);
    expect(find.text('2 payments'), findsOneWidget);
  });
}
