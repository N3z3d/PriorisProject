import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import '../base_form_skeleton_factory.dart';
import '../form_skeleton_config.dart';

/// Factory for creating standard form skeletons
/// Single Responsibility: Creates standard form layouts with multiple fields
class StandardFormSkeletonFactory extends BaseFormSkeletonFactory {
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
          // Form title
          if (config.showTitle)
            SkeletonShapeFactory.text(width: 200, height: 24),

          // Form fields
          ...List.generate(config.fieldCount, (index) => _createStandardField(
            config.copyWith(
              options: {
                ...config.options,
                'fieldType': getFieldTypeForIndex(index),
                'required': index < 2, // First two fields are required
              },
            ),
          )),

          // Action buttons
          createFormActions(config),
        ],
      ),
    );
  }

  /// Creates a standard form field with label and input
  Widget _createStandardField(FormSkeletonConfig config) {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        // Label with optional required indicator
        SkeletonLayoutBuilder.horizontal(
          children: [
            SkeletonShapeFactory.text(
              width: 100 + (config.fieldType.hashCode % 3) * 30.0,
              height: 16,
            ),
            if (config.required) ...[
              const SizedBox(width: 4),
              SkeletonShapeFactory.text(width: 8, height: 16),
            ],
          ],
        ),

        // Input field
        createInputByType(config.fieldType, config),
      ],
    );
  }
}