import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/specialized_skeleton_interfaces.dart';

/// Settings skeleton service implementation following SRP
/// Single Responsibility: Creates only settings-related skeletons
class SettingsSkeletonService implements ISettingsSkeletonService {

  @override
  Widget createSettingsSkeleton(SkeletonConfig config) {
    final sectionCount = config.options['sectionCount'] ?? 4;
    final showProfile = config.options['showProfile'] ?? true;

    return Scaffold(
      appBar: AppBar(
        title: SkeletonShapeFactory.text(width: 80, height: 20),
        actions: [
          SkeletonShapeFactory.circular(size: 24),
          const SizedBox(width: 16),
        ],
      ),
      body: SkeletonLayoutBuilder.list(
        children: [
          if (showProfile) createProfileSection(config),
          ...List.generate(sectionCount, (index) {
            return createSettingsSection(config, index);
          }),
        ],
      ),
    );
  }

  @override
  Widget createProfileSection(SkeletonConfig config) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SkeletonContainer(
        height: 80,
        borderRadius: BorderRadiusTokens.card,
        child: SkeletonLayoutBuilder.horizontal(
          children: [
            SkeletonShapeFactory.circular(size: 50),
            const SizedBox(width: 16),
            Expanded(
              child: _createProfileInfo(config),
            ),
            SkeletonShapeFactory.circular(size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget createSettingsSection(SkeletonConfig config, int sectionIndex) {
    final itemCount = 3 + (sectionIndex % 2); // Vary items per section

    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        createSectionHeader(config),
        ...List.generate(itemCount, (itemIndex) {
          return createSettingsItem(config, itemIndex);
        }),
      ],
    );
  }

  @override
  Widget createSectionHeader(SkeletonConfig config) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: SkeletonShapeFactory.text(width: 120, height: 16),
    );
  }

  @override
  Widget createSettingsItem(SkeletonConfig config, int itemIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SkeletonContainer(
        height: 56,
        borderRadius: BorderRadiusTokens.radiusSm,
        child: SkeletonLayoutBuilder.horizontal(
          children: [
            SkeletonShapeFactory.circular(size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: SkeletonShapeFactory.text(
                width: double.infinity,
                height: 16,
              ),
            ),
            _createSettingsControl(config, itemIndex),
          ],
        ),
      ),
    );
  }

  // Private helper methods following SRP

  Widget _createProfileInfo(SkeletonConfig config) {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 6,
      children: [
        SkeletonShapeFactory.text(width: 120, height: 18),
        SkeletonShapeFactory.text(width: 180, height: 14),
      ],
    );
  }

  Widget _createSettingsControl(SkeletonConfig config, int itemIndex) {
    // Some items have switches, others have navigation indicators
    if (itemIndex % 3 == 0) {
      return SkeletonShapeFactory.rounded(width: 44, height: 24);
    } else {
      return SkeletonShapeFactory.circular(size: 16);
    }
  }
}