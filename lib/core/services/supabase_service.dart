import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';
import 'package:flutter_bill_splitter/features/activity/domain/models/split_activity.dart';

/// Centralized Supabase backend service for TTMM.
/// Handles Authentication, Database sync, and Cloud Storage for stories, expenses, and files.
class SupabaseService {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://hqfdwqrhtertpvlmwvsk.supabase.co',
  );
  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_E55yVbk-WsMaVFFi6BP50g_VCIXQOez',
  );

  static const String storageBucket = 'app_data';

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  /// Supabase client instance (or null if not initialized).
  static SupabaseClient? get client {
    if (!_initialized) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Initialize Supabase connection.
  static Future<void> init() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabasePublishableKey,
      );
      _initialized = true;
      debugPrint('Supabase successfully initialized.');

      // Setup auth state listener to automatically sync profile data
      _setupAuthListener();
    } catch (e) {
      debugPrint('Supabase init warning (running in offline/local mode): $e');
    }
  }

  static void _setupAuthListener() {
    try {
      client?.auth.onAuthStateChange.listen((data) {
        if (data.session?.user != null) {
          syncLocalUserData().ignore();
        }
      });
    } catch (e) {
      debugPrint('Auth listener note: $e');
    }
  }

  /// Current authenticated user (or null).
  static User? get currentUser => client?.auth.currentUser;

  /// Whether a user is currently signed in.
  static bool get isSignedIn => currentUser != null;

  /// Retrieves the user's display name from Supabase user metadata or email.
  static String? get userDisplayName {
    final u = currentUser;
    if (u == null) return null;
    final meta = u.userMetadata;
    if (meta != null) {
      final fullName = meta['full_name'] ?? meta['name'];
      if (fullName is String && fullName.trim().isNotEmpty) {
        return fullName.trim();
      }
    }
    if (u.email != null && u.email!.isNotEmpty) {
      return u.email!.split('@').first;
    }
    return null;
  }

  /// Retrieves user contact info (phone or email).
  static String? get userContactInfo {
    final u = currentUser;
    if (u == null) return null;
    if (u.phone != null && u.phone!.trim().isNotEmpty) {
      return u.phone!.trim();
    }
    if (u.email != null && u.email!.trim().isNotEmpty) {
      return u.email!.trim();
    }
    return null;
  }

  /// Retrieves user avatar URL from Google OAuth metadata.
  static String? get userAvatarUrl {
    final u = currentUser;
    if (u == null) return null;
    final meta = u.userMetadata;
    if (meta != null) {
      final pic = meta['avatar_url'] ?? meta['picture'];
      if (pic is String && pic.trim().isNotEmpty) {
        return pic.trim();
      }
    }
    return null;
  }

  /// Retrieves user avatar index from Supabase user metadata.
  static int? get userAvatarIndex {
    final u = currentUser;
    if (u == null) return null;
    final meta = u.userMetadata;
    if (meta != null && meta['avatar_index'] != null) {
      final val = meta['avatar_index'];
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val);
    }
    return null;
  }

  /// Retrieves the authenticated user's email.
  static String? get userEmail => currentUser?.email;

  /// Updates user avatar in Supabase DB (Auth user metadata, profiles table, and Cloud Storage).
  static Future<bool> updateUserAvatarInDb({
    int? avatarIndex,
    String? avatarUrl,
  }) async {
    final u = currentUser;
    final cli = client;
    if (u == null || cli == null) {
      debugPrint('No Supabase authenticated user to update avatar.');
      return false;
    }

    try {
      // 1. Update in Supabase Auth User Metadata (persisted in Supabase auth.users DB)
      final metadata = <String, dynamic>{};
      if (avatarIndex != null) metadata['avatar_index'] = avatarIndex;
      if (avatarUrl != null) metadata['avatar_url'] = avatarUrl;

      await cli.auth.updateUser(
        UserAttributes(data: metadata),
      );
      debugPrint('Updated avatar in Supabase auth user_metadata.');

      // 2. Also upsert in 'profiles' table in Supabase Database
      try {
        await cli.from('profiles').upsert({
          'id': u.id,
          'email': u.email,
          'full_name': userDisplayName,
          if (avatarIndex != null) 'avatar_index': avatarIndex,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
          'updated_at': DateTime.now().toIso8601String(),
        });
        debugPrint('Updated avatar in Supabase "profiles" table.');
      } catch (dbErr) {
        debugPrint('Profiles table upsert note: $dbErr');
      }

      // 3. Upload avatar image binary to Supabase Cloud Storage bucket 'app_data'
      if (avatarIndex != null) {
        try {
          final assetPath = 'assets/avatars/memo_${(avatarIndex % 35) + 1}.png';
          final byteData = await rootBundle.load(assetPath);
          final bytes = byteData.buffer.asUint8List();
          final storagePath = 'avatars/${u.id}/avatar_$avatarIndex.png';
          await cli.storage.from(storageBucket).uploadBinary(
            storagePath,
            bytes,
            fileOptions:
                const FileOptions(upsert: true, contentType: 'image/png'),
          );
          final publicUrl =
              cli.storage.from(storageBucket).getPublicUrl(storagePath);
          await StorageService.instance
              .setString('user_profile_avatar_url', publicUrl);
          debugPrint('Avatar uploaded to Supabase Storage: $publicUrl');
        } catch (storageErr) {
          debugPrint('Storage avatar upload note: $storageErr');
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error updating avatar in DB: $e');
      return false;
    }
  }

  /// Synchronizes user data from Google/Supabase Auth to local storage and DB.
  static Future<void> syncLocalUserData() async {
    final name = userDisplayName;
    final contact = userContactInfo;
    final avatar = userAvatarUrl;
    final u = currentUser;

    if (name != null && name.isNotEmpty) {
      await StorageService.instance.setString('user_profile_name', name);
    }
    if (contact != null && contact.isNotEmpty) {
      await StorageService.instance.setString('user_profile_phone', contact);
    }
    if (u?.email != null && u!.email!.isNotEmpty) {
      await StorageService.instance.setString('user_profile_email', u.email!);
    }
    if (avatar != null && avatar.isNotEmpty) {
      await StorageService.instance.setString('user_profile_avatar_url', avatar);
    }

    await syncUserProfileToDb();
  }

  /// Upserts user profile in the Supabase 'profiles' table.
  static Future<void> syncUserProfileToDb() async {
    final u = currentUser;
    final cli = client;
    if (u == null || cli == null) return;

    try {
      await cli.from('profiles').upsert({
        'id': u.id,
        'full_name': userDisplayName,
        'email': u.email,
        'phone': u.phone,
        'avatar_url': userAvatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });
      debugPrint('User profile synced to Supabase "profiles" table.');
    } catch (e) {
      debugPrint('Supabase profile sync note: $e');
    }
  }

  /// Initiates Google OAuth Sign-In.
  static Future<bool> signInWithGoogle() async {
    try {
      final cli = client;
      if (cli == null) return false;

      return await cli.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'ttmm://login-callback',
      );
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      return false;
    }
  }

  /// Sends an SMS OTP to the provided phone number.
  static Future<void> signInWithPhoneOtp(String phone) async {
    final cli = client;
    if (cli == null) {
      throw Exception('Supabase connection unavailable.');
    }
    await cli.auth.signInWithOtp(phone: phone);
  }

  /// Verifies the phone SMS OTP code.
  static Future<bool> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    final cli = client;
    if (cli == null) return false;
    final res = await cli.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
    if (res.user != null) {
      await syncLocalUserData();
      return true;
    }
    return false;
  }

  /// Sign out current user.
  static Future<void> signOut() async {
    try {
      await client?.auth.signOut();
    } catch (e) {
      debugPrint('Sign-out error: $e');
    }
  }

  // =========================================================================
  // SUPABASE CLOUD STORAGE & DATABASE SYNC
  // =========================================================================

  /// Persists a Story to Supabase (Database table + Cloud Storage backup).
  static Future<bool> saveStory(Story story) async {
    final cli = client;
    if (cli == null) return false;

    bool savedToDb = false;
    bool savedToStorage = false;

    // 1. Save to Supabase Database Table ('stories')
    try {
      final userId = currentUser?.id ?? 'anonymous';
      await cli.from('stories').upsert({
        'story_id': story.storyId,
        'user_id': userId,
        'title': story.title,
        'description': story.description,
        'cover_emoji': story.coverEmoji,
        'currency': story.currency,
        'status': story.status,
        'created_by': story.createdBy,
        'created_at': story.createdAt,
        'data': story.toJson(),
      });
      savedToDb = true;
      debugPrint('Saved story "${story.title}" to Supabase database table.');
    } catch (e) {
      debugPrint('Supabase table upsert note: $e');
    }

    // 2. Save JSON backup to Supabase Cloud Storage bucket ('app_data')
    try {
      final userId = currentUser?.id ?? 'shared';
      final path = 'stories/$userId/${story.storyId}.json';
      final bytes =
          Uint8List.fromList(utf8.encode(jsonEncode(story.toJson())));

      await cli.storage.from(storageBucket).uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true, contentType: 'application/json'),
          );
      savedToStorage = true;
      debugPrint('Backed up story "${story.title}" to Supabase storage ($path).');
    } catch (e) {
      debugPrint('Supabase storage upload note: $e');
    }

    return savedToDb || savedToStorage;
  }

  /// Deletes a story from Supabase (Database table + Cloud Storage backup).
  static Future<bool> deleteStory(String storyId) async {
    final cli = client;
    if (cli == null) return false;

    bool deletedFromDb = false;
    bool deletedFromStorage = false;

    // 1. Delete from Supabase Database Table
    try {
      await cli.from('stories').delete().eq('story_id', storyId);
      deletedFromDb = true;
      debugPrint('Deleted story "$storyId" from Supabase database table.');
    } catch (e) {
      debugPrint('Supabase table delete note: $e');
    }

    try {
      await cli.from('activities').delete().eq('story_id', storyId);
    } catch (_) {}

    // 2. Delete JSON backup from Supabase Cloud Storage
    try {
      final userId = currentUser?.id ?? 'shared';
      final path = 'stories/$userId/$storyId.json';
      await cli.storage.from(storageBucket).remove([path]);
      deletedFromStorage = true;
      debugPrint('Deleted story "$storyId" from Supabase storage.');
    } catch (e) {
      debugPrint('Supabase storage remove note: $e');
    }

    return deletedFromDb || deletedFromStorage;
  }

  /// Fetches a specific Story by its unique ID (used for invite link joins).
  static Future<Story?> fetchStoryById(String storyId) async {
    final cli = client;
    if (cli == null) return null;

    try {
      final res = await cli
          .from('stories')
          .select()
          .eq('story_id', storyId)
          .maybeSingle();
      if (res != null && res['data'] != null) {
        final data = res['data'];
        if (data is Map<String, dynamic>) {
          return Story.fromJson(data);
        } else if (data is String) {
          return Story.fromJson(jsonDecode(data));
        }
      }
    } catch (e) {
      debugPrint('Supabase fetchStoryById table note: $e');
    }

    return null;
  }

  /// Fetches stories from Supabase (Database or Cloud Storage).
  static Future<List<Story>> fetchStories() async {
    final cli = client;
    if (cli == null) return [];

    // 1. Try querying Database table
    try {
      final userId = currentUser?.id;
      var query = cli.from('stories').select();
      if (userId != null) {
        query = query.or('user_id.eq.$userId,created_by.eq.$userId');
      }
      final response = await query.order('created_at', ascending: false);

      final List<Story> results = [];
      for (final item in response as List) {
        if (item is Map<String, dynamic> && item['data'] != null) {
          final data = item['data'];
          if (data is Map<String, dynamic>) {
            results.add(Story.fromJson(data));
          } else if (data is String) {
            results.add(Story.fromJson(jsonDecode(data)));
          }
        }
      }
      if (results.isNotEmpty) return results;
    } catch (e) {
      debugPrint('Supabase fetchStories table note: $e');
    }

    // 2. Fallback: read from Cloud Storage bucket
    try {
      final userId = currentUser?.id ?? 'shared';
      final files = await cli.storage.from(storageBucket).list(path: 'stories/$userId');
      final List<Story> storageResults = [];
      for (final file in files) {
        if (file.name.endsWith('.json')) {
          final data = await cli.storage
              .from(storageBucket)
              .download('stories/$userId/${file.name}');
          final jsonMap = jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
          storageResults.add(Story.fromJson(jsonMap));
        }
      }
      return storageResults;
    } catch (e) {
      debugPrint('Supabase storage fetch note: $e');
    }

    return [];
  }

  /// Persists a SplitActivity to Supabase.
  static Future<bool> saveActivity(SplitActivity activity) async {
    final cli = client;
    if (cli == null) return false;

    try {
      final userId = currentUser?.id ?? 'anonymous';
      await cli.from('activities').upsert({
        'id': activity.id,
        'user_id': userId,
        'group_name': activity.groupName,
        'total_amount': activity.totalAmount,
        'share_per_person': activity.sharePerPerson,
        'timestamp': activity.timestamp.toIso8601String(),
        'data': activity.toJson(),
      });
      return true;
    } catch (e) {
      debugPrint('Supabase saveActivity note: $e');
      return false;
    }
  }

  /// Uploads binary files (such as receipt images or user avatars) to Supabase Storage.
  static Future<String?> uploadFile({
    required String bucket,
    required String path,
    required Uint8List bytes,
    String? contentType,
  }) async {
    final cli = client;
    if (cli == null) return null;

    try {
      await cli.storage.from(bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(upsert: true, contentType: contentType),
          );
      return cli.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      debugPrint('Supabase uploadFile error: $e');
      return null;
    }
  }
}
