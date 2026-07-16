import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/onboarding/widgets/onboarding_capture_step.dart';
import 'package:prioris/presentation/pages/onboarding/widgets/onboarding_duel_step.dart';
import 'package:prioris/presentation/pages/onboarding/widgets/onboarding_reveal_step.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    locale: const Locale('fr'),
    theme: ThemeData(splashFactory: NoSplash.splashFactory),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  group('OnboardingCaptureStep', () {
    testWidgets('bouton actif à 5 lignes et onStart reçoit le texte',
        (tester) async {
      String? captured;
      await tester.pumpWidget(_wrap(OnboardingCaptureStep(
        onStart: (text) => captured = text,
        onSkip: () {},
      )));

      await tester.enterText(find.byType(TextField), 'A\nB\nC\nD\nE');
      await tester.pump();

      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(captured, 'A\nB\nC\nD\nE');
    });

    testWidgets('cadre d\'introduction affiché au départ (AC2)',
        (tester) async {
      await tester.pumpWidget(_wrap(OnboardingCaptureStep(
        onStart: (_) {},
        onSkip: () {},
      )));

      expect(
        find.text(
          'Note ce que tu as en tête. On t\'aide ensuite à choisir par quoi '
          'commencer. Moins d\'une minute.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('compteur en progression vers le seuil et aide dynamique (AC1)',
        (tester) async {
      await tester.pumpWidget(_wrap(OnboardingCaptureStep(
        onStart: (_) {},
        onSkip: () {},
      )));

      // Vide : « 0 / 5 » + aide indiquant qu\'il reste 5 tâches à ajouter.
      expect(find.text('0 / 5'), findsOneWidget);
      expect(find.text('Ajoute encore 5 tâches pour commencer'), findsOneWidget);

      await tester.tap(find.byType(ActionChip).first);
      await tester.pump();

      // Une tâche : progression et aide se mettent à jour.
      expect(find.text('1 / 5'), findsOneWidget);
      expect(find.text('Ajoute encore 4 tâches pour commencer'), findsOneWidget);
    });

    testWidgets('seuil atteint : « 5 / 5 », aide masquée, bouton actif (AC1)',
        (tester) async {
      await tester.pumpWidget(_wrap(OnboardingCaptureStep(
        onStart: (_) {},
        onSkip: () {},
      )));

      await tester.enterText(find.byType(TextField), 'A\nB\nC\nD\nE');
      await tester.pump();

      expect(find.text('5 / 5'), findsOneWidget);
      expect(find.textContaining('Ajoute encore'), findsNothing);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );
    });

    testWidgets('au-delà du seuil : compteur plafonné à « 5 / 5 » (pas « 7 / 5 »)',
        (tester) async {
      await tester.pumpWidget(_wrap(OnboardingCaptureStep(
        onStart: (_) {},
        onSkip: () {},
      )));

      // 7 tâches uniques : le numérateur est clampé au seuil, pas affiché brut.
      await tester.enterText(find.byType(TextField), 'A\nB\nC\nD\nE\nF\nG');
      await tester.pump();

      expect(find.text('5 / 5'), findsOneWidget);
      expect(find.text('7 / 5'), findsNothing);
      expect(find.textContaining('Ajoute encore'), findsNothing);
    });

    testWidgets('5 lignes avec doublons : bouton désactivé (compteur dédoublonne)',
        (tester) async {
      String? captured;
      await tester.pumpWidget(_wrap(OnboardingCaptureStep(
        onStart: (text) => captured = text,
        onSkip: () {},
      )));

      // 5 lignes mais 3 titres uniques → sous le seuil produit de 5.
      await tester.enterText(find.byType(TextField), 'Sport\nsport\nSPORT\nCourses\nAppeler');
      await tester.pump();

      expect(find.text('3 / 5'), findsOneWidget);
      expect(find.text('Ajoute encore 2 tâches pour commencer'), findsOneWidget);
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);

      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      expect(captured, isNull);
    });

    testWidgets('bouton Passer déclenche onSkip', (tester) async {
      var skipped = false;
      await tester.pumpWidget(_wrap(OnboardingCaptureStep(
        onStart: (_) {},
        onSkip: () => skipped = true,
      )));
      await tester.tap(find.text('Passer'));
      await tester.pump();
      expect(skipped, isTrue);
    });
  });

  group('OnboardingDuelStep', () {
    Widget buildDuel({required int index}) {
      return _wrap(OnboardingDuelStep(
        pair: [Task(title: 'Gauche'), Task(title: 'Droite')],
        index: index,
        total: 5,
        onChoose: (_, __) {},
      ));
    }

    testWidgets('pont d\'introduction affiché au premier duel (AC3)',
        (tester) async {
      await tester.pumpWidget(buildDuel(index: 0));
      expect(
        find.text(
          'Tu vas faire 5 choix. Ni classement ni chiffres à gérer : '
          'c\'est toi qui décides.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('pont d\'introduction masqué au-delà du premier duel (AC3)',
        (tester) async {
      await tester.pumpWidget(buildDuel(index: 1));
      expect(find.textContaining('Tu vas faire 5 choix'), findsNothing);
    });
  });

  group('OnboardingRevealStep', () {
    testWidgets('explication du mécanisme affichée avec une tâche (AC4)',
        (tester) async {
      await tester.pumpWidget(_wrap(OnboardingRevealStep(
        task: Task(title: 'Tâche de tête'),
        onContinue: () {},
        onMarkDone: () {},
      )));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Tu n\'as rien rangé — tu as choisi. Voici la tâche qui est '
          'remontée en tête.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('sans tâche : ni carte ni explication, pas de crash (AC4)',
        (tester) async {
      await tester.pumpWidget(_wrap(OnboardingRevealStep(
        task: null,
        onContinue: () {},
        onMarkDone: () {},
      )));
      await tester.pumpAndSettle();

      expect(find.textContaining('Voici la tâche'), findsNothing);
      // Le flux reste utilisable : les deux boutons de sortie sont présents.
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('libellé « Marquer comme fait » (action courte, AC5)',
        (tester) async {
      await tester.pumpWidget(_wrap(OnboardingRevealStep(
        task: Task(title: 'Tâche'),
        onContinue: () {},
        onMarkDone: () {},
      )));
      await tester.pumpAndSettle();

      expect(find.text('Marquer comme fait'), findsOneWidget);
    });

    testWidgets('Continuer déclenche onContinue', (tester) async {
      var continued = false;
      await tester.pumpWidget(_wrap(OnboardingRevealStep(
        task: Task(title: 'Tâche de tête'),
        onContinue: () => continued = true,
        onMarkDone: () {},
      )));
      await tester.pumpAndSettle();

      expect(find.text('Tâche de tête'), findsOneWidget);
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      expect(continued, isTrue);
    });

    testWidgets('Marquer comme fait déclenche onMarkDone', (tester) async {
      var doneTapped = false;
      await tester.pumpWidget(_wrap(OnboardingRevealStep(
        task: Task(title: 'Tâche'),
        onContinue: () {},
        onMarkDone: () => doneTapped = true,
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();
      expect(doneTapped, isTrue);
    });

    testWidgets('processing=true : boutons reveal désactivés (anti double-tap)',
        (tester) async {
      await tester.pumpWidget(_wrap(OnboardingRevealStep(
        task: Task(title: 'Tâche'),
        onContinue: () {},
        onMarkDone: () {},
        processing: true,
      )));
      await tester.pumpAndSettle();

      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(
        tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
        isNull,
      );
    });
  });
}
