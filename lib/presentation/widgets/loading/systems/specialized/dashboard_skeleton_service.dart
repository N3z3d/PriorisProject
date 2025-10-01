import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';

/// Service spécialisé pour les squelettes de dashboard
///
/// Respecte le Single Responsibility Principle en ne gérant que
/// les layouts de type dashboard avec leurs variantes
class DashboardSkeletonService {
  static const String serviceId = 'dashboard_skeleton_service';

  /// Types supportés par ce service
  static const List<String> supportedTypes = [
    'dashboard_page',
    'dashboard_layout',
    'stats_dashboard',
    'analytics_dashboard',
  ];

  /// Variantes disponibles
  static const List<String> availableVariants = [
    'standard',
    'compact',
    'detailed',
    'minimal',
  ];

  /// Vérifie si ce service peut gérer le type demandé
  static bool canHandle(String skeletonType) {
    return supportedTypes.contains(skeletonType) ||
           skeletonType.contains('dashboard');
  }

  /// Crée un squelette de dashboard selon la variante
  static Widget createDashboard({
    String variant = 'standard',
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    final config = SkeletonConfig(
      width: width,
      height: height,
      options: options ?? {},
    );

    switch (variant) {
      case 'compact':
        return _createCompactDashboard(config);
      case 'detailed':
        return _createDetailedDashboard(config);
      case 'minimal':
        return _createMinimalDashboard(config);
      case 'standard':
      default:
        return _createStandardDashboard(config);
    }
  }

  /// Dashboard standard avec toutes les sections
  static Widget _createStandardDashboard(SkeletonConfig config) {
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
              if (showHeader) _createHeader(config),
              if (showStats) _createStatsGrid(config),
              if (showChart) _createChartSection(config),
              if (showRecentItems) _createRecentActivity(config),
            ],
          ),
        ),
      ),
    );
  }

  /// Dashboard compact pour mobile
  static Widget _createCompactDashboard(SkeletonConfig config) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SkeletonLayoutBuilder.vertical(
            spacing: 16,
            children: [
              _createCompactHeader(),
              _createCompactStats(),
              _createMiniChart(),
            ],
          ),
        ),
      ),
    );
  }

  /// Dashboard détaillé avec plus d'informations
  static Widget _createDetailedDashboard(SkeletonConfig config) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SkeletonLayoutBuilder.vertical(
            spacing: 32,
            children: [
              _createDetailedHeader(),
              _createExtendedStats(),
              _createMultipleCharts(),
              _createDetailedActivity(),
            ],
          ),
        ),
      ),
    );
  }

  /// Dashboard minimal avec le strict nécessaire
  static Widget _createMinimalDashboard(SkeletonConfig config) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SkeletonLayoutBuilder.vertical(
            spacing: 20,
            children: [
              _createMinimalHeader(),
              _createBasicStats(),
            ],
          ),
        ),
      ),
    );
  }

  // === COMPOSANTS HEADER ===

  static Widget _createHeader(SkeletonConfig config) {
    return SkeletonLayoutBuilder.horizontal(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SkeletonLayoutBuilder.horizontal(
          spacing: 12,
          children: [
            SkeletonAvatar(size: 48),
            SkeletonLayoutBuilder.vertical(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                SkeletonText(width: 120, height: 18),
                SkeletonText(width: 80, height: 14),
              ],
            ),
          ],
        ),
        SkeletonLayoutBuilder.horizontal(
          spacing: 8,
          children: [
            SkeletonButton(width: 40, height: 40, borderRadius: 20),
            SkeletonButton(width: 40, height: 40, borderRadius: 20),
          ],
        ),
      ],
    );
  }

  static Widget _createCompactHeader() {
    return SkeletonLayoutBuilder.horizontal(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SkeletonText(width: 100, height: 16),
        SkeletonButton(width: 32, height: 32, borderRadius: 16),
      ],
    );
  }

  static Widget _createDetailedHeader() {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        _createHeader(SkeletonConfig()),
        SkeletonLayoutBuilder.horizontal(
          spacing: 12,
          children: [
            SkeletonButton(width: 80, height: 32),
            SkeletonButton(width: 80, height: 32),
            SkeletonButton(width: 80, height: 32),
          ],
        ),
      ],
    );
  }

  static Widget _createMinimalHeader() {
    return SkeletonText(width: 150, height: 20);
  }

  // === COMPOSANTS STATS ===

  static Widget _createStatsGrid(SkeletonConfig config) {
    final statsCount = config.options['statsCount'] ?? 4;

    return SkeletonLayoutBuilder.grid(
      crossAxisCount: 2,
      spacing: 16,
      children: List.generate(
        statsCount,
        (index) => _createStatCard(),
      ),
    );
  }

  static Widget _createCompactStats() {
    return SkeletonLayoutBuilder.horizontal(
      spacing: 12,
      children: [
        Expanded(child: _createMiniStatCard()),
        Expanded(child: _createMiniStatCard()),
      ],
    );
  }

  static Widget _createExtendedStats() {
    return SkeletonLayoutBuilder.grid(
      crossAxisCount: 3,
      spacing: 16,
      children: List.generate(6, (index) => _createStatCard()),
    );
  }

  static Widget _createBasicStats() {
    return SkeletonLayoutBuilder.horizontal(
      spacing: 16,
      children: [
        Expanded(child: _createStatCard()),
        Expanded(child: _createStatCard()),
      ],
    );
  }

  static Widget _createStatCard() {
    return SkeletonCard(
      padding: const EdgeInsets.all(16),
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          SkeletonText(width: 60, height: 12),
          SkeletonText(width: 80, height: 24, style: SkeletonTextStyle.bold),
          SkeletonText(width: 40, height: 12),
        ],
      ),
    );
  }

  static Widget _createMiniStatCard() {
    return SkeletonCard(
      padding: const EdgeInsets.all(12),
      child: SkeletonLayoutBuilder.vertical(
        spacing: 6,
        children: [
          SkeletonText(width: 50, height: 10),
          SkeletonText(width: 60, height: 16, style: SkeletonTextStyle.bold),
        ],
      ),
    );
  }

  // === COMPOSANTS CHART ===

  static Widget _createChartSection(SkeletonConfig config) {
    return SkeletonCard(
      padding: const EdgeInsets.all(20),
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          SkeletonText(width: 120, height: 18, style: SkeletonTextStyle.bold),
          SkeletonChart(height: 200, type: SkeletonChartType.line),
        ],
      ),
    );
  }

  static Widget _createMiniChart() {
    return SkeletonCard(
      padding: const EdgeInsets.all(12),
      child: SkeletonChart(height: 120, type: SkeletonChartType.bar),
    );
  }

  static Widget _createMultipleCharts() {
    return SkeletonLayoutBuilder.vertical(
      spacing: 20,
      children: [
        _createChartSection(SkeletonConfig()),
        SkeletonLayoutBuilder.horizontal(
          spacing: 16,
          children: [
            Expanded(child: _createMiniChart()),
            Expanded(child: _createMiniChart()),
          ],
        ),
      ],
    );
  }

  // === COMPOSANTS ACTIVITY ===

  static Widget _createRecentActivity(SkeletonConfig config) {
    final itemCount = config.options['recentItemsCount'] ?? 5;

    return SkeletonCard(
      padding: const EdgeInsets.all(20),
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          SkeletonText(width: 140, height: 18, style: SkeletonTextStyle.bold),
          ...List.generate(
            itemCount,
            (index) => _createActivityItem(),
          ),
        ],
      ),
    );
  }

  static Widget _createDetailedActivity() {
    return SkeletonLayoutBuilder.vertical(
      spacing: 16,
      children: [
        _createRecentActivity(SkeletonConfig(options: {'recentItemsCount': 8})),
        SkeletonButton(width: double.infinity, height: 40),
      ],
    );
  }

  static Widget _createActivityItem() {
    return SkeletonLayoutBuilder.horizontal(
      spacing: 12,
      children: [
        SkeletonAvatar(size: 32),
        Expanded(
          child: SkeletonLayoutBuilder.vertical(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              SkeletonText(width: double.infinity, height: 14),
              SkeletonText(width: 100, height: 12),
            ],
          ),
        ),
        SkeletonText(width: 40, height: 12),
      ],
    );
  }
}