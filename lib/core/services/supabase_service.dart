import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized Supabase backend service for TTMM.
class SupabaseService {
  static const String supabaseUrl = 'https://hqfdwqrhtertpvlmwvsk.supabase.co';
  static const String supabasePublishableKey =
      'sb_publishable_E55yVbk-WsMaVFFi6BP50g_VCIXQOez';

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
    } catch (e) {
      debugPrint('Supabase init warning (running in offline/local mode): $e');
    }
  }
}
