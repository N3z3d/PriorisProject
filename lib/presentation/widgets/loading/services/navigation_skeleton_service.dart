import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/specialized_skeleton_interfaces.dart';

/// Navigation skeleton service implementation following SRP
/// Single Responsibility: Creates only navigation-related skeletons
class NavigationSkeletonService implements INavigationSkeletonService {

  @override
  Widget createNavigationDrawer(SkeletonConfig config) {
    final showProfile = config.options['showProfile'] ?? true;

    return Drawer(
      child: SkeletonLayoutBuilder.vertical(
        spacing: 0,
        children: [
          if (showProfile) createDrawerHeader(config),
          Expanded(child: createMenuItems(config)),
          createDrawerFooter(config),
        ],
      ),
    );
  }

  @override
  Widget createDrawerHeader(SkeletonConfig config) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 12,
        children: [
          SkeletonShapeFactory.circular(size: 64),
          SkeletonShapeFactory.text(width: 140, height: 20),
          SkeletonShapeFactory.text(width: 180, height: 16),
        ],
      ),
    );
  }

  @override
  Widget createMenuItems(SkeletonConfig config) {
    final itemCount = config.options['itemCount'] ?? 8;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SkeletonLayoutBuilder.list(
        spacing: 4,
        children: List.generate(itemCount, (index) {
          return createMenuItem(config, index);
        }),
      ),
    );
  }

  @override
  Widget createMenuItem(SkeletonConfig config, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SkeletonContainer(
        height: 56,
        borderRadius: BorderRadiusTokens.radiusSm,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SkeletonLayoutBuilder.horizontal(
          children: [
            SkeletonShapeFactory.circular(size: 24),
            const SizedBox(width: 24),
            Expanded(
              child: SkeletonShapeFactory.text(
                width: double.infinity,
                height: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget createDrawerFooter(SkeletonConfig config) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SkeletonLayoutBuilder.vertical(
        spacing: 8,
        children: [
          SkeletonShapeFactory.rectangular(
            height: 1,
            width: double.infinity,
          ),
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