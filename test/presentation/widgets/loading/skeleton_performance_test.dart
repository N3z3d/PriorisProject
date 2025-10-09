import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';
import 'package:prioris/presentation/widgets/loading/premium_skeleton_manager.dart';

void main() {
  group('Skeleton performance tests', () {
    test('batch skeleton creation is efficient', () {
      final manager = PremiumSkeletonManager();
      final stopwatch = Stopwatch()..start();

      final skeletons = manager.createBatchSkeletons('list_item', count: 100);

      stopwatch.stop();

      expect(skeletons.length, equals(100));
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('system registration remains fast', () {
      final manager = PremiumSkeletonManager();
      final customSystem = _TestSkeletonSystem();
      final stopwatch = Stopwatch()..start();

      for (var i = 0; i < 10; i++) {
        manager.registerSystem('test_system_$i', customSystem);
      }

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(100));
      for (var i = 0; i < 10; i++) {
        expect(manager.registeredSystems.contains('test_system_$i'), isTrue);
      }
    });
  });
}

class _TestSkeletonSystem implements ISkeletonSystem {
  @override
  bool canHandle(String skeletonType) => supportedTypes.contains(skeletonType);

  @override
  Widget createSkeleton({
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    return const SizedBox.shrink();
  }

  @override
  String get systemId => 'test_system';

  @override
  List<String> get supportedTypes => const ['test_type'];
}
