import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_component_library.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';
import 'package:prioris/presentation/widgets/loading/strategies/skeleton_strategy_interface.dart';

/// List page skeleton strategy
/// Single Responsibility: Create list-specific skeleton layouts
/// Following SRP and Strategy pattern
class ListSkeletonStrategy extends BaseSkeletonStrategy {
  @override
  String get strategyId => 'list_skeleton_strategy';

  @override
  String get variant => 'list';

  @override
  List<String> get supportedOptions => [
    'showSearchBar',
    'showFilters',
    'showFab',
    'itemCount',
    'filterCount',
    'appBarTitle',
  ];

  @override
  Widget buildSkeletonLayout(SkeletonConfig config) {
    final showSearchBar = getOption(config.options, 'showSearchBar', true);
    final showFilters = getOption(config.options, 'showFilters', true);
    final showFab = getOption(config.options, 'showFab', true);

    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SkeletonLayoutBuilder.vertical(
          spacing: 16,
          children: [
            if (showSearchBar) _buildSearchSection(),
            if (showFilters) _buildFiltersSection(config),
            Expanded(child: _buildListSection(config)),
          ],
        ),
      ),
      floatingActionButton: showFab ? _buildFloatingActionButton() : null,
    );
  }

  /// Builds the app bar
  AppBar _buildAppBar() {
    return AppBar(
      title: SkeletonShapeFactory.text(width: 120, height: 20),
      actions: [
        SkeletonShapeFactory.circular(size: 24),
        const SizedBox(width: 8),
        SkeletonShapeFactory.circular(size: 24),
        const SizedBox(width: 16),
      ],
    );
  }

  /// Builds the search section
  Widget _buildSearchSection() {
    return SkeletonComponentLibrary.createSearchBar();
  }

  /// Builds the filters section
  Widget _buildFiltersSection(SkeletonConfig config) {
    final filterCount = getOption(config.options, 'filterCount', 5);
    return SkeletonComponentLibrary.createFilterList(
      filterCount: filterCount,
    );
  }

  /// Builds the main list section
  Widget _buildListSection(SkeletonConfig config) {
    final itemCount = getOption(config.options, 'itemCount', 8);

    return SkeletonLayoutBuilder.list(
      children: List.generate(itemCount, (index) {
        return SkeletonContainer(
          height: 80,
          borderRadius: BorderRadiusTokens.card,
          child: _buildListItem(),
        );
      }),
    );
  }

  /// Builds individual list item
  Widget _buildListItem() {
    return SkeletonLayoutBuilder.horizontal(
      children: [
        SkeletonShapeFactory.rounded(width: 50, height: 50),
        const SizedBox(width: 16),
        Expanded(
          child: SkeletonLayoutBuilder.vertical(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              SkeletonShapeFactory.text(width: double.infinity, height: 18),
              SkeletonShapeFactory.text(width: 150, height: 14),
            ],
          ),
        ),
        SkeletonShapeFactory.circular(size: 24),
      ],
    );
  }

  /// Builds the floating action button
  Widget _buildFloatingActionButton() {
    return SkeletonShapeFactory.circular(size: 56);
  }
}