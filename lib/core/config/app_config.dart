/// Centralized application environment configuration.
class AppConfig {
  AppConfig._();

  /// Supabase project URL loaded from compile-time environment or default project endpoint.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://hqfdwqrhtertpvlmwvsk.supabase.co',
  );

  /// Supabase anon / publishable key loaded from compile-time environment or default.
  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_E55yVbk-WsMaVFFi6BP50g_VCIXQOez',
  );

  /// Supabase Cloud Storage bucket name for persistent attachments and story JSON backups.
  static const String storageBucket = 'app_data';

  /// Deep linking fallback host.
  static const String webHostedUrl = 'https://flutter-bill-splitter.onrender.com';
}
