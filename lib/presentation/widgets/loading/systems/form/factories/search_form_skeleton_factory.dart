import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import '../base_form_skeleton_factory.dart';
import '../form_skeleton_config.dart';

/// Factory for creating search form skeletons
/// Single Responsibility: Creates search form layouts with input and filter options
class SearchFormSkeletonFactory extends BaseFormSkeletonFactory {
  @override
  Widget create(FormSkeletonConfig config) {
    return SkeletonContainer(
      width: config.width,
      height: config.height ?? 120,
      borderRadius: BorderRadiusTokens.card,
      animationDuration: config.animationDuration ?? defaultAnimationDuration,
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          // Main search input with button
          _createSearchInput(),

          // Filter options if requested
          if (config.showFilters)
            _createFilterBadges(config.filterCount),
        ],
      ),
    );
  }

  /// Creates the main search input field with search button
  Widget _createSearchInput() {
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

  /// Creates filter badge options
  Widget _createFilterBadges(int filterCount) {
    return SkeletonLayoutBuilder.horizontal(
      children: List.generate(filterCount, (index) {
        return Padding(
          padding: EdgeInsets.only(right: index < filterCount - 1 ? 12 : 0),
          child: SkeletonShapeFactory.badge(width: 80, height: 32),
        );
      }),
    );
  }
}