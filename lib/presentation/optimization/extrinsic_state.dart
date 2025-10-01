import 'package:flutter/material.dart';

/// Represents the extrinsic state of a UI component (unique per instance)
///
/// This state varies between widget instances and contains the specific
/// data and behavior for each individual component.
@immutable
class ExtrinsicState {
  /// The text content to display
  final String text;

  /// Position for layout calculations
  final Offset position;

  /// Whether this component is selected
  final bool isSelected;

  /// Whether this component is enabled/disabled
  final bool isEnabled;

  /// Custom semantic label for accessibility
  final String? semanticLabel;

  /// Custom semantic hint for accessibility
  final String? semanticHint;

  /// Callback for tap events
  final VoidCallback? onTap;

  /// Callback for long press events
  final VoidCallback? onLongPress;

  /// Animation progress (0.0 to 1.0)
  final double animationProgress;

  /// Custom data associated with this instance
  final Map<String, dynamic>? customData;

  /// Z-index for layering
  final int zIndex;

  /// Opacity for transparency effects
  final double opacity;

  /// Scale factor for size adjustments
  final double scale;

  /// Rotation angle in radians
  final double rotation;

  const ExtrinsicState({
    required this.text,
    this.position = Offset.zero,
    this.isSelected = false,
    this.isEnabled = true,
    this.semanticLabel,
    this.semanticHint,
    this.onTap,
    this.onLongPress,
    this.animationProgress = 1.0,
    this.customData,
    this.zIndex = 0,
    this.opacity = 1.0,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  /// Creates a copy with modified properties
  ExtrinsicState copyWith({
    String? text,
    Offset? position,
    bool? isSelected,
    bool? isEnabled,
    String? semanticLabel,
    String? semanticHint,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    double? animationProgress,
    Map<String, dynamic>? customData,
    int? zIndex,
    double? opacity,
    double? scale,
    double? rotation,
  }) {
    return ExtrinsicState(
      text: text ?? this.text,
      position: position ?? this.position,
      isSelected: isSelected ?? this.isSelected,
      isEnabled: isEnabled ?? this.isEnabled,
      semanticLabel: semanticLabel ?? this.semanticLabel,
      semanticHint: semanticHint ?? this.semanticHint,
      onTap: onTap ?? this.onTap,
      onLongPress: onLongPress ?? this.onLongPress,
      animationProgress: animationProgress ?? this.animationProgress,
      customData: customData ?? this.customData,
      zIndex: zIndex ?? this.zIndex,
      opacity: opacity ?? this.opacity,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
    );
  }

  /// Gets a custom data value
  T? getCustomData<T>(String key) {
    return customData?[key] as T?;
  }

  /// Checks if component should be interactive
  bool get isInteractive => isEnabled && (onTap != null || onLongPress != null);

  /// Gets transformation matrix for positioning and effects
  Matrix4 get transformMatrix {
    final matrix = Matrix4.identity();

    // Apply translation
    if (position != Offset.zero) {
      matrix.translate(position.dx, position.dy);
    }

    // Apply scale
    if (scale != 1.0) {
      matrix.scale(scale);
    }

    // Apply rotation
    if (rotation != 0.0) {
      matrix.rotateZ(rotation);
    }

    return matrix;
  }

  @override
  String toString() {
    return 'ExtrinsicState('
           'text: "$text", '
           'position: $position, '
           'selected: $isSelected, '
           'enabled: $isEnabled'
           ')';
  }

  @override
  int get hashCode {
    return Object.hash(
      text,
      position,
      isSelected,
      isEnabled,
      semanticLabel,
      semanticHint,
      animationProgress,
      zIndex,
      opacity,
      scale,
      rotation,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExtrinsicState &&
        other.text == text &&
        other.position == position &&
        other.isSelected == isSelected &&
        other.isEnabled == isEnabled &&
        other.semanticLabel == semanticLabel &&
        other.semanticHint == semanticHint &&
        other.animationProgress == animationProgress &&
        other.zIndex == zIndex &&
        other.opacity == opacity &&
        other.scale == scale &&
        other.rotation == rotation &&
        _mapEquals(other.customData, customData);
  }

  bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;

    for (final key in a.keys) {
      if (!b.containsKey(key) || b[key] != a[key]) return false;
    }
    return true;
  }
}

/// Specialized extrinsic state for button components
@immutable
class ButtonExtrinsicState extends ExtrinsicState {
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final bool isLoading;

  const ButtonExtrinsicState({
    required super.text,
    super.position,
    super.isSelected,
    super.isEnabled,
    super.semanticLabel,
    super.semanticHint,
    super.animationProgress,
    super.customData,
    super.zIndex,
    super.opacity,
    super.scale,
    super.rotation,
    this.onPressed,
    this.width = double.infinity,
    this.height = 44.0,
    this.isLoading = false,
  });

  @override
  ButtonExtrinsicState copyWith({
    String? text,
    Offset? position,
    bool? isSelected,
    bool? isEnabled,
    String? semanticLabel,
    String? semanticHint,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    double? animationProgress,
    Map<String, dynamic>? customData,
    int? zIndex,
    double? opacity,
    double? scale,
    double? rotation,
    VoidCallback? onPressed,
    double? width,
    double? height,
    bool? isLoading,
  }) {
    return ButtonExtrinsicState(
      text: text ?? this.text,
      position: position ?? this.position,
      isSelected: isSelected ?? this.isSelected,
      isEnabled: isEnabled ?? this.isEnabled,
      semanticLabel: semanticLabel ?? this.semanticLabel,
      semanticHint: semanticHint ?? this.semanticHint,
      animationProgress: animationProgress ?? this.animationProgress,
      customData: customData ?? this.customData,
      zIndex: zIndex ?? this.zIndex,
      opacity: opacity ?? this.opacity,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      onPressed: onPressed ?? this.onPressed,
      width: width ?? this.width,
      height: height ?? this.height,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  int get hashCode {
    return Object.hash(
      super.hashCode,
      width,
      height,
      isLoading,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ButtonExtrinsicState &&
            super == other &&
            other.width == width &&
            other.height == height &&
            other.isLoading == isLoading;
  }
}

/// Specialized extrinsic state for list item components
@immutable
class ListItemExtrinsicState extends ExtrinsicState {
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final bool isDense;
  final int index;

  const ListItemExtrinsicState({
    required super.text,
    super.position,
    super.isSelected,
    super.isEnabled,
    super.semanticLabel,
    super.semanticHint,
    super.onTap,
    super.onLongPress,
    super.animationProgress,
    super.customData,
    super.zIndex,
    super.opacity,
    super.scale,
    super.rotation,
    this.subtitle,
    this.trailing,
    this.leading,
    this.isDense = false,
    required this.index,
  });

  @override
  ListItemExtrinsicState copyWith({
    String? text,
    Offset? position,
    bool? isSelected,
    bool? isEnabled,
    String? semanticLabel,
    String? semanticHint,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    double? animationProgress,
    Map<String, dynamic>? customData,
    int? zIndex,
    double? opacity,
    double? scale,
    double? rotation,
    String? subtitle,
    Widget? trailing,
    Widget? leading,
    bool? isDense,
    int? index,
  }) {
    return ListItemExtrinsicState(
      text: text ?? this.text,
      position: position ?? this.position,
      isSelected: isSelected ?? this.isSelected,
      isEnabled: isEnabled ?? this.isEnabled,
      semanticLabel: semanticLabel ?? this.semanticLabel,
      semanticHint: semanticHint ?? this.semanticHint,
      onTap: onTap ?? this.onTap,
      onLongPress: onLongPress ?? this.onLongPress,
      animationProgress: animationProgress ?? this.animationProgress,
      customData: customData ?? this.customData,
      zIndex: zIndex ?? this.zIndex,
      opacity: opacity ?? this.opacity,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      subtitle: subtitle ?? this.subtitle,
      trailing: trailing ?? this.trailing,
      leading: leading ?? this.leading,
      isDense: isDense ?? this.isDense,
      index: index ?? this.index,
    );
  }

  @override
  int get hashCode {
    return Object.hash(
      super.hashCode,
      subtitle,
      trailing?.runtimeType,
      leading?.runtimeType,
      isDense,
      index,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ListItemExtrinsicState &&
            super == other &&
            other.subtitle == subtitle &&
            other.trailing?.runtimeType == trailing?.runtimeType &&
            other.leading?.runtimeType == leading?.runtimeType &&
            other.isDense == isDense &&
            other.index == index;
  }
}

/// Specialized extrinsic state for animated components
@immutable
class AnimatedExtrinsicState extends ExtrinsicState {
  final bool isVisible;
  final AnimationController? animationController;
  final Animation<double>? customAnimation;

  const AnimatedExtrinsicState({
    required super.text,
    super.position,
    super.isSelected,
    super.isEnabled,
    super.semanticLabel,
    super.semanticHint,
    super.onTap,
    super.onLongPress,
    super.animationProgress,
    super.customData,
    super.zIndex,
    super.opacity,
    super.scale,
    super.rotation,
    required this.isVisible,
    this.animationController,
    this.customAnimation,
  });

  @override
  AnimatedExtrinsicState copyWith({
    String? text,
    Offset? position,
    bool? isSelected,
    bool? isEnabled,
    String? semanticLabel,
    String? semanticHint,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    double? animationProgress,
    Map<String, dynamic>? customData,
    int? zIndex,
    double? opacity,
    double? scale,
    double? rotation,
    bool? isVisible,
    AnimationController? animationController,
    Animation<double>? customAnimation,
  }) {
    return AnimatedExtrinsicState(
      text: text ?? this.text,
      position: position ?? this.position,
      isSelected: isSelected ?? this.isSelected,
      isEnabled: isEnabled ?? this.isEnabled,
      semanticLabel: semanticLabel ?? this.semanticLabel,
      semanticHint: semanticHint ?? this.semanticHint,
      onTap: onTap ?? this.onTap,
      onLongPress: onLongPress ?? this.onLongPress,
      animationProgress: animationProgress ?? this.animationProgress,
      customData: customData ?? this.customData,
      zIndex: zIndex ?? this.zIndex,
      opacity: opacity ?? this.opacity,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      isVisible: isVisible ?? this.isVisible,
      animationController: animationController ?? this.animationController,
      customAnimation: customAnimation ?? this.customAnimation,
    );
  }

  @override
  int get hashCode {
    return Object.hash(
      super.hashCode,
      isVisible,
      animationController?.hashCode,
      customAnimation?.hashCode,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AnimatedExtrinsicState &&
            super == other &&
            other.isVisible == isVisible &&
            other.animationController == animationController &&
            other.customAnimation == customAnimation;
  }
}

/// Factory for creating common extrinsic states
class ExtrinsicStateFactory {
  /// Creates a basic extrinsic state for text display
  static ExtrinsicState createTextState({
    required String text,
    bool isSelected = false,
    bool isEnabled = true,
    VoidCallback? onTap,
  }) {
    return ExtrinsicState(
      text: text,
      isSelected: isSelected,
      isEnabled: isEnabled,
      onTap: onTap,
    );
  }

  /// Creates a button extrinsic state
  static ButtonExtrinsicState createButtonState({
    required String text,
    VoidCallback? onPressed,
    double? width,
    double? height,
    bool isLoading = false,
  }) {
    return ButtonExtrinsicState(
      text: text,
      onPressed: onPressed,
      width: width ?? double.infinity,
      height: height ?? 44.0,
      isLoading: isLoading,
    );
  }

  /// Creates a list item extrinsic state
  static ListItemExtrinsicState createListItemState({
    required String text,
    required int index,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return ListItemExtrinsicState(
      text: text,
      index: index,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
      isSelected: isSelected,
      onTap: onTap,
    );
  }

  /// Creates an animated extrinsic state
  static AnimatedExtrinsicState createAnimatedState({
    required String text,
    required bool isVisible,
    AnimationController? controller,
    double animationProgress = 1.0,
  }) {
    return AnimatedExtrinsicState(
      text: text,
      isVisible: isVisible,
      animationController: controller,
      animationProgress: animationProgress,
    );
  }

  /// Creates extrinsic state with positioning
  static ExtrinsicState createPositionedState({
    required String text,
    required Offset position,
    double scale = 1.0,
    double rotation = 0.0,
    double opacity = 1.0,
  }) {
    return ExtrinsicState(
      text: text,
      position: position,
      scale: scale,
      rotation: rotation,
      opacity: opacity,
    );
  }
}