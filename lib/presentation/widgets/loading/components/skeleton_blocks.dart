import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_component_library.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';

/// Facade providing simplified access to skeleton components
/// Maps legacy API to current SkeletonComponentLibrary implementation
///
/// ARCHITECTURE NOTE: This class exists to maintain API compatibility
/// with existing skeleton system files. It delegates to the current
/// SkeletonComponentLibrary and SkeletonShapeFactory implementations.
class SkeletonBlocks {
  SkeletonBlocks._();

  /// Creates a header with configurable width factor
  static Widget header({double widthFactor = 0.6}) {
    final width = widthFactor * 200; // Base width
    return SkeletonShapeFactory.text(width: width, height: 24);
  }

  /// Creates a subtitle with configurable width factor
  static Widget subtitle({double widthFactor = 0.4}) {
    final width = widthFactor * 200; // Base width
    return SkeletonShapeFactory.text(width: width, height: 16);
  }

  /// Creates a paragraph with multiple text lines
  static Widget paragraph({int lines = 3}) {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: List.generate(lines, (index) {
        final width = index == lines - 1 ? 150.0 : double.infinity;
        return SkeletonShapeFactory.text(width: width, height: 16);
      }),
    );
  }

  /// Creates a stepper indicator
  static Widget stepper({int stepCount = 3, int currentStep = 1}) {
    return SizedBox(
      height: 40,
      child: SkeletonLayoutBuilder.horizontal(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: List.generate(stepCount, (index) {
          return SkeletonShapeFactory.circular(size: 32);
        }),
      ),
    );
  }

  /// Creates a list tile skeleton
  static Widget listTile() {
    return SkeletonComponentLibrary.createListItemContent();
  }

  /// Creates a basic tile skeleton
  static Widget tile() {
    return SkeletonShapeFactory.rectangular(
      width: double.infinity,
      height: 100,
    );
  }

  /// Creates a stat card skeleton
  static Widget statCard() {
    return SkeletonLayoutBuilder.vertical(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children: [
        SkeletonShapeFactory.text(width: 60, height: 24),
        SkeletonShapeFactory.text(width: 80, height: 16),
        SkeletonShapeFactory.circular(size: 20),
      ],
    );
  }

  /// Creates a product card skeleton
  static Widget productCard() {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        SkeletonShapeFactory.rectangular(
          width: double.infinity,
          height: 120,
        ),
        SkeletonShapeFactory.text(width: double.infinity, height: 16),
        SkeletonShapeFactory.text(width: 100, height: 14),
        SkeletonLayoutBuilder.horizontal(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SkeletonShapeFactory.text(width: 60, height: 20),
            SkeletonShapeFactory.circular(size: 24),
          ],
        ),
      ],
    );
  }

  /// Creates a search bar skeleton
  static Widget searchBar({bool showFilter = true}) {
    return SkeletonComponentLibrary.createSearchBar(showFilter: showFilter);
  }
}
