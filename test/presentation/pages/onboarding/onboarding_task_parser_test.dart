import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/pages/onboarding/onboarding_task_parser.dart';

void main() {
  const parser = OnboardingTaskParser();

  group('OnboardingTaskParser.parse', () {
    test('nominal : 5 titres distincts → 5 tâches', () {
      expect(
        parser.parse('Sport\nCourses\nAppeler\nLire\nRanger'),
        ['Sport', 'Courses', 'Appeler', 'Lire', 'Ranger'],
      );
    });

    test('edge : doublons exacts dédoublonnés', () {
      expect(parser.parse('Sport\nSport\nSport'), ['Sport']);
    });

    test('edge : doublons insensibles à la casse (premier libellé conservé)',
        () {
      expect(parser.parse('Sport\nsport\nSPORT'), ['Sport']);
    });

    test('edge : lignes vides et blancs ignorés', () {
      expect(parser.parse('Sport\n\n   \nCourses'), ['Sport', 'Courses']);
    });

    test('edge : espaces périphériques trimés avant dédup', () {
      expect(parser.parse('  Sport  \nSport'), ['Sport']);
    });

    test('edge : chaîne vide → liste vide', () {
      expect(parser.parse(''), isEmpty);
    });
  });
}
