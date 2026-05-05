import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/providers/consent_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('ConsentNotifier.revoke', () {
    test('revoke après accept → state devient data(false)', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await Future<void>.delayed(Duration.zero);

      // Accepter via le notifier (plus fiable que pré-charger depuis SharedPreferences)
      await container.read(consentProvider.notifier).accept();
      expect(container.read(consentProvider).value, isTrue);

      await container.read(consentProvider.notifier).revoke();
      expect(container.read(consentProvider).value, isFalse);
    });

    test('revoke appelle revokeConsent sur le service (SharedPreferences)', () async {
      SharedPreferences.setMockInitialValues({'privacy_consent_v1': true});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await Future<void>.delayed(Duration.zero);
      await container.read(consentProvider.notifier).revoke();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('privacy_consent_v1'), isNull);
      expect(prefs.getString('privacy_consent_date_v1'), isNull);
    });

    test('revoke sur notifier non-accepté passe state à data(false) sans erreur', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await Future<void>.delayed(Duration.zero);

      await expectLater(
        container.read(consentProvider.notifier).revoke(),
        completes,
      );
      expect(container.read(consentProvider).value, isFalse);
    });
  });
}
