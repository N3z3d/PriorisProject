import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';

/// Configuration holder for form skeletons.
@immutable
class FormSkeletonConfig extends SkeletonConfig {
  const FormSkeletonConfig({
    super.width,
    super.height,
    super.options = const {},
    super.animationDuration,
    super.animationController,
  });

  int get fieldCount => (options['fieldCount'] as int?) ?? 4;
  bool get showTitle => options['showTitle'] as bool? ?? true;
  bool get showSubmitButton => options['showSubmitButton'] as bool? ?? true;
  bool get showCancelButton => options['showCancelButton'] as bool? ?? false;
  bool get showResetButton => options['showResetButton'] as bool? ?? false;
  bool get showDescription => options['showDescription'] as bool? ?? true;
  bool get showHelpText => options['showHelpText'] as bool? ?? false;
  bool get required => options['required'] as bool? ?? false;
  String get fieldType => options['fieldType'] as String? ?? 'text';
  int get stepCount => options['stepCount'] as int? ?? 0;

  @override
  FormSkeletonConfig copyWith({
    double? width,
    double? height,
    Map<String, dynamic>? options,
    Duration? animationDuration,
    AnimationController? animationController,
  }) {
    return FormSkeletonConfig(
      width: width ?? this.width,
      height: height ?? this.height,
      options: options ?? this.options,
      animationDuration: animationDuration ?? this.animationDuration,
      animationController: animationController ?? this.animationController,
    );
  }

  @override
  int get hashCode => Object.hash(
        width,
        height,
        animationDuration,
        animationController,
        Object.hashAll(options.entries),
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FormSkeletonConfig) return false;
    return width == other.width &&
        height == other.height &&
        animationDuration == other.animationDuration &&
        animationController == other.animationController &&
        _mapEquals(options, other.options);
  }

  bool _mapEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (!b.containsKey(entry.key) || b[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }
}
