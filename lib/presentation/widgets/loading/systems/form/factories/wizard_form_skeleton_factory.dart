import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import '../base_form_skeleton_factory.dart';
import '../form_skeleton_config.dart';

/// Factory for creating wizard form skeletons
/// Single Responsibility: Creates multi-step wizard form layouts with step indicators
class WizardFormSkeletonFactory extends BaseFormSkeletonFactory {
  @override
  Widget create(FormSkeletonConfig config) {
    return SkeletonContainer(
      width: config.width,
      height: config.height,
      borderRadius: BorderRadiusTokens.modal,
      animationDuration: config.animationDuration ?? defaultAnimationDuration,
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: [
          // Step indicators
          _createStepIndicators(config),

          // Step title
          SkeletonShapeFactory.text(width: 180, height: 24),

          // Current step fields
          ...List.generate(config.fieldsPerStep, (index) => createBasicFormField(
            config.copyWith(
              options: {
                ...config.options,
                'fieldType': getFieldTypeForIndex(index),
              },
            ),
          )),

          const Spacer(),

          // Navigation buttons
          _createNavigationButtons(config),
        ],
      ),
    );
  }

  /// Creates step indicators showing current progress through the wizard
  Widget _createStepIndicators(FormSkeletonConfig config) {
    return SkeletonLayoutBuilder.horizontal(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(config.stepCount, (index) {
        return SkeletonLayoutBuilder.horizontal(
          mainAxisSize: MainAxisSize.min,
          children: [
            SkeletonShapeFactory.circular(
              size: index <= config.currentStep ? 32 : 24,
            ),
            if (index < config.stepCount - 1) ...[
              const SizedBox(width: 8),
              SkeletonShapeFactory.rectangular(width: 40, height: 2),
              const SizedBox(width: 8),
            ],
          ],
        );
      }),
    );
  }

  /// Creates navigation buttons for moving between wizard steps
  Widget _createNavigationButtons(FormSkeletonConfig config) {
    return SkeletonLayoutBuilder.horizontal(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back button (visible only if not on first step)
        if (config.currentStep > 0)
          SkeletonShapeFactory.button(width: 80, height: 40)
        else
          const SizedBox(width: 80),

        // Next/Finish button
        SkeletonShapeFactory.button(
          width: config.currentStep < config.stepCount - 1 ? 80 : 120,
          height: 40,
        ),
      ],
    );
  }
}