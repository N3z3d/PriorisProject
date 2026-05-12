import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/list/repositories/list_item_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart'
    show InMemoryListItemRepository;
import 'package:prioris/data/repositories/supabase/supabase_list_item_repository.dart';
import 'package:prioris/data/repositories/hive_list_item_repository.dart';

void main() {
  group('ListItemRepository — contrat de port domaine', () {
    test('InMemoryListItemRepository implémente ListItemRepository du domaine', () {
      expect(InMemoryListItemRepository(), isA<ListItemRepository>());
    });

    test('SupabaseListItemRepository implémente ListItemRepository du domaine', () {
      expect(SupabaseListItemRepository(), isA<ListItemRepository>());
    });

    test('HiveListItemRepository implémente ListItemRepository du domaine', () {
      // isA<> ne déclenche aucune méthode — le constructeur default ne lance pas Hive.
      expect(HiveListItemRepository(), isA<ListItemRepository>());
    });

    test('ListItemRepository est dans lib/domain/, non dans lib/data/', () {
      // Test documentaire : si ce test compile, l'import domain est correct.
      ListItemRepository? repo;
      expect(repo, isNull);
    });
  });
}
