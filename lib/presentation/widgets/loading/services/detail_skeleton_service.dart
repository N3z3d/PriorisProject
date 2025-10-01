import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/specialized_skeleton_interfaces.dart';

/// Detail skeleton service implementation following SRP
/// Single Responsibility: Creates only detail-related skeletons
class DetailSkeletonService implements IDetailSkeletonService {

  @override
  Widget createDetailSkeleton(SkeletonConfig config) {
    final showImage = config.options['showImage'] ?? true;
    final showTabs = config.options['showTabs'] ?? false;

    return Scaffold(
      body: SkeletonLayoutBuilder.vertical(
        spacing: 0,
        children: [
          if (showImage) createHeaderImage(config),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SkeletonLayoutBuilder.vertical(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  createTitleSection(config),
                  createMetadataRow(config),
                  if (showTabs) _createTabBar(config),
                  Expanded(child: _createContentSections(config)),
                  createActionButtons(config),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget createHeaderImage(SkeletonConfig config) {
    final showActions = config.options['showActions'] ?? true;

    return Stack(
      children: [
        SkeletonShapeFactory.rectangular(
          width: double.infinity,
          height: 250,
        ),
        Positioned(
          top: 40,
          left: 16,
          child: SkeletonShapeFactory.circular(size: 40),
        ),
        if (showActions)
          Positioned(
            top: 40,
            right: 16,
            child: _createHeaderActions(config),
          ),
      ],
    );
  }

  @override
  Widget createTitleSection(SkeletonConfig config) {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        SkeletonShapeFactory.text(width: double.infinity, height: 28),
        SkeletonShapeFactory.text(width: 200, height: 16),
      ],
    );
  }

  @override
  Widget createMetadataRow(SkeletonConfig config) {
    return SkeletonLayoutBuilder.horizontal(
      children: [
        SkeletonShapeFactory.badge(width: 60),
        const SizedBox(width: 12),
        SkeletonShapeFactory.badge(width: 80),
        const Spacer(),
        SkeletonShapeFactory.text(width: 60, height: 14),
      ],
    );
  }

  @override
  Widget createDescriptionSection(SkeletonConfig config) {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        SkeletonShapeFactory.text(width: 100, height: 18),
        SkeletonShapeFactory.text(width: double.infinity, height: 16),
        SkeletonShapeFactory.text(width: double.infinity, height: 16),
        SkeletonShapeFactory.text(width: 250, height: 16),
      ],
    );
  }

  @override
  Widget createRelatedItems(SkeletonConfig config) {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        SkeletonShapeFactory.text(width: 120, height: 18),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _createRelatedItem(config, index);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget createActionButtons(SkeletonConfig config) {
    final showActions = config.options['showActions'] ?? true;
    if (!showActions) return const SizedBox.shrink();

    return SkeletonLayoutBuilder.horizontal(
      children: [
        Expanded(child: SkeletonShapeFactory.button(height: 48)),
        const SizedBox(width: 12),
        SkeletonShapeFactory.button(width: 100, height: 48),
      ],
    );
  }

  // Private helper methods following SRP

  Widget _createHeaderActions(SkeletonConfig config) {
    return SkeletonLayoutBuilder.horizontal(
      children: [
        SkeletonShapeFactory.circular(size: 40),
        const SizedBox(width: 8),
        SkeletonShapeFactory.circular(size: 40),
      ],
    );
  }

  Widget _createTabBar(SkeletonConfig config) {
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

  Widget _createContentSections(SkeletonConfig config) {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 24,
      children: [
        createDescriptionSection(config),
        _createStatsSection(config),
        createRelatedItems(config),
      ],
    );
  }

  Widget _createStatsSection(SkeletonConfig config) {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        SkeletonShapeFactory.text(width: 80, height: 18),
        SkeletonLayoutBuilder.horizontal(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(3, (index) {
            return SkeletonLayoutBuilder.vertical(
              children: [
                SkeletonShapeFactory.text(width: 40, height: 20),
                const SizedBox(height: 4),
                SkeletonShapeFactory.text(width: 60, height: 14),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _createRelatedItem(SkeletonConfig config, int index) {
    return SizedBox(
      width: 120,
      child: SkeletonContainer(
        borderRadius: BorderRadiusTokens.card,
        child: SkeletonLayoutBuilder.vertical(
          spacing: 8,
          children: [
            Expanded(
              child: SkeletonShapeFactory.rectangular(
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            SkeletonShapeFactory.text(width: double.infinity, height: 14),
          ],
        ),
      ),
    );
  }
}