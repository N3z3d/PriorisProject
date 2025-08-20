import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/core/value_objects/list_prioritization_settings.dart';

/// Tests TDD pour les paramètres de priorisation des listes
/// Red -> Green -> Refactor
void main() {
  group('ListPrioritizationSettings', () {
    test('devrait créer des paramètres par défaut (toutes listes activées)', () {
      // Act
      final settings = ListPrioritizationSettings.defaultSettings();

      // Assert
      expect(settings.enabledListIds, isEmpty);
      expect(settings.isAllListsEnabled, isTrue);
    });

    test('devrait permettre de désactiver une liste avec contexte complet', () {
      // Arrange
      const allLists = ['work-tasks', 'personal-tasks', 'shopping-list'];
      final settings = ListPrioritizationSettings.defaultSettings();

      // Act
      final updatedSettings = settings.disableListWithContext('shopping-list', allLists);

      // Assert
      expect(updatedSettings.isAllListsEnabled, isFalse);
      expect(updatedSettings.isListEnabled('shopping-list'), isFalse);
      expect(updatedSettings.isListEnabled('work-tasks'), isTrue);
      expect(updatedSettings.isListEnabled('personal-tasks'), isTrue);
    });

    test('devrait permettre d\'activer une liste spécifique', () {
      // Arrange
      const listIds = ['work-tasks', 'personal-tasks', 'shopping-list'];
      final settings = ListPrioritizationSettings(
        enabledListIds: {'work-tasks', 'personal-tasks'}, // shopping-list désactivée
      );

      // Act
      final updatedSettings = settings.enableList('shopping-list');

      // Assert
      expect(updatedSettings.isListEnabled('shopping-list'), isTrue);
      expect(updatedSettings.enabledListIds.contains('shopping-list'), isTrue);
    });

    test('isListEnabled devrait retourner true si toutes les listes sont activées', () {
      // Arrange
      final settings = ListPrioritizationSettings.defaultSettings();

      // Act & Assert
      expect(settings.isListEnabled('any-list-id'), isTrue);
    });

    test('isListEnabled devrait vérifier la liste spécifique si pas toutes activées', () {
      // Arrange
      final settings = ListPrioritizationSettings(
        enabledListIds: {'list1', 'list2'},
      );

      // Act & Assert
      expect(settings.isListEnabled('list1'), isTrue);
      expect(settings.isListEnabled('list3'), isFalse);
    });

    test('devrait pouvoir filtrer une liste de IDs selon les paramètres', () {
      // Arrange
      final settings = ListPrioritizationSettings(
        enabledListIds: {'work-tasks', 'personal-tasks'},
      );
      const allListIds = ['work-tasks', 'personal-tasks', 'shopping-list', 'movies-to-watch'];

      // Act
      final enabledIds = settings.filterEnabledLists(allListIds);

      // Assert
      expect(enabledIds, containsAll(['work-tasks', 'personal-tasks']));
      expect(enabledIds, isNot(contains('shopping-list')));
      expect(enabledIds, isNot(contains('movies-to-watch')));
    });

    test('devrait sérialiser vers JSON', () {
      // Arrange
      final settings = ListPrioritizationSettings(
        enabledListIds: {'list1', 'list2'},
      );

      // Act
      final json = settings.toJson();

      // Assert
      expect(json['enabledListIds'], isA<List>());
      expect(json['enabledListIds'], containsAll(['list1', 'list2']));
    });

    test('devrait désérialiser depuis JSON', () {
      // Arrange
      final json = {
        'enabledListIds': ['list1', 'list2']
      };

      // Act
      final settings = ListPrioritizationSettings.fromJson(json);

      // Assert
      expect(settings.enabledListIds, containsAll(['list1', 'list2']));
      expect(settings.isListEnabled('list1'), isTrue);
      expect(settings.isListEnabled('list3'), isFalse);
    });
  });
}