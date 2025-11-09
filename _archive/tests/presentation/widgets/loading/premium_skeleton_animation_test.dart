import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/loading/premium_skeleton_coordinator.dart';

void main() {
  final coordinator = SkeletonCoordinatorHelper.coordinator;

  group('Premium skeleton animations', () {
    testWidgets('animated skeletons support custom controllers', (tester) async {
      late AnimationController controller;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = AnimationController(
                duration: const Duration(milliseconds: 500),
                vsync: _TestVSync(),
              );
              return Scaffold(
                body: coordinator.createAnimatedSkeleton(
                  'card_skeleton_system',
                  controller: controller,
                ),
              );
            },
          ),
        ),
      );

      await tester.pump();
      controller.forward();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.byType(Container), findsWidgets);
      expect(controller.value, greaterThan(0));

      controller.dispose();
    });
  });
}

class _TestVSync implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}
