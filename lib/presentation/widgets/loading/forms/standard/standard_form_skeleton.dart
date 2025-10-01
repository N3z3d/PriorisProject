/// **STANDARD FORM SKELETON** - SRP Specialized Component
///
/// **LOT 7** : Composant spécialisé pour formulaires standards
/// **SRP** : Gestion uniquement des formulaires standards multi-champs
/// **Taille** : <200 lignes (extraction depuis 700 lignes God Class)

import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import '../interfaces/form_skeleton_interface.dart';
import '../shared/form_skeleton_helpers.dart';

/// Composant spécialisé pour créer des skelettes de formulaires standards
///
/// **SRP** : Formulaires standards avec champs multiples uniquement
/// **OCP** : Extensible via options de configuration
class StandardFormSkeleton implements IFormSkeletonComponent {
  @override
  String get componentId => 'standard_form_skeleton';

  @override
  List<String> get supportedTypes => [
    'form_field',
    'input_field',
    'standard_form',
  ];

  @override
  List<String> get availableVariants => [
    'standard',
    'basic',
  ];

  @override
  bool canHandle(String skeletonType) {
    return supportedTypes.contains(skeletonType) ||
           skeletonType.contains('standard') ||
           skeletonType.contains('basic');
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
    final config = SkeletonConfig(
      width: width,
      height: height,
      options: options ?? {},
    );

    switch (variant) {
      case 'basic':
        return _createBasicForm(config);
      case 'standard':
      default:
        return _createStandardForm(config);
    }
  }

  /// Crée un formulaire standard avec champs multiples
  Widget _createStandardForm(SkeletonConfig config) {
    final fieldCount = config.options['fieldCount'] ?? 4;
    final showTitle = config.options['showTitle'] ?? true;
    final showSubmitButton = config.options['showSubmitButton'] ?? true;
    final showCancelButton = config.options['showCancelButton'] ?? false;

    return SkeletonContainer(
      width: config.width,
      height: config.height,
      borderRadius: BorderRadiusTokens.modal,
      animationDuration: config.animationDuration ?? const Duration(milliseconds: 1500),
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: [
          // Form title
          if (showTitle)
            SkeletonShapeFactory.text(width: 200, height: 24),

          // Form fields
          ...List.generate(fieldCount, (index) => SharedFormHelpers.createFormField(
            SharedFormHelpers.getFieldType(index),
            required: index < 2,
          )),

          // Action buttons
          SharedFormHelpers.createFormActions(
            showSubmit: showSubmitButton,
            showCancel: showCancelButton,
          ),
        ],
      ),
    );
  }

  /// Crée un formulaire basique simplifié
  Widget _createBasicForm(SkeletonConfig config) {
    final fieldCount = config.options['fieldCount'] ?? 2;

    return SkeletonContainer(
      width: config.width,
      height: config.height,
      borderRadius: BorderRadiusTokens.card,
      animationDuration: config.animationDuration ?? const Duration(milliseconds: 1500),
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          ...List.generate(fieldCount, (index) => SharedFormHelpers.createFormField(
            'text',
            required: index == 0,
          )),
          SkeletonShapeFactory.button(width: double.infinity),
        ],
      ),
    );
  }
}