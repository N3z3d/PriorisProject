import 'package:flutter/material.dart';
import 'skeleton_system_interface.dart';

/// Dashboard-specific skeleton interface following ISP
/// Single Responsibility: Dashboard page skeletons only
abstract class IDashboardSkeletonService {
  Widget createDashboardSkeleton(SkeletonConfig config);
  Widget createStatsSection(SkeletonConfig config);
  Widget createChartSection(SkeletonConfig config);
  Widget createRecentSection(SkeletonConfig config);
  Widget createPageHeader(SkeletonConfig config);
}

/// Profile-specific skeleton interface following ISP
/// Single Responsibility: Profile page skeletons only
abstract class IProfileSkeletonService {
  Widget createProfileSkeleton(SkeletonConfig config);
  Widget createCoverImage(SkeletonConfig config);
  Widget createProfileInfo(SkeletonConfig config);
  Widget createBioSection(SkeletonConfig config);
  Widget createStatsRow(SkeletonConfig config);
  Widget createTabBar(SkeletonConfig config);
  Widget createTabContent(SkeletonConfig config);
}

/// List-specific skeleton interface following ISP
/// Single Responsibility: List page skeletons only
abstract class IListSkeletonService {
  Widget createListSkeleton(SkeletonConfig config);
  Widget createSearchBar(SkeletonConfig config);
  Widget createFilters(SkeletonConfig config);
  Widget createListItems(SkeletonConfig config);
  Widget createAppBarActions(SkeletonConfig config);
  Widget createFloatingActionButton(SkeletonConfig config);
}

/// Detail-specific skeleton interface following ISP
/// Single Responsibility: Detail page skeletons only
abstract class IDetailSkeletonService {
  Widget createDetailSkeleton(SkeletonConfig config);
  Widget createHeaderImage(SkeletonConfig config);
  Widget createTitleSection(SkeletonConfig config);
  Widget createMetadataRow(SkeletonConfig config);
  Widget createDescriptionSection(SkeletonConfig config);
  Widget createRelatedItems(SkeletonConfig config);
  Widget createActionButtons(SkeletonConfig config);
}

/// Settings-specific skeleton interface following ISP
/// Single Responsibility: Settings page skeletons only
abstract class ISettingsSkeletonService {
  Widget createSettingsSkeleton(SkeletonConfig config);
  Widget createProfileSection(SkeletonConfig config);
  Widget createSettingsSection(SkeletonConfig config, int sectionIndex);
  Widget createSettingsItem(SkeletonConfig config, int itemIndex);
  Widget createSectionHeader(SkeletonConfig config);
}

/// Navigation-specific skeleton interface following ISP
/// Single Responsibility: Navigation skeletons only
abstract class INavigationSkeletonService {
  Widget createNavigationDrawer(SkeletonConfig config);
  Widget createDrawerHeader(SkeletonConfig config);
  Widget createMenuItems(SkeletonConfig config);
  Widget createMenuItem(SkeletonConfig config, int index);
  Widget createDrawerFooter(SkeletonConfig config);
}

/// Modal-specific skeleton interface following ISP
/// Single Responsibility: Modal skeletons only
abstract class IModalSkeletonService {
  Widget createBottomSheet(SkeletonConfig config);
  Widget createModalHandle(SkeletonConfig config);
  Widget createModalTitle(SkeletonConfig config);
  Widget createModalItems(SkeletonConfig config);
  Widget createModalItem(SkeletonConfig config, int index);
}

/// Animation strategy interface following Strategy pattern
/// Single Responsibility: Animation behavior only
abstract class ISkeletonAnimationStrategy {
  String get strategyId;
  Duration get defaultDuration;
  Widget applyAnimation(Widget skeleton, SkeletonConfig config);
  bool supportsSkeletonType(String skeletonType);
}

/// Builder interface for complex skeleton construction following Builder pattern
/// Single Responsibility: Complex skeleton building only
abstract class ISkeletonBuilder {
  ISkeletonBuilder setWidth(double? width);
  ISkeletonBuilder setHeight(double? height);
  ISkeletonBuilder setOptions(Map<String, dynamic> options);
  ISkeletonBuilder setAnimationStrategy(ISkeletonAnimationStrategy strategy);
  ISkeletonBuilder addSection(Widget section);
  ISkeletonBuilder addSpacer(double space);
  Widget build();
}

/// Service locator interface for skeleton services following DIP
/// Single Responsibility: Service resolution only
abstract class ISkeletonServiceLocator {
  T? getService<T>();
  void registerService<T>(T service);
  void registerFactory<T>(T Function() factory);
  bool hasService<T>();
  List<Type> get registeredServices;
}

/// Registry interface for skeleton type discovery following Registry pattern
/// Single Responsibility: Type registration and discovery only
abstract class ISkeletonTypeRegistry {
  void registerSkeletonType(String type, String serviceKey);
  String? getServiceKeyForType(String type);
  List<String> getSupportedTypes();
  bool isTypeSupported(String type);
  void unregisterSkeletonType(String type);
}

/// Factory interface for creating skeleton services following Abstract Factory pattern
/// Single Responsibility: Service creation only
abstract class ISkeletonServiceFactory {
  IDashboardSkeletonService createDashboardService();
  IProfileSkeletonService createProfileService();
  IListSkeletonService createListService();
  IDetailSkeletonService createDetailService();
  ISettingsSkeletonService createSettingsService();
  INavigationSkeletonService createNavigationService();
  IModalSkeletonService createModalService();
  ISkeletonAnimationStrategy createAnimationStrategy(String strategyId);
  ISkeletonBuilder createBuilder();
}

/// Enhanced skeleton configuration with builder support
class EnhancedSkeletonConfig extends SkeletonConfig {
  final ISkeletonAnimationStrategy? animationStrategy;
  final List<Widget> sections;
  final Map<String, dynamic> metadata;

  const EnhancedSkeletonConfig({
    super.width,
    super.height,
    super.options = const {},
    super.animationDuration,
    super.animationController,
    this.animationStrategy,
    this.sections = const [],
    this.metadata = const {},
  });

  @override
  EnhancedSkeletonConfig copyWith({
    double? width,
    double? height,
    Map<String, dynamic>? options,
    Duration? animationDuration,
    AnimationController? animationController,
    ISkeletonAnimationStrategy? animationStrategy,
    List<Widget>? sections,
    Map<String, dynamic>? metadata,
  }) {
    return EnhancedSkeletonConfig(
      width: width ?? this.width,
      height: height ?? this.height,
      options: options ?? this.options,
      animationDuration: animationDuration ?? this.animationDuration,
      animationController: animationController ?? this.animationController,
      animationStrategy: animationStrategy ?? this.animationStrategy,
      sections: sections ?? this.sections,
      metadata: metadata ?? this.metadata,
    );
  }

  EnhancedSkeletonConfig addSection(Widget section) {
    return copyWith(sections: [...sections, section]);
  }

  EnhancedSkeletonConfig setMetadata(String key, dynamic value) {
    return copyWith(metadata: {...metadata, key: value});
  }
}