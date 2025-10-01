import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'intrinsic_state.dart';
import 'extrinsic_state.dart';

/// Abstract flyweight interface for UI components
abstract class UIFlyweight {
  /// The intrinsic state shared across all instances
  final IntrinsicState intrinsicState;

  const UIFlyweight(this.intrinsicState);

  /// Builds a widget using the provided extrinsic state
  Widget buildWidget(ExtrinsicState extrinsicState);

  /// Estimates the memory footprint of this flyweight
  int get memoryFootprint => intrinsicState.memoryUsage;

  /// Gets a unique identifier for caching
  String get cacheKey => intrinsicState.hashCode.toString();
}

/// Generic implementation of UIFlyweight for basic components
class GenericUIFlyweight extends UIFlyweight {
  const GenericUIFlyweight(super.intrinsicState);

  @override
  Widget buildWidget(ExtrinsicState extrinsicState) {
    return _buildOptimizedWidget(extrinsicState);
  }

  Widget _buildOptimizedWidget(ExtrinsicState extrinsicState) {
    Widget child = _buildContent(extrinsicState);

    // Apply transformations if needed
    if (extrinsicState.transformMatrix != Matrix4.identity()) {
      child = Transform(
        transform: extrinsicState.transformMatrix,
        child: child,
      );
    }

    // Apply opacity if needed
    if (extrinsicState.opacity < 1.0) {
      child = Opacity(
        opacity: extrinsicState.opacity,
        child: child,
      );
    }

    // Apply positioning if needed
    if (extrinsicState.position != Offset.zero) {
      child = Positioned(
        left: extrinsicState.position.dx,
        top: extrinsicState.position.dy,
        child: child,
      );
    }

    // Apply interaction handling
    if (extrinsicState.isInteractive) {
      child = _wrapWithGestureDetector(child, extrinsicState);
    }

    // Apply semantic information
    if (extrinsicState.semanticLabel != null) {
      child = Semantics(
        label: extrinsicState.semanticLabel,
        hint: extrinsicState.semanticHint,
        enabled: extrinsicState.isEnabled,
        selected: extrinsicState.isSelected,
        child: child,
      );
    }

    return child;
  }

  Widget _buildContent(ExtrinsicState extrinsicState) {
    return Container(
      decoration: intrinsicState.decoration,
      constraints: intrinsicState.constraints,
      padding: intrinsicState.padding,
      margin: intrinsicState.margin,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (intrinsicState.iconData != null)
            Icon(
              intrinsicState.iconData,
              color: intrinsicState.style?.color,
              size: intrinsicState.style?.fontSize,
            ),
          if (intrinsicState.iconData != null && extrinsicState.text.isNotEmpty)
            SizedBox(width: 8),
          if (extrinsicState.text.isNotEmpty)
            Flexible(
              child: Text(
                extrinsicState.text,
                style: intrinsicState.style,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _wrapWithGestureDetector(Widget child, ExtrinsicState extrinsicState) {
    return GestureDetector(
      onTap: extrinsicState.onTap,
      onLongPress: extrinsicState.onLongPress,
      child: child,
    );
  }
}

/// Specialized flyweight for button components
class ButtonFlyweight extends UIFlyweight {
  const ButtonFlyweight(ButtonIntrinsicState super.intrinsicState);

  ButtonIntrinsicState get buttonState => intrinsicState as ButtonIntrinsicState;

  @override
  Widget buildWidget(ExtrinsicState extrinsicState) {
    if (extrinsicState is ButtonExtrinsicState) {
      return _buildButton(extrinsicState);
    }

    // Fallback to generic implementation
    return GenericUIFlyweight(intrinsicState).buildWidget(extrinsicState);
  }

  Widget _buildButton(ButtonExtrinsicState extrinsicState) {
    return SizedBox(
      width: extrinsicState.width == double.infinity ? null : extrinsicState.width,
      height: extrinsicState.height,
      child: ElevatedButton(
        onPressed: extrinsicState.isEnabled && !extrinsicState.isLoading
            ? extrinsicState.onPressed
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonState.backgroundColor,
          foregroundColor: buttonState.foregroundColor,
          elevation: buttonState.elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonState.borderRadius),
            side: buttonState.borderSide ?? BorderSide.none,
          ),
          padding: intrinsicState.padding,
        ),
        child: extrinsicState.isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    buttonState.foregroundColor ?? Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (intrinsicState.iconData != null) ...[
                    Icon(intrinsicState.iconData, size: 18),
                    SizedBox(width: 8),
                  ],
                  Text(
                    extrinsicState.text,
                    style: intrinsicState.style,
                  ),
                ],
              ),
      ),
    );
  }
}

/// Specialized flyweight for card components
class CardFlyweight extends UIFlyweight {
  const CardFlyweight(CardIntrinsicState super.intrinsicState);

  CardIntrinsicState get cardState => intrinsicState as CardIntrinsicState;

  @override
  Widget buildWidget(ExtrinsicState extrinsicState) {
    return Card(
      elevation: cardState.elevation,
      color: cardState.backgroundColor,
      shadowColor: cardState.shadowColor,
      shape: cardState.shape,
      borderOnForeground: cardState.borderOnForeground,
      clipBehavior: cardState.clipBehavior,
      margin: intrinsicState.margin,
      child: Container(
        constraints: intrinsicState.constraints,
        padding: intrinsicState.padding,
        child: _buildCardContent(extrinsicState),
      ),
    );
  }

  Widget _buildCardContent(ExtrinsicState extrinsicState) {
    if (extrinsicState is ListItemExtrinsicState) {
      return _buildListTileContent(extrinsicState);
    }

    return _buildGenericContent(extrinsicState);
  }

  Widget _buildListTileContent(ListItemExtrinsicState extrinsicState) {
    return ListTile(
      leading: extrinsicState.leading,
      title: Text(
        extrinsicState.text,
        style: intrinsicState.style,
      ),
      subtitle: extrinsicState.subtitle != null
          ? Text(extrinsicState.subtitle!)
          : null,
      trailing: extrinsicState.trailing,
      dense: extrinsicState.isDense,
      selected: extrinsicState.isSelected,
      enabled: extrinsicState.isEnabled,
      onTap: extrinsicState.onTap,
      onLongPress: extrinsicState.onLongPress,
    );
  }

  Widget _buildGenericContent(ExtrinsicState extrinsicState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (intrinsicState.iconData != null)
          Icon(
            intrinsicState.iconData,
            color: intrinsicState.style?.color,
            size: 24,
          ),
        if (intrinsicState.iconData != null && extrinsicState.text.isNotEmpty)
          SizedBox(height: 8),
        if (extrinsicState.text.isNotEmpty)
          Text(
            extrinsicState.text,
            style: intrinsicState.style,
          ),
      ],
    );
  }
}

/// Specialized flyweight for animated components
class AnimatedFlyweight extends UIFlyweight {
  const AnimatedFlyweight(AnimatedIntrinsicState super.intrinsicState);

  AnimatedIntrinsicState get animatedState => intrinsicState as AnimatedIntrinsicState;

  @override
  Widget buildWidget(ExtrinsicState extrinsicState) {
    if (extrinsicState is AnimatedExtrinsicState) {
      return buildAnimatedWidget(extrinsicState);
    }

    return GenericUIFlyweight(intrinsicState).buildWidget(extrinsicState);
  }

  Widget buildAnimatedWidget(AnimatedExtrinsicState extrinsicState) {
    Widget child = _buildAnimatedContent(extrinsicState);

    return AnimatedBuilder(
      animation: extrinsicState.animationController ??
                 kAlwaysCompleteAnimation,
      builder: (context, child) {
        return _applyAnimation(child!, extrinsicState);
      },
      child: child,
    );
  }

  Widget _buildAnimatedContent(AnimatedExtrinsicState extrinsicState) {
    return Container(
      padding: intrinsicState.padding,
      margin: intrinsicState.margin,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (intrinsicState.iconData != null) ...[
            Icon(
              intrinsicState.iconData,
              color: animatedState.baseStyle.color,
              size: animatedState.baseStyle.fontSize,
            ),
            SizedBox(width: 8),
          ],
          Text(
            extrinsicState.text,
            style: animatedState.baseStyle,
          ),
        ],
      ),
    );
  }

  Widget _applyAnimation(Widget child, AnimatedExtrinsicState extrinsicState) {
    final animationValue = extrinsicState.animationController?.value ?? 1.0;

    switch (animatedState.animationType) {
      case AnimationType.fadeIn:
        return Opacity(
          opacity: extrinsicState.isVisible ? animationValue : 0.0,
          child: child,
        );

      case AnimationType.fadeOut:
        return Opacity(
          opacity: extrinsicState.isVisible ? 1.0 - animationValue : 1.0,
          child: child,
        );

      case AnimationType.fadeInScale:
        final scale = extrinsicState.isVisible ? animationValue : 0.0;
        final opacity = extrinsicState.isVisible ? animationValue : 0.0;
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        );

      case AnimationType.slideInFromLeft:
        final offset = extrinsicState.isVisible
            ? Offset(animationValue - 1.0, 0.0)
            : Offset(-1.0, 0.0);
        return Transform.translate(
          offset: offset * 100,
          child: child,
        );

      case AnimationType.slideInFromRight:
        final offset = extrinsicState.isVisible
            ? Offset(1.0 - animationValue, 0.0)
            : Offset(1.0, 0.0);
        return Transform.translate(
          offset: offset * 100,
          child: child,
        );

      case AnimationType.slideInFromTop:
        final offset = extrinsicState.isVisible
            ? Offset(0.0, animationValue - 1.0)
            : Offset(0.0, -1.0);
        return Transform.translate(
          offset: offset * 100,
          child: child,
        );

      case AnimationType.slideInFromBottom:
        final offset = extrinsicState.isVisible
            ? Offset(0.0, 1.0 - animationValue)
            : Offset(0.0, 1.0);
        return Transform.translate(
          offset: offset * 100,
          child: child,
        );

      case AnimationType.scaleIn:
        return Transform.scale(
          scale: extrinsicState.isVisible ? animationValue : 0.0,
          child: child,
        );

      case AnimationType.scaleOut:
        return Transform.scale(
          scale: extrinsicState.isVisible ? 1.0 - animationValue : 1.0,
          child: child,
        );

      case AnimationType.rotateIn:
        return Transform.rotate(
          angle: extrinsicState.isVisible ? (1.0 - animationValue) * 6.28 : 6.28,
          child: child,
        );

      case AnimationType.bounceIn:
        final bounceValue = _calculateBounceValue(animationValue);
        return Transform.scale(
          scale: extrinsicState.isVisible ? bounceValue : 0.0,
          child: child,
        );

      default:
        return child;
    }
  }

  double _calculateBounceValue(double t) {
    if (t < 1 / 2.75) {
      return 7.5625 * t * t;
    } else if (t < 2 / 2.75) {
      return 7.5625 * (t -= 1.5 / 2.75) * t + 0.75;
    } else if (t < 2.5 / 2.75) {
      return 7.5625 * (t -= 2.25 / 2.75) * t + 0.9375;
    } else {
      return 7.5625 * (t -= 2.625 / 2.75) * t + 0.984375;
    }
  }
}

/// Theme-aware flyweight that adapts to the current theme
class ThemeAwareFlyweight extends UIFlyweight {
  const ThemeAwareFlyweight() : super(const IntrinsicState());

  Widget buildThemedWidget(ExtrinsicState extrinsicState) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);

        final themedIntrinsicState = IntrinsicState(
          style: theme.textTheme.bodyLarge,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.all(16),
        );

        final themedFlyweight = GenericUIFlyweight(themedIntrinsicState);
        return themedFlyweight.buildWidget(extrinsicState);
      },
    );
  }

  @override
  Widget buildWidget(ExtrinsicState extrinsicState) {
    return buildThemedWidget(extrinsicState);
  }
}

/// Optimizes large lists using flyweight pattern
class ListItemOptimizer {
  final Map<String, UIFlyweight> _flyweightCache = <String, UIFlyweight>{};

  /// Optimizes a list of items by reusing flyweights
  List<Widget> optimizeList(List<ListItemData> items) {
    final widgets = <Widget>[];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final flyweight = _getFlyweightForItem(item);

      final extrinsicState = ListItemExtrinsicState(
        text: item.title,
        subtitle: item.subtitle,
        index: i,
        isSelected: item.isCompleted,
        onTap: () => _handleItemTap(item),
      );

      widgets.add(flyweight.buildWidget(extrinsicState));
    }

    return widgets;
  }

  UIFlyweight _getFlyweightForItem(ListItemData item) {
    final cacheKey = '${item.category}_${item.priority}';

    return _flyweightCache.putIfAbsent(cacheKey, () {
      final intrinsicState = IntrinsicState(
        style: _getStyleForItem(item),
        iconData: _getIconForCategory(item.category),
        decoration: _getDecorationForPriority(item.priority),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      );

      return GenericUIFlyweight(intrinsicState);
    });
  }

  TextStyle _getStyleForItem(ListItemData item) {
    Color textColor = Colors.black87;
    FontWeight fontWeight = FontWeight.normal;

    switch (item.priority) {
      case 'High':
        textColor = Colors.red.shade700;
        fontWeight = FontWeight.w600;
        break;
      case 'Medium':
        textColor = Colors.orange.shade700;
        fontWeight = FontWeight.w500;
        break;
      case 'Low':
        textColor = Colors.green.shade700;
        fontWeight = FontWeight.w400;
        break;
    }

    return TextStyle(
      fontSize: 16,
      color: item.isCompleted ? Colors.grey : textColor,
      fontWeight: fontWeight,
      decoration: item.isCompleted ? TextDecoration.lineThrough : null,
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Work':
        return Icons.work;
      case 'Personal':
        return Icons.person;
      case 'Shopping':
        return Icons.shopping_cart;
      case 'Health':
        return Icons.favorite;
      default:
        return Icons.circle;
    }
  }

  BoxDecoration _getDecorationForPriority(String priority) {
    Color borderColor;

    switch (priority) {
      case 'High':
        borderColor = Colors.red.shade300;
        break;
      case 'Medium':
        borderColor = Colors.orange.shade300;
        break;
      case 'Low':
        borderColor = Colors.green.shade300;
        break;
      default:
        borderColor = Colors.grey.shade300;
    }

    return BoxDecoration(
      border: Border(
        left: BorderSide(color: borderColor, width: 4),
      ),
    );
  }

  void _handleItemTap(ListItemData item) {
    // Handle item interaction
    print('Tapped item: ${item.title}');
  }

  /// Gets the number of unique flyweights created
  int getUniqueflyweightCount() => _flyweightCache.length;

  /// Clears the flyweight cache
  void clear() => _flyweightCache.clear();
}

/// Data class for list items
class ListItemData {
  final int id;
  final String title;
  final String subtitle;
  final String category;
  final String priority;
  final bool isCompleted;

  const ListItemData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.priority,
    this.isCompleted = false,
  });

  @override
  String toString() {
    return 'ListItemData(id: $id, title: "$title", category: $category, priority: $priority)';
  }
}

/// Factory for creating animated flyweights
class AnimatedFlyweightFactory {
  final Map<String, AnimatedFlyweight> _cache = <String, AnimatedFlyweight>{};

  AnimatedFlyweight createAnimatedFlyweight(AnimatedIntrinsicState intrinsicState) {
    final key = intrinsicState.hashCode.toString();

    return _cache.putIfAbsent(key, () {
      return AnimatedFlyweight(intrinsicState);
    });
  }

  void clear() => _cache.clear();
}