import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';
import '../interfaces/page_skeleton_factory.dart';

/// Factory for navigation skeletons (drawer, bottom sheet)
/// Single Responsibility: Creates navigation-specific skeleton layouts
class NavigationSkeletonFactory implements IPageSkeletonFactory {
  @override
  List<String> get supportedPageTypes => [
    'navigation_drawer',
    'drawer',
    'bottom_sheet',
    'sheet',
    'nav_drawer',
  ];

  @override
  bool canHandlePageType(String pageType) {
    return supportedPageTypes.contains(pageType) ||
           pageType.contains('drawer') ||
           pageType.contains('sheet') ||
           pageType.contains('nav');
  }

  @override
  Widget createPageSkeleton(String pageType, SkeletonConfig config) {
    if (pageType.contains('drawer') || pageType.contains('nav')) {
      return _createNavigationDrawer(config);
    } else if (pageType.contains('sheet')) {
      return _createBottomSheet(config);
    }
    return _createNavigationDrawer(config);
  }

  Widget _createNavigationDrawer(SkeletonConfig config) {
    return Container(
      width: config.width ?? 280,
      height: config.height ?? double.infinity,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDrawerHeader(),
          Expanded(child: _buildDrawerItems()),
          _buildDrawerFooter(),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 160,
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(height: 20),
          SkeletonAvatar(radius: 30),
          SizedBox(height: 16),
          SkeletonLine(width: 140, height: 18),
          SizedBox(height: 8),
          SkeletonLine(width: 180, height: 14),
        ],
      ),
    );
  }

  Widget _buildDrawerItems() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: List.generate(8, (index) => _buildDrawerItem()),
    );
  }

  Widget _buildDrawerItem() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: const SkeletonContainer(width: 24, height: 24),
        title: const SkeletonLine(width: 120, height: 16),
        trailing: const SkeletonContainer(width: 20, height: 20),
      ),
    );
  }

  Widget _buildDrawerFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: const [
          SkeletonContainer(width: 24, height: 24),
          SizedBox(width: 12),
          SkeletonLine(width: 100, height: 16),
        ],
      ),
    );
  }

  Widget _createBottomSheet(SkeletonConfig config) {
    return Container(
      width: config.width ?? double.infinity,
      height: config.height ?? 400,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildSheetHandle(),
          _buildSheetHeader(),
          Expanded(child: _buildSheetContent()),
          _buildSheetActions(),
        ],
      ),
    );
  }

  Widget _buildSheetHandle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildSheetHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonLine(width: 160, height: 20),
                SizedBox(height: 8),
                SkeletonLine(width: 120, height: 14),
              ],
            ),
          ),
          const SkeletonContainer(width: 32, height: 32),
        ],
      ),
    );
  }

  Widget _buildSheetContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(6, (index) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              const SkeletonContainer(width: 40, height: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonLine(width: 140, height: 16),
                    SizedBox(height: 4),
                    SkeletonLine(width: 100, height: 12),
                  ],
                ),
              ),
              const SkeletonContainer(width: 20, height: 20),
            ],
          ),
        )),
      ),
    );
  }

  Widget _buildSheetActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: SkeletonLine(width: 80, height: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: SkeletonLine(width: 100, height: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}