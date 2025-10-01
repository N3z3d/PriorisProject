import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import '../base_form_skeleton_factory.dart';
import '../form_skeleton_config.dart';

/// Factory for creating compact form skeletons
/// Single Responsibility: Creates compact form layouts with minimal spacing
class CompactFormSkeletonFactory extends BaseFormSkeletonFactory {
  @override
  Widget create(FormSkeletonConfig config) {
    return SkeletonContainer(
      width: config.width,
      height: config.height,
      borderRadius: BorderRadiusTokens.card,
      padding: const EdgeInsets.all(12),
      animationDuration: config.animationDuration ?? defaultAnimationDuration,
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          // Compact form fields
          ...List.generate(config.fieldCount, (index) => _createCompactField(
            config.copyWith(
              options: {
                ...config.options,
                'fieldType': getFieldTypeForIndex(index),
              },
            ),
          )),

          // Submit button if requested
          if (config.showSubmitButton)
            SkeletonShapeFactory.button(
              width: double.infinity,
              height: 36,
            ),
        ],
      ),
    );
  }

  /// Creates a compact form field with horizontal label-input layout
  Widget _createCompactField(FormSkeletonConfig config) {
    return SkeletonLayoutBuilder.horizontal(
      children: [
        SkeletonShapeFactory.text(width: 80, height: 14),
        const SizedBox(width: 12),
        Expanded(child: createInputByType(config.fieldType, config)),
      ],
    );
  }
}