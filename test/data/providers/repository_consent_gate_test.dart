import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/providers/repository_providers.dart';

/// Story 10.18 — AC1 : après retrait du consentement, le traitement est gelé.
/// Le choix du repository cloud (Supabase) doit exiger un consentement valide
/// en plus de l'authentification, sur les stratégies automatiques (auto/hybrid).
void main() {
  group('shouldUseCloudRepository — gel sur retrait de consentement (AC1)', () {
    test('auto: signedIn + consent → cloud', () {
      expect(
        shouldUseCloudRepository(true, true, RepositoryStrategy.auto),
        isTrue,
      );
    });

    test('auto: signedIn SANS consent → PAS de cloud (gel)', () {
      expect(
        shouldUseCloudRepository(true, false, RepositoryStrategy.auto),
        isFalse,
      );
    });

    test('auto: non signedIn → PAS de cloud', () {
      expect(
        shouldUseCloudRepository(false, true, RepositoryStrategy.auto),
        isFalse,
      );
    });

    test('hybrid: signedIn SANS consent → PAS de cloud (gel)', () {
      expect(
        shouldUseCloudRepository(true, false, RepositoryStrategy.hybrid),
        isFalse,
      );
    });

    test('hybrid: signedIn + consent → cloud', () {
      expect(
        shouldUseCloudRepository(true, true, RepositoryStrategy.hybrid),
        isTrue,
      );
    });

    test('hive: jamais de cloud, indépendamment du consentement', () {
      expect(
        shouldUseCloudRepository(true, true, RepositoryStrategy.hive),
        isFalse,
      );
    });
  });
}
