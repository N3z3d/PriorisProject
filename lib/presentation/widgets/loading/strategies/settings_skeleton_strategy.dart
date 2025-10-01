import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_component_library.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';
import 'package:prioris/presentation/widgets/loading/strategies/skeleton_strategy_interface.dart';

/// Settings page skeleton strategy
/// Single Responsibility: Create settings-specific skeleton layouts
/// Following SRP and Strategy pattern
class SettingsSkeletonStrategy extends BaseSkeletonStrategy {
  @override
  String get strategyId => 'settings_skeleton_strategy';

  @override
  String get variant => 'settings';

  @override
  List<String> get supportedOptions => [
    'showProfile',
    'sectionCount',
    'itemsPerSection',
  ];

  @override
  Widget buildSkeletonLayout(SkeletonConfig config) {
    final showProfile = getOption(config.options, 'showProfile', true);
    final sectionCount = getOption(config.options, 'sectionCount', 4);

    return Scaffold(
      appBar: _buildAppBar(),
      body: SkeletonLayoutBuilder.list(
        children: [
          if (showProfile) _buildProfileSection(),
          ...List.generate(sectionCount, (index) => _buildSettingsSection(config, index)),
        ],
      ),
    );
  }

  /// Builds the app bar
  AppBar _buildAppBar() {
    return AppBar(
      title: SkeletonShapeFactory.text(width: 80, height: 20),
      actions: [
        SkeletonShapeFactory.circular(size: 24),
        const SizedBox(width: 16),
      ],
    );
  }

  /// Builds the profile section at the top
  Widget _buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SkeletonContainer(
        height: 80,
        borderRadius: BorderRadiusTokens.card,
        child: SkeletonLayoutBuilder.horizontal(
          children: [
            SkeletonShapeFactory.circular(size: 50),
            const SizedBox(width: 16),
            Expanded(
              child: SkeletonLayoutBuilder.vertical(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 6,
                children: [
                  SkeletonShapeFactory.text(width: 120, height: 18),
                  SkeletonShapeFactory.text(width: 180, height: 14),
                ],
              ),
            ),
            SkeletonShapeFactory.circular(size: 20),
          ],
        ),
      ),
    );
  }

  /// Builds a settings section with header and items
  Widget _buildSettingsSection(SkeletonConfig config, int sectionIndex) {
    final itemsPerSection = getOption(config.options, 'itemsPerSection', 3);
    final itemCount = itemsPerSection + (sectionIndex % 2); // Vary items per section

    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        _buildSectionHeader(),
        ...List.generate(itemCount, (itemIndex) => _buildSettingsItem(itemIndex)),
      ],
    );
  }

  /// Builds a section header
  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: SkeletonShapeFactory.text(width: 120, height: 16),
    );
  }

  /// Builds a settings item
  Widget _buildSettingsItem(int itemIndex) {
    final hasSwitch = itemIndex % 3 == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SkeletonComponentLibrary.createSettingsItem(
        hasSwitch: hasSwitch,
        hasChevron: !hasSwitch,
      ),
    );
  }
}