import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/pages/statistics/widgets/summary/stat_item.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

void main() {
  group('StatItem Widget', () {
    testWidgets('should render with correct properties', (WidgetTester tester) async {
      // Arrange
      const testValue = '42';
      const testLabel = 'Test Label';
      const testIcon = Icons.star;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatItem(
              value: testValue,
              label: testLabel,
              icon: testIcon,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(testValue), findsOneWidget);
      expect(find.text(testLabel), findsOneWidget);
      expect(find.byIcon(testIcon), findsOneWidget);
    });

    testWidgets('should have correct styling', (WidgetTester tester) async {
      // Arrange
      const testValue = '78%';
      const testLabel = 'Taux de réussite';
      const testIcon = Icons.trending_up;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatItem(
              value: testValue,
              label: testLabel,
              icon: testIcon,
            ),
          ),
        ),
      );

      // Assert
      final valueText = tester.widget<Text>(find.text(testValue));
      expect(valueText.style?.color, AppTheme.primaryColor);
      expect(valueText.style?.fontSize, 20);
      expect(valueText.style?.fontWeight, FontWeight.bold);

      final labelText = tester.widget<Text>(find.text(testLabel));
      expect(labelText.style?.fontSize, 12);
      expect(labelText.textAlign, TextAlign.center);

      final icon = tester.widget<Icon>(find.byIcon(testIcon));
      expect(icon.color, AppTheme.primaryColor);
      expect(icon.size, 28);
    });

    testWidgets('should have correct container styling', (WidgetTester tester) async {
      // Arrange
      const testValue = '15 j';
      const testLabel = 'Série la plus longue';
      const testIcon = Icons.local_fire_department;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatItem(
              value: testValue,
              label: testLabel,
              icon: testIcon,
            ),
          ),
        ),
      );

      // Assert
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(StatItem),
          matching: find.byType(Container),
        ),
      );

      expect(container.padding, const EdgeInsets.all(16));
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(12));
      expect(decoration.color, AppTheme.primaryColor.withValues(alpha: 0.1));
    });

    testWidgets('should display complex values correctly', (WidgetTester tester) async {
      // Arrange
      const testValue = '2.1j';
      const testLabel = 'Temps moyen';
      const testIcon = Icons.schedule;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatItem(
              value: testValue,
              label: testLabel,
              icon: testIcon,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(testValue), findsOneWidget);
      expect(find.text(testLabel), findsOneWidget);
      expect(find.byIcon(testIcon), findsOneWidget);
    });

    testWidgets('should handle empty values', (WidgetTester tester) async {
      // Arrange
      const testValue = '';
      const testLabel = 'Empty Value';
      const testIcon = Icons.error;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatItem(
              value: testValue,
              label: testLabel,
              icon: testIcon,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(testValue), findsOneWidget);
      expect(find.text(testLabel), findsOneWidget);
      expect(find.byIcon(testIcon), findsOneWidget);
    });
  });
} 
