/// **SURVEY FORM SKELETON** - SRP Specialized Component
///
/// **LOT 7** : Composant spécialisé pour formulaires de sondage/questionnaire
/// **SRP** : Gestion uniquement des formulaires de questions/réponses
/// **Taille** : <200 lignes (extraction depuis 700 lignes God Class)

import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import '../interfaces/form_skeleton_interface.dart';
import 'survey_form_helpers.dart';

/// Composant spécialisé pour créer des skelettes de formulaires de sondage
///
/// **SRP** : Formulaires de questionnaires avec types de questions variés
/// **OCP** : Extensible via configuration de questions et réponses
class SurveyFormSkeleton implements IFormSkeletonComponent {
  @override
  String get componentId => 'survey_form_skeleton';

  @override
  List<String> get supportedTypes => [
    'survey_form',
    'questionnaire',
    'poll_form',
    'feedback_form',
  ];

  @override
  List<String> get availableVariants => [
    'survey',
    'poll',
  ];

  @override
  bool canHandle(String skeletonType) {
    return supportedTypes.contains(skeletonType) ||
           skeletonType.contains('survey') ||
           skeletonType.contains('poll') ||
           skeletonType.contains('question');
  }

  @override
  Widget createSkeleton({
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    return createVariant(
      'survey',
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
      case 'poll':
        return _createPollForm(config);
      case 'survey':
      default:
        return _createStandardSurvey(config);
    }
  }

  /// Crée un formulaire de sondage standard avec questions variées
  Widget _createStandardSurvey(SkeletonConfig config) {
    final questionCount = config.options['questionCount'] ?? 4;

    return SkeletonContainer(
      width: config.width,
      height: config.height,
      borderRadius: BorderRadiusTokens.card,
      animationDuration: config.animationDuration ?? const Duration(milliseconds: 1500),
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: [
          // Titre du sondage
          SkeletonShapeFactory.text(width: 220, height: 24),

          // Questions du sondage
          ...List.generate(questionCount, (index) => SurveyFormHelpers.createSurveyQuestion(
            config.copyWith(
              options: {
                ...config.options,
                'questionType': SurveyFormHelpers.getQuestionTypeForIndex(index),
                'questionNumber': index + 1,
              },
            ),
          )),

          // Indicateur de progression
          SurveyFormHelpers.createProgressSection(),

          // Bouton de soumission
          SkeletonShapeFactory.button(width: double.infinity),
        ],
      ),
    );
  }

  /// Crée un sondage simple style poll
  Widget _createPollForm(SkeletonConfig config) {
    final optionCount = config.options['optionCount'] ?? 4;

    return SkeletonContainer(
      width: config.width,
      height: config.height ?? 200,
      borderRadius: BorderRadiusTokens.card,
      animationDuration: config.animationDuration ?? const Duration(milliseconds: 1500),
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          // Question du poll
          SkeletonShapeFactory.text(width: 280, height: 20),

          // Options de réponse
          ...List.generate(optionCount, (index) => SurveyFormHelpers.createPollOption(index)),

          // Bouton vote
          SkeletonShapeFactory.button(width: 120, height: 40),
        ],
      ),
    );
  }

}