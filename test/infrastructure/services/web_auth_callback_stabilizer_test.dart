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
  });
}

class _RecordingBrowserAdapter extends WebAuthCallbackBrowserAdapter {
  _RecordingBrowserAdapter({required this.currentUri});

  @override
  final Uri? currentUri;

  final List<_PersistedSessionRecord> persistedSessions =
      <_PersistedSessionRecord>[];
  final List<String> replacedUrls = <String>[];

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
