/// **SURVEY FORM HELPERS** - Extracted Helper Methods
///
/// **LOT 7 FIX** : Méthodes helper extraites de SurveyFormSkeleton

import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import '../interfaces/form_skeleton_interface.dart';

/// Helpers spécialisés pour la création de composants survey form
class SurveyFormHelpers {

  /// Crée une question de sondage
  static Widget createSurveyQuestion(SkeletonConfig config) {
    final questionType = config.options['questionType'] ?? 'radio';

    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        // Numéro et texte de la question
        SkeletonLayoutBuilder.horizontal(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonShapeFactory.text(width: 20, height: 16),
            const SizedBox(width: 8),
            Expanded(
              child: SkeletonLayoutBuilder.vertical(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  SkeletonShapeFactory.text(width: double.infinity, height: 16),
                  SkeletonShapeFactory.text(width: 250, height: 16),
                ],
              ),
            ),
          ],
        ),
        // Options de réponse selon le type
        createAnswerOptions(questionType),
      ],
    );
  }

  /// Crée les options de réponse selon le type
  static Widget createAnswerOptions(String questionType) {
    switch (questionType) {
      case 'radio':
        return SkeletonLayoutBuilder.vertical(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: List.generate(4, (index) {
            return SkeletonLayoutBuilder.horizontal(
              children: [
                SkeletonShapeFactory.circular(size: 16),
                const SizedBox(width: 12),
                SkeletonShapeFactory.text(width: 120 + index * 20.0, height: 16),
              ],
            );
          }),
        );
      case 'checkbox':
        return SkeletonLayoutBuilder.vertical(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: List.generate(3, (index) {
            return SkeletonLayoutBuilder.horizontal(
              children: [
                SkeletonShapeFactory.rounded(width: 16, height: 16),
                const SizedBox(width: 12),
                SkeletonShapeFactory.text(width: 100 + index * 15.0, height: 16),
              ],
            );
          }),
        );
      case 'scale':
        return SkeletonLayoutBuilder.horizontal(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            return SkeletonLayoutBuilder.vertical(
              children: [
                SkeletonShapeFactory.circular(size: 20),
                const SizedBox(height: 4),
                SkeletonShapeFactory.text(width: 12, height: 12),
              ],
            );
          }),
        );
      case 'text':
      default:
        return SkeletonShapeFactory.input(height: 60);
    }
  }

  /// Crée la section de progression
  static Widget createProgressSection() {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        SkeletonShapeFactory.text(width: 120, height: 14),
        SkeletonShapeFactory.progressBar(width: double.infinity),
      ],
    );
  }

  /// Crée une option de poll
  static Widget createPollOption(int index) {
    return SkeletonLayoutBuilder.horizontal(
      children: [
        SkeletonShapeFactory.circular(size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: SkeletonShapeFactory.text(width: double.infinity, height: 16),
        ),
        SkeletonShapeFactory.text(width: 30, height: 14), // Pourcentage
      ],
    );
  }

  /// Obtient le type de question pour un index
  static String getQuestionTypeForIndex(int index) {
    const questionTypes = ['radio', 'checkbox', 'text', 'scale'];
    return questionTypes[index % questionTypes.length];
  }
}