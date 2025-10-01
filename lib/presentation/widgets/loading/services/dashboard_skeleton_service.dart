import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/specialized_skeleton_interfaces.dart';

/// Dashboard skeleton service implementation following SRP
/// Single Responsibility: Creates only dashboard-related skeletons
class DashboardSkeletonService implements IDashboardSkeletonService {

  @override
  Widget createDashboardSkeleton(SkeletonConfig config) {
    final showHeader = config.options['showHeader'] ?? true;
    final showStats = config.options['showStats'] ?? true;
    final showChart = config.options['showChart'] ?? true;
    final showRecentItems = config.options['showRecentItems'] ?? true;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SkeletonLayoutBuilder.vertical(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 24,
            children: [
              if (showHeader) createPageHeader(config),
              if (showStats) createStatsSection(config),
              if (showChart) createChartSection(config),
              if (showRecentItems) createRecentSection(config),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget createPageHeader(SkeletonConfig config) {
    return SkeletonLayoutBuilder.horizontal(
      children: [
        SkeletonShapeFactory.circular(size: 40),
        const SizedBox(width: 12),
        Expanded(
          child: SkeletonLayoutBuilder.vertical(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              SkeletonShapeFactory.text(width: 120, height: 20),
              SkeletonShapeFactory.text(width: 80, height: 16),
            ],
          ),
        ),
        SkeletonShapeFactory.circular(size: 32),
      ],
    );
  }

  @override
  Widget createStatsSection(SkeletonConfig config) {
    final statCount = config.options['statCount'] ?? 3;

    return SizedBox(
      height: 120,
      child: SkeletonLayoutBuilder.horizontal(
        children: List.generate(statCount, (index) {
          return Expanded(
            child: _createStatCard(config, index, statCount),
          );
        }),
      ),
    );
  }

  @override
  Widget createChartSection(SkeletonConfig config) {
    return SkeletonContainer(
      height: 200,
      borderRadius: BorderRadiusTokens.card,
      child: SkeletonLayoutBuilder.vertical(
        spacing: 16,
        children: [
          _createChartHeader(config),
          Expanded(child: _createChartBars(config)),
        ],
      ),
    );
  }

  @override
  Widget createRecentSection(SkeletonConfig config) {
    final itemCount = config.options['recentItemCount'] ?? 3;

    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        SkeletonShapeFactory.text(width: 140, height: 18),
        ...List.generate(itemCount, (index) {
          return _createRecentItem(config, index);
        }),
      ],
    );
  }

  // Private helper methods following SRP

  Widget _createStatCard(SkeletonConfig config, int index, int total) {
    return Padding(
      padding: EdgeInsets.only(right: index < total - 1 ? 12 : 0),
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
    );
  }

  Widget _createChartHeader(SkeletonConfig config) {
    return SkeletonLayoutBuilder.horizontal(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SkeletonShapeFactory.text(width: 140, height: 20),
        SkeletonShapeFactory.text(width: 80, height: 16),
      ],
    );
  }

  Widget _createChartBars(SkeletonConfig config) {
    return SkeletonLayoutBuilder.horizontal(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        final barHeight = 40.0 + (index % 4) * 30.0;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SkeletonShapeFactory.rectangular(height: barHeight),
          ),
        );
      }),
    );
  }

  Widget _createRecentItem(SkeletonConfig config, int index) {
    return SkeletonContainer(
      height: 70,
      borderRadius: BorderRadiusTokens.card,
      child: SkeletonLayoutBuilder.horizontal(
        children: [
          SkeletonShapeFactory.circular(size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: SkeletonLayoutBuilder.vertical(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 6,
              children: [
                SkeletonShapeFactory.text(width: double.infinity, height: 16),
                SkeletonShapeFactory.text(width: 150, height: 14),
              ],
            ),
          ),
          SkeletonShapeFactory.text(width: 40, height: 12),
        ],
      ),
    );
  }
}