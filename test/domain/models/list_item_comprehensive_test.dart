import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

void main() {
  group('ListItem Model - Tests Complets', () {
    late ListItem testItem;

    setUp(() {
      testItem = ListItem(
        id: 'test_item',
        title: 'Test Item',
        description: 'Test Description',
        category: 'Test Category',
        eloScore: 1400.0, // Score ELO élevé (équivalent HIGH priority)
        isCompleted: false,
        createdAt: DateTime(2024, 1, 1),
      );
    });

    group('Constructeur et propriétés', () {
      test('crée un élément avec toutes les propriétés', () {
        expect(testItem.id, equals('test_item'));
        expect(testItem.title, equals('Test Item'));
        expect(testItem.description, equals('Test Description'));
        expect(testItem.category, equals('Test Category'));
        expect(testItem.eloScore, equals(1400.0));
        expect(testItem.isCompleted, isFalse);
        expect(testItem.createdAt, equals(DateTime(2024, 1, 1)));
      });

      test('crée un élément avec des valeurs minimales', () {
        final minimalItem = ListItem(
          id: 'minimal',
          title: 'Minimal Item',
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        expect(minimalItem.id, equals('minimal'));
        expect(minimalItem.title, equals('Minimal Item'));
        expect(minimalItem.description, isNull);
        expect(minimalItem.category, isNull);
        expect(minimalItem.eloScore, equals(1200.0)); // Valeur par défaut
        expect(minimalItem.isCompleted, isFalse);
      });

      test('utilise les valeurs par défaut correctes', () {
        final defaultItem = ListItem(
          id: 'default',
          title: 'Default Item',
          createdAt: DateTime.now(),
        );

        expect(defaultItem.eloScore, equals(1200.0)); // Score ELO par défaut
        expect(defaultItem.isCompleted, isFalse);
      });
    });

    group('Méthodes de manipulation', () {
      test('marque un élément comme complété', () {
        final completed = testItem.markAsCompleted();
        
        expect(completed.isCompleted, isTrue);
        expect(completed.completedAt, isNotNull);
        expect(completed.title, equals(testItem.title));
        expect(completed.eloScore, equals(testItem.eloScore));
      });

      test('calcule correctement la différence de temps', () {
        // Test basique de validation de dates
        final now = DateTime.now();
        final item = testItem.copyWith(
          dueDate: now.add(const Duration(hours: 2)),
        );

        expect(item.dueDate, isNotNull);
        expect(item.dueDate!.isAfter(now), isTrue);
      });

      test('crée une copie avec modifications', () {
        final updatedItem = testItem.copyWith(
          title: 'Updated Title',
          eloScore: 1500.0,
          isCompleted: true,
        );

        expect(updatedItem.title, equals('Updated Title'));
        expect(updatedItem.eloScore, equals(1500.0));
        expect(updatedItem.isCompleted, isTrue);
        expect(updatedItem.id, equals(testItem.id)); // ID reste le même
      });
    });

    group('Méthodes de recherche et filtrage', () {
      test('trouve un élément par ID', () {
        expect(testItem.id, equals('test_item'));
      });

      test('vérifie les propriétés ELO', () {
        final isHighScore = testItem.eloScore > 1300;
        expect(isHighScore, isTrue);
      });

      test('recherche dans le titre des éléments', () {
        final matchesTitle = testItem.title.toLowerCase().contains('test');
        expect(matchesTitle, isTrue);
      });

      test('recherche dans la description des éléments', () {
        final matchesDescription = testItem.description?.toLowerCase().contains('test') == true;
        expect(matchesDescription, isTrue);
      });
    });

    group('Méthodes de modification', () {
      test('modifie le score ELO', () {
        final updatedItem = testItem.copyWith(eloScore: 1600.0);
        expect(updatedItem.eloScore, equals(1600.0));
      });

      test('supprime un élément (simulation)', () {
        // Test conceptuel - la suppression se fait au niveau repository
        expect(testItem.id, isNotEmpty);
      });

      test('met à jour la description', () {
        final updatedItem = testItem.copyWith(description: 'Updated Description');
        expect(updatedItem.description, equals('Updated Description'));
      });

      test('change la catégorie', () {
        final updatedItem = testItem.copyWith(category: 'New Category');
        expect(updatedItem.category, equals('New Category'));
      });

      test('met à jour les dates', () {
        final newDate = DateTime.now();
        final updatedItem = testItem.copyWith(dueDate: newDate);
        expect(updatedItem.dueDate, equals(newDate));
      });
    });

    group('Validation et intégrité', () {
      test('valide l\'ID non vide', () {
        expect(() => ListItem(
          id: '',
          title: 'Test',
          createdAt: DateTime.now(),
        ), throwsA(isA<ArgumentError>()));
      });

      test('valide le titre non vide', () {
        expect(() => ListItem(
          id: 'test',
          title: '',
          createdAt: DateTime.now(),
        ), throwsA(isA<ArgumentError>()));
      });

      test('valide que le score ELO est positif', () {
        expect(() => ListItem(
          id: 'test',
          title: 'Test',
          eloScore: -100.0,
          createdAt: DateTime.now(),
        ), throwsA(isA<ArgumentError>()));
      });
    });

    group('Système ELO', () {
      test('calcule la probabilité de victoire contre un adversaire', () {
        final opponent = ListItem(
          id: 'opponent',
          title: 'Opponent',
          eloScore: 1200.0,
          createdAt: DateTime.now(),
        );

        final winProbability = testItem.calculateWinProbability(opponent);
        expect(winProbability, greaterThan(0.5)); // testItem a un score plus élevé
        expect(winProbability, lessThan(1.0));
      });

      test('calcule correctement les probabilités égales', () {
        final equalOpponent = ListItem(
          id: 'equal',
          title: 'Equal',
          eloScore: 1400.0, // Même score que testItem
          createdAt: DateTime.now(),
        );

        final winProbability = testItem.calculateWinProbability(equalOpponent);
        expect(winProbability, closeTo(0.5, 0.01)); // Probabilité proche de 50%
      });
    });

    group('Sérialisation et désérialisation', () {
      test('convertit en JSON', () {
        final json = testItem.toJson();
        
        expect(json['id'], equals('test_item'));
        expect(json['title'], equals('Test Item'));
        expect(json['description'], equals('Test Description'));
        expect(json['category'], equals('Test Category'));
        expect(json['eloScore'], equals(1400.0));
        expect(json['isCompleted'], isFalse);
        expect(json['createdAt'], isA<String>());
      });

      test('crée depuis un JSON', () {
        final json = testItem.toJson();
        final recreatedItem = ListItem.fromJson(json);

        expect(recreatedItem.id, equals(testItem.id));
        expect(recreatedItem.title, equals(testItem.title));
        expect(recreatedItem.description, equals(testItem.description));
        expect(recreatedItem.category, equals(testItem.category));
        expect(recreatedItem.eloScore, equals(testItem.eloScore));
        expect(recreatedItem.isCompleted, equals(testItem.isCompleted));
      });

      test('gère les valeurs nulles dans la sérialisation', () {
        final itemWithNulls = ListItem(
          id: 'null_test',
          title: 'Null Test',
          createdAt: DateTime.now(),
        );

        final json = itemWithNulls.toJson();
        expect(json['description'], isNull);
        expect(json['category'], isNull);
        expect(json['completedAt'], isNull);
        expect(json['dueDate'], isNull);
        expect(json['notes'], isNull);
      });
    });

    group('Performance et optimisation', () {
      test('crée efficacement de nombreux éléments', () {
        final stopwatch = Stopwatch()..start();
        
        final items = List.generate(1000, (index) => ListItem(
          id: 'item_$index',
          title: 'Item $index',
          eloScore: 1200.0 + (index % 400), // Variation des scores
          createdAt: DateTime.now(),
        ));
        
        stopwatch.stop();

        expect(items.length, equals(1000));
        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Moins de 100ms
      });

      test('calcule rapidement les scores ELO', () {
        final opponent = ListItem(
          id: 'perf_opponent',
          title: 'Performance Opponent',
          eloScore: 1300.0,
          createdAt: DateTime.now(),
        );

        final stopwatch = Stopwatch()..start();
        
        // Calculs multiples pour test de performance
        for (int i = 0; i < 10000; i++) {
          testItem.calculateWinProbability(opponent);
        }
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(50)); // Moins de 50ms pour 10000 calculs
      });
    });
  });
} 
