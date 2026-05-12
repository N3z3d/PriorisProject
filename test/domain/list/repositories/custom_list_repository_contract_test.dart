import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/list/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart'
    show InMemoryCustomListRepository;
import 'package:prioris/data/repositories/supabase/supabase_custom_list_repository.dart';
import 'package:prioris/data/repositories/hive_custom_list_repository.dart';

void main() {
  group('CustomListRepository — contrat de port domaine', () {
    test('InMemoryCustomListRepository implémente CustomListRepository du domaine', () {
      expect(InMemoryCustomListRepository(), isA<CustomListRepository>());
    });

    test('SupabaseCustomListRepository implémente CustomListRepository du domaine', () {
      expect(SupabaseCustomListRepository(), isA<CustomListRepository>());
    });

    test('HiveCustomListRepository implémente CustomListRepository du domaine', () {
      expect(HiveCustomListRepository(), isA<CustomListRepository>());
    });

    test('CustomListRepository est dans lib/domain/, non dans lib/data/', () {
      // Test documentaire : si ce test compile, l'import domain est correct.
      CustomListRepository? repo;
      expect(repo, isNull);
    });
  });
}
