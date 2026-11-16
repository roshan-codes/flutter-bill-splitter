import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bill_splitter/app/app.dart';
import 'package:flutter_bill_splitter/core/constants/app_constants.dart';
import 'package:flutter_bill_splitter/core/services/invite_service.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/split_detail_screen.dart';
import 'package:flutter_bill_splitter/features/navigation/presentation/screens/main_screen.dart';
import 'package:flutter_bill_splitter/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter_bill_splitter/features/stories/data/repositories/story_repository.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';
import 'package:flutter_bill_splitter/features/stories/presentation/screens/join_story_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    await StorageService.instance.clear();
    await StoryRepository.instance.init();
    await StoryRepository.instance.clearAll();
    InviteService.resetForTesting();
    InviteService.onDeepLinkAction = null;
  });

  group('Deep Link Invitation & Authentication Flow Tests', () {
    testWidgets(
        'Scenario 1 (Fresh install + invite + logged out): Never renders Home screen, goes directly to Auth',
        (tester) async {
      // 1. Fresh install: No onboarding, no login
      const testStoryId = 'story_delhi_101';
      await InviteService.savePendingInvite(
        testStoryId,
        originalUrl:
            'https://flutter-bill-splitter.onrender.com/?story_id=$testStoryId',
      );

      // 2. Launch root app with AppAuthGate
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 3. Verify: Home Screen is NEVER rendered!
      expect(find.byType(MainScreen), findsNothing);

      // 4. Verify: Rendered directly to Onboarding / Auth screen with pending invite
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(
          find.text('Join Story Invite • Sign in to accept'), findsOneWidget);

      // 5. Verify: Token was preserved
      final pending = await InviteService.getPendingInvite();
      expect(pending, equals(testStoryId));
      final pendingUrl = await InviteService.getPendingInviteUrl();
      expect(pendingUrl, contains('story_id=$testStoryId'));
    });

    testWidgets(
        'Scenario 1b (Existing install + invite + logged out): Never renders Home screen, redirects to Auth',
        (tester) async {
      // Existing install with completed onboarding, but user logged out
      await StorageService.instance
          .setBool(AppConstants.keyHasCompletedOnboarding, true);
      await StorageService.instance
          .setBool(AppConstants.keyIsLoggedInWithGoogle, false);

      const testStoryId = 'story_goa_202';
      await InviteService.savePendingInvite(testStoryId);

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Home Screen should NOT be shown
      expect(find.byType(MainScreen), findsNothing);
      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets(
        'Scenario 2 (Logged-in user opening invite link): Navigates directly to JoinStoryScreen, no Home flash',
        (tester) async {
      // Setup authenticated user
      await StorageService.instance
          .setBool(AppConstants.keyHasCompletedOnboarding, true);
      await StorageService.instance
          .setBool(AppConstants.keyIsLoggedInWithGoogle, true);
      await StorageService.instance
          .setString(AppConstants.keyUserProfileName, 'Roshan');

      // Add target story to repository
      final sampleStory = Story.sampleDelhiTrip();
      await StoryRepository.instance.addStory(sampleStory);

      // User clicked invite link
      await InviteService.savePendingInvite(sampleStory.storyId);

      // Launch app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify: Home Screen is NOT shown unnecessarily
      expect(find.byType(MainScreen), findsNothing);

      // Verify: Navigates directly to JoinStoryScreen preview
      expect(find.byType(JoinStoryScreen), findsOneWidget);
      expect(find.text('Join Story'), findsOneWidget);
      expect(find.text(sampleStory.title), findsOneWidget);
      expect(find.text('Accept Invitation →'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);
    });

    testWidgets(
        'Scenario 3 (App already running): Incoming deep link processed at runtime without restarting',
        (tester) async {
      // Setup authenticated user running app on MainScreen
      await StorageService.instance
          .setBool(AppConstants.keyHasCompletedOnboarding, true);
      await StorageService.instance
          .setBool(AppConstants.keyIsLoggedInWithGoogle, true);
      await StorageService.instance
          .setString(AppConstants.keyUserProfileName, 'Roshan');

      final sampleStory = Story.sampleGoaTrip();
      await StoryRepository.instance.addStory(sampleStory);

      await tester.pumpWidget(const MyApp(home: MainScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(MainScreen), findsOneWidget);

      // Incoming deep link arrives at runtime via handleIncomingUri
      final uri = Uri.parse(
          'https://flutter-bill-splitter.onrender.com/?story_id=${sampleStory.storyId}');
      await InviteService.handleIncomingUri(uri);
      await tester.pumpAndSettle();

      // Navigates directly to JoinStoryScreen without app restart
      expect(find.byType(JoinStoryScreen), findsOneWidget);
      expect(find.text(sampleStory.title), findsOneWidget);
    });

    testWidgets(
        'Successful login resumes pending invitation and opens JoinStoryScreen directly',
        (tester) async {
      final sampleStory = Story.sampleDelhiTrip();
      await StoryRepository.instance.addStory(sampleStory);

      // Unauthenticated user arrives with invite
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: InviteService.navigatorKey,
          home: OnboardingScreen(inviteStoryId: sampleStory.storyId),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);

      // Tap Skip Login (Testing) to simulate successful auth
      final skipBtn = find.text('Skip Login (Testing)');
      expect(skipBtn, findsOneWidget);
      await tester.tap(skipBtn);
      await tester.pumpAndSettle();

      // Automatically resumes pending invitation into JoinStoryScreen!
      expect(find.byType(JoinStoryScreen), findsOneWidget);
      expect(find.text('Join Story'), findsOneWidget);
      expect(find.text(sampleStory.title), findsOneWidget);

      // Accept invitation
      await tester.tap(find.text('Accept Invitation →'));
      await tester.pumpAndSettle();

      // Successfully joined and transitioned to SplitDetailScreen
      expect(find.byType(SplitDetailScreen), findsOneWidget);
    });

    testWidgets(
        'Invalid or expired invitation link displays clean error and allows navigating home',
        (tester) async {
      // Authenticated user opens non-existent story ID
      await StorageService.instance
          .setBool(AppConstants.keyHasCompletedOnboarding, true);
      await StorageService.instance
          .setBool(AppConstants.keyIsLoggedInWithGoogle, true);

      await tester.pumpWidget(
        const MaterialApp(
          home: JoinStoryScreen(storyId: 'story_invalid_999'),
        ),
      );
      await tester.pumpAndSettle();

      // Error state displayed
      expect(find.text('Invitation Expired or Invalid'), findsOneWidget);
      expect(find.text('Go to Home'), findsOneWidget);

      // Tap Go to Home
      await tester.tap(find.text('Go to Home'));
      await tester.pumpAndSettle();

      expect(find.byType(MainScreen), findsOneWidget);
    });

    testWidgets(
        'User already a member opening invite displays Already a Member with View Story option',
        (tester) async {
      await StorageService.instance
          .setBool(AppConstants.keyHasCompletedOnboarding, true);
      await StorageService.instance
          .setBool(AppConstants.keyIsLoggedInWithGoogle, true);
      await StorageService.instance
          .setString(AppConstants.keyUserProfileName, 'Alex Johnson');

      final sampleStory = Story.sampleDelhiTrip();
      await StoryRepository.instance.addStory(sampleStory);

      await tester.pumpWidget(
        MaterialApp(
          home: JoinStoryScreen(storyId: sampleStory.storyId),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Already a Member'), findsOneWidget);
      expect(find.text('View Story →'), findsOneWidget);

      await tester.tap(find.text('View Story →'));
      await tester.pumpAndSettle();

      expect(find.byType(SplitDetailScreen), findsOneWidget);
    });

    testWidgets(
        'App killed and reopened during auth preserves token and resumes invitation',
        (tester) async {
      const testStoryId = 'story_persistent_777';
      const originalUrl =
          'https://flutter-bill-splitter.onrender.com/?story_id=$testStoryId';

      // 1. First run saves pending invite
      await InviteService.savePendingInvite(testStoryId,
          originalUrl: originalUrl);

      // 2. Simulate app killed and fresh boot
      InviteService.resetForTesting();

      // 3. New instance of AppAuthGate launches
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 4. Token was NOT lost: OnboardingScreen still has the invite
      expect(find.byType(OnboardingScreen), findsOneWidget);
      final storedId = await InviteService.getPendingInvite();
      expect(storedId, equals(testStoryId));
      final storedUrl = await InviteService.getPendingInviteUrl();
      expect(storedUrl, equals(originalUrl));
    });

    testWidgets(
        'Duplicate consecutive deep links for same story do not cause duplicate navigation',
        (tester) async {
      final sampleStory = Story.sampleGoaTrip();
      await StoryRepository.instance.addStory(sampleStory);

      int deepLinkCount = 0;
      InviteService.onDeepLinkAction = (storyId, auth) {
        deepLinkCount++;
      };

      final uri = Uri.parse(
          'https://flutter-bill-splitter.onrender.com/?story_id=${sampleStory.storyId}');

      // Send twice consecutively
      await InviteService.handleIncomingUri(uri);
      await InviteService.handleIncomingUri(uri);

      // Only handled once
      expect(deepLinkCount, equals(1));
    });
  });
}
