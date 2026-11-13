import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_avatar_kit/flutter_avatar_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/features/profile/presentation/screens/profile_tab.dart';
import 'package:flutter_bill_splitter/features/profile/presentation/widgets/memo_avatar_picker_sheet.dart';
import 'package:flutter_bill_splitter/features/profile/presentation/widgets/profile_avatar.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
  });

  testWidgets('ProfileAvatar renders initial when avatarIndex is null', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileAvatar(
            name: 'Roshan Badwaik',
            phone: '+91 9876543210',
            initial: 'R',
          ),
        ),
      ),
    );

    expect(find.text('R'), findsOneWidget);
    expect(find.text('Roshan Badwaik'), findsOneWidget);
    expect(find.text('+91 9876543210'), findsOneWidget);
  });

  testWidgets('ProfileAvatar renders AvatarWidget when avatarIndex is provided', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileAvatar(
            name: 'Roshan Badwaik',
            phone: '+91 9876543210',
            initial: 'R',
            avatarIndex: 5,
          ),
        ),
      ),
    );

    expect(find.byType(AvatarWidget), findsOneWidget);
    expect(find.text('Roshan Badwaik'), findsOneWidget);
    expect(find.text('+91 9876543210'), findsOneWidget);
  });

  testWidgets('ProfileTab opens MemoAvatarPickerSheet and updates avatar', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileTab(),
        ),
      ),
    );

    // Initial state shows 'R'
    expect(find.text('R'), findsOneWidget);

    // Tap avatar to open sheet
    await tester.tap(find.text('R'));
    await tester.pumpAndSettle();

    // Verify bottom sheet is displayed with 35 memo avatars
    expect(find.byType(MemoAvatarPickerSheet), findsOneWidget);
    expect(find.text('Choose Avatar'), findsOneWidget);
    expect(find.text('Select a memo avatar for your profile'), findsOneWidget);
    expect(find.text('Set as Profile Avatar'), findsOneWidget);

    // Tap third avatar in grid
    final avatarWidgets = find.byType(AvatarWidget);
    expect(avatarWidgets, findsWidgets);
    await tester.tap(avatarWidgets.at(2));
    await tester.pumpAndSettle();

    // Tap 'Set as Profile Avatar'
    await tester.tap(find.text('Set as Profile Avatar'));
    await tester.pumpAndSettle();

    // Verify bottom sheet dismissed and ProfileAvatar displays selected memo avatar
    expect(find.byType(MemoAvatarPickerSheet), findsNothing);
    expect(find.byType(AvatarWidget), findsOneWidget);

    // Verify persisted in StorageService
    final savedIndex = await StorageService.instance.getInt('user_profile_avatar_index');
    expect(savedIndex, equals(2));
  });
}
