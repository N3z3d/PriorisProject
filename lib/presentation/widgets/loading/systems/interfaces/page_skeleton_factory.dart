import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';

/// Interface for page skeleton factories
/// Defines contract for creating specific page types
abstract class IPageSkeletonFactory {
  /// The page types this factory can handle
  List<String> get supportedPageTypes;

  /// Create a skeleton for a specific page type
  Widget createPageSkeleton(String pageType, SkeletonConfig config);

  /// Check if this factory can handle the given page type
  bool canHandlePageType(String pageType);
}

/// Base configuration for page skeletons
class PageSkeletonConfig {
  final double? width;
  final double? height;
  final Map<String, dynamic> options;
  final Duration? animationDuration;

  const PageSkeletonConfig({
    this.width,
    this.height,
    this.options = const {},
    this.animationDuration,
  });
}