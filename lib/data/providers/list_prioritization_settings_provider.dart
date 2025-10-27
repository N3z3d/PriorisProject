import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/core/value_objects/list_prioritization_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage abstraction to persist prioritization settings.
abstract class ListPrioritizationSettingsStorage {
  Future<ListPrioritizationSettings?> load();
  Future<void> save(ListPrioritizationSettings settings);
}

class SharedPrefsListPrioritizationSettingsStorage
    implements ListPrioritizationSettingsStorage {
  static const _storageKey = 'list_prioritization_settings';

  @override
  Future<ListPrioritizationSettings?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) {
      return null;
    }

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return ListPrioritizationSettings.fromJson(json);
    } catch (error, stackTrace) {
      debugPrint(
        '[ListPrioritizationSettings] Failed to decode persisted settings: '
        '$error\n$stackTrace',
      );
      return null;
    }
  }

  @override
  Future<void> save(ListPrioritizationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(settings.toJson());
    await prefs.setString(_storageKey, json);
  }
}

class ListPrioritizationSettingsNotifier
    extends StateNotifier<ListPrioritizationSettings> {
  final ListPrioritizationSettingsStorage _storage;
  late final Future<void> _initialization;

  ListPrioritizationSettingsNotifier({
    required ListPrioritizationSettingsStorage storage,
  })  : _storage = storage,
        super(ListPrioritizationSettings.defaultSettings()) {
    _initialization = _loadPersistedSettings();
  }

  Future<void> _loadPersistedSettings() async {
    final stored = await _storage.load();
    if (stored != null) {
      state = stored;
    }
  }

  Future<void> update(ListPrioritizationSettings newSettings) async {
    await _initialization;
    state = newSettings;
    await _storage.save(newSettings);
  }
}

final listPrioritizationSettingsStorageProvider =
    Provider<ListPrioritizationSettingsStorage>((ref) {
  return SharedPrefsListPrioritizationSettingsStorage();
});

final listPrioritizationSettingsProvider = StateNotifierProvider<
    ListPrioritizationSettingsNotifier, ListPrioritizationSettings>((ref) {
  final storage = ref.watch(listPrioritizationSettingsStorageProvider);
  return ListPrioritizationSettingsNotifier(storage: storage);
});
