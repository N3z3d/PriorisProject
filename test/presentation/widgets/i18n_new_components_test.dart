import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/pages/lists/widgets/components/list_card_action_menu.dart';
import 'package:prioris/presentation/widgets/dialogs/enhanced_logout_dialog.dart';
import '../../helpers/localized_widget.dart';

void main() {
  group('EnhancedLogoutDialog i18n', () {
    testWidgets('affiche les labels FR', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: localizedApp(
            const EnhancedLogoutDialog(),
            locale: const Locale('fr'),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Que souhaitez-vous faire avec vos données locales ?'), findsOneWidget);
      expect(find.text('Garder mes données'), findsOneWidget);
      expect(find.text('Effacer mes données'), findsOneWidget);
    });

    testWidgets('affiche les labels EN', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: localizedApp(
            const EnhancedLogoutDialog(),
            locale: const Locale('en'),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('What would you like to do with your local data?'), findsOneWidget);
      expect(find.text('Keep my data'), findsOneWidget);
      expect(find.text('Clear my data'), findsOneWidget);
    });
  });

  group('ListCardActionMenu i18n', () {
    Widget buildMenu({required Locale locale}) {
      return localizedApp(
        ListCardActionMenu(
          onEdit: () {},
          onArchive: () {},
          onDelete: () {},
        ),
        locale: locale,
      );
    }

    testWidgets('menu items affichent Archive/Edit/Delete en EN', (tester) async {
      await tester.pumpWidget(buildMenu(locale: const Locale('en')));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Archive'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('menu items affichent Modifier/Archiver/Supprimer en FR', (tester) async {
      await tester.pumpWidget(buildMenu(locale: const Locale('fr')));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      expect(find.text('Modifier'), findsOneWidget);
      expect(find.text('Archiver'), findsOneWidget);
      expect(find.text('Supprimer'), findsOneWidget);
    });
  });
}
