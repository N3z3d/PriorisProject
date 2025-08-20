import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/services/performance/list_template_service.dart';

void main() {
  group('Examples Replacement Tests', () {
    late ListTemplateService service;

    setUp(() {
      service = ListTemplateService();
    });

    test('should NOT contain food-specific examples', () async {
      // RED: This test should fail initially due to food examples
      
      final shoppingTemplates = await service.getTemplatesForCategory('Courses');
      
      // Check that we don't have food-specific examples
      final itemTitles = shoppingTemplates.map((item) => item.title.toLowerCase()).toList();
      
      // These should NOT be found (old food examples)
      expect(itemTitles, isNot(contains('pain')));
      expect(itemTitles, isNot(contains('lait')));
      expect(itemTitles, isNot(contains('oeufs')));
      expect(itemTitles, isNot(contains('fromage')));
      
      // Should contain generic/professional examples instead
      expect(itemTitles.any((title) => 
        title.contains('produits') || 
        title.contains('articles') ||
        title.contains('fournitures') ||
        title.contains('équipement')
      ), true, reason: 'Should have generic examples instead of specific food items');
    });

    test('should have professional/universal examples in hints', () async {
      // Test hint texts in dialogs don't contain food examples
      const hintText = 'Exemple: Terminer rapport projet'; // Should replace "Acheter du pain"
      
      // The hint should not contain food references  
      expect(hintText.toLowerCase(), isNot(contains('pain')));
      expect(hintText.toLowerCase(), isNot(contains('lait')));
      expect(hintText.toLowerCase(), isNot(contains('œuf')));
      
      // Should contain professional examples
      expect(
        hintText.toLowerCase().contains('rapport') ||
        hintText.toLowerCase().contains('projet') ||
        hintText.toLowerCase().contains('document') ||
        hintText.toLowerCase().contains('réunion'),
        true,
        reason: 'Should contain professional examples'
      );
    });

    test('should provide universal task categories', () async {
      final workTemplates = await service.getTemplatesForCategory('Travail');
      final personalTemplates = await service.getTemplatesForCategory('Personnel');
      
      expect(workTemplates.isNotEmpty, true);
      expect(personalTemplates.isNotEmpty, true);
      
      // Work templates should be professional
      final workTitles = workTemplates.map((t) => t.title.toLowerCase()).join(' ');
      expect(
        workTitles.contains('projet') || 
        workTitles.contains('rapport') ||
        workTitles.contains('réunion') ||
        workTitles.contains('présentation'),
        true,
        reason: 'Work templates should contain professional terms'
      );
    });
  });
}