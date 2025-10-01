import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import 'form_skeleton_config.dart';

/// Base interface for form skeleton factories
/// Follows Interface Segregation Principle
abstract class BaseFormSkeletonFactory {
  /// Creates a form skeleton widget based on the provided configuration
  Widget create(FormSkeletonConfig config);

  /// Gets the default animation duration for this factory
  Duration get defaultAnimationDuration => const Duration(milliseconds: 1500);

  /// Utility method to get field type for a given index
  /// Provides consistent field type cycling across different forms
  String getFieldTypeForIndex(int index) {
    const fieldTypes = ['text', 'email', 'textarea', 'select', 'date', 'checkbox'];
    return fieldTypes[index % fieldTypes.length];
  }

  /// Utility method to get question type for surveys
  String getQuestionTypeForIndex(int index) {
    const questionTypes = ['radio', 'checkbox', 'text', 'scale'];
    return questionTypes[index % questionTypes.length];
  }

  /// Creates a basic form field with label and input
  Widget createBasicFormField(FormSkeletonConfig config) {
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

  /// Creates input widgets based on field type
  Widget createInputByType(String fieldType, FormSkeletonConfig config) {
    switch (fieldType) {
      case 'textarea':
        return SkeletonShapeFactory.input(height: 80);
      case 'select':
        return SkeletonLayoutBuilder.horizontal(
          children: [
            Expanded(child: SkeletonShapeFactory.input()),
            const SizedBox(width: 8),
            SkeletonShapeFactory.circular(size: 20),
          ],
        );
      case 'checkbox':
        return SkeletonLayoutBuilder.horizontal(
          children: [
            SkeletonShapeFactory.rounded(width: 20, height: 20),
            const SizedBox(width: 12),
            SkeletonShapeFactory.text(width: 120, height: 16),
          ],
        );
      case 'radio':
        return SkeletonLayoutBuilder.vertical(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: List.generate(3, (index) {
            return SkeletonLayoutBuilder.horizontal(
              children: [
                SkeletonShapeFactory.circular(size: 16),
                const SizedBox(width: 12),
                SkeletonShapeFactory.text(width: 100, height: 16),
              ],
            );
          }),
        );
      case 'date':
        return SkeletonLayoutBuilder.horizontal(
          children: [
            Expanded(child: SkeletonShapeFactory.input()),
            const SizedBox(width: 8),
            SkeletonShapeFactory.circular(size: 24),
          ],
        );
      default: // text, email, password, etc.
        return SkeletonShapeFactory.input();
    }
  }

  /// Creates form action buttons
  Widget createFormActions(FormSkeletonConfig config) {
    final buttons = <Widget>[];

    if (config.showResetButton) {
      buttons.add(SkeletonShapeFactory.button(width: 80, height: 40));
    }

    if (config.showCancelButton) {
      buttons.add(SkeletonShapeFactory.button(width: 80, height: 40));
    }

    if (config.showSubmitButton) {
      buttons.add(SkeletonShapeFactory.button(width: 120, height: 40));
    }

    return SkeletonLayoutBuilder.horizontal(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 12,
      children: buttons,
    );
  }
}