import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/core/value_objects/duel_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage abstraction to persist duel settings.
abstract class DuelSettingsStorage {
  Future<DuelSettings?> load();
  Future<void> save(DuelSettings settings);
}

class SharedPrefsDuelSettingsStorage implements DuelSettingsStorage {
  static const _storageKey = 'prioris_duel_settings';

  @override
  Future<DuelSettings?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) {
      return null;
    }

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return DuelSettings.fromJson(json);
    } catch (error, stackTrace) {
      debugPrint(
        '[DuelSettingsStorage] Failed to decode persisted settings: $error\n$stackTrace',
      );
      return null;
    }
  }

  @override
  Future<void> save(DuelSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(settings.toJson());
    await prefs.setString(_storageKey, json);
  }
}

class DuelSettingsNotifier extends StateNotifier<DuelSettings> {
  final DuelSettingsStorage _storage;
  late final Future<void> _initialization;

  DuelSettingsNotifier({required DuelSettingsStorage storage})
      : _storage = storage,
        super(const DuelSettings.defaults()) {
    _initialization = _loadPersistedSettings();
  }

  Future<void> ensureLoaded() => _initialization;

  Future<void> _loadPersistedSettings() async {
    final stored = await _storage.load();
    if (stored != null) {
      state = stored;
    }
  }

  Future<void> save(DuelSettings settings) async {
    await _initialization;
    state = settings.copyWith();
    await _storage.save(state);
  }

  Future<void> updateMode(DuelMode mode) {
    return save(state.copyWith(mode: mode));
  }

  Future<void> updateCardsPerRound(int cardsPerRound) {
    return save(state.copyWith(cardsPerRound: cardsPerRound));
  }

  Future<void> toggleHideElo() {
    return save(state.copyWith(hideEloScores: !state.hideEloScores));
  }

  Future<void> updateHideElo(bool hide) {
    return save(state.copyWith(hideEloScores: hide));
  }
}

final duelSettingsStorageProvider = Provider<DuelSettingsStorage>((ref) {
  return SharedPrefsDuelSettingsStorage();
});

final duelSettingsProvider =
    StateNotifierProvider<DuelSettingsNotifier, DuelSettings>((ref) {
  final storage = ref.watch(duelSettingsStorageProvider);
  return DuelSettingsNotifier(storage: storage);
});
