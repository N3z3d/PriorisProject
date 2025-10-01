import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';
import '../interfaces/page_skeleton_factory.dart';

/// Factory for settings page skeletons
/// Single Responsibility: Creates settings-specific skeleton layouts
class SettingsPageSkeletonFactory implements IPageSkeletonFactory {
  @override
  List<String> get supportedPageTypes => [
    'settings_page',
    'settings',
    'preferences',
    'config_page',
  ];

  @override
  bool canHandlePageType(String pageType) {
    return supportedPageTypes.contains(pageType) ||
           pageType.contains('settings') ||
           pageType.contains('preferences') ||
           pageType.contains('config');
  }

  @override
  Widget createPageSkeleton(String pageType, SkeletonConfig config) {
    return _createSettingsPage(config);
  }

  Widget _createSettingsPage(SkeletonConfig config) {
    final showProfile = config.options['showProfile'] ?? true;
    final showNotifications = config.options['showNotifications'] ?? true;
    final showPrivacy = config.options['showPrivacy'] ?? true;
    final showAccount = config.options['showAccount'] ?? true;

    return Container(
      width: config.width,
      height: config.height ?? 800,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingsHeader(),
            if (showProfile) _buildProfileSection(),
            if (showNotifications) _buildNotificationsSection(),
            if (showPrivacy) _buildPrivacySection(),
            if (showAccount) _buildAccountSection(),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const SkeletonContainer(width: 40, height: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonLine(width: 120, height: 24),
                SizedBox(height: 8),
                SkeletonLine(width: 180, height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return _buildSection('Profile', [
      _buildSettingItem(icon: true, toggle: false),
      _buildSettingItem(icon: true, toggle: false),
      _buildSettingItem(icon: true, toggle: false),
    ]);
  }

  Widget _buildNotificationsSection() {
    return _buildSection('Notifications', [
      _buildSettingItem(icon: true, toggle: true),
      _buildSettingItem(icon: true, toggle: true),
      _buildSettingItem(icon: true, toggle: true),
      _buildSettingItem(icon: true, toggle: false),
    ]);
  }

  Widget _buildPrivacySection() {
    return _buildSection('Confidentialité', [
      _buildSettingItem(icon: true, toggle: true),
      _buildSettingItem(icon: true, toggle: false),
      _buildSettingItem(icon: true, toggle: true),
    ]);
  }

  Widget _buildAccountSection() {
    return _buildSection('Compte', [
      _buildSettingItem(icon: true, toggle: false),
      _buildSettingItem(icon: true, toggle: false),
      _buildSettingItem(icon: true, toggle: false, isDestructive: true),
    ]);
  }

  Widget _buildAboutSection() {
    return _buildSection('À propos', [
      _buildSettingItem(icon: true, toggle: false),
      _buildSettingItem(icon: true, toggle: false),
      _buildSettingItem(icon: true, toggle: false),
    ]);
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: SkeletonLine(width: 100, height: 16),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: items,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    bool icon = false,
    bool toggle = false,
    bool isDestructive = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (icon) ...[
            SkeletonContainer(
              width: 24,
              height: 24,
              color: isDestructive ? Colors.red[100] : null,
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(
                  width: 140,
                  height: 16,
                  color: isDestructive ? Colors.red[100] : null,
                ),
                const SizedBox(height: 4),
                SkeletonLine(
                  width: 100,
                  height: 12,
                  color: Colors.grey[200],
                ),
              ],
            ),
          ),
          if (toggle)
            Container(
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
            )
          else
            const SkeletonContainer(width: 20, height: 20),
        ],
      ),
    );
  }
}