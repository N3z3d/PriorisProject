import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prioris/infrastructure/security/signup_guard.dart';

void main() {
  late SignupGuard guard;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    guard = SignupGuard.instance;
    await guard.resetCounters();
  });

  test('detects honeypot submission', () async {
    final metadata = const SignupAttemptMetadata(
      startedAt: null,
      honeypotFilled: true,
    );

    expect(
      () => guard.ensureCanSignUp(metadata),
      throwsA(isA<SignupThrottledException>()),
    );
  });

  test('requires minimal form dwell time', () async {
    final metadata = SignupAttemptMetadata(
      startedAt: DateTime.now(),
    );

    expect(
      () => guard.ensureCanSignUp(metadata),
      throwsA(isA<SignupThrottledException>()),
    );
  });

  test('limits number of attempts in window', () async {
    final now = DateTime.now().subtract(const Duration(seconds: 3));
    final validMetadata = SignupAttemptMetadata(startedAt: now);

    for (var i = 0; i < 3; i++) {
      await guard.ensureCanSignUp(validMetadata);
    }

    expect(
      () => guard.ensureCanSignUp(validMetadata),
      throwsA(isA<SignupThrottledException>()),
    );
  });
}
