import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
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
      expect(find.text('Categorie (optionnelle)'), findsOneWidget); // No accent - matches source
      expect(find.text("Type d'habitude"), findsOneWidget);

      // Change type
      await tester.tap(find.byType(DropdownButtonFormField<HabitType>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quantitatif (Nombre)').last);
      await tester.pumpAndSettle();
      expect(changedType, HabitType.quantitative);
    });
  });
} 
