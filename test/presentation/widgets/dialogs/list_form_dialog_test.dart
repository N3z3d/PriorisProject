import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/presentation/widgets/dialogs/list_form_dialog.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

void main() {
  group('ListFormDialog', () {
    testWidgets('affiche le titre de création', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => ListFormDialog(onSubmit: (_) {}),
              ),
              child: const Text('Ouvrir'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();
      expect(find.text('Créer une nouvelle liste'), findsOneWidget);
    });

    testWidgets('valide le nom requis', (WidgetTester tester) async {
      bool submitted = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => ListFormDialog(onSubmit: (_) => submitted = true),
              ),
              child: const Text('Ouvrir'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Créer'));
      await tester.pumpAndSettle();
      expect(find.text('Le nom de la liste est obligatoire pour l\'identifier'), findsOneWidget);
      expect(submitted, isFalse);
    });

    testWidgets('soumet le formulaire avec données valides', (WidgetTester tester) async {
      CustomList? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => ListFormDialog(onSubmit: (list) => result = list),
              ),
              child: const Text('Ouvrir'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'Nouvelle liste');
      await tester.tap(find.text('Créer'));
      await tester.pumpAndSettle();
      expect(result, isNotNull);
      expect(result!.name, 'Nouvelle liste');
    });

    testWidgets('affiche bouton Enregistrer en mode édition', (WidgetTester tester) async {
      final list = CustomList(
        id: 'id',
        name: 'Ma liste',
        type: ListType.CUSTOM,
        description: 'Desc',
        items: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => ListFormDialog(initialList: list, onSubmit: (_) {}),
              ),
              child: const Text('Ouvrir'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();
      expect(find.text('Enregistrer'), findsOneWidget);
      expect(find.text('Créer'), findsNothing);
    });
  });
}

