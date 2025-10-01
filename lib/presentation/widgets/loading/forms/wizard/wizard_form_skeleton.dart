/// **WIZARD FORM SKELETON** - SRP Specialized Component
///
/// **LOT 7** : Composant spécialisé pour formulaires à étapes (wizards)
/// **SRP** : Gestion uniquement des formulaires multi-étapes avec navigation
/// **Taille** : <200 lignes (extraction depuis 700 lignes God Class)

import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import '../interfaces/form_skeleton_interface.dart';
import 'wizard_form_helpers.dart';

/// Composant spécialisé pour créer des skelettes de formulaires wizard
///
/// **SRP** : Formulaires multi-étapes avec indicateurs de progression
/// **OCP** : Extensible via configuration d'étapes et navigation
class WizardFormSkeleton implements IFormSkeletonComponent {
  @override
  String get componentId => 'wizard_form_skeleton';

  @override
  List<String> get supportedTypes => [
    'wizard_form',
    'stepper_form',
    'multi_step_form',
    'guided_form',
  ];

  @override
  List<String> get availableVariants => [
    'wizard',
    'stepper',
  ];

  @override
  bool canHandle(String skeletonType) {
    return supportedTypes.contains(skeletonType) ||
           skeletonType.contains('wizard') ||
           skeletonType.contains('step') ||
           skeletonType.contains('multi');
  }

  @override
  Widget createSkeleton({
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    return createVariant(
      'wizard',
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
      case 'stepper':
        return _createStepperWizard(config);
      case 'wizard':
      default:
        return _createStandardWizard(config);
    }
  }

  /// Crée un formulaire wizard standard avec étapes
  Widget _createStandardWizard(SkeletonConfig config) {
    final stepCount = config.options['stepCount'] ?? 3;
    final currentStep = config.options['currentStep'] ?? 0;
    final fieldsPerStep = config.options['fieldsPerStep'] ?? 2;

    return SkeletonContainer(
      width: config.width,
      height: config.height,
      borderRadius: BorderRadiusTokens.modal,
      animationDuration: config.animationDuration ?? const Duration(milliseconds: 1500),
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: [
          // Indicateurs d'étapes
          WizardFormHelpers.createStepIndicators(stepCount, currentStep),

          // Titre de l'étape actuelle
          SkeletonShapeFactory.text(width: 180, height: 24),

          // Champs de l'étape courante
          ...List.generate(fieldsPerStep, (index) => WizardFormHelpers.createWizardField(
            config.copyWith(
              options: {
                'fieldType': WizardFormHelpers.getFieldTypeForIndex(index),
              },
            ),
          )),

          const Spacer(),

          // Boutons de navigation
          WizardFormHelpers.createNavigationButtons(stepCount, currentStep),
        ],
      ),
    );
  }

  /// Crée un wizard style stepper vertical
  Widget _createStepperWizard(SkeletonConfig config) {
    final stepCount = config.options['stepCount'] ?? 4;
    final currentStep = config.options['currentStep'] ?? 1;

    return SkeletonContainer(
      width: config.width,
      height: config.height,
      borderRadius: BorderRadiusTokens.card,
      animationDuration: config.animationDuration ?? const Duration(milliseconds: 1500),
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          // Progress indicator
          WizardFormHelpers.createProgressIndicator(),

          // Step content area
          Expanded(
            child: WizardFormHelpers.createStepContent(),
          ),

          // Action buttons
          WizardFormHelpers.createStepperActions(stepCount, currentStep),
        ],
      ),
    );
  }

}