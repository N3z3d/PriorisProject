import 'dart:convert';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'web_auth_callback_platform_stub.dart'
    if (dart.library.html) 'web_auth_callback_platform_web.dart' as platform;

class WebAuthCallbackBrowserAdapter {
  const WebAuthCallbackBrowserAdapter();

  Uri? get currentUri => platform.readCurrentBrowserUri();

  Future<void> persistSession({
    required String storageKey,
    required String serializedSession,
  }) {
    return platform.persistBrowserSession(
      storageKey: storageKey,
      serializedSession: serializedSession,
    );
  }

  void replaceUrl(String url) {
    platform.replaceBrowserUrl(url);
  }
}

class WebAuthCallbackStabilizer {
  static const Set<String> _authSignalKeys = <String>{
    'code',
    'access_token',
    'refresh_token',
    'error',
    'error_description',
  };

  static const Set<String> _authPayloadKeys = <String>{
    'code',
    'type',
    'access_token',
    'refresh_token',
    'expires_in',
    'token_type',
    'provider_token',
    'provider_refresh_token',
    'error',
    'error_code',
    'error_description',
  };

  static Future<bool> stabilizeIfNeeded({
    required String supabaseUrl,
    required Session? session,
    WebAuthCallbackBrowserAdapter browserAdapter =
        const WebAuthCallbackBrowserAdapter(),
  }) async {
    final currentUri = browserAdapter.currentUri;
    if (currentUri == null || !isAuthCallbackUri(currentUri)) {
      return false;
    }

    if (!isSessionUsable(session)) {
      return false;
    }

    final storageKey = buildPersistedSessionStorageKey(supabaseUrl);
    final serializedSession = jsonEncode(session!.toJson());
    await browserAdapter.persistSession(
      storageKey: storageKey,
      serializedSession: serializedSession,
    );

    final sanitizedUri = stripAuthCallbackPayload(currentUri);
    browserAdapter.replaceUrl(sanitizedUri.toString());
    return true;
  }

  @visibleForTesting
  static String buildPersistedSessionStorageKey(String supabaseUrl) {
    final host = Uri.parse(supabaseUrl).host;
    final projectRef = host.split('.').first;
    return 'sb-$projectRef-auth-token';
  }

  @visibleForTesting
  static bool isSessionUsable(Session? session) {
    if (session == null) {
      return false;
    }

    if (session.accessToken.trim().isEmpty) {
      return false;
    }

    return !session.isExpired;
  }

  @visibleForTesting
  static bool isAuthCallbackUri(Uri uri) {
    if (_containsAuthSignal(uri.queryParameters)) {
      return true;
    }

    final fragmentParameters = _parseFragmentParameters(uri.fragment);
    if (fragmentParameters == null) {
      return false;
    }

    return _containsAuthSignal(fragmentParameters);
  }

  @visibleForTesting
  static Uri stripAuthCallbackPayload(Uri uri) {
    final filteredQueryParameters = Map<String, String>.from(uri.queryParameters)
      ..removeWhere((key, _) => _authPayloadKeys.contains(key));

    final fragmentParameters = _parseFragmentParameters(uri.fragment);
    final filteredFragment = _buildFilteredFragment(
      rawFragment: uri.fragment,
      fragmentParameters: fragmentParameters,
    );

    return uri.replace(
      queryParameters:
          filteredQueryParameters.isEmpty ? null : filteredQueryParameters,
      fragment: filteredFragment.isEmpty ? null : filteredFragment,
    );
  }

  static bool _containsAuthSignal(Map<String, String> parameters) {
    for (final key in _authSignalKeys) {
      final value = parameters[key];
      if (value != null && value.trim().isNotEmpty) {
        return true;
      }
    }

    return false;
  }

  static Map<String, String>? _parseFragmentParameters(String fragment) {
    if (fragment.trim().isEmpty ||
        (!fragment.contains('=') && !fragment.contains('&'))) {
      return null;
    }

    try {
      return Uri.splitQueryString(fragment);
    } on FormatException {
      return null;
    }
  }

  static String _buildFilteredFragment({
    required String rawFragment,
    required Map<String, String>? fragmentParameters,
  }) {
    if (rawFragment.isEmpty) {
      return '';
    }

    if (fragmentParameters == null) {
      return rawFragment;
    }

    final filteredFragmentParameters =
        Map<String, String>.from(fragmentParameters)
          ..removeWhere((key, _) => _authPayloadKeys.contains(key));

    if (filteredFragmentParameters.isEmpty) {
      return '';
    }

    return Uri(queryParameters: filteredFragmentParameters).query;
  }
}
