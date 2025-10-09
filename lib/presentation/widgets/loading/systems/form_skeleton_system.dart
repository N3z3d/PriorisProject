import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_component_library.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';

/// Form skeleton system generating various form layouts.
class FormSkeletonSystem implements IVariantSkeletonSystem, IAnimatedSkeletonSystem {
  static const _supportedTypes = <String>{
    'form',
    'form_field',
    'login_form',
    'wizard_form',
  };

  static const _variants = <String>{
    'standard',
    'login',
    'wizard',
  };

  @override
  String get systemId => 'form_skeleton_system';

  @override
  List<String> get supportedTypes => _supportedTypes.toList(growable: false);

  @override
  List<String> get availableVariants => _variants.toList(growable: false);

  @override
  bool canHandle(String skeletonType) => _supportedTypes.contains(skeletonType);

  SkeletonConfig _config({
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    return SkeletonConfig(
      width: width,
      height: height,
      options: options ?? const {},
    );
  }

  @override
  Widget createSkeleton({
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    return createVariant(
      'standard',
      width: width,
      height: height,
      options: options,
    );
  }

  @override
  Widget createVariant(
    String variant, {
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    final config = _config(width: width, height: height, options: options);
    switch (variant) {
      case 'login':
        return _buildLoginForm(config);
      case 'wizard':
        return _buildWizardForm(config);
      case 'standard':
      default:
        return _buildStandardForm(config);
    }
  }

  @override
  Widget createAnimatedSkeleton({
    double? width,
    double? height,
    Duration? duration,
    AnimationController? controller,
    Map<String, dynamic>? options,
  }) {
    final child = createSkeleton(
      width: width,
      height: height,
      options: options,
    );

    final animationDuration = duration ?? defaultAnimationDuration;

    if (controller != null) {
      return AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return FadeTransition(
            opacity: controller,
            child: child,
          );
        },
      );
    }

    return AnimatedOpacity(
      opacity: 1,
      duration: animationDuration,
      curve: Curves.easeIn,
      child: child,
    );
  }

  @override
  Duration get defaultAnimationDuration => const Duration(milliseconds: 350);

  Widget _buildStandardForm(SkeletonConfig config) {
    final fieldCount = (config.options['fieldCount'] as int?) ?? 4;
    final showSubmit = config.options['showSubmitButton'] as bool? ?? true;

    return SkeletonLayoutBuilder.vertical(
      spacing: 16,
      children: [
        SkeletonBlocks.header(widthFactor: 0.5),
        SkeletonBlocks.subtitle(widthFactor: 0.3),
        for (int i = 0; i < fieldCount; i++) SkeletonShapeFactory.input(),
        if (showSubmit) SkeletonShapeFactory.button(width: double.infinity),
      ],
    );
  }

  Widget _buildLoginForm(SkeletonConfig config) {
    final showSocial = config.options['showSocialLogin'] as bool? ?? true;

    return SkeletonLayoutBuilder.vertical(
      spacing: 20,
      children: [
        SkeletonBlocks.header(widthFactor: 0.6),
        SkeletonShapeFactory.input(),
        SkeletonShapeFactory.input(),
        SkeletonShapeFactory.button(width: double.infinity),
        if (showSocial)
          SkeletonLayoutBuilder.horizontal(
            spacing: 12,
            children: [
              Expanded(child: SkeletonShapeFactory.button(height: 44)),
              Expanded(child: SkeletonShapeFactory.button(height: 44)),
            ],
          ),
      ],
    );
  }

  Widget _buildWizardForm(SkeletonConfig config) {
    final steps = (config.options['stepCount'] as int?) ?? 3;
    final currentStep = (config.options['currentStep'] as int?) ?? 1;

    return SkeletonLayoutBuilder.vertical(
      spacing: 20,
      children: [
        SkeletonBlocks.header(widthFactor: 0.5),
        SkeletonBlocks.stepper(stepCount: steps, currentStep: currentStep),
        SkeletonBlocks.paragraph(lines: 3),
        SkeletonShapeFactory.input(height: 80),
        SkeletonLayoutBuilder.horizontal(
          spacing: 12,
          children: [
            SkeletonShapeFactory.button(width: 120),
            Expanded(child: SkeletonShapeFactory.button()),
          ],
        ),
      ],
    );
  }
}
