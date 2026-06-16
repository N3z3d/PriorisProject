import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/repositories/shared_preferences_consent_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SharedPreferencesConsentRepository', () {
    test('hasAcceptedConsent retourne false initialement', () async {
      final repo = SharedPreferencesConsentRepository();
      expect(await repo.hasAcceptedConsent(), isFalse);
    });

    test('acceptConsent → hasAcceptedConsent retourne true', () async {
      final repo = SharedPreferencesConsentRepository();
      await repo.acceptConsent();
      expect(await repo.hasAcceptedConsent(), isTrue);
    });

    test('acceptConsent persiste entre instances', () async {
      await SharedPreferencesConsentRepository().acceptConsent();
      expect(
        await SharedPreferencesConsentRepository().hasAcceptedConsent(),
        isTrue,
      );
    });

    test('acceptConsent enregistre la date', () async {
      final repo = SharedPreferencesConsentRepository();
      await repo.acceptConsent();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('privacy_consent_date_v1'), isNotNull);
    });

    test('acceptConsent est idempotent (double appel)', () async {
      final repo = SharedPreferencesConsentRepository();
      await repo.acceptConsent();
      await repo.acceptConsent();
      expect(await repo.hasAcceptedConsent(), isTrue);
    });

    test('revokeConsent → hasAcceptedConsent retourne false', () async {
      final repo = SharedPreferencesConsentRepository();
      await repo.acceptConsent();
      await repo.revokeConsent();
      expect(await repo.hasAcceptedConsent(), isFalse);
    });

    test('revokeConsent supprime la date de consentement', () async {
      final repo = SharedPreferencesConsentRepository();
      await repo.acceptConsent();
      await repo.revokeConsent();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('privacy_consent_date_v1'), isNull);
    });

    test('revokeConsent est idempotent (double appel ne lève pas)', () async {
      final repo = SharedPreferencesConsentRepository();
      await repo.acceptConsent();
      await repo.revokeConsent();
      await expectLater(repo.revokeConsent(), completes);
    });

    test('revokeConsent sur prefs vides ne lève pas', () async {
      final repo = SharedPreferencesConsentRepository();
      await expectLater(repo.revokeConsent(), completes);
      expect(await repo.hasAcceptedConsent(), isFalse);
    });
  });
}
