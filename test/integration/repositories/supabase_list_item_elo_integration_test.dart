// ignore_for_file: avoid_print

@Tags(['integration'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/repositories/supabase/supabase_custom_list_repository.dart';
import 'package:prioris/data/repositories/supabase/supabase_list_item_repository.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../helpers/supabase_test_harness.dart';

void main() {
  group('SupabaseListItemRepository — persistance ELO après duel', () {
    late SupabaseListItemRepository repository;
    late SupabaseCustomListRepository listRepository;
    String testListId = '';

    setUpAll(() async {
      await SupabaseTestHarness.setUp();
      repository = SupabaseListItemRepository();
      listRepository = SupabaseCustomListRepository();
      testListId = const Uuid().v4();

      // Crée une liste de test réelle (FK requise par list_items.list_id)
      final now = DateTime.now();
      await listRepository.saveList(CustomList(
        id: testListId,
        name: 'Test ELO 7.9',
        type: ListType.CUSTOM,
        createdAt: now,
        updatedAt: now,
      ));
      print('Setup: liste test $testListId créée');
    });

    tearDownAll(() async {
      // Hard delete des items (soft-delete laisse les lignes → FK bloque la suppression de la liste)
      try {
        await Supabase.instance.client
            .from('list_items')
            .delete()
            .eq('list_id', testListId);
        print('Cleanup: items de la liste $testListId supprimés');
      } catch (e) {
        print('Cleanup warning items: $e');
      }
      // Hard delete de la liste de test
      try {
        await Supabase.instance.client
            .from('custom_lists')
            .delete()
            .eq('id', testListId);
        print('Cleanup: liste test $testListId supprimée');
      } catch (e) {
        print('Cleanup warning liste: $e');
      }
      try {
        await SupabaseTestHarness.tearDown();
      } catch (e) {
        print('Cleanup warning tearDown: $e');
      }
    });

    test('update persiste le nouveau elo_score dans Supabase', () async {
      final initialItem = ListItem(
        id: const Uuid().v4(),
        title: 'Test ELO 7.2',
        eloScore: 1200.0,
        createdAt: DateTime.now(),
        listId: testListId,
      );
      await repository.add(initialItem);

      final updatedItem = ListItem(
        id: initialItem.id,
        title: initialItem.title,
        eloScore: 1216.0,
        createdAt: initialItem.createdAt,
        listId: initialItem.listId,
      );

      await repository.update(updatedItem);

      final fetched = await repository.getById(initialItem.id);
      expect(fetched, isNotNull);
      expect(fetched!.eloScore, closeTo(1216.0, 0.01),
          reason: 'Le nouveau ELO doit être persisté dans Supabase');
    });

    test('update loser persiste le score réduit dans Supabase', () async {
      final loserItem = ListItem(
        id: const Uuid().v4(),
        title: 'Test ELO Loser 7.2',
        eloScore: 1200.0,
        createdAt: DateTime.now(),
        listId: testListId,
      );
      final loserId = loserItem.id;

      await repository.add(loserItem);

      final updatedLoser = ListItem(
        id: loserId,
        title: loserItem.title,
        eloScore: 1184.0,
        createdAt: loserItem.createdAt,
        listId: loserItem.listId,
      );

      await repository.update(updatedLoser);

      final fetched = await repository.getById(loserId);
      expect(fetched, isNotNull);
      expect(fetched!.eloScore, closeTo(1184.0, 0.01),
          reason: 'Le score du perdant doit être persisté dans Supabase');

      await repository.delete(loserId);
    });
  });
}
