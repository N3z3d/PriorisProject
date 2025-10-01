import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';

/// Library of reusable skeleton components
/// Single Responsibility: Provide standardized skeleton building blocks
/// Following DRY principle to eliminate code duplication
class SkeletonComponentLibrary {
  SkeletonComponentLibrary._();

  /// Creates a standard page header with avatar, name, and action
  static Widget createPageHeader({
    double avatarSize = 40,
    double nameWidth = 120,
    double subtitleWidth = 80,
    double actionSize = 32,
  }) {
    return SkeletonLayoutBuilder.horizontal(
      children: [
        SkeletonShapeFactory.circular(size: avatarSize),
        const SizedBox(width: 12),
        Expanded(
          child: SkeletonLayoutBuilder.vertical(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              SkeletonShapeFactory.text(width: nameWidth, height: 20),
              SkeletonShapeFactory.text(width: subtitleWidth, height: 16),
            ],
          ),
        ),
        SkeletonShapeFactory.circular(size: actionSize),
      ],
    );
  }

  /// Creates a stats section with configurable number of stat cards
  static Widget createStatsSection({
    int statCount = 3,
    double height = 120,
  }) {
    return SizedBox(
      height: height,
      child: SkeletonLayoutBuilder.horizontal(
        children: List.generate(statCount, (index) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index < statCount - 1 ? 12 : 0),
              child: SkeletonContainer(
                borderRadius: BorderRadiusTokens.card,
                child: SkeletonLayoutBuilder.vertical(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8,
                  children: [
                    SkeletonShapeFactory.text(width: 60, height: 24),
                    SkeletonShapeFactory.text(width: 80, height: 16),
                    SkeletonShapeFactory.circular(size: 20),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Creates a chart section with title and bar chart
  static Widget createChartSection({
    double height = 200,
    int barCount = 7,
  }) {
    return SkeletonContainer(
      height: height,
      borderRadius: BorderRadiusTokens.card,
      child: SkeletonLayoutBuilder.vertical(
        spacing: 16,
        children: [
          SkeletonLayoutBuilder.horizontal(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonShapeFactory.text(width: 140, height: 20),
              SkeletonShapeFactory.text(width: 80, height: 16),
            ],
          ),
          Expanded(
            child: SkeletonLayoutBuilder.horizontal(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(barCount, (index) {
                final barHeight = 40.0 + (index % 4) * 30.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: SkeletonShapeFactory.rectangular(height: barHeight),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// Creates a list of recent items
  static Widget createRecentItemsList({
    int itemCount = 3,
    String title = '',
  }) {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        if (title.isNotEmpty)
          SkeletonShapeFactory.text(width: 140, height: 18),
        ...List.generate(itemCount, (index) {
          return SkeletonContainer(
            height: 70,
            borderRadius: BorderRadiusTokens.card,
            child: createListItemContent(),
          );
        }),
      ],
    );
  }

  /// Creates standard list item content layout
  static Widget createListItemContent({
    double avatarSize = 40,
    double titleHeight = 16,
    double subtitleHeight = 14,
    bool showAction = true,
  }) {
    return SkeletonLayoutBuilder.horizontal(
      children: [
        SkeletonShapeFactory.circular(size: avatarSize),
        const SizedBox(width: 16),
        Expanded(
          child: SkeletonLayoutBuilder.vertical(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 6,
            children: [
              SkeletonShapeFactory.text(width: double.infinity, height: titleHeight),
              SkeletonShapeFactory.text(width: 150, height: subtitleHeight),
            ],
          ),
        ),
        if (showAction)
          SkeletonShapeFactory.text(width: 40, height: 12),
      ],
    );
  }

  /// Creates a profile info section with avatar and details
  static Widget createProfileInfo({
    double avatarSize = 80,
    bool showButton = true,
  }) {
    return SkeletonLayoutBuilder.horizontal(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonShapeFactory.circular(size: avatarSize),
        const SizedBox(width: 16),
        Expanded(
          child: SkeletonLayoutBuilder.vertical(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              SkeletonShapeFactory.text(width: 140, height: 24),
              SkeletonShapeFactory.text(width: 100, height: 16),
              SkeletonShapeFactory.text(width: 120, height: 14),
            ],
          ),
        ),
        if (showButton)
          SkeletonShapeFactory.button(width: 100, height: 36),
      ],
    );
  }

  /// Creates a search bar with filter button
  static Widget createSearchBar({bool showFilter = true}) {
    return SkeletonLayoutBuilder.horizontal(
      children: [
        Expanded(child: SkeletonShapeFactory.input()),
        if (showFilter) ...[
          const SizedBox(width: 12),
          SkeletonShapeFactory.circular(size: 48),
        ],
      ],
    );
  }

  /// Creates a horizontal filter list
  static Widget createFilterList({
    int filterCount = 5,
    double height = 40,
  }) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filterCount,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return SkeletonShapeFactory.badge(width: 80, height: 32);
        },
      ),
    );
  }

  /// Creates a tab bar with specified number of tabs
  static Widget createTabBar({int tabCount = 3}) {
    return SkeletonLayoutBuilder.horizontal(
      children: List.generate(tabCount, (index) {
        return Expanded(
          child: Center(
            child: SkeletonShapeFactory.text(width: 60, height: 16),
          ),
        );
      }),
    );
  }

  /// Creates action buttons layout
  static Widget createActionButtons({
    bool expandFirst = true,
    double buttonHeight = 48,
  }) {
    return SkeletonLayoutBuilder.horizontal(
      children: [
        if (expandFirst)
          Expanded(child: SkeletonShapeFactory.button(height: buttonHeight))
        else
          SkeletonShapeFactory.button(width: 100, height: buttonHeight),
        const SizedBox(width: 12),
        SkeletonShapeFactory.button(width: 100, height: buttonHeight),
      ],
    );
  }

  /// Creates a settings list item
  static Widget createSettingsItem({
    bool hasSwitch = false,
    bool hasChevron = true,
  }) {
    return SkeletonContainer(
      height: 56,
      borderRadius: BorderRadiusTokens.radiusSm,
      child: SkeletonLayoutBuilder.horizontal(
        children: [
          SkeletonShapeFactory.circular(size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: SkeletonShapeFactory.text(width: double.infinity, height: 16),
          ),
          if (hasSwitch)
            SkeletonShapeFactory.rounded(width: 44, height: 24)
          else if (hasChevron)
            SkeletonShapeFactory.circular(size: 16),
        ],
      ),
    );
  }

  /// Creates navigation drawer header
  static Widget createDrawerHeader({
    double height = 200,
    double avatarSize = 64,
  }) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 12,
        children: [
          SkeletonShapeFactory.circular(size: avatarSize),
          SkeletonShapeFactory.text(width: 140, height: 20),
          SkeletonShapeFactory.text(width: 180, height: 16),
        ],
      ),
    );
  }

  /// Creates navigation menu item
  static Widget createNavigationItem() {
    return SkeletonContainer(
      height: 56,
      borderRadius: BorderRadiusTokens.radiusSm,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SkeletonLayoutBuilder.horizontal(
        children: [
          SkeletonShapeFactory.circular(size: 24),
          const SizedBox(width: 24),
          Expanded(
            child: SkeletonShapeFactory.text(width: double.infinity, height: 16),
          ),
        ],
      ),
    );
  }

  /// Creates bottom sheet handle
  static Widget createSheetHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        child: SkeletonShapeFactory.rounded(width: 40, height: 4),
      ),
    );
  }

  /// Creates standard content section with title and text lines
  static Widget createContentSection({
    double titleWidth = 140,
    int textLineCount = 3,
    bool includeImage = false,
  }) {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        SkeletonShapeFactory.text(width: titleWidth, height: 20),
        SkeletonLayoutBuilder.vertical(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: List.generate(textLineCount, (index) {
            final width = index == textLineCount - 1 ? 200.0 : double.infinity;
            return SkeletonShapeFactory.text(width: width, height: 16);
          }),
        ),
        if (includeImage)
          SkeletonShapeFactory.rectangular(
            width: double.infinity,
            height: 100,
          ),
      ],
    );
  }
}