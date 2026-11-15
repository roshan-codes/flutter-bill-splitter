import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/core/services/supabase_service.dart';
import 'package:flutter_bill_splitter/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:flutter_bill_splitter/features/profile/presentation/screens/profile_tab.dart';
import 'package:flutter_bill_splitter/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:flutter_bill_splitter/features/onboarding/presentation/screens/onboarding_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    await StorageService.instance.clear();
  });

  group('Profile and Authentication Gates', () {
    testWidgets('ProfileAvatar displays name, email, and phone', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileAvatar(
              name: 'John Doe',
              email: 'john.doe@example.com',
              phone: '+1 555-0199',
            ),
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john.doe@example.com'), findsOneWidget);
      expect(find.text('+1 555-0199'), findsOneWidget);
    });

    testWidgets('SplashScreen routes unauthenticated users to OnboardingScreen',
        (tester) async {
      await StorageService.instance.setBool('has_completed_onboarding', true);

      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(
            autoNavigate: true,
            duration: Duration(milliseconds: 100),
          ),
        ),
      );

      // Advance timer past duration and animation
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 600));

      // Should be on OnboardingScreen because SupabaseService.isSignedIn is false
      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    test('SupabaseService.updateUserAvatarInDb handles gracefully when unauthenticated',
        () async {
      final res = await SupabaseService.updateUserAvatarInDb(avatarIndex: 2);
      expect(res, isFalse);
    });

    testWidgets('ProfileTab renders with resolved user email when set in storage',
        (tester) async {
      await StorageService.instance
          .setString('user_profile_name', 'Verified User');
      await StorageService.instance
          .setString('user_profile_email', 'verified@supabase.io');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileTab(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Verified User'), findsOneWidget);
      expect(find.text('verified@supabase.io'), findsOneWidget);
    });
  });
}
