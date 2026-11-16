/// Centralized application constants including storage keys, currency codes, and metadata.
class AppConstants {
  AppConstants._();

  // Application Metadata
  static const String appName = 'TTMM Club';
  static const String appFullName = 'The Trusted Money Management Club';
  static const String appTagline = 'SPLIT · TRACK · SETTLE';

  // Currency
  static const String currencySymbol = '₹';
  static const String defaultCurrencyCode = 'INR';

  // Offline SharedPreferences Keys
  static const String keyHasCompletedOnboarding = 'has_completed_onboarding';
  static const String keyIsLoggedInWithGoogle = 'is_logged_in_with_google';
  static const String keyUserProfileName = 'user_profile_name';
  static const String keyUserProfileEmail = 'user_profile_email';
  static const String keyUserProfilePhone = 'user_profile_phone';
  static const String keyUserProfileAvatarUrl = 'user_profile_avatar_url';
  static const String keyUserProfileAvatarIndex = 'user_profile_avatar_index';
  static const String keyPendingInviteStoryId = 'pending_invite_story_id';
  static const String keyPendingInviteUrl = 'pending_invite_url';
  static const String keySavedStories = 'saved_stories_key';
  static const String keySavedFriends = 'saved_friends_key';
  static const String keySavedActivities = 'saved_activities_key';

  // Fallback defaults
  static const String defaultUserName = 'Friend';
  static const String defaultUserGuestId = 'user_guest';
}
