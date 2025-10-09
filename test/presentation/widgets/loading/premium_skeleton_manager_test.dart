import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/loading/premium_skeleton_manager.dart';

void main() {
  group('Premium Skeleton Manager Tests', () {
    testWidgets('is singleton', (tester) async {
      final manager1 = PremiumSkeletonManager();
      final manager2 = PremiumSkeletonManager();

      expect(identical(manager1, manager2), isTrue);
    });

    testWidgets('registers default systems', (tester) async {
      final manager = PremiumSkeletonManager();
      final systems = manager.registeredSystems;

      expect(systems.length, greaterThanOrEqualTo(5));
      expect(systems.contains('card_skeleton_system'), isTrue);
      expect(systems.contains('list_skeleton_system'), isTrue);
      expect(systems.contains('form_skeleton_system'), isTrue);
      expect(systems.contains('grid_skeleton_system'), isTrue);
      expect(systems.contains('complex_layout_skeleton_system'), isTrue);
    });

    testWidgets('creates skeleton by type', (tester) async {
      final manager = PremiumSkeletonManager();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: manager.createSkeletonByType('task_card'),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('creates smart skeleton', (tester) async {
      final manager = PremiumSkeletonManager();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: manager.createSmartSkeleton('task card with priority'),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('creates batch skeletons', (tester) async {
      final manager = PremiumSkeletonManager();

      final skeletons = manager.createBatchSkeletons(
        'list_item',
        count: 3,
      );

      expect(skeletons.length, equals(3));
      for (final skeleton in skeletons) {
        expect(skeleton, isA<Widget>());
      }
    });

    testWidgets('creates adaptive skeleton', (tester) async {
      final manager = PremiumSkeletonManager();
      const childWidget = Text('Content');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: manager.createAdaptiveSkeleton(
              child: childWidget,
              isLoading: true,
              skeletonType: 'task_card',
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(Stack), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('validates skeleton types', (tester) async {
      final manager = PremiumSkeletonManager();

      expect(manager.isSkeletonTypeSupported('task_card'), isTrue);
      expect(manager.isSkeletonTypeSupported('list_item'), isTrue);
      expect(manager.isSkeletonTypeSupported('unknown_type'), isFalse);
    });

    testWidgets('provides system info', (tester) async {
      final manager = PremiumSkeletonManager();
      final info = manager.getSystemInfo();

      expect(info, isA<Map<String, dynamic>>());
      expect(info['registered_systems'], greaterThan(0));
      expect(info['available_types'], greaterThan(0));
      expect(info['systems'], isA<List>());
      expect(info['type_mappings'], isA<Map>());
    });

    testWidgets('extension helpers build skeleton widgets', (tester) async {
      final manager = PremiumSkeletonManager();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                manager.card(variant: 'task'),
                manager.list(itemCount: 2),
                manager.form(fieldCount: 2),
                manager.grid(itemCount: 4),
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
