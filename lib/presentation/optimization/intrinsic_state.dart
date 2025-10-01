import 'package:flutter/material.dart';

/// Represents the intrinsic state of a UI component (shared across instances)
///
/// This state is immutable and can be safely shared between multiple
/// widget instances to optimize memory usage through the Flyweight pattern.
@immutable
class IntrinsicState {
  /// Text style shared across components
  final TextStyle? style;

  /// Icon data for components with icons
  final IconData? iconData;

  /// Box decoration for styling
  final BoxDecoration? decoration;

  /// Semantic label for accessibility
  final String? semanticLabel;

  /// Widget size constraints
  final BoxConstraints? constraints;

  /// Padding configuration
  final EdgeInsets? padding;

  /// Margin configuration
  final EdgeInsets? margin;

  /// Border configuration
  final Border? border;

  /// Shadow configuration
  final List<BoxShadow>? shadows;

  /// Gradient configuration
  final Gradient? gradient;

  /// Animation curve for transitions
  final Curve? animationCurve;

  /// Default animation duration
  final Duration? animationDuration;

  const IntrinsicState({
    this.style,
    this.iconData,
    this.decoration,
    this.semanticLabel,
    this.constraints,
    this.padding,
    this.margin,
    this.border,
    this.shadows,
    this.gradient,
    this.animationCurve,
    this.animationDuration,
  });

  /// Creates a copy with modified properties
  IntrinsicState copyWith({
    TextStyle? style,
    IconData? iconData,
    BoxDecoration? decoration,
    String? semanticLabel,
    BoxConstraints? constraints,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Border? border,
    List<BoxShadow>? shadows,
    Gradient? gradient,
    Curve? animationCurve,
    Duration? animationDuration,
  }) {
    return IntrinsicState(
      style: style ?? this.style,
      iconData: iconData ?? this.iconData,
      decoration: decoration ?? this.decoration,
      semanticLabel: semanticLabel ?? this.semanticLabel,
      constraints: constraints ?? this.constraints,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      border: border ?? this.border,
      shadows: shadows ?? this.shadows,
      gradient: gradient ?? this.gradient,
      animationCurve: animationCurve ?? this.animationCurve,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }

  /// Calculates a hash code for efficient caching
  @override
  int get hashCode {
    return Object.hash(
      style?.hashCode,
      iconData?.hashCode,
      decoration?.hashCode,
      semanticLabel?.hashCode,
      constraints?.hashCode,
      padding?.hashCode,
      margin?.hashCode,
      border?.hashCode,
      shadows?.hashCode,
      gradient?.hashCode,
      animationCurve?.hashCode,
      animationDuration?.hashCode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is IntrinsicState &&
        other.style == style &&
        other.iconData == iconData &&
        other.decoration == decoration &&
        other.semanticLabel == semanticLabel &&
        other.constraints == constraints &&
        other.padding == padding &&
        other.margin == margin &&
        other.border == border &&
        _listEquals(other.shadows, shadows) &&
        other.gradient == gradient &&
        other.animationCurve == animationCurve &&
        other.animationDuration == animationDuration;
  }

  /// Helper method to compare lists
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;

    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'IntrinsicState('
           'style: $style, '
           'icon: $iconData, '
           'decoration: $decoration'
           ')';
  }

  /// Estimates memory usage of this state
  int get memoryUsage {
    int size = 0;

    // Base object overhead
    size += 64;

    // Style overhead
    if (style != null) size += 128;

    // Icon data overhead
    if (iconData != null) size += 32;

    // Decoration overhead
    if (decoration != null) size += 96;

    // String overhead
    if (semanticLabel != null) size += semanticLabel!.length * 2;

    // Other properties
    size += 32 * 8; // Remaining properties average

    return size;
  }
}

/// Specialized intrinsic state for button components
@immutable
class ButtonIntrinsicState extends IntrinsicState {
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final double borderRadius;
  final BorderSide? borderSide;

  const ButtonIntrinsicState({
    super.style,
    super.iconData,
    super.constraints,
    super.padding,
    super.margin,
    super.shadows,
    super.animationCurve,
    super.animationDuration,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.borderRadius = 0.0,
    this.borderSide,
  });

  @override
  ButtonIntrinsicState copyWith({
    TextStyle? style,
    IconData? iconData,
    BoxConstraints? constraints,
    EdgeInsets? padding,
    EdgeInsets? margin,
    List<BoxShadow>? shadows,
    Curve? animationCurve,
    Duration? animationDuration,
    Color? backgroundColor,
    Color? foregroundColor,
    double? elevation,
    double? borderRadius,
    BorderSide? borderSide,
  }) {
    return ButtonIntrinsicState(
      style: style ?? this.style,
      iconData: iconData ?? this.iconData,
      constraints: constraints ?? this.constraints,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      shadows: shadows ?? this.shadows,
      animationCurve: animationCurve ?? this.animationCurve,
      animationDuration: animationDuration ?? this.animationDuration,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      elevation: elevation ?? this.elevation,
      borderRadius: borderRadius ?? this.borderRadius,
      borderSide: borderSide ?? this.borderSide,
    );
  }

  @override
  int get hashCode {
    return Object.hash(
      super.hashCode,
      backgroundColor,
      foregroundColor,
      elevation,
      borderRadius,
      borderSide,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ButtonIntrinsicState &&
            super == other &&
            other.backgroundColor == backgroundColor &&
            other.foregroundColor == foregroundColor &&
            other.elevation == elevation &&
            other.borderRadius == borderRadius &&
            other.borderSide == borderSide;
  }
}

/// Specialized intrinsic state for card components
@immutable
class CardIntrinsicState extends IntrinsicState {
  final double elevation;
  final Color? shadowColor;
  final Color? backgroundColor;
  final ShapeBorder? shape;
  final bool borderOnForeground;
  final Clip clipBehavior;

  const CardIntrinsicState({
    super.constraints,
    super.padding,
    super.margin,
    super.semanticLabel,
    super.animationCurve,
    super.animationDuration,
    this.elevation = 1.0,
    this.shadowColor,
    this.backgroundColor,
    this.shape,
    this.borderOnForeground = true,
    this.clipBehavior = Clip.none,
    double borderRadius = 4.0,
  }) : super(
    decoration: shape == null ? BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
    ) : null,
  );

  @override
  CardIntrinsicState copyWith({
    BoxConstraints? constraints,
    EdgeInsets? padding,
    EdgeInsets? margin,
    String? semanticLabel,
    Curve? animationCurve,
    Duration? animationDuration,
    double? elevation,
    Color? shadowColor,
    Color? backgroundColor,
    ShapeBorder? shape,
    bool? borderOnForeground,
    Clip? clipBehavior,
  }) {
    return CardIntrinsicState(
      constraints: constraints ?? this.constraints,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      semanticLabel: semanticLabel ?? this.semanticLabel,
      animationCurve: animationCurve ?? this.animationCurve,
      animationDuration: animationDuration ?? this.animationDuration,
      elevation: elevation ?? this.elevation,
      shadowColor: shadowColor ?? this.shadowColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      shape: shape ?? this.shape,
      borderOnForeground: borderOnForeground ?? this.borderOnForeground,
      clipBehavior: clipBehavior ?? this.clipBehavior,
    );
  }

  @override
  int get hashCode {
    return Object.hash(
      super.hashCode,
      elevation,
      shadowColor,
      backgroundColor,
      shape,
      borderOnForeground,
      clipBehavior,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CardIntrinsicState &&
            super == other &&
            other.elevation == elevation &&
            other.shadowColor == shadowColor &&
            other.backgroundColor == backgroundColor &&
            other.shape == shape &&
            other.borderOnForeground == borderOnForeground &&
            other.clipBehavior == clipBehavior;
  }
}

/// Specialized intrinsic state for animated components
@immutable
class AnimatedIntrinsicState extends IntrinsicState {
  final TextStyle baseStyle;
  final Duration animationDuration;
  final AnimationType animationType;
  final Curve curve;

  const AnimatedIntrinsicState({
    required this.baseStyle,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationType = AnimationType.fadeIn,
    this.curve = Curves.easeInOut,
  }) : super(
    style: baseStyle,
    animationCurve: curve,
    animationDuration: animationDuration,
  );

  @override
  AnimatedIntrinsicState copyWith({
    TextStyle? baseStyle,
    Duration? animationDuration,
    AnimationType? animationType,
    Curve? curve,
  }) {
    return AnimatedIntrinsicState(
      baseStyle: baseStyle ?? this.baseStyle,
      animationDuration: animationDuration ?? this.animationDuration,
      animationType: animationType ?? this.animationType,
      curve: curve ?? this.curve,
    );
  }

  @override
  int get hashCode {
    return Object.hash(
      super.hashCode,
      baseStyle,
      animationDuration,
      animationType,
      curve,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AnimatedIntrinsicState &&
            super == other &&
            other.baseStyle == baseStyle &&
            other.animationDuration == animationDuration &&
            other.animationType == animationType &&
            other.curve == curve;
  }
}

/// Animation types supported by the flyweight system
enum AnimationType {
  fadeIn,
  fadeOut,
  fadeInScale,
  slideInFromLeft,
  slideInFromRight,
  slideInFromTop,
  slideInFromBottom,
  scaleIn,
  scaleOut,
  rotateIn,
  bounceIn,
}

/// Factory for creating common intrinsic states
class IntrinsicStateFactory {
  static const Map<String, IntrinsicState> _precomputedStates = {
    'list_item_primary': IntrinsicState(
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    'list_item_secondary': IntrinsicState(
      style: TextStyle(fontSize: 14, color: Colors.grey),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    'card_default': IntrinsicState(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(8),
    ),
  };

  /// Gets a precomputed intrinsic state for common UI patterns
  static IntrinsicState? getPrecomputed(String key) {
    return _precomputedStates[key];
  }

  /// Creates a list item intrinsic state
  static IntrinsicState createListItemState({
    double fontSize = 16,
    Color? textColor,
    IconData? icon,
    EdgeInsets? padding,
  }) {
    return IntrinsicState(
      style: TextStyle(fontSize: fontSize, color: textColor),
      iconData: icon,
      padding: padding ?? EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  /// Creates a button intrinsic state
  static ButtonIntrinsicState createButtonState({
    Color? backgroundColor,
    Color? foregroundColor,
    double elevation = 2.0,
    double borderRadius = 8.0,
  }) {
    return ButtonIntrinsicState(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      borderRadius: borderRadius,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  /// Creates a card intrinsic state
  static CardIntrinsicState createCardState({
    double elevation = 2.0,
    Color? backgroundColor,
    double borderRadius = 8.0,
  }) {
    return CardIntrinsicState(
      elevation: elevation,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(8),
    );
  }
}