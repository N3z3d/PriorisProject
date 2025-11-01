import 'package:shared_preferences/shared_preferences.dart';

/// Metadata describing a signup attempt characteristics.
class SignupAttemptMetadata {
  final DateTime? startedAt;
  final bool honeypotFilled;

  const SignupAttemptMetadata({
    this.startedAt,
    this.honeypotFilled = false,
  });

  SignupAttemptMetadata copyWith({
    DateTime? startedAt,
    bool? honeypotFilled,
  }) {
    return SignupAttemptMetadata(
      startedAt: startedAt ?? this.startedAt,
      honeypotFilled: honeypotFilled ?? this.honeypotFilled,
    );
  }
}

/// Exception raised when the signup flow should be throttled.
class SignupThrottledException implements Exception {
  final Duration retryAfter;
  final String message;

  SignupThrottledException(this.retryAfter, this.message);

  @override
  String toString() => message;
}

/// Guard responsible for throttling signup attempts.
class SignupGuard {
  SignupGuard._();

  static final SignupGuard instance = SignupGuard._();

  static const _attemptCountKey = 'signup_guard_attempt_count';
  static const _windowStartKey = 'signup_guard_window_start';
  static const _lastAttemptKey = 'signup_guard_last_attempt';

  static const Duration _attemptWindow = Duration(minutes: 1);
  static const int _maxAttemptsInWindow = 3;
  static const Duration _minFormDuration = Duration(seconds: 2);
  static const Duration _honeypotPenalty = Duration(minutes: 10);

  Future<void> ensureCanSignUp(SignupAttemptMetadata metadata) async {
    final now = DateTime.now();

    if (metadata.honeypotFilled) {
      throw SignupThrottledException(
        _honeypotPenalty,
        'Tentative suspecte detectee. Reessayez plus tard.',
      );
    }

    if (metadata.startedAt != null) {
      final elapsed = now.difference(metadata.startedAt!);
      if (elapsed < _minFormDuration) {
        final remaining = _minFormDuration - elapsed;
        throw SignupThrottledException(
          remaining,
          'Formulaire soumis trop rapidement. Reessayez dans ${remaining.inSeconds}s.',
        );
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final windowStartMillis = prefs.getInt(_windowStartKey);
    var attempts = prefs.getInt(_attemptCountKey) ?? 0;

    DateTime windowStart;
    if (windowStartMillis == null) {
      windowStart = now;
    } else {
      windowStart = DateTime.fromMillisecondsSinceEpoch(windowStartMillis);
      if (now.difference(windowStart) > _attemptWindow) {
        windowStart = now;
        attempts = 0;
      }
    }

    if (attempts >= _maxAttemptsInWindow) {
      final retryAfter = _attemptWindow - now.difference(windowStart);
      final safeDelay = retryAfter.isNegative ? Duration.zero : retryAfter;
      throw SignupThrottledException(
        safeDelay,
        'Trop de tentatives. Reessayez dans ${safeDelay.inSeconds}s.',
      );
    }

    attempts += 1;
    await prefs.setInt(_attemptCountKey, attempts);
    await prefs.setInt(_windowStartKey, windowStart.millisecondsSinceEpoch);
    await prefs.setInt(_lastAttemptKey, now.millisecondsSinceEpoch);
  }

  Future<void> recordSuccessfulSignup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_attemptCountKey);
    await prefs.remove(_windowStartKey);
    await prefs.remove(_lastAttemptKey);
  }

  Future<void> resetCounters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_attemptCountKey);
    await prefs.remove(_windowStartKey);
    await prefs.remove(_lastAttemptKey);
  }
}
