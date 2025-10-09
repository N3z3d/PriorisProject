import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_component_library.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';
import 'package:prioris/presentation/widgets/loading/services/dashboard_skeleton_service.dart';
import 'package:prioris/presentation/widgets/loading/services/profile_skeleton_service.dart';
import 'package:prioris/presentation/widgets/loading/services/detail_skeleton_service.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';

/// Complex layout skeleton system delegating to specialized services.
class ComplexLayoutSkeletonSystem implements IVariantSkeletonSystem, IAnimatedSkeletonSystem {
  ComplexLayoutSkeletonSystem()
      : _dashboardService = DashboardSkeletonService(),
        _profileService = ProfileSkeletonService(),
        _detailService = DetailSkeletonService();

  final DashboardSkeletonService _dashboardService;
  final ProfileSkeletonService _profileService;
  final DetailSkeletonService _detailService;

  static const _supportedTypes = <String>{
    'page_layout',
    'dashboard_page',
    'profile_page',
    'detail_page',
  };

  static const _variants = <String>{
    'dashboard',
    'profile',
    'detail',
    'list',
  };

  @override
  String get systemId => 'complex_layout_skeleton_system';

  @override
  List<String> get supportedTypes => _supportedTypes.toList(growable: false);

  @override
  List<String> get availableVariants => _variants.toList(growable: false);

  @override
  bool canHandle(String skeletonType) => _supportedTypes.contains(skeletonType);

  SkeletonConfig _config({
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    return SkeletonConfig(
      width: width,
      height: height,
      options: options ?? const {},
    );
  }

  @override
  Widget createSkeleton({
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    return createVariant(
      'dashboard',
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
    final config = _config(width: width, height: height, options: options);

    switch (variant) {
      case 'profile':
        return _profileService.createProfileSkeleton(config);
      case 'detail':
        return _detailService.createDetailSkeleton(config);
      case 'dashboard':
        return _dashboardService.createDashboardSkeleton(config);
      case 'list':
      default:
        return _buildListPage(config);
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
    final child = createSkeleton(
      width: width,
      height: height,
      options: options,
    );
    final animationDuration = duration ?? defaultAnimationDuration;

    if (controller != null) {
      return AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return FadeTransition(
            opacity: controller,
            child: child,
          );
        },
      );
    }

    return AnimatedOpacity(
      opacity: 1,
      duration: animationDuration,
      curve: Curves.easeInOut,
      child: child,
    );
  }

  @override
  Duration get defaultAnimationDuration => const Duration(milliseconds: 400);

  Widget _buildListPage(SkeletonConfig config) {
    final itemCount = config.options['itemCount'] as int? ?? 6;

    return Scaffold(
      appBar: AppBar(
        title: SkeletonBlocks.header(widthFactor: 0.6),
        actions: [
          SkeletonShapeFactory.circular(size: 40),
          const SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonLayoutBuilder.horizontal(
              spacing: 12,
              children: [
                Expanded(child: SkeletonBlocks.searchBar()),
                SkeletonShapeFactory.badge(width: 64, height: 32),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: itemCount,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => SkeletonBlocks.listTile(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SkeletonShapeFactory.circular(size: 56),
    );
  }
}
