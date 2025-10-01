import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_component_library.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';
import 'package:prioris/presentation/widgets/loading/strategies/skeleton_strategy_interface.dart';

/// Profile page skeleton strategy
/// Single Responsibility: Create profile-specific skeleton layouts
/// Following SRP and Strategy pattern
class ProfileSkeletonStrategy extends BaseSkeletonStrategy {
  @override
  String get strategyId => 'profile_skeleton_strategy';

  @override
  String get variant => 'profile';

  @override
  List<String> get supportedOptions => [
    'showCoverImage',
    'showStats',
    'showBio',
    'showTabs',
    'tabCount',
    'contentItemCount',
  ];

  @override
  Widget buildSkeletonLayout(SkeletonConfig config) {
    final showCoverImage = getOption(config.options, 'showCoverImage', true);
    final showStats = getOption(config.options, 'showStats', true);
    final showBio = getOption(config.options, 'showBio', true);
    final showTabs = getOption(config.options, 'showTabs', true);

    return Scaffold(
      body: SkeletonLayoutBuilder.vertical(
        spacing: 0,
        children: [
          if (showCoverImage) _buildCoverImage(),
          _buildProfileContent(config, showStats, showBio, showTabs),
        ],
      ),
    );
  }

  /// Builds the cover image section
  Widget _buildCoverImage() {
    return SkeletonShapeFactory.rectangular(
      width: double.infinity,
      height: 200,
    );
  }

  /// Builds the main profile content section
  Widget _buildProfileContent(
    SkeletonConfig config,
    bool showStats,
    bool showBio,
    bool showTabs,
  ) {
    return Expanded(
      child: SkeletonLayoutBuilder.vertical(
        spacing: 0,
        children: [
          // Profile info section
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildProfileInfo(showStats, showBio, showTabs),
          ),
          // Tab content
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  /// Builds the profile information section
  Widget _buildProfileInfo(bool showStats, bool showBio, bool showTabs) {
    return SkeletonLayoutBuilder.vertical(
      spacing: 16,
      children: [
        SkeletonComponentLibrary.createProfileInfo(),
        if (showBio) _buildBioSection(),
        if (showStats) _buildStatsRow(),
        if (showTabs) _buildTabBar(),
      ],
    );
  }

  /// Builds the bio section
  Widget _buildBioSection() {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        SkeletonShapeFactory.text(width: double.infinity, height: 16),
        SkeletonShapeFactory.text(width: 280, height: 16),
        SkeletonShapeFactory.text(width: 200, height: 16),
      ],
    );
  }

  /// Builds the stats row
  Widget _buildStatsRow() {
    return SkeletonLayoutBuilder.horizontal(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(3, (index) {
        return SkeletonLayoutBuilder.vertical(
          children: [
            SkeletonShapeFactory.text(width: 40, height: 24),
            const SizedBox(height: 4),
            SkeletonShapeFactory.text(width: 60, height: 16),
          ],
        );
      }),
    );
  }

  /// Builds the tab bar
  Widget _buildTabBar() {
    return SkeletonComponentLibrary.createTabBar();
  }

  /// Builds the tab content section
  Widget _buildTabContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SkeletonLayoutBuilder.list(
        children: List.generate(4, (index) {
          return SkeletonContainer(
            height: 100,
            borderRadius: BorderRadiusTokens.card,
            child: _buildContentItem(),
          );
        }),
      ),
    );
  }

  /// Builds individual content item
  Widget _buildContentItem() {
    return SkeletonLayoutBuilder.horizontal(
      children: [
        SkeletonShapeFactory.rounded(width: 60, height: 60),
        const SizedBox(width: 16),
        Expanded(
          child: SkeletonLayoutBuilder.vertical(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              SkeletonShapeFactory.text(width: double.infinity, height: 18),
              SkeletonShapeFactory.text(width: 200, height: 14),
              SkeletonShapeFactory.text(width: 80, height: 12),
            ],
          ),
        ),
      ],
    );
  }
}