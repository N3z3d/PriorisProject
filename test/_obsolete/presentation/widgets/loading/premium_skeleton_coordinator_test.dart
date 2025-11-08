import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/loading/premium_skeleton_coordinator.dart';

void main() {
  final coordinator = SkeletonCoordinatorHelper.coordinator;

  group('PremiumSkeletonCoordinator', () {
    test('registers default systems', () {
      expect(coordinator.registeredSystems, contains('card_skeleton_system'));
      expect(coordinator.registeredSystems, contains('list_skeleton_system'));
      expect(coordinator.availableSkeletonTypes, contains('task_card'));
      expect(coordinator.availableSkeletonTypes, contains('list_item'));
    });

    testWidgets('creates skeletons by type', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                coordinator.createSkeletonByType('task_card'),
                coordinator.createSkeletonByType('list_item'),
                coordinator.createSkeletonByType('form_field'),
              ],
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('detects skeleton type from hint', (tester) async {
      final widget = coordinator.createSmartSkeleton('habit card with streak');

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
      await tester.pump();

      expect(find.byType(Container), findsWidgets);
    });
  });
}
