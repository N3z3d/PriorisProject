/// **COMPACT FORM SKELETON** - SRP Specialized Component
///
/// **LOT 7** : Composant spécialisé pour formulaires compacts
/// **SRP** : Gestion uniquement des formulaires avec espacement minimal
/// **Taille** : <200 lignes (extraction depuis 700 lignes God Class)

import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import '../interfaces/form_skeleton_interface.dart';

/// Composant spécialisé pour créer des skelettes de formulaires compacts
///
/// **SRP** : Formulaires avec espacement réduit et layout horizontal
/// **OCP** : Extensible via configuration de densité et alignement
class CompactFormSkeleton implements IFormSkeletonComponent {
  @override
  String get componentId => 'compact_form_skeleton';

  @override
  List<String> get supportedTypes => [
    'compact_form',
    'inline_form',
    'horizontal_form',
    'dense_form',
  ];

  @override
  List<String> get availableVariants => [
    'compact',
    'inline',
    'dense',
    'horizontal',
  ];

  @override
  bool canHandle(String skeletonType) {
    return supportedTypes.contains(skeletonType) ||
           skeletonType.contains('compact') ||
           skeletonType.contains('inline') ||
           skeletonType.contains('dense');
  }

  @override
  Widget createSkeleton({
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    return createVariant(
      'compact',
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
      case 'inline':
        return _createInlineForm(config);
      case 'dense':
        return _createDenseForm(config);
      case 'horizontal':
        return _createHorizontalForm(config);
      case 'compact':
      default:
        return _createCompactForm(config);
    }
  }

  /// Crée un formulaire compact avec espacement minimal
  Widget _createCompactForm(SkeletonConfig config) {
    final fieldCount = config.options['fieldCount'] ?? 3;
    final showSubmitButton = config.options['showSubmitButton'] ?? true;

    return SkeletonContainer(
      width: config.width,
      height: config.height,
      borderRadius: BorderRadiusTokens.card,
      padding: const EdgeInsets.all(12),
      animationDuration: config.animationDuration ?? const Duration(milliseconds: 1500),
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          ...List.generate(fieldCount, (index) => _createCompactField(
            config.copyWith(
              options: {
                ...config.options,
                'fieldType': _getFieldTypeForIndex(index),
              },
            ),
          )),

          if (showSubmitButton)
            SkeletonShapeFactory.button(
              width: double.infinity,
              height: 36,
            ),
        ],
      ),
    );
  }

  /// Crée un formulaire inline avec champs sur une ligne
  Widget _createInlineForm(SkeletonConfig config) {
    final fieldCount = config.options['fieldCount'] ?? 2;
    final showSubmitButton = config.options['showSubmitButton'] ?? true;

    return SkeletonContainer(
      width: config.width,
      height: config.height ?? 60,
      borderRadius: BorderRadiusTokens.card,
      padding: const EdgeInsets.all(8),
      animationDuration: config.animationDuration ?? const Duration(milliseconds: 1500),
      child: SkeletonLayoutBuilder.horizontal(
        children: [
          // Fields en ligne
          ...List.generate(fieldCount, (index) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index < fieldCount - 1 ? 8 : 0),
                child: SkeletonShapeFactory.input(height: 40),
              ),
            );
          }),

          // Button submit compact
          if (showSubmitButton) ...[
            const SizedBox(width: 8),
            SkeletonShapeFactory.button(width: 80, height: 40),
          ],
        ],
      ),
    );
  }

  /// Crée un formulaire dense avec labels courts
  Widget _createDenseForm(SkeletonConfig config) {
    final fieldCount = config.options['fieldCount'] ?? 4;

    return SkeletonContainer(
      width: config.width,
      height: config.height,
      borderRadius: BorderRadiusTokens.card,
      padding: const EdgeInsets.all(10),
      animationDuration: config.animationDuration ?? const Duration(milliseconds: 1500),
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          ...List.generate(fieldCount, (index) => _createDenseField(
            config.copyWith(
              options: {
                'fieldType': _getFieldTypeForIndex(index),
              },
            ),
          )),
          const SizedBox(height: 4),
          SkeletonShapeFactory.button(width: double.infinity, height: 32),
        ],
      ),
    );
  }

  /// Crée un formulaire horizontal avec labels à côté
  Widget _createHorizontalForm(SkeletonConfig config) {
    final fieldCount = config.options['fieldCount'] ?? 3;

    return SkeletonContainer(
      width: config.width,
      height: config.height,
      borderRadius: BorderRadiusTokens.card,
      padding: const EdgeInsets.all(16),
      animationDuration: config.animationDuration ?? const Duration(milliseconds: 1500),
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          ...List.generate(fieldCount, (index) => _createHorizontalField(
            config.copyWith(
              options: {
                'fieldType': _getFieldTypeForIndex(index),
              },
            ),
          )),
          SkeletonLayoutBuilder.horizontal(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SkeletonShapeFactory.button(width: 100, height: 36),
            ],
          ),
        ],
      ),
    );
  }

  // === MÉTHODES HELPER SPÉCIALISÉES ===

  Widget _createCompactField(SkeletonConfig config) {
    final fieldType = config.options['fieldType'] ?? 'text';

    return SkeletonLayoutBuilder.horizontal(
      children: [
        SkeletonShapeFactory.text(width: 80, height: 14),
        const SizedBox(width: 12),
        Expanded(child: _createInputByType(fieldType, height: 36)),
      ],
    );
  }

  Widget _createDenseField(SkeletonConfig config) {
    final fieldType = config.options['fieldType'] ?? 'text';

    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        SkeletonShapeFactory.text(width: 60, height: 12),
        _createInputByType(fieldType, height: 32),
      ],
    );
  }

  Widget _createHorizontalField(SkeletonConfig config) {
    final fieldType = config.options['fieldType'] ?? 'text';

    return SkeletonLayoutBuilder.horizontal(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: SkeletonShapeFactory.text(width: 90, height: 16),
        ),
        const SizedBox(width: 16),
        Expanded(child: _createInputByType(fieldType, height: 40)),
      ],
    );
  }

  Widget _createInputByType(String fieldType, {double height = 40}) {
    switch (fieldType) {
      case 'select':
        return SkeletonLayoutBuilder.horizontal(
          children: [
            Expanded(child: SkeletonShapeFactory.input(height: height)),
            const SizedBox(width: 4),
            SkeletonShapeFactory.circular(size: height * 0.5),
          ],
        );
      case 'checkbox':
        return SkeletonLayoutBuilder.horizontal(
          children: [
            SkeletonShapeFactory.rounded(width: 16, height: 16),
            const SizedBox(width: 8),
            SkeletonShapeFactory.text(width: 80, height: 14),
          ],
        );
      case 'date':
        return SkeletonLayoutBuilder.horizontal(
          children: [
            Expanded(child: SkeletonShapeFactory.input(height: height)),
            const SizedBox(width: 4),
            SkeletonShapeFactory.circular(size: height * 0.6),
          ],
        );
      default: // text, email, etc.
        return SkeletonShapeFactory.input(height: height);
    }
  }

  String _getFieldTypeForIndex(int index) {
    const fieldTypes = ['text', 'email', 'select', 'date', 'checkbox'];
    return fieldTypes[index % fieldTypes.length];
  }
}