import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_component_library.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';
import 'package:prioris/presentation/widgets/loading/strategies/skeleton_strategy_interface.dart';

/// Detail page skeleton strategy
/// Single Responsibility: Create detail-specific skeleton layouts
/// Following SRP and Strategy pattern
class DetailSkeletonStrategy extends BaseSkeletonStrategy {
  @override
  String get strategyId => 'detail_skeleton_strategy';

  @override
  String get variant => 'detail';

  @override
  List<String> get supportedOptions => [
    'showImage',
    'showActions',
    'showTabs',
    'imageHeight',
    'relatedItemCount',
  ];

  @override
  Widget buildSkeletonLayout(SkeletonConfig config) {
    final showImage = getOption(config.options, 'showImage', true);
    final showActions = getOption(config.options, 'showActions', true);

    return Scaffold(
      body: SkeletonLayoutBuilder.vertical(
        spacing: 0,
        children: [
          if (showImage) _buildHeaderImage(config, showActions),
          Expanded(child: _buildContent(config, showActions)),
        ],
      ),
    );
  }

  /// Builds the header image with navigation and actions
  Widget _buildHeaderImage(SkeletonConfig config, bool showActions) {
    final imageHeight = getOption(config.options, 'imageHeight', 250.0);

    return Stack(
      children: [
        SkeletonShapeFactory.rectangular(
          width: double.infinity,
          height: imageHeight,
        ),
        _buildNavigationOverlay(showActions),
      ],
    );
  }

  /// Builds the navigation overlay on the image
  Widget _buildNavigationOverlay(bool showActions) {
    return Positioned(
      top: 40,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SkeletonShapeFactory.circular(size: 40),
          if (showActions) _buildImageActions(),
        ],
      ),
    );
  }

  /// Builds action buttons for the image overlay
  Widget _buildImageActions() {
    return SkeletonLayoutBuilder.horizontal(
      children: [
        SkeletonShapeFactory.circular(size: 40),
        const SizedBox(width: 8),
        SkeletonShapeFactory.circular(size: 40),
      ],
    );
  }

  /// Builds the main content section
  Widget _buildContent(SkeletonConfig config, bool showActions) {
    final showTabs = getOption(config.options, 'showTabs', false);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          _buildTitleSection(),
          _buildMetadataSection(),
          if (showTabs) _buildTabsSection(),
          Expanded(child: _buildContentSections(config)),
          if (showActions) _buildActionButtonsSection(),
        ],
      ),
    );
  }

  /// Builds the title and subtitle section
  Widget _buildTitleSection() {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        SkeletonShapeFactory.text(width: double.infinity, height: 28),
        SkeletonShapeFactory.text(width: 200, height: 16),
      ],
    );
  }

  /// Builds the metadata row with badges and info
  Widget _buildMetadataSection() {
    return SkeletonLayoutBuilder.horizontal(
      children: [
        SkeletonShapeFactory.badge(width: 60),
        const SizedBox(width: 12),
        SkeletonShapeFactory.badge(width: 80),
        const Spacer(),
        SkeletonShapeFactory.text(width: 60, height: 14),
      ],
    );
  }

  /// Builds the tabs section
  Widget _buildTabsSection() {
    return SkeletonComponentLibrary.createTabBar();
  }

  /// Builds the main content sections
  Widget _buildContentSections(SkeletonConfig config) {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 24,
      children: [
        _buildDescriptionSection(),
        _buildFeaturesSection(),
        _buildRelatedSection(config),
      ],
    );
  }

  /// Builds the description section
  Widget _buildDescriptionSection() {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        SkeletonShapeFactory.text(width: 100, height: 18),
        SkeletonShapeFactory.text(width: double.infinity, height: 16),
        SkeletonShapeFactory.text(width: double.infinity, height: 16),
        SkeletonShapeFactory.text(width: 250, height: 16),
      ],
    );
  }

  /// Builds the features/stats section
  Widget _buildFeaturesSection() {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        SkeletonShapeFactory.text(width: 80, height: 18),
        SkeletonLayoutBuilder.horizontal(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(3, (index) {
            return SkeletonLayoutBuilder.vertical(
              children: [
                SkeletonShapeFactory.text(width: 40, height: 20),
                const SizedBox(height: 4),
                SkeletonShapeFactory.text(width: 60, height: 14),
              ],
            );
          }),
        ),
      ],
    );
  }

  /// Builds the related items section
  Widget _buildRelatedSection(SkeletonConfig config) {
    final relatedItemCount = getOption(config.options, 'relatedItemCount', 4);

    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        SkeletonShapeFactory.text(width: 120, height: 18),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: relatedItemCount,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _buildRelatedItem(),
          ),
        ),
      ],
    );
  }

  /// Builds a related item card
  Widget _buildRelatedItem() {
    return SizedBox(
      width: 120,
      child: SkeletonContainer(
        borderRadius: BorderRadiusTokens.card,
        child: SkeletonLayoutBuilder.vertical(
          spacing: 8,
          children: [
            Expanded(
              child: SkeletonShapeFactory.rectangular(
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            SkeletonShapeFactory.text(width: double.infinity, height: 14),
          ],
        ),
      ),
    );
  }

  /// Builds the action buttons section
  Widget _buildActionButtonsSection() {
    return SkeletonComponentLibrary.createActionButtons();
  }
}