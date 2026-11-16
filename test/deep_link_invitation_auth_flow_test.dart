import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
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

class _FakeHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _FakeHttpClient();
  }
}

class _FakeHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;

  @override
  bool autoUncompress = true;
  @override
  Duration? connectionTimeout;
  @override
  Duration idleTimeout = const Duration(seconds: 15);
  @override
  int? maxConnectionsPerHost;
  @override
  String? userAgent;

  @override
  void addCredentials(Uri url, String realm, HttpClientCredentials credentials) {}
  @override
  void addProxyCredentials(String host, int port, String realm, HttpClientCredentials credentials) {}
  @override
  set authenticate(Future<bool> Function(Uri url, String scheme, String? realm)? f) {}
  @override
  set authenticateProxy(Future<bool> Function(String host, int port, String scheme, String? realm)? f) {}
  @override
  set badCertificateCallback(bool Function(X509Certificate cert, String host, int port)? callback) {}
  @override
  void close({bool force = false}) {}
  @override
  Future<HttpClientRequest> delete(String host, int port, String path) => openUrl('DELETE', Uri(scheme: 'http', host: host, port: port, path: path));
  @override
  Future<HttpClientRequest> deleteUrl(Uri url) => openUrl('DELETE', url);
  @override
  set findProxy(String Function(Uri url)? f) {}
  @override
  Future<HttpClientRequest> get(String host, int port, String path) => openUrl('GET', Uri(scheme: 'http', host: host, port: port, path: path));
  @override
  Future<HttpClientRequest> getUrl(Uri url) => openUrl('GET', url);
  @override
  Future<HttpClientRequest> head(String host, int port, String path) => openUrl('HEAD', Uri(scheme: 'http', host: host, port: port, path: path));
  @override
  Future<HttpClientRequest> headUrl(Uri url) => openUrl('HEAD', url);
  @override
  Future<HttpClientRequest> open(String method, String host, int port, String path) => openUrl(method, Uri(scheme: 'http', host: host, port: port, path: path));
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async => _FakeHttpClientRequest();
  @override
  Future<HttpClientRequest> patch(String host, int port, String path) => openUrl('PATCH', Uri(scheme: 'http', host: host, port: port, path: path));
  @override
  Future<HttpClientRequest> patchUrl(Uri url) => openUrl('PATCH', url);
  @override
  Future<HttpClientRequest> post(String host, int port, String path) => openUrl('POST', Uri(scheme: 'http', host: host, port: port, path: path));
  @override
  Future<HttpClientRequest> postUrl(Uri url) => openUrl('POST', url);
  @override
  Future<HttpClientRequest> put(String host, int port, String path) => openUrl('PUT', Uri(scheme: 'http', host: host, port: port, path: path));
  @override
  Future<HttpClientRequest> putUrl(Uri url) => openUrl('PUT', url);
}

class _FakeHttpClientRequest implements HttpClientRequest {
  @override
  final HttpHeaders headers = _FakeHttpHeaders();
  @override
  bool bufferOutput = true;
  @override
  int contentLength = 0;
  @override
  Encoding encoding = utf8;
  @override
  bool followRedirects = true;
  @override
  int maxRedirects = 5;
  @override
  bool persistentConnection = true;

  @override
  void add(List<int> data) {}
  @override
  void addError(Object error, [StackTrace? stackTrace]) {}
  @override
  Future addStream(Stream<List<int>> stream) => Future.value();
  @override
  Future<HttpClientResponse> close() async => _FakeHttpClientResponse();
  @override
  HttpConnectionInfo? get connectionInfo => null;
  @override
  List<Cookie> get cookies => [];
  @override
  Future<HttpClientResponse> get done => Future.value(_FakeHttpClientResponse());
  @override
  Future flush() => Future.value();
  @override
  String get method => 'GET';
  @override
  Uri get uri => Uri.parse('http://example.com');
  @override
  void write(Object? object) {}
  @override
  void writeAll(Iterable objects, [String separator = ""]) {}
  @override
  void writeCharCode(int charCode) {}
  @override
  void writeln([Object? object = ""]) {}
  @override
  void abort([Object? exception, StackTrace? stackTrace]) {}
}

class _FakeHttpHeaders implements HttpHeaders {
  final Map<String, List<String>> _headers = {};
  @override
  List<String>? operator [](String name) => _headers[name];
  @override
  void add(String name, Object value, {bool? preserveHeaderCase}) {
    _headers.putIfAbsent(name, () => []).add(value.toString());
  }
  @override
  void clear() => _headers.clear();
  @override
  void forEach(void Function(String name, List<String> values) action) {
    _headers.forEach(action);
  }
  @override
  void noFolding(String name) {}
  @override
  void remove(String name, Object value) {
    _headers[name]?.remove(value.toString());
  }
  @override
  void removeAll(String name) => _headers.remove(name);
  @override
  void set(String name, Object value, {bool? preserveHeaderCase}) {
    _headers[name] = [value.toString()];
  }
  @override
  String? value(String name) => _headers[name]?.first;
  @override
  bool chunkedTransferEncoding = false;
  @override
  int contentLength = 0;
  @override
  ContentType? contentType;
  @override
  DateTime? date;
  @override
  DateTime? expires;
  @override
  String? host;
  @override
  DateTime? ifModifiedSince;
  @override
  bool persistentConnection = true;
  @override
  int? port;
}

class _FakeHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  static final _kTransparentImage = Uint8List.fromList(<int>[
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
    0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
    0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
    0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
    0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
    0x42, 0x60, 0x82,
  ]);

  @override
  int get statusCode => 200;
  @override
  int get contentLength => _kTransparentImage.length;
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.value(_kTransparentImage).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
  @override
  X509Certificate? get certificate => null;
  @override
  HttpConnectionInfo? get connectionInfo => null;
  @override
  List<Cookie> get cookies => [];
  @override
  Future<Socket> detachSocket() => throw UnimplementedError();
  @override
  HttpHeaders get headers => _FakeHttpHeaders();
  @override
  bool get isRedirect => false;
  @override
  String get reasonPhrase => 'OK';
  @override
  Future<HttpClientResponse> redirect([String? method, Uri? url, bool? followLoops]) =>
      throw UnimplementedError();
  @override
  List<RedirectInfo> get redirects => [];
  @override
  bool get persistentConnection => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    HttpOverrides.global = _FakeHttpOverrides();
  });

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
          .setString(AppConstants.keyUserProfileName, 'Priya');

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
          .setString(AppConstants.keyUserProfileName, 'Roshan');

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
