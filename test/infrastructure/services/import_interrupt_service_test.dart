import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/infrastructure/services/import_interrupt_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ImportInterruptService.instance.onComplete();
  });

  group('ImportInterruptService', () {
    test('onProgress persiste current/total dans SharedPreferences', () async {
      final service = ImportInterruptService.instance;
      await service.onProgress(5, 10);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('import_interrupt_current_v1'), equals(5));
      expect(prefs.getInt('import_interrupt_total_v1'), equals(10));
    });

    test('onComplete efface les clés de SharedPreferences', () async {
      final service = ImportInterruptService.instance;
      await service.onProgress(3, 10);
      await service.onComplete();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('import_interrupt_current_v1'), isNull);
      expect(prefs.getInt('import_interrupt_total_v1'), isNull);
    });

    test('checkAndLoadPersistedState charge l\'état depuis SharedPreferences',
        () async {
      // setUp a déjà réinitialisé _startupInterrupt via onComplete()
      // On recharge les prefs avec les valeurs de test
      SharedPreferences.setMockInitialValues({
        'import_interrupt_current_v1': 42,
        'import_interrupt_total_v1': 100,
      });
      final service = ImportInterruptService.instance;
      await service.checkAndLoadPersistedState();
      final result = service.consumeStartupInterrupt();
      expect(result, isNotNull);
      expect(result!.current, equals(42));
      expect(result.total, equals(100));
    });

    test('checkAndLoadPersistedState efface les clés après lecture', () async {
      // setUp a déjà réinitialisé _startupInterrupt
      SharedPreferences.setMockInitialValues({
        'import_interrupt_current_v1': 7,
        'import_interrupt_total_v1': 20,
      });
      final service = ImportInterruptService.instance;
      await service.checkAndLoadPersistedState();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('import_interrupt_current_v1'), isNull);
    });

    test('consumeStartupInterrupt retourne null si aucun état persisté',
        () async {
      final service = ImportInterruptService.instance;
      await service.onComplete();
      expect(service.consumeStartupInterrupt(), isNull);
    });

    test('checkAndLoadPersistedState ignore current=0 (pas d\'items traités)',
        () async {
      SharedPreferences.setMockInitialValues({
        'import_interrupt_current_v1': 0,
        'import_interrupt_total_v1': 10,
      });
      final service = ImportInterruptService.instance;
      await service.checkAndLoadPersistedState();
      expect(service.consumeStartupInterrupt(), isNull);
    });
  });
}
