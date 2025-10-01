import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_component_library.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';
import 'package:prioris/presentation/widgets/loading/strategies/skeleton_strategy_interface.dart';

/// Navigation drawer skeleton strategy
/// Single Responsibility: Create navigation-specific skeleton layouts
/// Following SRP and Strategy pattern
class NavigationSkeletonStrategy extends BaseSkeletonStrategy {
  @override
  String get strategyId => 'navigation_skeleton_strategy';

  @override
  String get variant => 'drawer';

  @override
  List<String> get supportedOptions => [
    'showProfile',
    'itemCount',
    'showFooter',
  ];

  @override
  Widget buildSkeletonLayout(SkeletonConfig config) {
    final showProfile = getOption(config.options, 'showProfile', true);
    final showFooter = getOption(config.options, 'showFooter', true);

    return Drawer(
      child: SkeletonLayoutBuilder.vertical(
        spacing: 0,
        children: [
          if (showProfile) _buildHeader(),
          Expanded(child: _buildMenuItems(config)),
          if (showFooter) _buildFooter(),
        ],
      ),
    );
  }

  /// Builds the drawer header with profile information
  Widget _buildHeader() {
    return SkeletonComponentLibrary.createDrawerHeader();
  }

  /// Builds the menu items section
  Widget _buildMenuItems(SkeletonConfig config) {
    final itemCount = getOption(config.options, 'itemCount', 8);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SkeletonLayoutBuilder.list(
        spacing: 4,
        children: List.generate(itemCount, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SkeletonComponentLibrary.createNavigationItem(),
          );
        }),
      ),
    );
  }

  /// Builds the drawer footer
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SkeletonLayoutBuilder.vertical(
        spacing: 8,
        children: [
          SkeletonShapeFactory.rectangular(height: 1, width: double.infinity),
          SkeletonLayoutBuilder.horizontal(
            children: [
              SkeletonShapeFactory.circular(size: 20),
              const SizedBox(width: 12),
              SkeletonShapeFactory.text(width: 80, height: 14),
            ],
          ),
        ],
      ),
    );
  }
}