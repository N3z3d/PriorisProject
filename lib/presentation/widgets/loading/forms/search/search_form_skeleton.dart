/// **SEARCH FORM SKELETON** - SRP Specialized Component
///
/// **LOT 7** : Composant spécialisé pour formulaires de recherche
/// **SRP** : Gestion uniquement des formulaires de recherche et filtres
/// **Taille** : <200 lignes (extraction depuis 700 lignes God Class)

import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import '../interfaces/form_skeleton_interface.dart';

/// Composant spécialisé pour créer des skelettes de formulaires de recherche
///
/// **SRP** : Formulaires de recherche avec filtres et suggestions
/// **OCP** : Extensible via configuration de filtres et options
class SearchFormSkeleton implements IFormSkeletonComponent {
  @override
  String get componentId => 'search_form_skeleton';

  @override
  List<String> get supportedTypes => [
    'search_form',
    'filter_form',
    'search_bar',
    'advanced_search',
  ];

  @override
  List<String> get availableVariants => [
    'search',
    'simple',
    'advanced',
    'filtered',
  ];

  @override
  bool canHandle(String skeletonType) {
    return supportedTypes.contains(skeletonType) ||
           skeletonType.contains('search') ||
           skeletonType.contains('filter') ||
           skeletonType.contains('find');
  }

  @override
  Widget createSkeleton({
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    return createVariant(
      'search',
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
      case 'simple':
        return _createSimpleSearch(config);
      case 'advanced':
        return _createAdvancedSearch(config);
      case 'filtered':
        return _createFilteredSearch(config);
      case 'search':
      default:
        return _createStandardSearch(config);
    }
  }

  /// Crée un formulaire de recherche standard avec filtres
  Widget _createStandardSearch(SkeletonConfig config) {
    final showFilters = config.options['showFilters'] ?? true;
    final filterCount = config.options['filterCount'] ?? 3;

    return SkeletonContainer(
      width: config.width,
      height: config.height ?? 120,
      borderRadius: BorderRadiusTokens.card,
      animationDuration: config.animationDuration ?? const Duration(milliseconds: 1500),
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          // Barre de recherche principale
          _createSearchBar(),

          // Filtres de recherche
          if (showFilters)
            _createFilterSection(filterCount),
        ],
      ),
    );
  }

  /// Crée une barre de recherche simple sans filtres
  Widget _createSimpleSearch(SkeletonConfig config) {
    return SkeletonContainer(
      width: config.width,
      height: config.height ?? 60,
      borderRadius: BorderRadiusTokens.card,
      animationDuration: config.animationDuration ?? const Duration(milliseconds: 1500),
      child: _createSearchBar(),
    );
  }

  /// Crée un formulaire de recherche avancée avec options multiples
  Widget _createAdvancedSearch(SkeletonConfig config) {
    final criteriaCount = config.options['criteriaCount'] ?? 4;

    return SkeletonContainer(
      width: config.width,
      height: config.height,
      borderRadius: BorderRadiusTokens.modal,
      animationDuration: config.animationDuration ?? const Duration(milliseconds: 1500),
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          // Titre recherche avancée
          SkeletonShapeFactory.text(width: 160, height: 24),

          // Barre de recherche
          _createSearchBar(),

          // Critères de recherche avancée
          ...List.generate(criteriaCount, (index) => _createAdvancedCriteria(index)),

          // Boutons d'action
          _createAdvancedActions(),
        ],
      ),
    );
  }

  /// Crée un formulaire avec emphasis sur les filtres
  Widget _createFilteredSearch(SkeletonConfig config) {
    final categoryCount = config.options['categoryCount'] ?? 4;
    final filterCount = config.options['filterCount'] ?? 6;

    return SkeletonContainer(
      width: config.width,
      height: config.height,
      borderRadius: BorderRadiusTokens.card,
      animationDuration: config.animationDuration ?? const Duration(milliseconds: 1500),
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          _createSearchBar(),

          // Catégories de filtres
          _createCategoryFilters(categoryCount),

          // Filtres détaillés
          _createDetailedFilters(filterCount),

          // Résultats compteur
          SkeletonShapeFactory.text(width: 120, height: 14),
        ],
      ),
    );
  }

  // === MÉTHODES HELPER SPÉCIALISÉES ===

  Widget _createSearchBar() {
    return SkeletonLayoutBuilder.horizontal(
      children: [
        Expanded(
          child: SkeletonShapeFactory.input(height: 48),
        ),
        const SizedBox(width: 12),
        SkeletonShapeFactory.button(width: 100, height: 48),
      ],
    );
  }

  Widget _createFilterSection(int filterCount) {
    return SkeletonLayoutBuilder.horizontal(
      children: List.generate(filterCount, (index) {
        return Padding(
          padding: EdgeInsets.only(right: index < filterCount - 1 ? 12 : 0),
          child: SkeletonShapeFactory.badge(width: 80, height: 32),
        );
      }),
    );
  }

  Widget _createAdvancedCriteria(int index) {
    return SkeletonLayoutBuilder.horizontal(
      children: [
        // Label du critère
        SizedBox(
          width: 120,
          child: SkeletonShapeFactory.text(width: 100, height: 16),
        ),
        const SizedBox(width: 16),

        // Opérateur (contient, égal, etc.)
        SkeletonShapeFactory.badge(width: 80, height: 32),
        const SizedBox(width: 12),

        // Valeur
        Expanded(
          child: SkeletonShapeFactory.input(height: 36),
        ),
      ],
    );
  }

  Widget _createAdvancedActions() {
    return SkeletonLayoutBuilder.horizontal(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SkeletonShapeFactory.button(width: 80, height: 36), // Reset
        SkeletonLayoutBuilder.horizontal(
          children: [
            SkeletonShapeFactory.button(width: 80, height: 36), // Cancel
            const SizedBox(width: 12),
            SkeletonShapeFactory.button(width: 100, height: 36), // Search
          ],
        ),
      ],
    );
  }

  Widget _createCategoryFilters(int categoryCount) {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        SkeletonShapeFactory.text(width: 80, height: 16), // "Categories"
        SkeletonLayoutBuilder.horizontal(
          children: List.generate(categoryCount, (index) {
            return Padding(
              padding: EdgeInsets.only(right: index < categoryCount - 1 ? 8 : 0),
              child: SkeletonShapeFactory.badge(width: 70, height: 28),
            );
          }),
        ),
      ],
    );
  }

  Widget _createDetailedFilters(int filterCount) {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        SkeletonShapeFactory.text(width: 60, height: 16), // "Filters"
        ...List.generate((filterCount / 2).ceil(), (rowIndex) {
          final startIndex = rowIndex * 2;
          final endIndex = (startIndex + 2).clamp(0, filterCount);
          final filtersInRow = endIndex - startIndex;

          return SkeletonLayoutBuilder.horizontal(
            children: List.generate(filtersInRow, (index) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index < filtersInRow - 1 ? 12 : 0),
                  child: SkeletonLayoutBuilder.horizontal(
                    children: [
                      SkeletonShapeFactory.rounded(width: 16, height: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SkeletonShapeFactory.text(width: double.infinity, height: 14),
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        }),
      ],
    );
  }
}