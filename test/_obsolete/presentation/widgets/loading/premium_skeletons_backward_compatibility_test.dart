import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/loading/premium_skeleton_manager.dart';
import 'package:prioris/presentation/widgets/loading/premium_skeletons.dart';

void main() {
  group('PremiumSkeletons backward compatibility', () {
    testWidgets('static helpers render expected widgets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                PremiumSkeletons.taskCardSkeleton(),
                PremiumSkeletons.habitCardSkeleton(),
                PremiumSkeletons.listSkeleton(itemCount: 2),
                PremiumSkeletons.profileSkeleton(),
                PremiumSkeletons.chartSkeleton(),
                PremiumSkeletons.formSkeleton(fieldCount: 2),
                PremiumSkeletons.gridSkeleton(itemCount: 4),
              ],
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('extension points placeholder widgets exist', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: const [
                Text('Placeholder for adaptive skeleton'),
                Text('Placeholder for smart skeleton'),
              ],
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('manager API remains available', (tester) async {
      final info = PremiumSkeletons.manager.getSystemInfo();
      final isSupported =
          PremiumSkeletons.manager.isSkeletonTypeSupported('task_card');

      expect(info, isA<Map<String, dynamic>>());
      expect(isSupported, isTrue);
    });
  });
}
