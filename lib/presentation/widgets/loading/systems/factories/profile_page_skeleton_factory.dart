import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';
import '../interfaces/page_skeleton_factory.dart';

/// Factory for profile page skeletons
/// Single Responsibility: Creates profile-specific skeleton layouts
class ProfilePageSkeletonFactory implements IPageSkeletonFactory {
  @override
  List<String> get supportedPageTypes => [
    'profile_page',
    'profile',
    'user_profile',
    'account_page',
  ];

  @override
  bool canHandlePageType(String pageType) {
    return supportedPageTypes.contains(pageType) ||
           pageType.contains('profile') ||
           pageType.contains('account');
  }

  @override
  Widget createPageSkeleton(String pageType, SkeletonConfig config) {
    return _createProfilePage(config);
  }

  Widget _createProfilePage(SkeletonConfig config) {
    final showAvatar = config.options['showAvatar'] ?? true;
    final showStats = config.options['showStats'] ?? true;
    final showActions = config.options['showActions'] ?? true;
    final showSettings = config.options['showSettings'] ?? true;

    return Container(
      width: config.width,
      height: config.height ?? 800,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showAvatar) _buildProfileHeader(),
            if (showStats) _buildProfileStats(),
            if (showActions) _buildProfileActions(),
            if (showSettings) _buildProfileSettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SkeletonAvatar(radius: 50),
          const SizedBox(height: 16),
          const SkeletonLine(width: 160, height: 24),
          const SizedBox(height: 8),
          const SkeletonLine(width: 200, height: 16),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton('Modifier'),
              const SizedBox(width: 12),
              _buildActionButton('Partager'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label) {
    return Container(
      width: 80,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: SkeletonLine(width: 60, height: 14),
      ),
    );
  }

  Widget _buildProfileStats() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) => _buildStatItem()),
      ),
    );
  }

  Widget _buildStatItem() {
    return Column(
      children: const [
        SkeletonLine(width: 40, height: 20),
        SizedBox(height: 4),
        SkeletonLine(width: 60, height: 14),
      ],
    );
  }

  Widget _buildProfileActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLine(width: 120, height: 18),
          const SizedBox(height: 16),
          ...List.generate(4, (index) => _buildActionTile()),
        ],
      ),
    );
  }

  Widget _buildActionTile() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
    );
  }

  Widget _buildProfileSettings() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLine(width: 100, height: 18),
          const SizedBox(height: 16),
          ...List.generate(6, (index) => _buildSettingsTile()),
        ],
      ),
    );
  }

  Widget _buildSettingsTile() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SkeletonContainer(width: 24, height: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonLine(width: 120, height: 14),
                SizedBox(height: 4),
                SkeletonLine(width: 80, height: 12),
              ],
            ),
          ),
          const SkeletonContainer(width: 40, height: 20),
        ],
      ),
    );
  }
}