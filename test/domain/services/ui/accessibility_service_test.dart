import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/services/ui/accessibility_service.dart';

double round2(double v) => double.parse(v.toStringAsFixed(2));

void main() {
  group('AccessibilityService', () {
    late AccessibilityService service;

    setUp(() {
      service = AccessibilityService();
    });

    test('should be a singleton', () {
      final instance1 = AccessibilityService();
      final instance2 = AccessibilityService();
      expect(identical(instance1, instance2), isTrue);
    });

    test('getAriaLabel returns correct label', () {
      expect(service.getAriaLabel('Bouton'), 'Bouton');
      expect(service.getAriaLabel('Bouton', context: 'Valider'), 'Bouton (Valider)');
    });

    test('getAriaRole returns correct role', () {
      expect(service.getAriaRole('button'), 'button');
      expect(service.getAriaRole('checkbox'), 'checkbox');
      expect(service.getAriaRole('dialog'), 'dialog');
      expect(service.getAriaRole('list'), 'list');
      expect(service.getAriaRole('listitem'), 'listitem');
      expect(service.getAriaRole('tab'), 'tab');
      expect(service.getAriaRole('tabpanel'), 'tabpanel');
      expect(service.getAriaRole('navigation'), 'navigation');
      expect(service.getAriaRole('form'), 'form');
      expect(service.getAriaRole('autre'), 'region');
    });

    test('getContrastRatio returns correct ratio', () {
      final black = Colors.black;
      final white = Colors.white;
      final ratio = service.getContrastRatio(black, white);
      expect(round2(ratio), closeTo(21.0, 0.1)); // Ratio max WCAG
    });

    test('isContrastSufficient returns true for good contrast', () {
      expect(service.isContrastSufficient(Colors.black, Colors.white), isTrue);
      expect(service.isContrastSufficient(Colors.white, Colors.black), isTrue);
    });

    test('isContrastSufficient returns false for bad contrast', () {
      expect(service.isContrastSufficient(Colors.grey, Colors.white), isFalse);
    });

    test('getAccessibleFontSize returns correct size', () {
      expect(service.getAccessibleFontSize(16), 16);
      expect(service.getAccessibleFontSize(16, isLarge: true), 19.2);
    });
  });
} 
