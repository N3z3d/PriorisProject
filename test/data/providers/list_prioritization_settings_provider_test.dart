import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/list_prioritization_settings_provider.dart';
import 'package:prioris/domain/core/value_objects/list_prioritization_settings.dart';

void main() {
  group('ListPrioritizationSettingsNotifier', () {
    test('charge les paramètres persistés au démarrage', () async {
      final storage = _InMemorySettingsStorage(
        initial: ListPrioritizationSettings(enabledListIds: {'alpha', 'beta'}),
      );
      final container = ProviderContainer(overrides: [
        listPrioritizationSettingsStorageProvider.overrideWithValue(storage),
      ]);
      addTearDown(container.dispose);

      final notifier =
          container.read(listPrioritizationSettingsProvider.notifier);
      await notifier.ready;

      final settings = container.read(listPrioritizationSettingsProvider);
      expect(settings.enabledListIds, containsAll(['alpha', 'beta']));
    });

    test('persiste les paramètres mis à jour', () async {
      final storage = _InMemorySettingsStorage();
      final container = ProviderContainer(overrides: [
        listPrioritizationSettingsStorageProvider.overrideWithValue(storage),
      ]);
      addTearDown(container.dispose);

      final notifier =
          container.read(listPrioritizationSettingsProvider.notifier);
      await notifier.ready;
      final updatedSettings =
          ListPrioritizationSettings(enabledListIds: {'list-1'});

      await notifier.update(updatedSettings);

      expect(storage.lastSaved?.enabledListIds, contains('list-1'));
    });
  });
}

class _InMemorySettingsStorage implements ListPrioritizationSettingsStorage {
  ListPrioritizationSettings? _stored;
  ListPrioritizationSettings? lastSaved;

  _InMemorySettingsStorage({ListPrioritizationSettings? initial})
      : _stored = initial;

  @override
  Future<ListPrioritizationSettings?> load() async => _stored;

  @override
  Future<void> save(ListPrioritizationSettings settings) async {
    _stored = settings;
    lastSaved = settings;
  }
}
