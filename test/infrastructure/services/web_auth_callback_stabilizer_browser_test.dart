// ignore_for_file: depend_on_referenced_packages

@TestOn('browser')
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/infrastructure/services/web_auth_callback_stabilizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web/web.dart' as web;

void main() {
  group('WebAuthCallbackStabilizer browser contract', () {
    const supabaseUrl = 'https://tests-prioris.supabase.co';
    final storageKey =
        WebAuthCallbackStabilizer.buildPersistedSessionStorageKey(supabaseUrl);
    late Uri originalUri;

    setUp(() {
      originalUri = Uri.parse(web.window.location.href);
      web.window.localStorage.removeItem(storageKey);

      final callbackUri = originalUri.replace(
        path: '/auth/callback',
        queryParameters: const <String, String>{
          'code': 'browser-one-shot-code',
          'type': 'signup',
          'next': 'lists',
        },
        fragment: null,
      );

      web.window.history.replaceState(null, '', callbackUri.toString());
    });

    tearDown(() {
      web.window.localStorage.removeItem(storageKey);
      web.window.history.replaceState(null, '', originalUri.toString());
    });

    test(
        'persists callback session in browser storage and strips one-shot auth params',
        () async {
      final session = _buildBrowserSession();

      final stabilized = await WebAuthCallbackStabilizer.stabilizeIfNeeded(
        supabaseUrl: supabaseUrl,
        session: session,
      );

      expect(stabilized, isTrue);

      final storedSession = web.window.localStorage.getItem(storageKey);
      expect(storedSession, isNotNull);

      final storedJson = jsonDecode(storedSession!) as Map<String, dynamic>;
      expect(storedJson['refresh_token'], 'browser-refresh-token');
      expect(
        (storedJson['user'] as Map<String, dynamic>)['email'],
        'browser-callback@example.com',
      );

      final sanitizedUri = Uri.parse(web.window.location.href);
      expect(sanitizedUri.queryParameters['code'], isNull);
      expect(sanitizedUri.queryParameters['type'], isNull);
      expect(sanitizedUri.queryParameters['next'], 'lists');
      expect(sanitizedUri.fragment, isEmpty);
    });
  });
}

Session _buildBrowserSession() {
  final user = User(
    id: 'browser-callback-user',
    appMetadata: const <String, dynamic>{},
    userMetadata: const <String, dynamic>{},
    aud: 'authenticated',
    createdAt: DateTime(2024, 1, 1).toIso8601String(),
    email: 'browser-callback@example.com',
  );

  return Session(
    accessToken: 'browser-opaque-callback-token',
    tokenType: 'bearer',
    expiresIn: 3600,
    refreshToken: 'browser-refresh-token',
    user: user,
  );
}
