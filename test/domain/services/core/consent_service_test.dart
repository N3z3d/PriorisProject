import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/services/core/consent_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ConsentService', () {
    test('hasAcceptedConsent retourne false initialement', () async {
      final service = ConsentService();
      expect(await service.hasAcceptedConsent(), isFalse);
    });

    test('acceptConsent → hasAcceptedConsent retourne true', () async {
      final service = ConsentService();
      await service.acceptConsent();
      expect(await service.hasAcceptedConsent(), isTrue);
    });

    test('acceptConsent persiste entre instances (même SharedPreferences)', () async {
      await ConsentService().acceptConsent();
      expect(await ConsentService().hasAcceptedConsent(), isTrue);
    });

    test('consentContactEmail est non-vide', () {
      expect(ConsentService.consentContactEmail, isNotEmpty);
    });

    test('acceptConsent persiste la date de consentement', () async {
      final service = ConsentService();
      await service.acceptConsent();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('privacy_consent_date_v1'), isNotNull);
    });

    test('acceptConsent est idempotent (double appel)', () async {
      final service = ConsentService();
      await service.acceptConsent();
      await service.acceptConsent();
      expect(await service.hasAcceptedConsent(), isTrue);
    });
  });

  group('ConsentService.revokeConsent', () {
    test('revokeConsent → hasAcceptedConsent retourne false', () async {
      final service = ConsentService();
      await service.acceptConsent();
      await service.revokeConsent();
      expect(await service.hasAcceptedConsent(), isFalse);
    });

    test('revokeConsent supprime aussi la date de consentement', () async {
      final service = ConsentService();
      await service.acceptConsent();
      await service.revokeConsent();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('privacy_consent_date_v1'), isNull);
    });

    test('revokeConsent est idempotent (double appel ne lève pas)', () async {
      final service = ConsentService();
      await service.acceptConsent();
      await service.revokeConsent();
      await expectLater(service.revokeConsent(), completes);
    });

    test('revokeConsent sur prefs vides ne lève pas', () async {
      final service = ConsentService();
      await expectLater(service.revokeConsent(), completes);
      expect(await service.hasAcceptedConsent(), isFalse);
    });
  });
}
