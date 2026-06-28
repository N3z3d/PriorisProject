import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/repositories/shared_preferences_onboarding_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SharedPreferencesOnboardingRepository', () {
    test('hasCompletedOnboarding retourne false initialement', () async {
      final repo = SharedPreferencesOnboardingRepository();
      expect(await repo.hasCompletedOnboarding(), isFalse);
    });

    test('markCompleted → hasCompletedOnboarding retourne true', () async {
      final repo = SharedPreferencesOnboardingRepository();
      await repo.markCompleted();
      expect(await repo.hasCompletedOnboarding(), isTrue);
    });

    test('markCompleted persiste entre instances', () async {
      await SharedPreferencesOnboardingRepository().markCompleted();
      expect(
        await SharedPreferencesOnboardingRepository().hasCompletedOnboarding(),
        isTrue,
      );
    });

    test('markCompleted est idempotent (double appel)', () async {
      final repo = SharedPreferencesOnboardingRepository();
      await repo.markCompleted();
      await repo.markCompleted();
      expect(await repo.hasCompletedOnboarding(), isTrue);
    });

    test('valeur pré-existante true est respectée', () async {
      SharedPreferences.setMockInitialValues({'onboarding_completed_v1': true});
      final repo = SharedPreferencesOnboardingRepository();
      expect(await repo.hasCompletedOnboarding(), isTrue);
    });
  });
}
