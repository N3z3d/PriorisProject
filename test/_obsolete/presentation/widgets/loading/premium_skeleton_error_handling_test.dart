import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/loading/premium_skeleton_manager.dart';

void main() {
  group('Premium skeleton error handling', () {
    testWidgets('createSkeletonByType tolerates unknown types', (tester) async {
      final manager = PremiumSkeletonManager();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: manager.createSkeletonByType('unknown_type'),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('createSkeletonVariant handles invalid system IDs', (tester) async {
      final manager = PremiumSkeletonManager();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: manager.createSkeletonVariant('invalid_system_id', 'variant'),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('createSkeletonByType accepts null options', (tester) async {
      final manager = PremiumSkeletonManager();
      final supportedTypes = manager.availableSkeletonTypes.take(3);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                for (final type in supportedTypes)
                  manager.createSkeletonByType(type, options: null),
              ],
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(Container), findsWidgets);
    });
  });
}
