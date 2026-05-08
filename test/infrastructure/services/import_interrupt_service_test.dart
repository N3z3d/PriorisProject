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

    // --- Nouveaux tests story 8.8 ---

    test('onImportStarted persiste listId, listName et items JSON', () async {
      final service = ImportInterruptService.instance;
      await service.onImportStarted('list-1', 'Ma liste', ['A', 'B', 'C']);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('import_interrupt_list_id_v1'), equals('list-1'));
      expect(prefs.getString('import_interrupt_list_name_v1'), equals('Ma liste'));
      expect(prefs.getString('import_interrupt_pending_items_v1'), equals('["A","B","C"]'));
      expect(prefs.getInt('import_interrupt_current_v1'), equals(0));
      expect(prefs.getInt('import_interrupt_total_v1'), equals(3));
    });

    test(
        'checkAndLoadPersistedState charge les items restants depuis JSON '
        '(current=1 → sublist à partir de l\'index 1)', () async {
      SharedPreferences.setMockInitialValues({
        'import_interrupt_current_v1': 1,
        'import_interrupt_total_v1': 3,
        'import_interrupt_list_id_v1': 'list-abc',
        'import_interrupt_list_name_v1': 'Test',
        'import_interrupt_pending_items_v1': '["A","B","C"]',
      });
      final service = ImportInterruptService.instance;
      await service.checkAndLoadPersistedState();
      final result = service.peekPendingResume('list-abc');
      expect(result, isNotNull);
      expect(result!.pendingItems, equals(['B', 'C']));
      expect(result.current, equals(1));
      expect(result.total, equals(3));
    });

    test('peekPendingResume retourne null si listId ne correspond pas',
        () async {
      SharedPreferences.setMockInitialValues({
        'import_interrupt_current_v1': 2,
        'import_interrupt_total_v1': 5,
        'import_interrupt_list_id_v1': 'list-abc',
        'import_interrupt_list_name_v1': 'Test',
        'import_interrupt_pending_items_v1': '["X","Y","Z","A","B"]',
      });
      final service = ImportInterruptService.instance;
      await service.checkAndLoadPersistedState();
      expect(service.peekPendingResume('autre-liste'), isNull);
    });

    test('consumePendingResume retourne les données et efface _startupInterrupt',
        () async {
      SharedPreferences.setMockInitialValues({
        'import_interrupt_current_v1': 2,
        'import_interrupt_total_v1': 4,
        'import_interrupt_list_id_v1': 'list-xyz',
        'import_interrupt_list_name_v1': 'Ma liste',
        'import_interrupt_pending_items_v1': '["A","B","C","D"]',
      });
      final service = ImportInterruptService.instance;
      await service.checkAndLoadPersistedState();

      final result = service.consumePendingResume();
      expect(result, isNotNull);
      expect(result!.pendingItems, equals(['C', 'D']));
      expect(result.current, equals(2));
      expect(result.total, equals(4));

      // Après consommation, peekPendingResume retourne null
      expect(service.peekPendingResume('list-xyz'), isNull);
    });

    test('onComplete efface aussi les 3 nouvelles clés', () async {
      final service = ImportInterruptService.instance;
      await service.onImportStarted('list-1', 'Liste', ['X']);
      await service.onComplete();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('import_interrupt_list_id_v1'), isNull);
      expect(prefs.getString('import_interrupt_list_name_v1'), isNull);
      expect(prefs.getString('import_interrupt_pending_items_v1'), isNull);
    });

    test('peekStartupInterrupt ne consomme pas _startupInterrupt', () async {
      SharedPreferences.setMockInitialValues({
        'import_interrupt_current_v1': 3,
        'import_interrupt_total_v1': 10,
      });
      final service = ImportInterruptService.instance;
      await service.checkAndLoadPersistedState();

      final first = service.peekStartupInterrupt();
      final second = service.peekStartupInterrupt();
      expect(first, isNotNull);
      expect(second, isNotNull);
      expect(first!.current, equals(second!.current));
    });
  });
}
