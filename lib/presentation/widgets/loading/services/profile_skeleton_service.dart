import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/specialized_skeleton_interfaces.dart';

/// Profile skeleton service implementation following SRP
/// Single Responsibility: Creates only profile-related skeletons
class ProfileSkeletonService implements IProfileSkeletonService {

  @override
  Widget createProfileSkeleton(SkeletonConfig config) {
    final showCoverImage = config.options['showCoverImage'] ?? true;
    final showTabs = config.options['showTabs'] ?? true;

    return Scaffold(
      body: SkeletonLayoutBuilder.vertical(
        spacing: 0,
        children: [
          if (showCoverImage) createCoverImage(config),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SkeletonLayoutBuilder.vertical(
              spacing: 16,
              children: [
                createProfileInfo(config),
                createBioSection(config),
                createStatsRow(config),
                if (showTabs) createTabBar(config),
              ],
            ),
          ),
          Expanded(child: createTabContent(config)),
        ],
      ),
    );
  }

  @override
  Widget createCoverImage(SkeletonConfig config) {
    return SkeletonShapeFactory.rectangular(
      width: double.infinity,
      height: 200,
    );
  }

  @override
  Widget createProfileInfo(SkeletonConfig config) {
    return SkeletonLayoutBuilder.horizontal(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonShapeFactory.circular(size: 80),
        const SizedBox(width: 16),
        Expanded(
          child: _createBasicInfo(config),
        ),
        SkeletonShapeFactory.button(width: 100, height: 36),
      ],
    );
  }

  @override
  Widget createBioSection(SkeletonConfig config) {
    final showBio = config.options['showBio'] ?? true;
    if (!showBio) return const SizedBox.shrink();

    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        SkeletonShapeFactory.text(width: double.infinity, height: 16),
        SkeletonShapeFactory.text(width: 280, height: 16),
        SkeletonShapeFactory.text(width: 200, height: 16),
      ],
    );
  }

  @override
  Widget createStatsRow(SkeletonConfig config) {
    final showStats = config.options['showStats'] ?? true;
    if (!showStats) return const SizedBox.shrink();

    return SkeletonLayoutBuilder.horizontal(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(3, (index) {
        return _createStatItem(config, index);
      }),
    );
  }

  @override
  Widget createTabBar(SkeletonConfig config) {
    return SkeletonLayoutBuilder.horizontal(
      children: List.generate(3, (index) {
        return Expanded(
          child: Center(
            child: SkeletonShapeFactory.text(width: 60, height: 16),
          ),
        );
      }),
    );
  }

  @override
  Widget createTabContent(SkeletonConfig config) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SkeletonLayoutBuilder.list(
        children: List.generate(4, (index) {
          return _createContentItem(config, index);
        }),
      ),
    );
  }

  // Private helper methods following SRP

  Widget _createBasicInfo(SkeletonConfig config) {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        SkeletonShapeFactory.text(width: 140, height: 24),
        SkeletonShapeFactory.text(width: 100, height: 16),
        SkeletonShapeFactory.text(width: 120, height: 14),
      ],
    );
  }

  Widget _createStatItem(SkeletonConfig config, int index) {
    return SkeletonLayoutBuilder.vertical(
      children: [
        SkeletonShapeFactory.text(width: 40, height: 24),
        const SizedBox(height: 4),
        SkeletonShapeFactory.text(width: 60, height: 16),
      ],
    );
  }

  Widget _createContentItem(SkeletonConfig config, int index) {
    return SkeletonContainer(
      height: 100,
      borderRadius: BorderRadiusTokens.card,
      child: SkeletonLayoutBuilder.horizontal(
        children: [
          SkeletonShapeFactory.rounded(width: 60, height: 60),
          const SizedBox(width: 16),
          Expanded(
            child: SkeletonLayoutBuilder.vertical(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                SkeletonShapeFactory.text(width: double.infinity, height: 18),
                SkeletonShapeFactory.text(width: 200, height: 14),
                SkeletonShapeFactory.text(width: 80, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}