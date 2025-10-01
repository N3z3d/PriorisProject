/// **DETAILED FORM HELPERS** - Extracted Helper Methods
///
/// **LOT 7 FIX** : Méthodes helper extraites de DetailedFormSkeleton

import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import '../interfaces/form_skeleton_interface.dart';

/// Helpers spécialisés pour la création de composants detailed form
class DetailedFormHelpers {

  /// Crée l'en-tête du formulaire
  static Widget createFormHeader(bool showDescription) {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        SkeletonShapeFactory.text(width: 250, height: 28),
        if (showDescription)
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

  /// Crée un champ détaillé
  static Widget createDetailedField(SkeletonConfig config) {
    final fieldType = config.options['fieldType'] ?? 'text';
    final showHelpText = config.options['showHelpText'] ?? false;
    final required = config.options['required'] ?? false;

    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        // Label avec indicateur obligatoire
        SkeletonLayoutBuilder.horizontal(
          children: [
            SkeletonShapeFactory.text(width: 120, height: 18),
            if (required) ...[
              const SizedBox(width: 4),
              SkeletonShapeFactory.text(width: 8, height: 18),
            ],
          ],
        ),
        // Champ de saisie
        createInputByType(fieldType),
        // Texte d'aide
        if (showHelpText)
          SkeletonShapeFactory.text(width: 180, height: 14),
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
      case 'date':
        return SkeletonLayoutBuilder.horizontal(
          children: [
            Expanded(child: SkeletonShapeFactory.input()),
            const SizedBox(width: 8),
            SkeletonShapeFactory.circular(size: 24),
          ],
        );
      default: // text, email, password
        return SkeletonShapeFactory.input();
    }
  }

  /// Crée les actions du formulaire détaillé
  static Widget createDetailedFormActions() {
    return SkeletonLayoutBuilder.horizontal(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SkeletonShapeFactory.button(width: 80, height: 40), // Reset
        SkeletonLayoutBuilder.horizontal(
          children: [
            SkeletonShapeFactory.button(width: 80, height: 40), // Cancel
            const SizedBox(width: 12),
            SkeletonShapeFactory.button(width: 120, height: 40), // Submit
          ],
        ),
      ],
    );
  }

  /// Obtient le type de champ pour un index
  static String getFieldTypeForIndex(int index) {
    const fieldTypes = ['text', 'email', 'textarea', 'select', 'date'];
    return fieldTypes[index % fieldTypes.length];
  }
}