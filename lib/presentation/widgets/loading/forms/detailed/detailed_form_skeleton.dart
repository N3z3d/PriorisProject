/// **DETAILED FORM SKELETON** - SRP Specialized Component
///
/// **LOT 7** : Composant spécialisé pour formulaires détaillés avec aide
/// **SRP** : Gestion uniquement des formulaires avec descriptions et aide
/// **Taille** : <200 lignes (extraction depuis 700 lignes God Class)

import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import '../interfaces/form_skeleton_interface.dart';
import 'detailed_form_helpers.dart';

/// Composant spécialisé pour créer des skelettes de formulaires détaillés
///
/// **SRP** : Formulaires avec descriptions, aide contextuelle et validation
/// **OCP** : Extensible via configuration d'aide et descriptions
class DetailedFormSkeleton implements IFormSkeletonComponent {
  @override
  String get componentId => 'detailed_form_skeleton';

  @override
  List<String> get supportedTypes => [
    'detailed_form',
    'descriptive_form',
    'help_form',
    'validated_form',
  ];

  @override
  List<String> get availableVariants => [
    'detailed',
    'descriptive',
  ];

  @override
  bool canHandle(String skeletonType) {
    return supportedTypes.contains(skeletonType) ||
           skeletonType.contains('detailed') ||
           skeletonType.contains('help') ||
           skeletonType.contains('validate');
  }

  @override
  Widget createSkeleton({
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    return createVariant(
      'detailed',
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
      case 'descriptive':
        return _createDescriptiveForm(config);
      case 'detailed':
      default:
        return _createDetailedForm(config);
    }
  }

  /// Crée un formulaire détaillé avec descriptions et aide
  Widget _createDetailedForm(SkeletonConfig config) {
    final fieldCount = config.options['fieldCount'] ?? 5;
    final showDescription = config.options['showDescription'] ?? true;

    return SkeletonContainer(
      width: config.width,
      height: config.height,
      borderRadius: BorderRadiusTokens.modal,
      animationDuration: config.animationDuration ?? const Duration(milliseconds: 1500),
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: [
          // En-tête du formulaire
          DetailedFormHelpers.createFormHeader(showDescription),

          // Champs détaillés
          ...List.generate(fieldCount, (index) => DetailedFormHelpers.createDetailedField(
            config.copyWith(
              options: {
                ...config.options,
                'fieldType': DetailedFormHelpers.getFieldTypeForIndex(index),
                'showHelpText': index % 2 == 0,
                'required': index < 3,
              },
            ),
          )),

          // Footer avec actions
          DetailedFormHelpers.createDetailedFormActions(),
        ],
      ),
    );
  }

  /// Crée un formulaire avec emphasis sur les descriptions
  Widget _createDescriptiveForm(SkeletonConfig config) {
    final fieldCount = config.options['fieldCount'] ?? 4;

    return SkeletonContainer(
      width: config.width,
      height: config.height,
      borderRadius: BorderRadiusTokens.card,
      animationDuration: config.animationDuration ?? const Duration(milliseconds: 1500),
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          DetailedFormHelpers.createFormHeader(true),
          ...List.generate(fieldCount, (index) => DetailedFormHelpers.createDetailedField(
            config.copyWith(
              options: {
                'fieldType': DetailedFormHelpers.getFieldTypeForIndex(index),
                'showHelpText': true,
                'required': index < 2,
              },
            ),
          )),
          SkeletonShapeFactory.button(width: double.infinity),
        ],
      ),
    );
  }
}