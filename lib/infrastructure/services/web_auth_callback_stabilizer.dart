import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'web_auth_callback_platform_stub.dart'
    if (dart.library.html) 'web_auth_callback_platform_web.dart' as platform;

class WebAuthCallbackBrowserAdapter {
  const WebAuthCallbackBrowserAdapter();

  Uri? get currentUri => platform.readCurrentBrowserUri();

  String? readStorageItem(String key) {
    return platform.readBrowserStorageItem(key);
  }

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
  static const Duration _defaultSessionWaitTimeout = Duration(seconds: 5);
  static const String _sharedPreferencesWebPrefix = 'flutter.';
  static const String _pkceCodeVerifierStorageKey =
      'supabase.auth.token-code-verifier';

  /// Vrai si un callback d'authentification a été détecté au démarrage mais
  /// qu'aucune session n'a pu être établie (lien expiré, code déjà utilisé,
  /// ou navigateur différent de celui où le flux a été initié).
  /// Lu une seule fois par [LoginPage] pour afficher un message contextuel.
  static bool _callbackWithoutSession = false;

  /// Lit et réinitialise l'indicateur en une seule opération.
  /// À appeler une seule fois par [LoginPage] au démarrage.
  static bool consumeCallbackWithoutSession() {
    final value = _callbackWithoutSession;
    _callbackWithoutSession = false;
    return value;
  }

  @visibleForTesting
  static set callbackWithoutSession(bool value) {
    _callbackWithoutSession = value;
  }

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

  static Future<bool> stabilizeFromCurrentOrIncomingSessionIfNeeded({
    required String supabaseUrl,
    required Session? initialSession,
    required Session? Function() currentSessionReader,
    required Stream<AuthState> authStateChanges,
    required Future<void> Function(Uri uri) exchangeSessionFromUrl,
    WebAuthCallbackBrowserAdapter browserAdapter =
        const WebAuthCallbackBrowserAdapter(),
    Duration waitTimeout = _defaultSessionWaitTimeout,
  }) async {
    final currentUri = browserAdapter.currentUri;
    if (currentUri == null || !isAuthCallbackUri(currentUri)) {
      return false;
    }

    if (_hasPkceCodeVerifier(browserAdapter)) {
      return _exchangeAndStabilizeCallback(
        supabaseUrl: supabaseUrl,
        currentUri: currentUri,
        initialSession: initialSession,
        currentSessionReader: currentSessionReader,
        authStateChanges: authStateChanges,
        exchangeSessionFromUrl: exchangeSessionFromUrl,
        browserAdapter: browserAdapter,
        waitTimeout: waitTimeout,
      );
    }

    if (isSessionUsable(initialSession)) {
      return stabilizeIfNeeded(
        supabaseUrl: supabaseUrl,
        session: initialSession,
        browserAdapter: browserAdapter,
      );
    }

    _callbackWithoutSession = true;
    browserAdapter.replaceUrl(stripAuthCallbackPayload(currentUri).toString());
    return false;
  }

  static Future<bool> _exchangeAndStabilizeCallback({
    required String supabaseUrl,
    required Uri currentUri,
    required Session? initialSession,
    required Session? Function() currentSessionReader,
    required Stream<AuthState> authStateChanges,
    required Future<void> Function(Uri uri) exchangeSessionFromUrl,
    required WebAuthCallbackBrowserAdapter browserAdapter,
    required Duration waitTimeout,
  }) async {
    final incomingSessionFuture = authStateChanges
        .map((authState) => authState.session)
        .firstWhere(isSessionUsable)
        .timeout(waitTimeout);

    try {
      await exchangeSessionFromUrl(currentUri);
      final sessionToPersist = await _resolveExchangedSession(
        initialSession: initialSession,
        currentSessionReader: currentSessionReader,
        incomingSessionFuture: incomingSessionFuture,
      );
      return stabilizeIfNeeded(
        supabaseUrl: supabaseUrl,
        session: sessionToPersist,
        browserAdapter: browserAdapter,
      );
    } on TimeoutException {
      return _fallbackToExistingSessionOrSanitize(
        supabaseUrl: supabaseUrl,
        currentUri: currentUri,
        fallbackSession: currentSessionReader(),
        browserAdapter: browserAdapter,
      );
    } on StateError {
      return _fallbackToExistingSessionOrSanitize(
        supabaseUrl: supabaseUrl,
        currentUri: currentUri,
        fallbackSession: currentSessionReader(),
        browserAdapter: browserAdapter,
      );
    } catch (_) {
      return _fallbackToExistingSessionOrSanitize(
        supabaseUrl: supabaseUrl,
        currentUri: currentUri,
        fallbackSession: currentSessionReader(),
        browserAdapter: browserAdapter,
      );
    }
  }

  static Future<Session?> _resolveExchangedSession({
    required Session? initialSession,
    required Session? Function() currentSessionReader,
    required Future<Session?> incomingSessionFuture,
  }) async {
    final exchangedSession = currentSessionReader();
    if (_isNewUsableSessionAvailable(
      candidate: exchangedSession,
      baseline: initialSession,
    )) {
      return exchangedSession;
    }

    return incomingSessionFuture;
  }

  static Future<bool> _fallbackToExistingSessionOrSanitize({
    required String supabaseUrl,
    required Uri currentUri,
    required Session? fallbackSession,
    required WebAuthCallbackBrowserAdapter browserAdapter,
  }) async {
    if (isSessionUsable(fallbackSession)) {
      return stabilizeIfNeeded(
        supabaseUrl: supabaseUrl,
        session: fallbackSession,
        browserAdapter: browserAdapter,
      );
    }

    _callbackWithoutSession = true;
    browserAdapter.replaceUrl(stripAuthCallbackPayload(currentUri).toString());
    return false;
  }

  @visibleForTesting
  static String buildPersistedSessionStorageKey(String supabaseUrl) {
    final host = Uri.parse(supabaseUrl).host;
    final projectRef = host.split('.').first;
    return 'sb-$projectRef-auth-token';
  }

  @visibleForTesting
  static String get pkceCodeVerifierStorageKey => _pkceCodeVerifierStorageKey;

  @visibleForTesting
  static String get prefixedPkceCodeVerifierStorageKey =>
      '$_sharedPreferencesWebPrefix$_pkceCodeVerifierStorageKey';

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

  static bool _hasPkceCodeVerifier(
    WebAuthCallbackBrowserAdapter browserAdapter,
  ) {
    return _hasStoredValue(
          browserAdapter,
          _pkceCodeVerifierStorageKey,
        ) ||
        _hasStoredValue(
          browserAdapter,
          prefixedPkceCodeVerifierStorageKey,
        );
  }

  static bool _hasStoredValue(
    WebAuthCallbackBrowserAdapter browserAdapter,
    String key,
  ) {
    final rawValue = browserAdapter.readStorageItem(key);
    return rawValue != null && rawValue.trim().isNotEmpty;
  }

  static bool _isNewUsableSessionAvailable({
    required Session? candidate,
    required Session? baseline,
  }) {
    if (!isSessionUsable(candidate)) {
      return false;
    }

    if (!isSessionUsable(baseline)) {
      return true;
    }

    return candidate!.accessToken != baseline!.accessToken ||
        candidate.refreshToken != baseline.refreshToken ||
        candidate.user.id != baseline.user.id;
  }

  @visibleForTesting
  static bool isAuthCallbackUri(Uri uri) {
    if (_containsAuthSignal(uri.queryParameters)) {
      return true;
    }

    if (isSupabaseRouteLikeFragment(uri.fragment)) {
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
    final sanitizedUrl = StringBuffer()
      ..write(uri.scheme)
      ..write('://')
      ..write(uri.authority)
      ..write(uri.path);

    if (filteredQueryParameters.isNotEmpty) {
      sanitizedUrl
        ..write('?')
        ..write(Uri(queryParameters: filteredQueryParameters).query);
    }

    if (filteredFragment.isNotEmpty) {
      sanitizedUrl
        ..write('#')
        ..write(filteredFragment);
    }

    return Uri.parse(sanitizedUrl.toString());
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

  /// Retourne true si [fragment] correspond à un fragment Supabase route-like.
  /// [fragment] doit être pré-strippé : sans `#` initial. Ex: 'sb', 'sb-xxx', 'sb.xxx'.
  /// Appeler avec '#sb' retourne false — supprimer le '#' avant l'appel.
  static bool isSupabaseRouteLikeFragment(String fragment) {
    return fragment == 'sb' ||
        fragment.startsWith('sb-') ||
        fragment.startsWith('sb.');
  }

  static String _buildFilteredFragment({
    required String rawFragment,
    required Map<String, String>? fragmentParameters,
  }) {
    if (rawFragment.isEmpty) {
      return '';
    }

    if (isSupabaseRouteLikeFragment(rawFragment)) {
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
