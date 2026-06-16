import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/ports/consent_repository.dart';
import 'package:prioris/domain/services/core/consent_service.dart';

class FakeConsentRepository implements IConsentRepository {
  bool _consent = false;

  @override
  Future<bool> hasAcceptedConsent() async => _consent;

  @override
  Future<void> acceptConsent() async {
    _consent = true;
  }

  @override
  Future<void> revokeConsent() async {
    _consent = false;
  }
}

class _ThrowingConsentRepository implements IConsentRepository {
  @override
  Future<bool> hasAcceptedConsent() => Future.error(Exception('repo error'));

  @override
  Future<void> acceptConsent() => Future.error(Exception('repo error'));

  @override
  Future<void> revokeConsent() => Future.error(Exception('repo error'));
}

void main() {
  group('ConsentService', () {
    test('hasAcceptedConsent retourne false initialement', () async {
      final service = ConsentService(FakeConsentRepository());
      expect(await service.hasAcceptedConsent(), isFalse);
    });

    test('acceptConsent → hasAcceptedConsent retourne true', () async {
      final service = ConsentService(FakeConsentRepository());
      await service.acceptConsent();
      expect(await service.hasAcceptedConsent(), isTrue);
    });

    test('acceptConsent est idempotent (double appel)', () async {
      final service = ConsentService(FakeConsentRepository());
      await service.acceptConsent();
      await service.acceptConsent();
      expect(await service.hasAcceptedConsent(), isTrue);
    });

    test('consentContactEmail est non-vide', () {
      expect(ConsentService.consentContactEmail, isNotEmpty);
    });
  });

  group('ConsentService.revokeConsent', () {
    test('revokeConsent → hasAcceptedConsent retourne false', () async {
      final service = ConsentService(FakeConsentRepository());
      await service.acceptConsent();
      await service.revokeConsent();
      expect(await service.hasAcceptedConsent(), isFalse);
    });

    test('revokeConsent est idempotent (double appel ne lève pas)', () async {
      final service = ConsentService(FakeConsentRepository());
      await service.acceptConsent();
      await service.revokeConsent();
      await expectLater(service.revokeConsent(), completes);
    });

    test('revokeConsent sur état vide ne lève pas', () async {
      final service = ConsentService(FakeConsentRepository());
      await expectLater(service.revokeConsent(), completes);
      expect(await service.hasAcceptedConsent(), isFalse);
    });
  });

  group('ConsentService exception propagation', () {
    test('hasAcceptedConsent propage l\'exception du repository', () async {
      final service = ConsentService(_ThrowingConsentRepository());
      await expectLater(service.hasAcceptedConsent(), throwsException);
    });

    test('acceptConsent propage l\'exception du repository', () async {
      final service = ConsentService(_ThrowingConsentRepository());
      await expectLater(service.acceptConsent(), throwsException);
    });

    test('revokeConsent propage l\'exception du repository', () async {
      final service = ConsentService(_ThrowingConsentRepository());
      await expectLater(service.revokeConsent(), throwsException);
    });
  });
}
