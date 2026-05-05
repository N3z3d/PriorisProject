import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/widgets/forms/habit_basic_info_form.dart';

void main() {
  group('HabitBasicInfoForm', () {
    late TextEditingController nameController;
    late TextEditingController descriptionController;
    late TextEditingController categoryController;
    late HabitType selectedType;
    late List<String> existingCategories;
    late HabitType changedType;

    setUp(() {
      nameController = TextEditingController();
      descriptionController = TextEditingController();
      categoryController = TextEditingController();
      selectedType = HabitType.binary;
      existingCategories = ['Santé', 'Sport'];
      changedType = selectedType;
    });

    testWidgets('should display all fields and change type', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr'),
          theme: ThemeData(splashFactory: InkRipple.splashFactory),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('fr'), Locale('en')],
          home: Scaffold(
            body: HabitBasicInfoForm(
              nameController: nameController,
              descriptionController: descriptionController,
              categoryController: categoryController,
              selectedType: selectedType,
              existingCategories: existingCategories,
              onTypeChanged: (type) => changedType = type,
            ),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(DropdownButtonFormField<HabitType>), findsOneWidget);
      expect(find.text('Nom *'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Categorie (optionnelle)'), findsOneWidget);
      expect(find.text("Type d'habitude"), findsOneWidget);

      // Change type — uses i18n keys (FR: "notant une quantité accomplie")
      await tester.tap(find.byType(DropdownButtonFormField<HabitType>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('notant une quantité accomplie').last);
      await tester.pumpAndSettle();
      expect(changedType, HabitType.quantitative);
    });
  });
}
