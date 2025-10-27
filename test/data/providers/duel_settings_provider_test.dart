import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/duel_settings_provider.dart';
import 'package:prioris/domain/core/value_objects/duel_settings.dart';

void main() {
  group('DuelSettingsNotifier', () {
    test('charge les paramètres persistés au démarrage', () async {
      final storage = _InMemoryDuelSettingsStorage(
        initial: const DuelSettings(
          mode: DuelMode.ranking,
          cardsPerRound: 4,
          hideEloScores: false,
        ),
      );

      final container = ProviderContainer(
        overrides: [
          duelSettingsStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);

      // Forcer l'initialisation puis attendre la fin du chargement asynchrone.
      container.read(duelSettingsProvider);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final settings = container.read(duelSettingsProvider);
      expect(settings.mode, DuelMode.ranking);
      expect(settings.cardsPerRound, 4);
      expect(settings.hideEloScores, isFalse);
    });

    test('persiste les paramètres mis à jour', () async {
      final storage = _InMemoryDuelSettingsStorage();
      final container = ProviderContainer(
        overrides: [
          duelSettingsStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(duelSettingsProvider.notifier);
      const updatedSettings = DuelSettings(
        mode: DuelMode.ranking,
        cardsPerRound: 3,
        hideEloScores: false,
      );

      await notifier.save(updatedSettings);

      expect(storage.lastSaved, equals(updatedSettings));
    });

    test('normalise les options invalides de cartes par manche', () async {
      final storage = _InMemoryDuelSettingsStorage();
      final container = ProviderContainer(
        overrides: [
          duelSettingsStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(duelSettingsProvider.notifier);

      await notifier.updateCardsPerRound(6);
      expect(container.read(duelSettingsProvider).cardsPerRound, 4);

      await notifier.updateCardsPerRound(1);
      expect(container.read(duelSettingsProvider).cardsPerRound, 2);
    });

    test(
        'attend le chargement initial avant de sauvegarder une mise � jour',
        () async {
      final storage = _DelayedInMemoryDuelSettingsStorage(
        initial: const DuelSettings(
          mode: DuelMode.ranking,
          cardsPerRound: 4,
          hideEloScores: false,
        ),
        delay: const Duration(milliseconds: 50),
      );

      final container = ProviderContainer(
        overrides: [
          duelSettingsStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(duelSettingsProvider.notifier);

      await notifier.updateMode(DuelMode.winner);

      expect(storage.lastSaved?.mode, DuelMode.winner);
      expect(container.read(duelSettingsProvider).mode, DuelMode.winner);
    });
  });
}

class _InMemoryDuelSettingsStorage implements DuelSettingsStorage {
  DuelSettings? _stored;
  DuelSettings? lastSaved;

  _InMemoryDuelSettingsStorage({DuelSettings? initial}) : _stored = initial;

  @override
  Future<DuelSettings?> load() async => _stored;

  @override
  Future<void> save(DuelSettings settings) async {
    _stored = settings;
    lastSaved = settings;
  }
}

class _DelayedInMemoryDuelSettingsStorage implements DuelSettingsStorage {
  DuelSettings? _stored;
  DuelSettings? lastSaved;
  final Duration delay;

  _DelayedInMemoryDuelSettingsStorage({
    DuelSettings? initial,
    required this.delay,
  }) : _stored = initial;

  @override
  Future<DuelSettings?> load() async {
    await Future<void>.delayed(delay);
    return _stored;
  }

  @override
  Future<void> save(DuelSettings settings) async {
    _stored = settings;
    lastSaved = settings;
  }
}
