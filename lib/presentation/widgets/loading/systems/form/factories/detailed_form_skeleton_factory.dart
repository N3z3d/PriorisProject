import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import '../base_form_skeleton_factory.dart';
import '../form_skeleton_config.dart';

/// Factory for creating detailed form skeletons
/// Single Responsibility: Creates detailed form layouts with descriptions and help text
class DetailedFormSkeletonFactory extends BaseFormSkeletonFactory {
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
          // Form header with title and description
          _createFormHeader(config),

          // Detailed form fields
          ...List.generate(config.fieldCount, (index) => _createDetailedField(
            config.copyWith(
              options: {
                ...config.options,
                'fieldType': getFieldTypeForIndex(index),
                'showHelpText': index % 2 == 0,
                'required': index < 3,
              },
            ),
          )),

          // Form footer with extended actions
          _createExtendedFormActions(config),
        ],
      ),
    );
  }

  /// Creates form header with title and optional description
  Widget _createFormHeader(FormSkeletonConfig config) {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        SkeletonShapeFactory.text(width: 250, height: 28),
        if (config.showDescription)
          SkeletonLayoutBuilder.vertical(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              SkeletonShapeFactory.text(width: double.infinity, height: 16),
              SkeletonShapeFactory.text(width: 300, height: 16),
            ],
          ),
      ],
    );
  }

  /// Creates a detailed form field with label, input, and optional help text
  Widget _createDetailedField(FormSkeletonConfig config) {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        // Label with required indicator
        SkeletonLayoutBuilder.horizontal(
          children: [
            SkeletonShapeFactory.text(width: 120, height: 18),
            if (config.required) ...[
              const SizedBox(width: 4),
              SkeletonShapeFactory.text(width: 8, height: 18),
            ],
          ],
        ),

        // Input field
        createInputByType(config.fieldType, config),

        // Help text
        if (config.showHelpText)
          SkeletonShapeFactory.text(width: 180, height: 14),
      ],
    );
  }

  /// Creates extended form actions with submit, cancel, and reset buttons
  Widget _createExtendedFormActions(FormSkeletonConfig config) {
    final extendedConfig = config.copyWith(
      options: {
        ...config.options,
        'showSubmitButton': true,
        'showCancelButton': true,
        'showResetButton': true,
      },
    );

    return createFormActions(extendedConfig);
  }
}