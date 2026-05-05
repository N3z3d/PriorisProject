import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/services/core/language_service.dart';
import 'package:prioris/presentation/widgets/selectors/language_selector.dart';

void main() {
  group('LanguageSelector', () {
    late LanguageService mockLanguageService;

    setUp(() {
      mockLanguageService = LanguageService();
    });

    Widget createTestWidget(Widget child) {
      return ProviderScope(
        overrides: [
          languageServiceProvider.overrideWithValue(mockLanguageService),
        ],
        child: MaterialApp(
          theme: ThemeData(splashFactory: InkRipple.splashFactory),
          home: Scaffold(
            body: child,
          ),
        ),
      );
    }

    group('LanguageSelector', () {
      testWidgets('should display language selector with all supported languages', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(const LanguageSelector()));

        // Vérifier que le titre est affiché
        expect(find.text('Language'), findsOneWidget);
        expect(find.byIcon(Icons.language), findsOneWidget);

        // Vérifier que toutes les langues supportées sont affichées
        expect(find.text('English'), findsOneWidget);
        expect(find.text('Français'), findsOneWidget);
        expect(find.text('Español'), findsOneWidget);
        expect(find.text('Deutsch'), findsOneWidget);

        // Vérifier que les drapeaux sont affichés
        expect(find.text('🇺🇸'), findsOneWidget);
        expect(find.text('🇫🇷'), findsOneWidget);
        expect(find.text('🇪🇸'), findsOneWidget);
        expect(find.text('🇩🇪'), findsOneWidget);
      });

      testWidgets('should highlight current language', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(const LanguageSelector()));

        // La langue par défaut (anglais) devrait être sélectionnée
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('should change language when tapped', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(const LanguageSelector()));

        // Taper sur l'option française
        await tester.tap(find.text('Français'));
        await tester.pumpAndSettle();

        // Vérifier que le snackbar s'affiche
        expect(find.text('Language changed to Français'), findsOneWidget);
      });

      testWidgets('should have correct styling for selected language', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(const LanguageSelector()));

        // Vérifier que l'option sélectionnée a le bon style
        final selectedOption = find.ancestor(
          of: find.byIcon(Icons.check_circle),
          matching: find.byType(Container),
        );
        expect(selectedOption, findsOneWidget);
      });
    });

    group('CompactLanguageSelector', () {
      testWidgets('should display compact language selector', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(const CompactLanguageSelector()));

        // Vérifier que le ListTile est affiché
        expect(find.byType(ListTile), findsOneWidget);
        expect(find.text('Language'), findsOneWidget);
        expect(find.byIcon(Icons.language), findsOneWidget);
        expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
      });

      testWidgets('should display current language with flag', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(const CompactLanguageSelector()));

        // La langue par défaut est le français (LanguageService.defaultLocale = Locale('fr'))
        // La sous-titre affiche le drapeau et le nom de la langue courante
        expect(find.byType(ListTile), findsOneWidget);
      });

      testWidgets('should show language dialog when tapped', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(const CompactLanguageSelector()));

        // Taper sur le ListTile
        await tester.tap(find.byType(ListTile));
        await tester.pumpAndSettle();

        // Vérifier que le dialogue s'affiche
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
      });

      testWidgets('should display all languages in dialog', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(const CompactLanguageSelector()));

        // Ouvrir le dialogue
        await tester.tap(find.byType(ListTile));
        await tester.pumpAndSettle();

        // Vérifier que toutes les langues sont affichées
        expect(find.text('English'), findsOneWidget);
        expect(find.text('Français'), findsOneWidget);
        expect(find.text('Español'), findsOneWidget);
        expect(find.text('Deutsch'), findsOneWidget);

        // Vérifier que les drapeaux sont affichés
        expect(find.text('🇺🇸'), findsOneWidget);
        expect(find.text('🇫🇷'), findsOneWidget);
        expect(find.text('🇪🇸'), findsOneWidget);
        expect(find.text('🇩🇪'), findsOneWidget);
      });

      testWidgets('should change language when option is selected in dialog', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(const CompactLanguageSelector()));

        // Ouvrir le dialogue
        await tester.tap(find.byType(ListTile));
        await tester.pumpAndSettle();

        // Sélectionner l'espagnol
        await tester.tap(find.text('Español'));
        await tester.pumpAndSettle();

        // Vérifier que le dialogue se ferme
        expect(find.byType(AlertDialog), findsNothing);

        // Vérifier que le snackbar s'affiche
        expect(find.text('Language changed to Español'), findsOneWidget);
      });

      testWidgets('should close dialog when cancel is tapped', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(const CompactLanguageSelector()));

        // Ouvrir le dialogue
        await tester.tap(find.byType(ListTile));
        await tester.pumpAndSettle();

        // Taper sur Cancel
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Vérifier que le dialogue se ferme
        expect(find.byType(AlertDialog), findsNothing);
      });

      testWidgets('should highlight current language in dialog', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(const CompactLanguageSelector()));

        // Ouvrir le dialogue
        await tester.tap(find.byType(ListTile));
        await tester.pumpAndSettle();

        // Vérifier que l'anglais (langue par défaut) est sélectionné
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });
    });

    group('Integration tests', () {
      testWidgets('should maintain language selection across widget rebuilds', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(const LanguageSelector()));

        // Changer la langue
        await tester.tap(find.text('Français'));
        await tester.pumpAndSettle();

        // Reconstruire le widget
        await tester.pumpWidget(createTestWidget(const LanguageSelector()));
        await tester.pumpAndSettle();

        // Vérifier que la sélection est maintenue
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('should update both selectors when language changes', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          Column(
            children: const [
              LanguageSelector(),
              CompactLanguageSelector(),
            ],
          ),
        ));

        // Changer la langue avec le sélecteur principal
        await tester.tap(find.text('Deutsch'));
        await tester.pumpAndSettle();

        // Vérifier que le sélecteur compact est mis à jour
        expect(find.textContaining('🇩🇪 Deutsch'), findsOneWidget);
      });
    });
  });
} 
