import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';
import '../interfaces/page_skeleton_factory.dart';

/// Factory for list page skeletons
/// Single Responsibility: Creates list-specific skeleton layouts
class ListPageSkeletonFactory implements IPageSkeletonFactory {
  @override
  List<String> get supportedPageTypes => [
    'list_page',
    'list',
    'lists_page',
    'collection_page',
  ];

  @override
  bool canHandlePageType(String pageType) {
    return supportedPageTypes.contains(pageType) ||
           pageType.contains('list') ||
           pageType.contains('collection');
  }

  @override
  Widget createPageSkeleton(String pageType, SkeletonConfig config) {
    return _createListPage(config);
  }

  Widget _createListPage(SkeletonConfig config) {
    final showHeader = config.options['showHeader'] ?? true;
    final showSearch = config.options['showSearch'] ?? true;
    final showFilters = config.options['showFilters'] ?? true;
    final itemCount = config.options['itemCount'] ?? 8;

    return Container(
      width: config.width,
      height: config.height ?? 800,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) _buildListHeader(),
          if (showSearch) _buildSearchBar(),
          if (showFilters) _buildFilterChips(),
          Expanded(child: _buildListItems(itemCount)),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonLine(width: 180, height: 24),
                SizedBox(height: 8),
                SkeletonLine(width: 120, height: 16),
              ],
            ),
          ),
          const SkeletonContainer(width: 40, height: 40),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Row(
          children: [
            SizedBox(width: 16),
            SkeletonContainer(width: 20, height: 20),
            SizedBox(width: 12),
            Expanded(child: SkeletonLine(width: double.infinity, height: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: List.generate(4, (index) => Container(
          margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
          child: _buildFilterChip(),
        )),
      ),
    );
  }

  Widget _buildFilterChip() {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: SkeletonLine(width: 60, height: 12),
      ),
    );
  }

  Widget _buildListItems(int itemCount) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, index) => _buildListItem(),
    );
  }

  Widget _buildListItem() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SkeletonContainer(width: 48, height: 48),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLine(width: 200, height: 18),
                const SizedBox(height: 8),
                const SkeletonLine(width: 150, height: 14),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const SkeletonLine(width: 80, height: 12),
                    const SizedBox(width: 16),
                    const SkeletonLine(width: 60, height: 12),
                  ],
                ),
              ],
            ),
          ),
          const SkeletonContainer(width: 24, height: 24),
        ],
      ),
    );
  }
}