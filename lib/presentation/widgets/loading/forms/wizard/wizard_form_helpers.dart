/// **WIZARD FORM HELPERS** - Extracted Helper Methods
///
/// **LOT 7 FIX** : Méthodes helper extraites de WizardFormSkeleton
/// **SRP** : Utilitaires de création de widgets wizard uniquement

import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import '../interfaces/form_skeleton_interface.dart';

/// Helpers spécialisés pour la création de composants wizard
class WizardFormHelpers {

  /// Crée les indicateurs d'étapes
  static Widget createStepIndicators(int stepCount, int currentStep) {
    return SkeletonLayoutBuilder.horizontal(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(stepCount, (index) {
        return SkeletonLayoutBuilder.horizontal(
          mainAxisSize: MainAxisSize.min,
          children: [
            SkeletonShapeFactory.circular(
              size: index <= currentStep ? 32 : 24,
            ),
            if (index < stepCount - 1) ...[
              const SizedBox(width: 8),
              SkeletonShapeFactory.rectangular(width: 40, height: 2),
              const SizedBox(width: 8),
            ],
          ],
        );
      }),
    );
  }

  /// Crée les boutons de navigation
  static Widget createNavigationButtons(int stepCount, int currentStep) {
    return SkeletonLayoutBuilder.horizontal(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (currentStep > 0)
          SkeletonShapeFactory.button(width: 80, height: 40)
        else
          const SizedBox(width: 80),
        SkeletonShapeFactory.button(
          width: currentStep < stepCount - 1 ? 80 : 120,
          height: 40,
        ),
      ],
    );
  }

  /// Crée un champ de wizard
  static Widget createWizardField(SkeletonConfig config) {
    final fieldType = config.options['fieldType'] ?? 'text';

    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        SkeletonShapeFactory.text(width: 120, height: 16),
        createInputByType(fieldType),
      ],
    );
  }

  /// Crée un input selon le type
  static Widget createInputByType(String fieldType) {
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
      default:
        return SkeletonShapeFactory.input();
    }
  }

  /// Crée un indicateur de progression
  static Widget createProgressIndicator() {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        SkeletonShapeFactory.text(width: 100, height: 16),
        SkeletonShapeFactory.progressBar(width: double.infinity),
      ],
    );
  }

  /// Crée le contenu d'une étape
  static Widget createStepContent() {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        SkeletonShapeFactory.text(width: 200, height: 20),
        SkeletonShapeFactory.input(),
        SkeletonShapeFactory.input(),
      ],
    );
  }

  /// Crée les actions de stepper
  static Widget createStepperActions(int stepCount, int currentStep) {
    return SkeletonLayoutBuilder.horizontal(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (currentStep > 0) ...[
          SkeletonShapeFactory.button(width: 70, height: 36),
          const SizedBox(width: 12),
        ],
        SkeletonShapeFactory.button(width: 90, height: 36),
      ],
    );
  }

  /// Obtient le type de champ pour un index
  static String getFieldTypeForIndex(int index) {
    const fieldTypes = ['text', 'email', 'textarea', 'select'];
    return fieldTypes[index % fieldTypes.length];
  }
}