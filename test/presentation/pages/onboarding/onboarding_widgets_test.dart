import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/onboarding/widgets/onboarding_capture_step.dart';
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

    testWidgets('un chip ajoute une ligne (compteur passe à 1)',
        (tester) async {
      await tester.pumpWidget(_wrap(OnboardingCaptureStep(
        onStart: (_) {},
        onSkip: () {},
      )));

      expect(find.text('Aucune tâche'), findsOneWidget);
      await tester.tap(find.byType(ActionChip).first);
      await tester.pump();
      expect(find.text('1 tâche'), findsOneWidget);
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

      expect(find.text('3 tâches'), findsOneWidget);
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

  group('OnboardingRevealStep', () {
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
  });
}
