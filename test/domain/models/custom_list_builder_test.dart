import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/builders/custom_list_builder.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

void main() {
  group('CustomListBuilder', () {
    late DateTime now;

    setUp(() {
      now = DateTime(2024, 1, 1, 12, 0, 0);
    });

    group('Construction de base', () {
      test('cree une liste avec les valeurs minimales', () {
        final list = CustomListBuilder()
            .withId('test-list')
            .withName('Test List')
            .withType(ListType.SHOPPING)
            .build();

        expect(list.id, equals('test-list'));
        expect(list.name, equals('Test List'));
        expect(list.type, equals(ListType.SHOPPING));
        expect(list.items, isEmpty);
        expect(list.description, isNull);
      });

      test('cree une liste avec toutes les proprietes', () {
        final list = CustomListBuilder()
            .withId('complete-list')
            .withName('Complete List')
            .withType(ListType.TRAVEL)
            .withDescription('Une liste complete')
            .withCreatedAt(now)
            .withUpdatedAt(now)
            .build();

        expect(list.id, equals('complete-list'));
        expect(list.name, equals('Complete List'));
        expect(list.type, equals(ListType.TRAVEL));
        expect(list.description, equals('Une liste complete'));
        expect(list.createdAt, equals(now));
        expect(list.updatedAt, equals(now));
      });
    });

    group('Gestion des items', () {
      test('ajoute des items a la liste', () {
        final item1 = ListItem(id: 'item-1', title: 'Item 1', createdAt: now);
        final item2 = ListItem(id: 'item-2', title: 'Item 2', createdAt: now);

        final list = CustomListBuilder()
            .withId('list-with-items')
            .withName('List with Items')
            .withType(ListType.SHOPPING)
            .withItems([item1, item2])
            .build();

        expect(list.items.length, equals(2));
        expect(list.items.first, equals(item1));
        expect(list.items.last, equals(item2));
      });
    });

    group('Validation', () {
      test('lance une exception si l\'ID est vide', () {
        expect(
          () => CustomListBuilder()
              .withId('')
              .withName('Test List')
              .withType(ListType.SHOPPING)
              .build(),
          throwsArgumentError,
        );
      });

      test('lance une exception si le nom est vide', () {
        expect(
          () => CustomListBuilder()
              .withId('test-list')
              .withName('')
              .withType(ListType.SHOPPING)
              .build(),
          throwsArgumentError,
        );
      });

      test('lance une exception si les dates sont incoherentes', () {
        final futureDate = now.add(Duration(days: 1));
        final pastDate = now.subtract(Duration(days: 1));

        expect(
          () => CustomListBuilder()
              .withId('test-list')
              .withName('Test List')
              .withType(ListType.SHOPPING)
              .withCreatedAt(futureDate)
              .withUpdatedAt(pastDate)
              .build(),
          throwsArgumentError,
        );
      });
    });
  });
} 
