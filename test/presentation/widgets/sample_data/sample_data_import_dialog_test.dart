import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/presentation/widgets/sample_data/sample_data_import_dialog.dart';
import 'package:prioris/data/repositories/sample_data_service.dart';

// Mock providers pour les tests
final mockSampleDataServiceProvider = Provider<SampleDataService>((ref) {
  return MockSampleDataService();
});

class MockSampleDataService implements SampleDataService {
  @override
  Future<bool> hasSampleData() async => false;

  @override
  Future<void> resetWithSampleData() async {
    // Mock implementation
  }

  @override
  Future<bool> importSampleData() async => true;

  @override
  Future<void> importAllSampleData() async {
    // Mock implementation
  }

  @override
  Future<void> clearAllData() async {
    // Mock implementation
  }

  @override
  Map<String, int> getSampleDataStats() {
    return {
      'tasks': 10,
      'habits': 5,
      'total': 15,
    };
  }
}

void main() {
  group('SampleDataImportDialog', () {
    testWidgets('affiche le titre du dialogue', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sampleDataServiceProvider.overrideWithValue(MockSampleDataService()),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const SampleDataImportDialog(),
                ),
                child: const Text('Ouvrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      expect(find.text('Importer des données d\'exemple'), findsOneWidget);
    });

    testWidgets('affiche les statistiques des données d\'exemple', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sampleDataServiceProvider.overrideWithValue(MockSampleDataService()),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const SampleDataImportDialog(),
                ),
                child: const Text('Ouvrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      // Vérifie que les statistiques sont affichées
      expect(find.text("10 tâches d'exemple"), findsOneWidget); // tasksCount
      expect(find.text("5 habitudes d'exemple"), findsOneWidget); // habitsCount
      expect(find.text('Total: 15 éléments'), findsOneWidget); // total
    });

    testWidgets('affiche le bouton Annuler', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sampleDataServiceProvider.overrideWithValue(MockSampleDataService()),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const SampleDataImportDialog(),
                ),
                child: const Text('Ouvrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      expect(find.text('Annuler'), findsOneWidget);
    });

    testWidgets('affiche le bouton Importer', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sampleDataServiceProvider.overrideWithValue(MockSampleDataService()),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const SampleDataImportDialog(),
                ),
                child: const Text('Ouvrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      expect(find.text('Importer'), findsOneWidget);
    });

    testWidgets('ferme le dialogue quand on appuie sur Annuler', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sampleDataServiceProvider.overrideWithValue(MockSampleDataService()),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const SampleDataImportDialog(),
                ),
                child: const Text('Ouvrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      expect(find.text('Importer des données d\'exemple'), findsOneWidget);

      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      expect(find.text('Importer des données d\'exemple'), findsNothing);
    });
  });
} 
