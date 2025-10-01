import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';

/// List skeleton system implementation - Single Responsibility: List-based skeletons
/// Follows SRP by handling only list and tile-related skeleton patterns
class ListSkeletonSystem implements IVariantSkeletonSystem, IAnimatedSkeletonSystem {
  @override
  String get systemId => 'list_skeleton_system';

  @override
  List<String> get supportedTypes => [
    'list_item',
    'search_list',
    'conversation_list',
    'notification_list',
    'menu_list',
    'settings_list',
    'infinite_scroll',
  ];

  @override
  List<String> get availableVariants => [
    'standard',
    'detailed',
    'compact',
    'conversation',
    'notification',
    'menu',
    'settings',
  ];

  @override
  Duration get defaultAnimationDuration => const Duration(milliseconds: 1500);

  @override
  bool canHandle(String skeletonType) {
    return supportedTypes.contains(skeletonType) ||
           skeletonType.endsWith('_list') ||
           skeletonType.contains('list') ||
           availableVariants.any((variant) => skeletonType.contains(variant));
  }

  @override
  Widget createSkeleton({
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    return createVariant(
      'standard',
      width: width,
      height: height,
      options: options,
    );
  }

  @override
  Widget createVariant(
    String variant, {
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    final config = SkeletonConfig(
      width: width,
      height: height,
      options: options ?? {},
    );

    switch (variant) {
      case 'detailed':
        return _createDetailedList(config);
      case 'compact':
        return _createCompactList(config);
      case 'conversation':
        return _createConversationList(config);
      case 'notification':
        return _createNotificationList(config);
      case 'menu':
        return _createMenuList(config);
      case 'settings':
        return _createSettingsList(config);
      case 'standard':
      default:
        return _createStandardList(config);
    }
  }

  @override
  Widget createAnimatedSkeleton({
    double? width,
    double? height,
    Duration? duration,
    AnimationController? controller,
    Map<String, dynamic>? options,
  }) {
    return createVariant(
      'standard',
      width: width,
      height: height,
      options: {
        ...options ?? {},
        'animation_duration': duration,
        'animation_controller': controller,
      },
    );
  }

  /// Creates a standard list skeleton with basic items
  Widget _createStandardList(SkeletonConfig config) {
    final itemCount = config.options['itemCount'] ?? 5;
    final itemHeight = config.options['itemHeight']?.toDouble() ?? 80.0;
    final spacing = config.options['spacing']?.toDouble() ?? 12.0;

    return SkeletonLayoutBuilder.list(
      spacing: spacing,
      children: List.generate(itemCount, (index) => _createStandardListItem(
        SkeletonConfig(
          width: config.width,
          height: itemHeight,
          animationDuration: config.animationDuration,
        ),
      )),
    );
  }

  /// Creates a detailed list skeleton with rich content
  Widget _createDetailedList(SkeletonConfig config) {
    final itemCount = config.options['itemCount'] ?? 4;
    final itemHeight = config.options['itemHeight']?.toDouble() ?? 120.0;
    final spacing = config.options['spacing']?.toDouble() ?? 16.0;

    return SkeletonLayoutBuilder.list(
      spacing: spacing,
      children: List.generate(itemCount, (index) => _createDetailedListItem(
        SkeletonConfig(
          width: config.width,
          height: itemHeight,
          animationDuration: config.animationDuration,
        ),
      )),
    );
  }

  /// Creates a compact list skeleton with minimal content
  Widget _createCompactList(SkeletonConfig config) {
    final itemCount = config.options['itemCount'] ?? 8;
    final itemHeight = config.options['itemHeight']?.toDouble() ?? 50.0;
    final spacing = config.options['spacing']?.toDouble() ?? 8.0;

    return SkeletonLayoutBuilder.list(
      spacing: spacing,
      children: List.generate(itemCount, (index) => _createCompactListItem(
        SkeletonConfig(
          width: config.width,
          height: itemHeight,
          animationDuration: config.animationDuration,
        ),
      )),
    );
  }

  /// Creates a conversation list skeleton for chat-like interfaces
  Widget _createConversationList(SkeletonConfig config) {
    final itemCount = config.options['itemCount'] ?? 6;
    final spacing = config.options['spacing']?.toDouble() ?? 12.0;

    return SkeletonLayoutBuilder.list(
      spacing: spacing,
      children: List.generate(itemCount, (index) => _createConversationListItem(
        SkeletonConfig(
          width: config.width,
          animationDuration: config.animationDuration,
          options: {
            'isOutgoing': index % 3 == 0, // Vary message alignment
          },
        ),
      )),
    );
  }

  /// Creates a notification list skeleton
  Widget _createNotificationList(SkeletonConfig config) {
    final itemCount = config.options['itemCount'] ?? 5;
    final spacing = config.options['spacing']?.toDouble() ?? 12.0;

    return SkeletonLayoutBuilder.list(
      spacing: spacing,
      children: List.generate(itemCount, (index) => _createNotificationListItem(
        SkeletonConfig(
          width: config.width,
          height: 90,
          animationDuration: config.animationDuration,
          options: {
            'showBadge': index % 2 == 0, // Some notifications have badges
          },
        ),
      )),
    );
  }

  /// Creates a menu list skeleton for navigation
  Widget _createMenuList(SkeletonConfig config) {
    final itemCount = config.options['itemCount'] ?? 6;
    final spacing = config.options['spacing']?.toDouble() ?? 8.0;

    return SkeletonLayoutBuilder.list(
      spacing: spacing,
      children: List.generate(itemCount, (index) => _createMenuListItem(
        SkeletonConfig(
          width: config.width,
          height: 56,
          animationDuration: config.animationDuration,
          options: {
            'showIcon': true,
            'showArrow': index % 4 != 0, // Not all menu items have arrows
          },
        ),
      )),
    );
  }

  /// Creates a settings list skeleton
  Widget _createSettingsList(SkeletonConfig config) {
    final itemCount = config.options['itemCount'] ?? 5;
    final spacing = config.options['spacing']?.toDouble() ?? 16.0;

    return SkeletonLayoutBuilder.list(
      spacing: spacing,
      children: List.generate(itemCount, (index) => _createSettingsListItem(
        SkeletonConfig(
          width: config.width,
          height: 72,
          animationDuration: config.animationDuration,
          options: {
            'showSwitch': index % 3 == 0,
            'showDescription': index % 2 == 0,
          },
        ),
      )),
    );
  }

  // Individual list item skeletons

  Widget _createStandardListItem(SkeletonConfig config) {
    return SkeletonContainer(
      width: config.width,
      height: config.height,
      borderRadius: BorderRadiusTokens.card,
      animationDuration: config.animationDuration ?? defaultAnimationDuration,
      child: SkeletonLayoutBuilder.horizontal(
        children: [
          SkeletonShapeFactory.rounded(width: 50, height: 50),
          const SizedBox(width: 16),
          Expanded(
            child: SkeletonLayoutBuilder.vertical(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                SkeletonShapeFactory.text(width: double.infinity, height: 18),
                SkeletonShapeFactory.text(width: 150, height: 14),
              ],
            ),
          ),
          SkeletonShapeFactory.button(width: 80, height: 32),
        ],
      ),
    );
  }

  Widget _createDetailedListItem(SkeletonConfig config) {
    return SkeletonContainer(
      width: config.width,
      height: config.height,
      borderRadius: BorderRadiusTokens.card,
      animationDuration: config.animationDuration ?? defaultAnimationDuration,
      child: SkeletonLayoutBuilder.horizontal(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonShapeFactory.rounded(width: 60, height: 60),
          const SizedBox(width: 16),
          Expanded(
            child: SkeletonLayoutBuilder.vertical(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                SkeletonLayoutBuilder.horizontal(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonShapeFactory.text(width: 140, height: 18),
                    SkeletonShapeFactory.text(width: 60, height: 14),
                  ],
                ),
                SkeletonShapeFactory.text(width: double.infinity, height: 16),
                SkeletonShapeFactory.text(width: 200, height: 16),
                const SizedBox(height: 8),
                SkeletonLayoutBuilder.horizontal(
                  children: [
                    SkeletonShapeFactory.badge(width: 50),
                    const SizedBox(width: 8),
                    SkeletonShapeFactory.badge(width: 40),
                    const Spacer(),
                    SkeletonShapeFactory.circular(size: 20),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _createCompactListItem(SkeletonConfig config) {
    return SkeletonContainer(
      width: config.width,
      height: config.height,
      borderRadius: BorderRadiusTokens.radiusSm,
      animationDuration: config.animationDuration ?? defaultAnimationDuration,
      child: SkeletonLayoutBuilder.horizontal(
        children: [
          SkeletonShapeFactory.circular(size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: SkeletonShapeFactory.text(width: double.infinity, height: 16),
          ),
          SkeletonShapeFactory.circular(size: 16),
        ],
      ),
    );
  }

  Widget _createConversationListItem(SkeletonConfig config) {
    final isOutgoing = config.options['isOutgoing'] ?? false;
    final messageWidth = 200.0 + (config.options['messageLength'] ?? 0) * 20.0;

    return SkeletonContainer(
      width: config.width,
      height: null, // Auto height
      borderRadius: BorderRadiusTokens.card,
      animationDuration: config.animationDuration ?? defaultAnimationDuration,
      child: SkeletonLayoutBuilder.horizontal(
        mainAxisAlignment: isOutgoing
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isOutgoing) ...[
            SkeletonShapeFactory.circular(size: 40),
            const SizedBox(width: 12),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: messageWidth),
            child: SkeletonLayoutBuilder.vertical(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                SkeletonShapeFactory.text(width: double.infinity, height: 16),
                SkeletonShapeFactory.text(width: messageWidth * 0.7, height: 16),
                SkeletonShapeFactory.text(width: 60, height: 12), // Timestamp
              ],
            ),
          ),
          if (isOutgoing) ...[
            const SizedBox(width: 12),
            SkeletonShapeFactory.circular(size: 40),
          ],
        ],
      ),
    );
  }

  Widget _createNotificationListItem(SkeletonConfig config) {
    final showBadge = config.options['showBadge'] ?? false;

    return SkeletonContainer(
      width: config.width,
      height: config.height,
      borderRadius: BorderRadiusTokens.card,
      animationDuration: config.animationDuration ?? defaultAnimationDuration,
      child: SkeletonLayoutBuilder.horizontal(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonShapeFactory.circular(size: 48),
          const SizedBox(width: 16),
          Expanded(
            child: SkeletonLayoutBuilder.vertical(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                SkeletonLayoutBuilder.horizontal(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonShapeFactory.text(width: 120, height: 18),
                    SkeletonShapeFactory.text(width: 50, height: 14),
                  ],
                ),
                SkeletonShapeFactory.text(width: double.infinity, height: 16),
                SkeletonShapeFactory.text(width: 180, height: 16),
              ],
            ),
          ),
          if (showBadge) ...[
            const SizedBox(width: 8),
            SkeletonShapeFactory.circular(size: 12),
          ],
        ],
      ),
    );
  }

  Widget _createMenuListItem(SkeletonConfig config) {
    final showIcon = config.options['showIcon'] ?? true;
    final showArrow = config.options['showArrow'] ?? true;

    return SkeletonContainer(
      width: config.width,
      height: config.height,
      borderRadius: BorderRadiusTokens.radiusSm,
      animationDuration: config.animationDuration ?? defaultAnimationDuration,
      child: SkeletonLayoutBuilder.horizontal(
        children: [
          if (showIcon) ...[
            SkeletonShapeFactory.circular(size: 24),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: SkeletonShapeFactory.text(width: double.infinity, height: 16),
          ),
          if (showArrow)
            SkeletonShapeFactory.circular(size: 16),
        ],
      ),
    );
  }

  Widget _createSettingsListItem(SkeletonConfig config) {
    final showSwitch = config.options['showSwitch'] ?? false;
    final showDescription = config.options['showDescription'] ?? false;

    return SkeletonContainer(
      width: config.width,
      height: config.height,
      borderRadius: BorderRadiusTokens.card,
      animationDuration: config.animationDuration ?? defaultAnimationDuration,
      child: SkeletonLayoutBuilder.horizontal(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonShapeFactory.circular(size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: SkeletonLayoutBuilder.vertical(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: showDescription ? 6 : 0,
              children: [
                SkeletonShapeFactory.text(width: 140, height: 18),
                if (showDescription)
                  SkeletonShapeFactory.text(width: 200, height: 14),
              ],
            ),
          ),
          if (showSwitch)
            SkeletonShapeFactory.rounded(width: 44, height: 24)
          else
            SkeletonShapeFactory.circular(size: 20),
        ],
      ),
    );
  }
}