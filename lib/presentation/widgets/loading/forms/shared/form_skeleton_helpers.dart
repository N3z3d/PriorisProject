/// **SHARED FORM SKELETON HELPERS** - Common Helper Methods
///
/// **LOT 7 FIX** : Helpers communs pour réduire taille des composants

import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';

/// Helpers partagés pour tous les composants form skeleton
class SharedFormHelpers {

  /// Crée un champ de formulaire standard
  static Widget createFormField(String fieldType, {bool required = false}) {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        SkeletonLayoutBuilder.horizontal(
          children: [
            SkeletonShapeFactory.text(width: 100, height: 16),
            if (required) ...[
              const SizedBox(width: 4),
              SkeletonShapeFactory.text(width: 8, height: 16),
            ],
          ],
        ),
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
      case 'date':
        return SkeletonLayoutBuilder.horizontal(
          children: [
            Expanded(child: SkeletonShapeFactory.input()),
            const SizedBox(width: 8),
            SkeletonShapeFactory.circular(size: 24),
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
      default: // text, email, password
        return SkeletonShapeFactory.input();
    }
  }

  /// Crée les boutons d'actions standard
  static Widget createFormActions({
    bool showSubmit = true,
    bool showCancel = false,
    bool showReset = false,
  }) {
    final buttons = <Widget>[];

    if (showReset) {
      buttons.add(SkeletonShapeFactory.button(width: 80, height: 40));
    }
    if (showCancel) {
      buttons.add(SkeletonShapeFactory.button(width: 80, height: 40));
    }
    if (showSubmit) {
      buttons.add(SkeletonShapeFactory.button(width: 120, height: 40));
    }

    return SkeletonLayoutBuilder.horizontal(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 12,
      children: buttons,
    );
  }

  /// Obtient le type de champ pour un index donné
  static String getFieldType(int index) {
    const types = ['text', 'email', 'textarea', 'select', 'date'];
    return types[index % types.length];
  }
}