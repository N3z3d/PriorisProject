import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_component_library.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';
import 'package:prioris/presentation/widgets/loading/strategies/skeleton_strategy_interface.dart';

/// Standard page skeleton strategy
/// Single Responsibility: Create standard/generic skeleton layouts
/// Following SRP and Strategy pattern
class StandardSkeletonStrategy extends BaseSkeletonStrategy {
  @override
  String get strategyId => 'standard_skeleton_strategy';

  @override
  String get variant => 'standard';

  @override
  List<String> get supportedOptions => [
    'showAppBar',
    'showFab',
    'contentSections',
  ];

  @override
  Widget buildSkeletonLayout(SkeletonConfig config) {
    final showAppBar = getOption(config.options, 'showAppBar', true);
    final showFab = getOption(config.options, 'showFab', false);
    final contentSections = getOption(config.options, 'contentSections', 3);

    return Scaffold(
      appBar: showAppBar ? _buildAppBar() : null,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SkeletonLayoutBuilder.vertical(
          spacing: 24,
          children: List.generate(contentSections, (index) {
            return _buildContentSection(index);
          }),
        ),
      ),
      floatingActionButton: showFab ? _buildFloatingActionButton() : null,
    );
  }

  /// Builds the app bar
  AppBar _buildAppBar() {
    return AppBar(
      title: SkeletonShapeFactory.text(width: 100, height: 20),
      actions: [
        SkeletonShapeFactory.circular(size: 24),
        const SizedBox(width: 16),
      ],
    );
  }

  /// Builds a content section
  Widget _buildContentSection(int index) {
    final includeImage = index % 2 == 0;
    return SkeletonComponentLibrary.createContentSection(
      includeImage: includeImage,
    );
  }

  /// Builds the floating action button
  Widget _buildFloatingActionButton() {
    return SkeletonShapeFactory.circular(size: 56);
  }
}