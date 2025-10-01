import 'package:flutter/material.dart';

/// Value object for form skeleton configuration
/// Encapsulates all configuration parameters for form skeleton factories
class FormSkeletonConfig {
  const FormSkeletonConfig({
    this.width,
    this.height,
    this.animationDuration,
    this.animationController,
    this.options = const {},
  });

  final double? width;
  final double? height;
  final Duration? animationDuration;
  final AnimationController? animationController;
  final Map<String, dynamic> options;

  /// Creates a copy of this config with optional parameter overrides
  FormSkeletonConfig copyWith({
    double? width,
    double? height,
    Duration? animationDuration,
    AnimationController? animationController,
    Map<String, dynamic>? options,
  }) {
    return FormSkeletonConfig(
      width: width ?? this.width,
      height: height ?? this.height,
      animationDuration: animationDuration ?? this.animationDuration,
      animationController: animationController ?? this.animationController,
      options: options ?? this.options,
    );
  }

  // Getters for commonly used options with defaults

  int get fieldCount => options['fieldCount'] ?? 4;
  bool get showTitle => options['showTitle'] ?? true;
  bool get showSubmitButton => options['showSubmitButton'] ?? true;
  bool get showCancelButton => options['showCancelButton'] ?? false;
  bool get showResetButton => options['showResetButton'] ?? false;
  bool get showDescription => options['showDescription'] ?? true;
  bool get showHelpText => options['showHelpText'] ?? false;
  bool get required => options['required'] ?? false;
  String get fieldType => options['fieldType'] ?? 'text';

  // Wizard-specific getters
  int get stepCount => options['stepCount'] ?? 3;
  int get currentStep => options['currentStep'] ?? 0;
  int get fieldsPerStep => options['fieldsPerStep'] ?? 2;

  // Survey-specific getters
  int get questionCount => options['questionCount'] ?? 4;
  String get questionType => options['questionType'] ?? 'radio';
  int get questionNumber => options['questionNumber'] ?? 1;

  // Search-specific getters
  bool get showFilters => options['showFilters'] ?? true;
  int get filterCount => options['filterCount'] ?? 3;

  // Login-specific getters
  bool get showSocialLogin => options['showSocialLogin'] ?? true;
  bool get showForgotPassword => options['showForgotPassword'] ?? true;
  bool get showSignUp => options['showSignUp'] ?? true;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FormSkeletonConfig &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          height == other.height &&
          animationDuration == other.animationDuration &&
          animationController == other.animationController &&
          _mapEquals(options, other.options);

  @override
  int get hashCode =>
      width.hashCode ^
      height.hashCode ^
      animationDuration.hashCode ^
      animationController.hashCode ^
      options.hashCode;

  bool _mapEquals(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (map1.length != map2.length) return false;
    for (final key in map1.keys) {
      if (!map2.containsKey(key) || map1[key] != map2[key]) return false;
    }
    return true;
  }
}