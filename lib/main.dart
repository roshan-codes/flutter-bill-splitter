import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/core/services/supabase_service.dart';
import 'package:flutter_bill_splitter/features/activity/data/repositories/activity_repository.dart';
import 'package:flutter_bill_splitter/features/friends/data/repositories/friends_repository.dart';
import 'package:flutter_bill_splitter/features/stories/data/repositories/story_repository.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';
import 'app/app.dart';

export 'app/app.dart';
export 'package:supabase_flutter/supabase_flutter.dart';
export 'core/services/storage_service.dart';
export 'core/services/supabase_service.dart';
export 'shared/widgets/platform_adaptive.dart';
export 'features/friends/domain/models/friend.dart';
export 'features/friends/domain/models/group.dart';
export 'features/friends/data/repositories/friends_repository.dart';
export 'features/stories/domain/models/story.dart';
export 'features/stories/data/repositories/story_repository.dart';
export 'features/navigation/presentation/screens/main_screen.dart';
export 'features/stories/presentation/screens/create_story_screen.dart';
export 'features/expenses/presentation/screens/split_detail_screen.dart';
export 'features/expenses/presentation/screens/split_summary_screen.dart';
export 'features/expenses/domain/models/settlement_transaction.dart';
export 'features/expenses/domain/services/expense_calculator.dart';
export 'features/activity/domain/models/split_activity.dart';
export 'features/activity/domain/models/activity_display_item.dart';
export 'features/activity/data/repositories/activity_repository.dart';
export 'features/activity/presentation/screens/activity_tab.dart';
export 'features/home/presentation/screens/home_tab.dart';
export 'features/profile/presentation/screens/profile_tab.dart';
export 'features/onboarding/presentation/screens/splash_screen.dart';
export 'features/onboarding/presentation/screens/onboarding_screen.dart';
export 'features/stories/presentation/screens/join_story_screen.dart';
export 'core/routing/app_auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Production error logging & crash boundary
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Uncaught Flutter Error: ${details.exceptionAsString()}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught Platform Error: $error');
    return true; // Prevents crash propagation
  };

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Supabase backend
  await SupabaseService.init();

  // Initialize offline storage and clean up obsolete local story/activity cache
  await StorageService.instance.init();
  await StorageService.instance.remove('saved_stories_key');
  await StorageService.instance.remove('split_activities_key');

  Story.currentUserNameResolver = () {
    return SupabaseService.userDisplayName ??
        StorageService.instance.getStringSync('user_profile_name');
  };

  await ActivityRepository.instance.init();
  await FriendsRepository.instance.init();
  await StoryRepository.instance.init();

  runApp(const MyApp());
}
