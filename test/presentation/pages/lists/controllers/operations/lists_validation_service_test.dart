import 'package:flutter_test/flutter_test.dart';

import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/pages/lists/controllers/operations/lists_validation_service.dart';

void main() {
  group('ListsValidationService Tests - SOLID SRP Compliance', () {
    late ListsValidationService validationService;

    setUp(() {
      validationService = ListsValidationService();
    });

    group('SRP - Single Responsibility Principle Tests', () {
      test('should only validate business rules without persistence logic', () {
        // GIVEN - Données valides
        final validList = CustomList(
          id: 'valid-id',
          name: 'Valid List Name',
          createdAt: DateTime.now().subtract(Duration(hours: 1)),
        );

        // WHEN - Validation uniquement (pas de persistance)
        final errors = validationService.validateListCreation(validList);

        // THEN - Aucune erreur de validation, pas d'effet de bord
        expect(errors, isEmpty);
      });

      test('should not contain any state management logic', () {
        // GIVEN - Le service ne doit pas avoir d'état persistant
        final list1 = CustomList(id: '1', name: 'List 1', createdAt: DateTime.now());
        final list2 = CustomList(id: '2', name: 'List 2', createdAt: DateTime.now());

        // WHEN - Validations multiples
        validationService.validateListCreation(list1);
        final errors = validationService.validateListCreation(list2);

        // THEN - Pas d'état conservé entre les validations
        expect(errors, isEmpty); // Chaque validation est indépendante
      });

      test('should not contain persistence or CRUD operations', () {
        // GIVEN
        final testList = CustomList(id: '1', name: 'Test', createdAt: DateTime.now());

        // WHEN - La validation ne doit pas persister ou modifier de données
        expect(() => validationService.validateListCreation(testList), returnsNormally);

        // THEN - Aucun effet de bord sur la persistance (teste par l'absence d'exception)
        // Le service ne doit contenir aucune logique de persistance
      });
    });

    group('List Validation Rules', () {
      test('should validate list name requirements', () {
        // GIVEN - Nom vide
        final emptyNameList = CustomList(
          id: '1',
          name: '',
          createdAt: DateTime.now(),
        );

        // WHEN
        final errors = validationService.validateListCreation(emptyNameList);

        // THEN
        expect(errors, isNotEmpty);
        expect(errors.first, contains('ne peut pas être vide'));
      });

      test('should validate list name length constraints', () {
        // GIVEN - Nom trop long
        final longNameList = CustomList(
          id: '1',
          name: 'x' * 101, // 101 caractères
          createdAt: DateTime.now(),
        );

        // WHEN
        final errors = validationService.validateListCreation(longNameList);

        // THEN
        expect(errors, isNotEmpty);
        expect(errors.first, contains('100 caractères'));
      });

      test('should validate list name forbidden characters', () {
        // GIVEN - Caractères interdits
        final invalidCharsList = CustomList(
          id: '1',
          name: 'List<>Name',
          createdAt: DateTime.now(),
        );

        // WHEN
        final errors = validationService.validateListCreation(invalidCharsList);

        // THEN
        expect(errors, isNotEmpty);
        expect(errors.first, contains('caractères interdits'));
      });

      test('should validate list ID requirements', () {
        // GIVEN - ID vide
        final emptyIdList = CustomList(
          id: '',
          name: 'Valid Name',
          createdAt: DateTime.now(),
        );

        // WHEN
        final errors = validationService.validateListCreation(emptyIdList);

        // THEN
        expect(errors, isNotEmpty);
        expect(errors.any((error) => error.contains('ID')), true);
      });

      test('should validate creation date logic', () {
        // GIVEN - Date future
        final futureDateList = CustomList(
          id: '1',
          name: 'Valid Name',
          createdAt: DateTime.now().add(Duration(days: 1)),
        );

        // WHEN
        final errors = validationService.validateListCreation(futureDateList);

        // THEN
        expect(errors, isNotEmpty);
        expect(errors.any((error) => error.contains('futur')), true);
      });
    });

    group('List Update Validation', () {
      test('should validate updated date logic', () {
        // GIVEN - Date de mise à jour antérieure à la création
        final invalidUpdateList = CustomList(
          id: '1',
          name: 'Valid Name',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now().subtract(Duration(hours: 1)),
        );

        // WHEN
        final errors = validationService.validateListUpdate(invalidUpdateList);

        // THEN
        expect(errors, isNotEmpty);
        expect(errors.any((error) => error.contains('antérieure')), true);
      });

      test('should validate future update date', () {
        // GIVEN - Date de mise à jour future
        final futureUpdateList = CustomList(
          id: '1',
          name: 'Valid Name',
          createdAt: DateTime.now().subtract(Duration(hours: 1)),
          updatedAt: DateTime.now().add(Duration(days: 1)),
        );

        // WHEN
        final errors = validationService.validateListUpdate(futureUpdateList);

        // THEN
        expect(errors, isNotEmpty);
        expect(errors.any((error) => error.contains('futur')), true);
      });
    });

    group('Item Validation Rules', () {
      test('should validate item title requirements', () {
        // GIVEN - Titre vide
        final emptyTitleItem = ListItem(
          id: 'item1',
          title: '',
          listId: 'list1',
          createdAt: DateTime.now(),
        );

        // WHEN
        final errors = validationService.validateItemCreation(emptyTitleItem);

        // THEN
        expect(errors, isNotEmpty);
        expect(errors.first, contains('ne peut pas être vide'));
      });

      test('should validate item title length constraints', () {
        // GIVEN - Titre trop long
        final longTitleItem = ListItem(
          id: 'item1',
          title: 'x' * 201, // 201 caractères
          listId: 'list1',
          createdAt: DateTime.now(),
        );

        // WHEN
        final errors = validationService.validateItemCreation(longTitleItem);

        // THEN
        expect(errors, isNotEmpty);
        expect(errors.first, contains('200 caractères'));
      });

      test('should validate item parent list ID', () {
        // GIVEN - ListId vide
        final invalidListIdItem = ListItem(
          id: 'item1',
          title: 'Valid Title',
          listId: '',
          createdAt: DateTime.now(),
        );

        // WHEN
        final errors = validationService.validateItemCreation(invalidListIdItem);

        // THEN
        expect(errors, isNotEmpty);
        expect(errors.any((error) => error.contains('liste parente')), true);
      });
    });

    group('Multiple Items Validation', () {
      test('should validate empty titles list', () {
        // GIVEN
        final emptyTitles = <String>[];

        // WHEN
        final errors = validationService.validateMultipleItemsCreation('list1', emptyTitles);

        // THEN
        expect(errors, isNotEmpty);
        expect(errors.first, contains('ne peut pas être vide'));
      });

      test('should validate individual item titles in bulk', () {
        // GIVEN - Liste avec titres invalides
        final mixedTitles = ['Valid Title', '', 'x' * 201, 'Another Valid'];

        // WHEN
        final errors = validationService.validateMultipleItemsCreation('list1', mixedTitles);

        // THEN
        expect(errors, hasLength(2)); // 2 titres invalides
        expect(errors.any((error) => error.contains('Item 2')), true); // Titre vide
        expect(errors.any((error) => error.contains('Item 3')), true); // Titre trop long
      });

      test('should detect duplicate titles in bulk', () {
        // GIVEN - Titres en double
        final duplicateTitles = ['Title 1', 'Title 2', 'Title 1', 'Title 3'];

        // WHEN
        final errors = validationService.validateMultipleItemsCreation('list1', duplicateTitles);

        // THEN
        expect(errors, isNotEmpty);
        expect(errors.any((error) => error.contains('double')), true);
      });

      test('should validate bulk size constraints', () {
        // GIVEN - Trop d'items
        final tooManyTitles = List.generate(51, (index) => 'Item ${index + 1}');

        // WHEN
        final errors = validationService.validateMultipleItemsCreation('list1', tooManyTitles);

        // THEN
        expect(errors, isNotEmpty);
        expect(errors.any((error) => error.contains('Maximum 50')), true);
      });
    });

    group('List Deletion Validation', () {
      test('should warn about items being deleted', () {
        // GIVEN - Liste avec des items
        final items = [
          ListItem(id: 'item1', title: 'Item 1', listId: 'list1', createdAt: DateTime.now()),
          ListItem(id: 'item2', title: 'Item 2', listId: 'list1', createdAt: DateTime.now()),
        ];

        final listWithItems = CustomList(
          id: 'list1',
          name: 'List with items',
          createdAt: DateTime.now(),
          items: items,
        );

        // WHEN
        final warnings = validationService.validateListDeletion('list1', listWithItems);

        // THEN
        expect(warnings, isNotEmpty);
        expect(warnings.any((warning) => warning.contains('2 élément(s)')), true);
      });

      test('should warn about recently created lists', () {
        // GIVEN - Liste créée récemment
        final recentList = CustomList(
          id: 'list1',
          name: 'Recent List',
          createdAt: DateTime.now().subtract(Duration(hours: 1)), // Moins de 24h
        );

        // WHEN
        final warnings = validationService.validateListDeletion('list1', recentList);

        // THEN
        expect(warnings, isNotEmpty);
        expect(warnings.any((warning) => warning.contains('récemment')), true);
      });

      test('should validate empty list ID', () {
        // GIVEN
        const emptyListId = '';

        // WHEN
        final warnings = validationService.validateListDeletion(emptyListId, null);

        // THEN
        expect(warnings, isNotEmpty);
        expect(warnings.first, contains('ne peut pas être vide'));
      });
    });

    group('Performance Constraints Validation', () {
      test('should validate items per list limit', () {
        // GIVEN - Liste avec beaucoup d'items
        final existingItems = List.generate(950, (index) =>
          ListItem(id: 'item$index', title: 'Item $index', listId: 'list1', createdAt: DateTime.now())
        );

        final listWithManyItems = CustomList(
          id: 'list1',
          name: 'Full List',
          createdAt: DateTime.now(),
          items: existingItems,
        );

        // WHEN - Tenter d'ajouter 100 items de plus
        final errors = validationService.validatePerformanceConstraints(listWithManyItems, 100);

        // THEN
        expect(errors, isNotEmpty);
        expect(errors.first, contains('1000 items'));
      });

      test('should allow addition within limits', () {
        // GIVEN - Liste avec peu d'items
        final fewItems = List.generate(10, (index) =>
          ListItem(id: 'item$index', title: 'Item $index', listId: 'list1', createdAt: DateTime.now())
        );

        final listWithFewItems = CustomList(
          id: 'list1',
          name: 'Small List',
          createdAt: DateTime.now(),
          items: fewItems,
        );

        // WHEN - Ajouter quelques items de plus
        final errors = validationService.validatePerformanceConstraints(listWithFewItems, 5);

        // THEN
        expect(errors, isEmpty);
      });
    });

    group('Input Sanitization', () {
      test('should trim whitespace', () {
        // GIVEN
        const inputWithWhitespace = '  Test Input  ';

        // WHEN
        final result = validationService.sanitizeUserInput(inputWithWhitespace);

        // THEN
        expect(result, equals('Test Input'));
      });

      test('should remove control characters', () {
        // GIVEN
        const inputWithControlChars = 'Test\x00Input\x1F';

        // WHEN
        final result = validationService.sanitizeUserInput(inputWithControlChars);

        // THEN
        expect(result, equals('TestInput'));
        expect(result, isNot(contains('\x00')));
        expect(result, isNot(contains('\x1F')));
      });

      test('should limit input length', () {
        // GIVEN
        final longInput = 'x' * 600; // Plus de 500 caractères

        // WHEN
        final result = validationService.sanitizeUserInput(longInput);

        // THEN
        expect(result.length, equals(500));
      });
    });

    group('Access Permissions', () {
      test('should validate user permissions', () {
        // GIVEN
        const validUserId = 'user123';
        const operation = 'createList';

        // WHEN
        final hasPermission = validationService.validateAccessPermissions(operation, validUserId);

        // THEN
        expect(hasPermission, true);
      });

      test('should reject null or empty user ID', () {
        // GIVEN
        const operation = 'createList';

        // WHEN & THEN
        expect(validationService.validateAccessPermissions(operation, null), false);
        expect(validationService.validateAccessPermissions(operation, ''), false);
      });
    });

    group('Business Rules Validation', () {
      test('should validate general business rules', () {
        // WHEN
        final isValid = validationService.validateBusinessRules();

        // THEN
        expect(isValid, true); // Pour l'instant, toujours valide
      });

      test('should validate data integrity', () async {
        // WHEN
        final isIntegrityValid = await validationService.validateDataIntegrity();

        // THEN
        expect(isIntegrityValid, true); // Pour l'instant, toujours valide
      });
    });
  });
}