import 'package:supabase_flutter/supabase_flutter.dart';

/// Operation types for recording auth operations
enum AuthOperation {
  signUp,
  signInWithPassword,
  signOut,
  resetPasswordForEmail,
  updateUser,
  refreshSession,
  signInWithOAuth,
  getOAuthSignInUrl,
}

/// Recorded auth operation entry
class AuthOperationRecord {
  final AuthOperation operation;
  final DateTime timestamp;
  final Map<String, dynamic> parameters;
  final bool succeeded;

  AuthOperationRecord({
    required this.operation,
    required this.timestamp,
    required this.parameters,
    required this.succeeded,
  });

  @override
  String toString() =>
      '$operation(${parameters.keys.join(', ')}) - ${succeeded ? 'OK' : 'FAIL'}';
}

/// Deterministic fake GoTrueClient for auth testing
///
/// Features:
/// - Stable, deterministic tokens (no random generation)
/// - Configurable failure scenarios
/// - Operation journaling
/// - No real I/O or network calls
/// - ASCII + \uXXXX for error messages (no emojis)
class FakeGoTrueClient implements GoTrueClient {
  final Map<String, _FakeUser> _users = {};
  final List<AuthOperationRecord> _operationsLog = [];
  final Map<AuthOperation, bool> _failureConfig = {};

  Session? _currentSession;
  User? _currentUser;

  int _operationCount = 0;

  /// Get all recorded operations
  List<AuthOperationRecord> get operationsLog =>
      List.unmodifiable(_operationsLog);

  /// Get operation count
  int get operationCount => _operationCount;

  /// Clear all data and logs
  void clear() {
    _users.clear();
    _operationsLog.clear();
    _currentSession = null;
    _currentUser = null;
    _operationCount = 0;
  }

  /// Clear only operation logs (keep user data, session, and operation counter)
  void clearLogs() {
    _operationsLog.clear();
    // Note: DO NOT reset _operationCount - it's used for deterministic token generation
  }

  /// Configure operation to fail
  void setOperationFailure(AuthOperation operation, bool shouldFail) {
    _failureConfig[operation] = shouldFail;
  }

  bool _shouldFail(AuthOperation operation) {
    return _failureConfig[operation] ?? false;
  }

  void _record(
      AuthOperation operation, Map<String, dynamic> parameters, bool succeeded) {
    _operationsLog.add(AuthOperationRecord(
      operation: operation,
      timestamp: DateTime.now(),
      parameters: parameters,
      succeeded: succeeded,
    ));
    _operationCount++;
  }

  /// Generate deterministic token based on user ID
  String _generateToken(String userId, {bool isRefresh = false}) {
    final prefix = isRefresh ? 'refresh' : 'access';
    final counter = _operationCount.toString().padLeft(4, '0');
    return 'fake_${prefix}_token_${userId}_$counter';
  }

  /// Generate deterministic user from email
  User _createUser(String email, {String? fullName}) {
    final userId = 'user_${email.split('@').first}';
    final now = DateTime.now();

    return User(
      id: userId,
      appMetadata: {},
      userMetadata: fullName != null ? {'full_name': fullName} : {},
      aud: 'authenticated',
      createdAt: now.toIso8601String(),
      email: email,
    );
  }

  /// Generate deterministic session
  Session _createSession(User user) {
    final now = DateTime.now();
    final expiresIn = 3600; // 1 hour
    final expiresAt = (now.millisecondsSinceEpoch / 1000).round() + expiresIn;

    // Create Session via fromJson
    final sessionJson = {
      'access_token': _generateToken(user.id),
      'token_type': 'bearer',
      'expires_in': expiresIn,
      'refresh_token': _generateToken(user.id, isRefresh: true),
      'user': {
        'id': user.id,
        'app_metadata': user.appMetadata,
        'user_metadata': user.userMetadata,
        'aud': user.aud,
        'created_at': user.createdAt,
        if (user.email != null) 'email': user.email,
      },
    };

    final session = Session.fromJson(sessionJson)!;

    // Manually set expiresAt (Session tries to parse it from JWT, but our tokens aren't real JWTs)
    session.expiresAt = expiresAt;

    return session;
  }

  @override
  Future<AuthResponse> signUp({
    String? email,
    String? phone,
    String? password,
    String? emailRedirectTo,
    Map<String, dynamic>? data,
    String? captchaToken,
    OtpChannel? channel,
  }) async {
    final shouldFail = _shouldFail(AuthOperation.signUp);

    // Check for natural failures first (before recording)
    if (email == null || password == null) {
      _record(
        AuthOperation.signUp,
        {
          'email': email,
          'phone': phone,
          'hasPassword': password != null,
          'data': data,
        },
        false,
      );
      throw Exception('Email and password required for signup');
    }

    if (_users.containsKey(email)) {
      _record(
        AuthOperation.signUp,
        {
          'email': email,
          'phone': phone,
          'hasPassword': password != null,
          'data': data,
        },
        false,
      );
      throw Exception('User already exists: $email');
    }

    // Record operation
    _record(
      AuthOperation.signUp,
      {
        'email': email,
        'phone': phone,
        'hasPassword': password != null,
        'data': data,
      },
      !shouldFail,
    );

    // Check for configured failure
    if (shouldFail) {
      throw Exception('signUp failure (deterministic)');
    }

    final user = _createUser(email, fullName: data?['full_name']);
    final session = _createSession(user);

    _users[email] = _FakeUser(user: user, password: password);
    _currentUser = user;
    _currentSession = session;

    return AuthResponse(session: session, user: user);
  }

  @override
  Future<AuthResponse> signInWithPassword({
    String? email,
    String? phone,
    required String password,
    String? captchaToken,
  }) async {
    final shouldFail = _shouldFail(AuthOperation.signInWithPassword);

    // Check for natural failures first
    if (email == null || password.isEmpty) {
      _record(
        AuthOperation.signInWithPassword,
        {
          'email': email,
          'phone': phone,
          'hasPassword': password.isNotEmpty,
        },
        false,
      );
      throw Exception('Email and password required for sign in');
    }

    final fakeUser = _users[email];
    if (fakeUser == null) {
      _record(
        AuthOperation.signInWithPassword,
        {
          'email': email,
          'phone': phone,
          'hasPassword': password.isNotEmpty,
        },
        false,
      );
      throw Exception('Invalid credentials: user not found');
    }

    if (fakeUser.password != password) {
      _record(
        AuthOperation.signInWithPassword,
        {
          'email': email,
          'phone': phone,
          'hasPassword': password.isNotEmpty,
        },
        false,
      );
      throw Exception('Invalid credentials: incorrect password');
    }

    // Record operation
    _record(
      AuthOperation.signInWithPassword,
      {
        'email': email,
        'phone': phone,
        'hasPassword': password.isNotEmpty,
      },
      !shouldFail,
    );

    // Check for configured failure
    if (shouldFail) {
      throw Exception('signInWithPassword failure (deterministic)');
    }

    final session = _createSession(fakeUser.user);
    _currentUser = fakeUser.user;
    _currentSession = session;

    return AuthResponse(session: session, user: fakeUser.user);
  }

  @override
  Future<void> signOut({SignOutScope scope = SignOutScope.global}) async {
    final succeeded = !_shouldFail(AuthOperation.signOut);
    _record(
      AuthOperation.signOut,
      {'scope': scope.toString()},
      succeeded,
    );

    if (!succeeded) {
      throw Exception('signOut failure (deterministic)');
    }

    _currentUser = null;
    _currentSession = null;
  }

  @override
  Future<void> resetPasswordForEmail(
    String email, {
    String? redirectTo,
    String? captchaToken,
  }) async {
    final succeeded = !_shouldFail(AuthOperation.resetPasswordForEmail);
    _record(
      AuthOperation.resetPasswordForEmail,
      {'email': email, 'redirectTo': redirectTo},
      succeeded,
    );

    if (!succeeded) {
      throw Exception('resetPasswordForEmail failure (deterministic)');
    }

    if (!_users.containsKey(email)) {
      // Silent failure per Supabase behavior (security)
      return;
    }
  }

  @override
  Future<UserResponse> updateUser(
    UserAttributes attributes, {
    String? emailRedirectTo,
  }) async {
    final succeeded = !_shouldFail(AuthOperation.updateUser);
    _record(
      AuthOperation.updateUser,
      {'data': attributes.data},
      succeeded,
    );

    if (!succeeded) {
      throw Exception('updateUser failure (deterministic)');
    }

    if (_currentUser == null) {
      throw Exception('No authenticated user');
    }

    // Update user metadata
    final updatedMetadata = Map<String, dynamic>.from(_currentUser!.userMetadata ?? {});
    if (attributes.data != null) {
      // Cast Object to Map<String, dynamic>
      final dataMap = attributes.data as Map<String, dynamic>?;
      if (dataMap != null) {
        updatedMetadata.addAll(dataMap);
      }
    }

    final updatedUser = User(
      id: _currentUser!.id,
      appMetadata: _currentUser!.appMetadata,
      userMetadata: updatedMetadata,
      aud: _currentUser!.aud,
      createdAt: _currentUser!.createdAt,
      email: _currentUser!.email,
    );

    _currentUser = updatedUser;

    // Update stored user
    for (final entry in _users.entries) {
      if (entry.value.user.id == updatedUser.id) {
        _users[entry.key] = _FakeUser(
          user: updatedUser,
          password: entry.value.password,
        );
        break;
      }
    }

    // Create UserResponse from JSON (UserResponse only has fromJson constructor)
    final userJson = {
      'id': updatedUser.id,
      'app_metadata': updatedUser.appMetadata,
      'user_metadata': updatedUser.userMetadata,
      'aud': updatedUser.aud,
      'created_at': updatedUser.createdAt,
      if (updatedUser.email != null) 'email': updatedUser.email,
    };
    return UserResponse.fromJson(userJson);
  }

  @override
  Future<AuthResponse> refreshSession([String? refreshToken]) async {
    final succeeded = !_shouldFail(AuthOperation.refreshSession);
    _record(
      AuthOperation.refreshSession,
      {'hasSession': _currentSession != null, 'refreshToken': refreshToken},
      succeeded,
    );

    if (!succeeded) {
      throw Exception('refreshSession failure (deterministic)');
    }

    if (_currentSession == null || _currentUser == null) {
      throw Exception('No session to refresh');
    }

    final newSession = _createSession(_currentUser!);
    _currentSession = newSession;

    return AuthResponse(session: newSession, user: _currentUser);
  }

  @override
  Future<bool> signInWithOAuth(
    OAuthProvider provider, {
    String? redirectTo,
    String? scopes,
    Map<String, String>? queryParams,
  }) async {
    final succeeded = !_shouldFail(AuthOperation.signInWithOAuth);
    _record(
      AuthOperation.signInWithOAuth,
      {
        'provider': provider.toString(),
        'redirectTo': redirectTo,
        'scopes': scopes,
      },
      succeeded,
    );

    if (!succeeded) {
      throw Exception('signInWithOAuth failure (deterministic)');
    }

    return true;
  }

  @override
  Future<OAuthResponse> getOAuthSignInUrl({
    required OAuthProvider provider,
    String? redirectTo,
    String? scopes,
    Map<String, String>? queryParams,
  }) async {
    final succeeded = !_shouldFail(AuthOperation.getOAuthSignInUrl);
    _record(
      AuthOperation.getOAuthSignInUrl,
      {
        'provider': provider.toString(),
        'redirectTo': redirectTo,
        'scopes': scopes,
      },
      succeeded,
    );

    if (!succeeded) {
      throw Exception('getOAuthSignInUrl failure (deterministic)');
    }

    return OAuthResponse(
      provider: provider,
      url: 'https://fake-oauth.example.com/auth?provider=${provider.name}',
    );
  }

  @override
  User? get currentUser => _currentUser;

  @override
  Session? get currentSession => _currentSession;

  @override
  Stream<AuthState> get onAuthStateChange => Stream.empty();

  // Unimplemented methods (throw if called)
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'FakeGoTrueClient.${invocation.memberName} not implemented',
    );
  }
}

/// Internal user storage
class _FakeUser {
  final User user;
  final String password;

  _FakeUser({required this.user, required this.password});
}
