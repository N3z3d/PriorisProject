import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/loading/systems/form/form_skeleton_config.dart';

void main() {
  group('FormSkeletonConfig', () {
    test('should create instance with default values', () {
      const config = FormSkeletonConfig();

      expect(config.width, isNull);
      expect(config.height, isNull);
      expect(config.animationDuration, isNull);
      expect(config.animationController, isNull);
      expect(config.options, isEmpty);
    });

    test('should create instance with all parameters', () {
      const duration = Duration(milliseconds: 2000);
      const options = {'fieldCount': 5, 'showTitle': false};

      const config = FormSkeletonConfig(
        width: 300.0,
        height: 400.0,
        animationDuration: duration,
        options: options,
      );

      expect(config.width, 300.0);
      expect(config.height, 400.0);
      expect(config.animationDuration, duration);
      expect(config.options, options);
    });

    test('should provide correct default values for getters', () {
      const config = FormSkeletonConfig();

      expect(config.fieldCount, 4);
      expect(config.showTitle, true);
      expect(config.showSubmitButton, true);
      expect(config.showCancelButton, false);
      expect(config.showResetButton, false);
      expect(config.showDescription, true);
      expect(config.showHelpText, false);
      expect(config.required, false);
      expect(config.fieldType, 'text');
    });

    test('should return custom values from options', () {
      const config = FormSkeletonConfig(
        options: {
          'fieldCount': 7,
          'showTitle': false,
          'showSubmitButton': false,
          'fieldType': 'email',
          'stepCount': 5,
        },
      );

      expect(config.fieldCount, 7);
      expect(config.showTitle, false);
      expect(config.showSubmitButton, false);
      expect(config.fieldType, 'email');
      expect(config.stepCount, 5);
    });

    test('should create copy with overridden values', () {
      const originalConfig = FormSkeletonConfig(
        width: 200.0,
        options: {'fieldCount': 3},
      );

      final newConfig = originalConfig.copyWith(
        width: 300.0,
        height: 400.0,
        options: {'fieldCount': 5, 'showTitle': false},
      );

      expect(newConfig.width, 300.0);
      expect(newConfig.height, 400.0);
      expect(newConfig.fieldCount, 5);
      expect(newConfig.showTitle, false);

      // Original should remain unchanged
      expect(originalConfig.width, 200.0);
      expect(originalConfig.height, isNull);
      expect(originalConfig.fieldCount, 3);
    });

    test('should implement equality correctly', () {
      const config1 = FormSkeletonConfig(
        width: 200.0,
        height: 300.0,
        options: {'fieldCount': 4},
      );

      const config2 = FormSkeletonConfig(
        width: 200.0,
        height: 300.0,
        options: {'fieldCount': 4},
      );

      const config3 = FormSkeletonConfig(
        width: 200.0,
        height: 300.0,
        options: {'fieldCount': 5},
      );

      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
    });

    test('should implement hashCode correctly', () {
      const config1 = FormSkeletonConfig(
        width: 200.0,
        options: {'fieldCount': 4},
      );

      const config2 = FormSkeletonConfig(
        width: 200.0,
        options: {'fieldCount': 4},
      );

      expect(config1.hashCode, equals(config2.hashCode));
    });
  });
}

