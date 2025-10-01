import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_component_library.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';
import 'package:prioris/presentation/widgets/loading/strategies/skeleton_strategy_interface.dart';

/// Bottom sheet skeleton strategy
/// Single Responsibility: Create bottom sheet-specific skeleton layouts
/// Following SRP and Strategy pattern
class SheetSkeletonStrategy extends BaseSkeletonStrategy {
  @override
  String get strategyId => 'sheet_skeleton_strategy';

  @override
  String get variant => 'sheet';

  @override
  List<String> get supportedOptions => [
    'showHandle',
    'showTitle',
    'itemCount',
    'titleText',
  ];

  @override
  Widget buildSkeletonLayout(SkeletonConfig config) {
    final showHandle = getOption(config.options, 'showHandle', true);
    final showTitle = getOption(config.options, 'showTitle', true);

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SkeletonLayoutBuilder.vertical(
        spacing: 16,
        children: [
          if (showHandle) _buildHandle(),
          _buildContent(config, showTitle),
        ],
      ),
    );
  }

  /// Builds the bottom sheet handle
  Widget _buildHandle() {
    return SkeletonComponentLibrary.createSheetHandle();
  }

  /// Builds the main content section
  Widget _buildContent(SkeletonConfig config, bool showTitle) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SkeletonLayoutBuilder.vertical(
        spacing: 16,
        children: [
          if (showTitle) _buildTitle(),
          ..._buildItems(config),
        ],
      ),
    );
  }

  /// Builds the sheet title
  Widget _buildTitle() {
    return Center(
      child: SkeletonShapeFactory.text(width: 160, height: 24),
    );
  }

  /// Builds the list of items
  List<Widget> _buildItems(SkeletonConfig config) {
    final itemCount = getOption(config.options, 'itemCount', 5);

    return List.generate(itemCount, (index) {
      return SkeletonContainer(
        height: 56,
        borderRadius: BorderRadiusTokens.card,
        child: _buildSheetItem(),
      );
    });
  }

  /// Builds an individual sheet item
  Widget _buildSheetItem() {
    return SkeletonLayoutBuilder.horizontal(
      children: [
        SkeletonShapeFactory.circular(size: 32),
        const SizedBox(width: 16),
        Expanded(
          child: SkeletonLayoutBuilder.vertical(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 4,
            children: [
              SkeletonShapeFactory.text(width: double.infinity, height: 16),
              SkeletonShapeFactory.text(width: 120, height: 14),
            ],
          ),
        ),
        SkeletonShapeFactory.circular(size: 20),
      ],
    );
  }
}