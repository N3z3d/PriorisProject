/// SOLID Implementation: Skeleton Layout Strategies
///
/// Strategy Pattern implementation for different skeleton layouts.
/// RESPONSIBILITY: Apply different layout strategies to skeleton components.
/// CONSTRAINT: <300 lines total for all strategies.

import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interfaces.dart';

/// Column layout strategy
/// SOLID COMPLIANCE: SRP - Single responsibility for column layouts
class ColumnLayoutStrategy implements ISkeletonLayoutStrategy {
  @override
  String get strategyName => 'column';

  @override
  bool canHandleLayout(String layoutType) {
    return ['column', 'vertical', 'list', 'page'].contains(layoutType.toLowerCase());
  }

  @override
  Widget applyLayout({
    required List<Widget> components,
    required String layoutType,
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    final spacing = options?['spacing']?.toDouble() ?? 16.0;
    final alignment = _parseAlignment(options?['alignment']) ?? CrossAxisAlignment.start;
    final padding = options?['padding'] as EdgeInsets? ?? EdgeInsets.zero;

    return Container(
      width: width,
      height: height,
      padding: padding,
      child: Column(
        crossAxisAlignment: alignment,
        children: _addSpacing(components, spacing),
      ),
    );
  }

  List<Widget> _addSpacing(List<Widget> components, double spacing) {
    final spacedComponents = <Widget>[];
    for (int i = 0; i < components.length; i++) {
      spacedComponents.add(components[i]);
      if (i < components.length - 1) {
        spacedComponents.add(SizedBox(height: spacing));
      }
    }
    return spacedComponents;
  }

  CrossAxisAlignment? _parseAlignment(dynamic alignment) {
    if (alignment == null) return null;
    switch (alignment.toString()) {
      case 'start': return CrossAxisAlignment.start;
      case 'center': return CrossAxisAlignment.center;
      case 'end': return CrossAxisAlignment.end;
      case 'stretch': return CrossAxisAlignment.stretch;
      default: return CrossAxisAlignment.start;
    }
  }
}

/// Row layout strategy
/// SOLID COMPLIANCE: SRP - Single responsibility for row layouts
class RowLayoutStrategy implements ISkeletonLayoutStrategy {
  @override
  String get strategyName => 'row';

  @override
  bool canHandleLayout(String layoutType) {
    return ['row', 'horizontal', 'header', 'toolbar'].contains(layoutType.toLowerCase());
  }

  @override
  Widget applyLayout({
    required List<Widget> components,
    required String layoutType,
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    final spacing = options?['spacing']?.toDouble() ?? 16.0;
    final alignment = _parseAlignment(options?['alignment']) ?? CrossAxisAlignment.center;
    final padding = options?['padding'] as EdgeInsets? ?? EdgeInsets.zero;

    return Container(
      width: width,
      height: height,
      padding: padding,
      child: Row(
        crossAxisAlignment: alignment,
        children: _addSpacing(components, spacing),
      ),
    );
  }

  List<Widget> _addSpacing(List<Widget> components, double spacing) {
    final spacedComponents = <Widget>[];
    for (int i = 0; i < components.length; i++) {
      spacedComponents.add(components[i]);
      if (i < components.length - 1) {
        spacedComponents.add(SizedBox(width: spacing));
      }
    }
    return spacedComponents;
  }

  CrossAxisAlignment? _parseAlignment(dynamic alignment) {
    if (alignment == null) return null;
    switch (alignment.toString()) {
      case 'start': return CrossAxisAlignment.start;
      case 'center': return CrossAxisAlignment.center;
      case 'end': return CrossAxisAlignment.end;
      case 'stretch': return CrossAxisAlignment.stretch;
      default: return CrossAxisAlignment.center;
    }
  }
}

/// Grid layout strategy
/// SOLID COMPLIANCE: SRP - Single responsibility for grid layouts
class GridLayoutStrategy implements ISkeletonLayoutStrategy {
  @override
  String get strategyName => 'grid';

  @override
  bool canHandleLayout(String layoutType) {
    return ['grid', 'dashboard', 'cards'].contains(layoutType.toLowerCase());
  }

  @override
  Widget applyLayout({
    required List<Widget> components,
    required String layoutType,
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    final crossAxisCount = options?['crossAxisCount'] ?? 2;
    final spacing = options?['spacing']?.toDouble() ?? 16.0;
    final childAspectRatio = options?['childAspectRatio']?.toDouble() ?? 1.0;
    final padding = options?['padding'] as EdgeInsets? ?? EdgeInsets.zero;

    return Container(
      width: width,
      height: height,
      padding: padding,
      child: GridView.count(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: components,
      ),
    );
  }
}

/// Stack layout strategy
/// SOLID COMPLIANCE: SRP - Single responsibility for stack layouts
class StackLayoutStrategy implements ISkeletonLayoutStrategy {
  @override
  String get strategyName => 'stack';

  @override
  bool canHandleLayout(String layoutType) {
    return ['stack', 'overlay', 'floating'].contains(layoutType.toLowerCase());
  }

  @override
  Widget applyLayout({
    required List<Widget> components,
    required String layoutType,
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    final alignment = _parseStackAlignment(options?['alignment']) ?? AlignmentDirectional.topStart;
    final padding = options?['padding'] as EdgeInsets? ?? EdgeInsets.zero;

    return Container(
      width: width,
      height: height,
      padding: padding,
      child: Stack(
        alignment: alignment,
        children: components,
      ),
    );
  }

  AlignmentGeometry? _parseStackAlignment(dynamic alignment) {
    if (alignment == null) return null;
    switch (alignment.toString()) {
      case 'topStart': return AlignmentDirectional.topStart;
      case 'topCenter': return AlignmentDirectional.topCenter;
      case 'topEnd': return AlignmentDirectional.topEnd;
      case 'center': return AlignmentDirectional.center;
      case 'bottomStart': return AlignmentDirectional.bottomStart;
      case 'bottomCenter': return AlignmentDirectional.bottomCenter;
      case 'bottomEnd': return AlignmentDirectional.bottomEnd;
      default: return AlignmentDirectional.topStart;
    }
  }
}

/// Wrap layout strategy
/// SOLID COMPLIANCE: SRP - Single responsibility for wrap layouts
class WrapLayoutStrategy implements ISkeletonLayoutStrategy {
  @override
  String get strategyName => 'wrap';

  @override
  bool canHandleLayout(String layoutType) {
    return ['wrap', 'tags', 'chips', 'flexible'].contains(layoutType.toLowerCase());
  }

  @override
  Widget applyLayout({
    required List<Widget> components,
    required String layoutType,
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    final spacing = options?['spacing']?.toDouble() ?? 8.0;
    final runSpacing = options?['runSpacing']?.toDouble() ?? 8.0;
    final padding = options?['padding'] as EdgeInsets? ?? EdgeInsets.zero;

    return Container(
      width: width,
      height: height,
      padding: padding,
      child: Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        children: components,
      ),
    );
  }
}

/// Strategy registry for managing all layout strategies
/// SOLID COMPLIANCE: OCP - Open for extension, closed for modification
class SkeletonLayoutStrategyRegistry {
  final Map<String, ISkeletonLayoutStrategy> _strategies = {};

  SkeletonLayoutStrategyRegistry() {
    // Register all available strategies
    _registerDefaultStrategies();
  }

  void _registerDefaultStrategies() {
    registerStrategy(ColumnLayoutStrategy());
    registerStrategy(RowLayoutStrategy());
    registerStrategy(GridLayoutStrategy());
    registerStrategy(StackLayoutStrategy());
    registerStrategy(WrapLayoutStrategy());
  }

  /// Register a new layout strategy
  void registerStrategy(ISkeletonLayoutStrategy strategy) {
    _strategies[strategy.strategyName] = strategy;
  }

  /// Get strategy by name
  ISkeletonLayoutStrategy? getStrategy(String name) {
    return _strategies[name];
  }

  /// Get strategy that can handle layout type
  ISkeletonLayoutStrategy? getStrategyForLayout(String layoutType) {
    for (final strategy in _strategies.values) {
      if (strategy.canHandleLayout(layoutType)) {
        return strategy;
      }
    }
    return null;
  }

  /// Get all registered strategies
  List<ISkeletonLayoutStrategy> get allStrategies => _strategies.values.toList();

  /// Get all strategy names
  List<String> get strategyNames => _strategies.keys.toList();
}