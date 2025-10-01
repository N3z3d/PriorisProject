import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/specialized_skeleton_interfaces.dart';

/// List skeleton service implementation following SRP
/// Single Responsibility: Creates only list-related skeletons
class ListSkeletonService implements IListSkeletonService {

  @override
  Widget createListSkeleton(SkeletonConfig config) {
    final showSearchBar = config.options['showSearchBar'] ?? true;
    final showFilters = config.options['showFilters'] ?? true;

    return Scaffold(
      appBar: AppBar(
        title: SkeletonShapeFactory.text(width: 120, height: 20),
        actions: [createAppBarActions(config)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SkeletonLayoutBuilder.vertical(
          spacing: 16,
          children: [
            if (showSearchBar) createSearchBar(config),
            if (showFilters) createFilters(config),
            Expanded(child: createListItems(config)),
          ],
        ),
      ),
      floatingActionButton: createFloatingActionButton(config),
    );
  }

  @override
  Widget createSearchBar(SkeletonConfig config) {
    return SkeletonLayoutBuilder.horizontal(
      children: [
        Expanded(child: SkeletonShapeFactory.input()),
        const SizedBox(width: 12),
        SkeletonShapeFactory.circular(size: 48),
      ],
    );
  }

  @override
  Widget createFilters(SkeletonConfig config) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return SkeletonShapeFactory.badge(width: 80, height: 32);
        },
      ),
    );
  }

  @override
  Widget createListItems(SkeletonConfig config) {
    final itemCount = config.options['itemCount'] ?? 8;

    return SkeletonLayoutBuilder.list(
      children: List.generate(itemCount, (index) {
        return _createListItem(config, index);
      }),
    );
  }

  @override
  Widget createAppBarActions(SkeletonConfig config) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SkeletonShapeFactory.circular(size: 24),
        const SizedBox(width: 8),
        SkeletonShapeFactory.circular(size: 24),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Widget createFloatingActionButton(SkeletonConfig config) {
    return SkeletonShapeFactory.circular(size: 56);
  }

  // Private helper methods following SRP

  Widget _createListItem(SkeletonConfig config, int index) {
    return SkeletonContainer(
      height: 80,
      borderRadius: BorderRadiusTokens.card,
      child: SkeletonLayoutBuilder.horizontal(
        children: [
          SkeletonShapeFactory.rounded(width: 50, height: 50),
          const SizedBox(width: 16),
          Expanded(
            child: _createItemContent(config),
          ),
          SkeletonShapeFactory.circular(size: 24),
        ],
      ),
    );
  }

  Widget _createItemContent(SkeletonConfig config) {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children: [
        SkeletonShapeFactory.text(width: double.infinity, height: 18),
        SkeletonShapeFactory.text(width: 150, height: 14),
      ],
    );
  }
}