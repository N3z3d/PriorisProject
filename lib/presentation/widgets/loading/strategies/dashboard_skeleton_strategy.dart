import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_component_library.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';
import 'package:prioris/presentation/widgets/loading/strategies/skeleton_strategy_interface.dart';

/// Dashboard page skeleton strategy
/// Single Responsibility: Create dashboard-specific skeleton layouts
/// Following SRP and Strategy pattern
class DashboardSkeletonStrategy extends BaseSkeletonStrategy {
  @override
  String get strategyId => 'dashboard_skeleton_strategy';

  @override
  String get variant => 'dashboard';

  @override
  List<String> get supportedOptions => [
    'showHeader',
    'showStats',
    'showChart',
    'showRecentItems',
    'statCount',
    'recentItemCount',
  ];

  @override
  Widget buildSkeletonLayout(SkeletonConfig config) {
    final showHeader = getOption(config.options, 'showHeader', true);
    final showStats = getOption(config.options, 'showStats', true);
    final showChart = getOption(config.options, 'showChart', true);
    final showRecentItems = getOption(config.options, 'showRecentItems', true);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SkeletonLayoutBuilder.vertical(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 24,
            children: [
              if (showHeader) _buildHeaderSection(),
              if (showStats) _buildStatsSection(config),
              if (showChart) _buildChartSection(),
              if (showRecentItems) _buildRecentSection(config),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the dashboard header section
  Widget _buildHeaderSection() {
    return SkeletonComponentLibrary.createPageHeader();
  }

  /// Builds the stats cards section
  Widget _buildStatsSection(SkeletonConfig config) {
    final statCount = getOption(config.options, 'statCount', 3);
    return SkeletonComponentLibrary.createStatsSection(statCount: statCount);
  }

  /// Builds the chart section
  Widget _buildChartSection() {
    return SkeletonComponentLibrary.createChartSection();
  }

  /// Builds the recent items section
  Widget _buildRecentSection(SkeletonConfig config) {
    final itemCount = getOption(config.options, 'recentItemCount', 3);
    return SkeletonComponentLibrary.createRecentItemsList(
      itemCount: itemCount,
    );
  }
}