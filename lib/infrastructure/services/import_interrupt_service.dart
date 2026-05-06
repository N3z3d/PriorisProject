import 'package:shared_preferences/shared_preferences.dart';

class ImportInterruptService {
  static final ImportInterruptService instance = ImportInterruptService._();
  ImportInterruptService._();

  static const String _progressKey = 'import_interrupt_current_v1';
  static const String _totalKey = 'import_interrupt_total_v1';

  ({int current, int total})? _startupInterrupt;

  Future<void> checkAndLoadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_progressKey);
    final total = prefs.getInt(_totalKey);
    if (current != null && total != null && current > 0 && total > 0) {
      _startupInterrupt = (current: current, total: total);
      await Future.wait([prefs.remove(_progressKey), prefs.remove(_totalKey)]);
    }
  }

  ({int current, int total})? consumeStartupInterrupt() {
    final result = _startupInterrupt;
    _startupInterrupt = null;
    return result;
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
    await Future.wait([prefs.remove(_progressKey), prefs.remove(_totalKey)]);
  }
}
