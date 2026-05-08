import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ImportInterruptService {
  static final ImportInterruptService instance = ImportInterruptService._();
  ImportInterruptService._();

  static const String _progressKey = 'import_interrupt_current_v1';
  static const String _totalKey = 'import_interrupt_total_v1';
  static const String _listIdKey = 'import_interrupt_list_id_v1';
  static const String _listNameKey = 'import_interrupt_list_name_v1';
  static const String _pendingItemsKey = 'import_interrupt_pending_items_v1';

  ({int current, int total, String? listId, String? listName, List<String>? pendingItems})?
      _startupInterrupt;

  Future<void> checkAndLoadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_progressKey);
    final total = prefs.getInt(_totalKey);
    if (current != null && total != null && current > 0 && total > 0) {
      List<String>? pendingItems;
      final allItemsJson = prefs.getString(_pendingItemsKey);
      if (allItemsJson != null) {
        try {
          final allItems = List<String>.from(jsonDecode(allItemsJson) as List);
          pendingItems =
              current < allItems.length ? allItems.sublist(current) : const [];
        } catch (_) {
          // Malformed or corrupted JSON — treat as no pending items
        }
      }
      _startupInterrupt = (
        current: current,
        total: total,
        listId: prefs.getString(_listIdKey),
        listName: prefs.getString(_listNameKey),
        pendingItems: pendingItems,
      );
      await Future.wait([
        prefs.remove(_progressKey),
        prefs.remove(_totalKey),
        prefs.remove(_listIdKey),
        prefs.remove(_listNameKey),
        prefs.remove(_pendingItemsKey),
      ]);
    }
  }

  ({int current, int total, String? listId, String? listName, List<String>? pendingItems})?
      peekStartupInterrupt() => _startupInterrupt;

  ({int current, int total, String? listId, String? listName, List<String>? pendingItems})?
      consumeStartupInterrupt() {
    final result = _startupInterrupt;
    _startupInterrupt = null;
    return result;
  }

  ({int current, int total, List<String> pendingItems})?
      peekPendingResume(String listId) {
    final interrupt = _startupInterrupt;
    if (interrupt?.listId != listId) return null;
    final pending = interrupt!.pendingItems;
    if (pending == null) return null;
    return (current: interrupt.current, total: interrupt.total, pendingItems: pending);
  }

  ({int current, int total, List<String> pendingItems})?
      consumePendingResume() {
    final interrupt = _startupInterrupt;
    _startupInterrupt = null;
    if (interrupt?.pendingItems == null) return null;
    return (
      current: interrupt!.current,
      total: interrupt.total,
      pendingItems: interrupt.pendingItems!,
    );
  }

  Future<void> onImportStarted(
      String listId, String listName, List<String> allItems) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_listIdKey, listId),
      prefs.setString(_listNameKey, listName),
      prefs.setString(_pendingItemsKey, jsonEncode(allItems)),
      prefs.setInt(_progressKey, 0),
      prefs.setInt(_totalKey, allItems.length),
    ]);
  }

  Future<void> onProgress(int current, int total) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setInt(_progressKey, current),
      prefs.setInt(_totalKey, total),
    ]);
  }

  Future<void> onComplete() async {
    _startupInterrupt = null;
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_progressKey),
      prefs.remove(_totalKey),
      prefs.remove(_listIdKey),
      prefs.remove(_listNameKey),
      prefs.remove(_pendingItemsKey),
    ]);
  }
}
