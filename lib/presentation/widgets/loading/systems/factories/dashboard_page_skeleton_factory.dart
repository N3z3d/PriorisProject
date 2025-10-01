import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';
import '../interfaces/page_skeleton_factory.dart';

/// Factory for dashboard page skeletons
/// Single Responsibility: Creates dashboard-specific skeleton layouts
class DashboardPageSkeletonFactory implements IPageSkeletonFactory {
  @override
  List<String> get supportedPageTypes => [
    'dashboard_page',
    'dashboard',
    'main_dashboard',
    'home_dashboard',
  ];

  @override
  bool canHandlePageType(String pageType) {
    return supportedPageTypes.contains(pageType) ||
           pageType.contains('dashboard');
  }

  @override
  Widget createPageSkeleton(String pageType, SkeletonConfig config) {
    return _createDashboardPage(config);
  }

  Widget _createDashboardPage(SkeletonConfig config) {
    final showHeader = config.options['showHeader'] ?? true;
    final showStats = config.options['showStats'] ?? true;
    final showCharts = config.options['showCharts'] ?? true;
    final showActions = config.options['showActions'] ?? true;

    return Container(
      width: config.width,
      height: config.height ?? 800,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) _buildDashboardHeader(),
          if (showStats) _buildStatsSection(),
          if (showCharts) _buildChartsSection(),
          if (showActions) _buildQuickActions(),
          Expanded(child: _buildRecentActivity()),
        ],
      ),
    );
  }

  Widget _buildDashboardHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const SkeletonAvatar(radius: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonLine(width: 150, height: 20),
                SizedBox(height: 8),
                SkeletonLine(width: 200, height: 16),
              ],
            ),
          ),
          const SkeletonContainer(width: 40, height: 40),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(3, (index) => Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
            child: _buildStatCard(),
          ),
        )),
      ),
    );
  }

  Widget _buildStatCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: const [
          SkeletonLine(width: 60, height: 24),
          SizedBox(height: 8),
          SkeletonLine(width: 80, height: 16),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLine(width: 120, height: 18),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: SkeletonContainer(width: 300, height: 150),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLine(width: 100, height: 18),
          const SizedBox(height: 16),
          Row(
            children: List.generate(4, (index) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index < 3 ? 12 : 0),
                child: _buildActionButton(),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SkeletonContainer(width: 32, height: 32),
          SizedBox(height: 8),
          SkeletonLine(width: 60, height: 12),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLine(width: 140, height: 18),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) => _buildActivityItem(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SkeletonContainer(width: 40, height: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonLine(width: 180, height: 14),
                SizedBox(height: 4),
                SkeletonLine(width: 120, height: 12),
              ],
            ),
          ),
          const SkeletonLine(width: 50, height: 12),
        ],
      ),
    );
  }
}