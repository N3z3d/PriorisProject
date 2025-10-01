import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/specialized_skeleton_interfaces.dart';

/// Modal skeleton service implementation following SRP
/// Single Responsibility: Creates only modal-related skeletons
class ModalSkeletonService implements IModalSkeletonService {

  @override
  Widget createBottomSheet(SkeletonConfig config) {
    final showHandle = config.options['showHandle'] ?? true;
    final showTitle = config.options['showTitle'] ?? true;

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SkeletonLayoutBuilder.vertical(
        spacing: 16,
        children: [
          if (showHandle) createModalHandle(config),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SkeletonLayoutBuilder.vertical(
              spacing: 16,
              children: [
                if (showTitle) createModalTitle(config),
                createModalItems(config),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget createModalHandle(SkeletonConfig config) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        child: SkeletonShapeFactory.rounded(width: 40, height: 4),
      ),
    );
  }

  @override
  Widget createModalTitle(SkeletonConfig config) {
    return Center(
      child: SkeletonShapeFactory.text(width: 160, height: 24),
    );
  }

  @override
  Widget createModalItems(SkeletonConfig config) {
    final itemCount = config.options['itemCount'] ?? 5;

    return Column(
      children: List.generate(itemCount, (index) {
        return createModalItem(config, index);
      }),
    );
  }

  @override
  Widget createModalItem(SkeletonConfig config, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SkeletonContainer(
        height: 56,
        borderRadius: BorderRadiusTokens.card,
        child: SkeletonLayoutBuilder.horizontal(
          children: [
            SkeletonShapeFactory.circular(size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: _createItemContent(config),
            ),
            SkeletonShapeFactory.circular(size: 20),
          ],
        ),
      ),
    );
  }

  // Private helper methods following SRP

  Widget _createItemContent(SkeletonConfig config) {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 4,
      children: [
        SkeletonShapeFactory.text(width: double.infinity, height: 16),
        SkeletonShapeFactory.text(width: 120, height: 14),
      ],
    );
  }
}