import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/infrastructure/services/web_auth_callback_stabilizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('WebAuthCallbackStabilizer', () {
    test('buildPersistedSessionStorageKey uses the Supabase project ref', () {
      final storageKey =
          WebAuthCallbackStabilizer.buildPersistedSessionStorageKey(
        'https://vgowxrktjzgwrfivtvse.supabase.co',
      );

      expect(storageKey, 'sb-vgowxrktjzgwrfivtvse-auth-token');
    });

    test('isAuthCallbackUri detects a PKCE callback query', () {
      final callbackUri = Uri.parse(
        'https://tests.prioris.app/auth/callback?code=pkce-code&type=signup',
      );

      expect(WebAuthCallbackStabilizer.isAuthCallbackUri(callbackUri), isTrue);
    });

    test('stripAuthCallbackPayload preserves unrelated query parameters', () {
      final callbackUri = Uri.parse(
        'https://tests.prioris.app/auth/callback?code=pkce-code&type=signup&next=lists',
      );

      final sanitizedUri =
          WebAuthCallbackStabilizer.stripAuthCallbackPayload(callbackUri);

      expect(
        sanitizedUri.toString(),
        'https://tests.prioris.app/auth/callback?next=lists',
      );
    });

    test('stripAuthCallbackPayload removes an auth-only query payload', () {
      final callbackUri = Uri.parse(
        'https://tests.prioris.app/auth/callback?code=pkce-code&type=signup',
      );

      final sanitizedUri =
          WebAuthCallbackStabilizer.stripAuthCallbackPayload(callbackUri);

      expect(
        sanitizedUri.toString(),
        'https://tests.prioris.app/auth/callback',
      );
    });

    test('stripAuthCallbackPayload removes auth tokens from fragment payload', () {
      final callbackUri = Uri.parse(
        'https://tests.prioris.app/auth/callback#access_token=token&refresh_token=refresh&tab=settings',
      );

      final sanitizedUri =
          WebAuthCallbackStabilizer.stripAuthCallbackPayload(callbackUri);

      expect(
        sanitizedUri.toString(),
        'https://tests.prioris.app/auth/callback#tab=settings',
      );
    });

    test('stripAuthCallbackPayload removes an auth-only fragment payload', () {
      final callbackUri = Uri.parse(
        'https://tests.prioris.app/auth/callback#access_token=token&refresh_token=refresh',
      );

      final sanitizedUri =
          WebAuthCallbackStabilizer.stripAuthCallbackPayload(callbackUri);

      expect(
        sanitizedUri.toString(),
        'https://tests.prioris.app/auth/callback',
      );
    });

    test('stabilizeIfNeeded persists a valid callback session and sanitizes URL',
        () async {
      final browserAdapter = _RecordingBrowserAdapter(
        currentUri: Uri.parse(
          'https://tests.prioris.app/auth/callback?code=pkce-code&type=signup&next=lists',
        ),
      );
      final session = _buildCallbackSession('callback@example.com');

      final stabilized = await WebAuthCallbackStabilizer.stabilizeIfNeeded(
        supabaseUrl: 'https://tests-prioris.supabase.co',
        session: session,
        browserAdapter: browserAdapter,
      );

      expect(stabilized, isTrue);
      expect(browserAdapter.persistedSessions, hasLength(1));
      expect(
        browserAdapter.persistedSessions.single.storageKey,
        'sb-tests-prioris-auth-token',
      );
      expect(
        browserAdapter.replacedUrls.single,
        'https://tests.prioris.app/auth/callback?next=lists',
      );

      final persistedJson = jsonDecode(
        browserAdapter.persistedSessions.single.serializedSession,
      ) as Map<String, dynamic>;
      expect(persistedJson['refresh_token'], 'refresh-callback@example.com');
      expect((persistedJson['user'] as Map<String, dynamic>)['email'],
          'callback@example.com');
    });

    test('stabilizeIfNeeded ignores non callback URLs', () async {
      final browserAdapter = _RecordingBrowserAdapter(
        currentUri: Uri.parse('https://tests.prioris.app/'),
      );

      final stabilized = await WebAuthCallbackStabilizer.stabilizeIfNeeded(
        supabaseUrl: 'https://tests-prioris.supabase.co',
        session: _buildCallbackSession('callback@example.com'),
        browserAdapter: browserAdapter,
      );

      expect(stabilized, isFalse);
      expect(browserAdapter.persistedSessions, isEmpty);
      expect(browserAdapter.replacedUrls, isEmpty);
    });

    test('stabilizeIfNeeded ignores unusable sessions', () async {
      final browserAdapter = _RecordingBrowserAdapter(
        currentUri: Uri.parse(
          'https://tests.prioris.app/auth/callback?code=pkce-code',
        ),
      );

      final stabilized = await WebAuthCallbackStabilizer.stabilizeIfNeeded(
        supabaseUrl: 'https://tests-prioris.supabase.co',
        session: null,
        browserAdapter: browserAdapter,
      );

      expect(stabilized, isFalse);
      expect(browserAdapter.persistedSessions, isEmpty);
      expect(browserAdapter.replacedUrls, isEmpty);
    });

    test(
        'stabilizeFromCurrentOrIncomingSessionIfNeeded exchanges a fresh PKCE callback and then sanitizes the URL',
        () async {
      final browserAdapter = _RecordingBrowserAdapter(
        currentUri: Uri.parse(
          'https://tests.prioris.app/auth/callback?code=pkce-code&type=signup&next=lists',
        ),
        storageItems: <String, String>{
          WebAuthCallbackStabilizer.prefixedPkceCodeVerifierStorageKey:
              '"raw-code-verifier"',
        },
      );
      final authStateController = StreamController<AuthState>();
      addTearDown(authStateController.close);
      Session? currentSession;
      Uri? exchangedUri;

      final future = WebAuthCallbackStabilizer
          .stabilizeFromCurrentOrIncomingSessionIfNeeded(
        supabaseUrl: 'https://tests-prioris.supabase.co',
        initialSession: null,
        currentSessionReader: () => currentSession,
        authStateChanges: authStateController.stream,
        exchangeSessionFromUrl: (uri) async {
          exchangedUri = uri;
          currentSession = _buildCallbackSession('delayed-callback@example.com');
          authStateController.add(
            AuthState(AuthChangeEvent.signedIn, currentSession),
          );
        },
        browserAdapter: browserAdapter,
        waitTimeout: const Duration(milliseconds: 100),
      );

      final stabilized = await future;

      expect(stabilized, isTrue);
      expect(exchangedUri, browserAdapter.currentUri);
      expect(browserAdapter.persistedSessions, hasLength(1));
      expect(
        browserAdapter.replacedUrls.single,
        'https://tests.prioris.app/auth/callback?next=lists',
      );
    });

    test(
        'stabilizeFromCurrentOrIncomingSessionIfNeeded also accepts the unprefixed PKCE verifier key',
        () async {
      final browserAdapter = _RecordingBrowserAdapter(
        currentUri: Uri.parse(
          'https://tests.prioris.app/auth/callback?code=pkce-code&type=signup',
        ),
        storageItems: <String, String>{
          WebAuthCallbackStabilizer.pkceCodeVerifierStorageKey:
              '"raw-code-verifier"',
        },
      );
      final authStateController = StreamController<AuthState>();
      addTearDown(authStateController.close);
      Session? currentSession;

      final stabilized = await WebAuthCallbackStabilizer
          .stabilizeFromCurrentOrIncomingSessionIfNeeded(
        supabaseUrl: 'https://tests-prioris.supabase.co',
        initialSession: null,
        currentSessionReader: () => currentSession,
        authStateChanges: authStateController.stream,
        exchangeSessionFromUrl: (_) async {
          currentSession = _buildCallbackSession('unprefixed@example.com');
          authStateController.add(
            AuthState(AuthChangeEvent.signedIn, currentSession),
          );
        },
        browserAdapter: browserAdapter,
        waitTimeout: const Duration(milliseconds: 100),
      );

      expect(stabilized, isTrue);
      expect(
        browserAdapter.replacedUrls.single,
        'https://tests.prioris.app/auth/callback',
      );
    });

    test(
        'stabilizeFromCurrentOrIncomingSessionIfNeeded sanitizes a stale callback by reusing the restored session when no PKCE verifier remains',
        () async {
      final browserAdapter = _RecordingBrowserAdapter(
        currentUri: Uri.parse(
          'https://tests.prioris.app/auth/callback?code=pkce-code&type=signup&next=lists',
        ),
      );
      final restoredSession = _buildCallbackSession('restored@example.com');
      var exchanged = false;

      final stabilized = await WebAuthCallbackStabilizer
          .stabilizeFromCurrentOrIncomingSessionIfNeeded(
        supabaseUrl: 'https://tests-prioris.supabase.co',
        initialSession: restoredSession,
        currentSessionReader: () => restoredSession,
        authStateChanges: const Stream<AuthState>.empty(),
        exchangeSessionFromUrl: (_) async {
          exchanged = true;
        },
        browserAdapter: browserAdapter,
        waitTimeout: const Duration(milliseconds: 10),
      );

      expect(stabilized, isTrue);
      expect(exchanged, isFalse);
      expect(browserAdapter.persistedSessions, hasLength(1));
      expect(
        browserAdapter.replacedUrls.single,
        'https://tests.prioris.app/auth/callback?next=lists',
      );
    });

    test(
        'stabilizeFromCurrentOrIncomingSessionIfNeeded sanitizes a stale callback without session when no PKCE verifier remains',
        () async {
      final browserAdapter = _RecordingBrowserAdapter(
        currentUri: Uri.parse(
          'https://tests.prioris.app/auth/callback?code=pkce-code&type=signup',
        ),
      );
      var exchanged = false;

      final stabilized = await WebAuthCallbackStabilizer
          .stabilizeFromCurrentOrIncomingSessionIfNeeded(
        supabaseUrl: 'https://tests-prioris.supabase.co',
        initialSession: null,
        currentSessionReader: () => null,
        authStateChanges: const Stream<AuthState>.empty(),
        exchangeSessionFromUrl: (_) async {
          exchanged = true;
        },
        browserAdapter: browserAdapter,
        waitTimeout: const Duration(milliseconds: 10),
      );

      expect(stabilized, isFalse);
      expect(exchanged, isFalse);
      expect(browserAdapter.persistedSessions, isEmpty);
      expect(
        browserAdapter.replacedUrls.single,
        'https://tests.prioris.app/auth/callback',
      );
    });
  });
}

class _RecordingBrowserAdapter extends WebAuthCallbackBrowserAdapter {
  _RecordingBrowserAdapter({
    required this.currentUri,
    this.storageItems = const <String, String>{},
  });

  @override
  final Uri? currentUri;

  final Map<String, String> storageItems;

  final List<_PersistedSessionRecord> persistedSessions =
      <_PersistedSessionRecord>[];
  final List<String> replacedUrls = <String>[];

  @override
  String? readStorageItem(String key) {
    return storageItems[key];
  }

  @override
  Future<void> persistSession({
    required String storageKey,
    required String serializedSession,
  }) async {
    persistedSessions.add(
      _PersistedSessionRecord(
        storageKey: storageKey,
        serializedSession: serializedSession,
      ),
    );
  }

  @override
  void replaceUrl(String url) {
    replacedUrls.add(url);
  }
}

class _PersistedSessionRecord {
  const _PersistedSessionRecord({
    required this.storageKey,
    required this.serializedSession,
  });

  final String storageKey;
  final String serializedSession;
}

Session _buildCallbackSession(String email) {
  final user = User(
    id: 'callback-${email.hashCode}',
    appMetadata: const <String, dynamic>{},
    userMetadata: const <String, dynamic>{},
    aud: 'authenticated',
    createdAt: DateTime(2024, 1, 1).toIso8601String(),
    email: email,
  );

  return Session(
    accessToken: 'opaque-callback-token-$email',
    tokenType: 'bearer',
    expiresIn: 3600,
    refreshToken: 'refresh-$email',
    user: user,
  );
}
