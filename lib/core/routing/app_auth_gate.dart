import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/services/invite_service.dart';
import 'package:flutter_bill_splitter/features/navigation/presentation/screens/main_screen.dart';
import 'package:flutter_bill_splitter/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter_bill_splitter/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:flutter_bill_splitter/features/stories/presentation/screens/join_story_screen.dart';

/// Centralized authentication-aware route guard and deep-link dispatcher.
///
/// Navigation Priority:
/// 1. App Initialization
/// 2. Authentication State Resolution
/// 3. Deep Link Resolution
/// 4. Appropriate Destination Screen
///
/// Crucially, NEVER navigates to Home Screen as the default initial route while
/// authentication is loading or when the user is unauthenticated.
class AppAuthGate extends StatefulWidget {
  final Widget? fallbackInitialScreen;

  const AppAuthGate({
    super.key,
    this.fallbackInitialScreen,
  });

  @override
  State<AppAuthGate> createState() => _AppAuthGateState();
}

class _AppAuthGateState extends State<AppAuthGate> {
  bool _initialized = false;
  bool _isAuthenticated = false;
  String? _pendingStoryId;

  @override
  void initState() {
    super.initState();
    _resolveAuthStateAndDeepLink();
  }

  Future<void> _resolveAuthStateAndDeepLink() async {
    InviteService.initDeepLinkListener();

    final initialUri = await InviteService.getInitialUri();
    String? deepLinkStoryId = InviteService.parseStoryIdFromUri(initialUri);
    deepLinkStoryId ??= InviteService.getInviteStoryIdFromUri();

    if (deepLinkStoryId != null && deepLinkStoryId.isNotEmpty) {
      await InviteService.savePendingInvite(
        deepLinkStoryId,
        originalUrl: initialUri?.toString(),
      );
    }

    final storedPendingStoryId = await InviteService.getPendingInvite();
    final effectiveStoryId = deepLinkStoryId ?? storedPendingStoryId;

    final authenticated = await InviteService.isUserAuthenticated();

    if (!mounted) return;

    setState(() {
      _isAuthenticated = authenticated;
      _pendingStoryId = effectiveStoryId;
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. App Initialization / Loading state (NEVER render Home Screen here)
    if (!_initialized) {
      return const SplashScreen(autoNavigate: false);
    }

    // 4. Appropriate Destination Screen based on authentication & invitation priority:
    if (!_isAuthenticated) {
      // Scenario 1: User is NOT logged in -> direct to Authentication screen immediately.
      // Home Screen is NEVER rendered before authentication!
      return OnboardingScreen(inviteStoryId: _pendingStoryId);
    }

    // Scenario 2: User is already logged in with an invitation -> direct to Join Story Screen!
    // Home Screen is NOT shown unnecessarily.
    if (_pendingStoryId != null && _pendingStoryId!.isNotEmpty) {
      return JoinStoryScreen(storyId: _pendingStoryId!);
    }

    // Authenticated user with no pending invitation
    return widget.fallbackInitialScreen ?? const MainScreen();
  }
}
