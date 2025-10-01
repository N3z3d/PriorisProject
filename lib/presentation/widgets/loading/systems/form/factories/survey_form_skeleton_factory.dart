import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import '../base_form_skeleton_factory.dart';
import '../form_skeleton_config.dart';

/// Factory for creating survey form skeletons
/// Single Responsibility: Creates survey form layouts with questions and progress indicators
class SurveyFormSkeletonFactory extends BaseFormSkeletonFactory {
  @override
  Widget create(FormSkeletonConfig config) {
    return SkeletonContainer(
      width: config.width,
      height: config.height,
      borderRadius: BorderRadiusTokens.card,
      animationDuration: config.animationDuration ?? defaultAnimationDuration,
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: [
          // Survey title
          SkeletonShapeFactory.text(width: 220, height: 24),

          // Survey questions
          ...List.generate(config.questionCount, (index) => _createSurveyQuestion(
            config.copyWith(
              options: {
                ...config.options,
                'questionType': getQuestionTypeForIndex(index),
                'questionNumber': index + 1,
              },
            ),
          )),

          // Progress section
          _createProgressSection(),

          // Submit button
          SkeletonShapeFactory.button(width: double.infinity),
        ],
      ),
    );
  }

  /// Creates a survey question with numbered label and answer options
  Widget _createSurveyQuestion(FormSkeletonConfig config) {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        // Question text with number
        SkeletonLayoutBuilder.horizontal(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonShapeFactory.text(width: 20, height: 16), // Question number
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

        // Answer options based on question type
        _createAnswerOptions(config.questionType, config),
      ],
    );
  }

  /// Creates answer options based on question type
  Widget _createAnswerOptions(String questionType, FormSkeletonConfig config) {
    switch (questionType) {
      case 'radio':
        return _createRadioOptions();
      case 'checkbox':
        return _createCheckboxOptions();
      case 'scale':
        return _createScaleOptions();
      case 'text':
      default:
        return SkeletonShapeFactory.input(height: 60);
    }
  }

  /// Creates radio button options
  Widget _createRadioOptions() {
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
  }

  /// Creates checkbox options
  Widget _createCheckboxOptions() {
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
  }

  /// Creates scale rating options
  Widget _createScaleOptions() {
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
  }

  /// Creates progress indicator section
  Widget _createProgressSection() {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        SkeletonShapeFactory.text(width: 120, height: 14),
        SkeletonShapeFactory.progressBar(width: double.infinity),
      ],
    );
  }
}