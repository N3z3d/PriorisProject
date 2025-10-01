import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Interface pour les effets de glassmorphisme - ISP Compliance
abstract class IGlassEffects {
  Widget glassCard({
    required Widget child,
    double blur,
    double opacity,
    Color color,
    BorderRadius? borderRadius,
    Border? border,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    List<BoxShadow>? boxShadow,
  });

  Widget blurredBackground({
    required Widget child,
    required Widget background,
    double blur,
  });

  Widget professionalMorphism({
    required Widget child,
    Color? backgroundColor,
    double blur,
    double opacity,
    BorderRadius? borderRadius,
  });

  Widget professionalReflectiveSurface({
    required Widget child,
    double reflectionOpacity,
    Color? reflectionColor,
    BorderRadius? borderRadius,
  });
}

/// Énumération pour position des toasts
enum ToastPosition {
  top,
  bottom,
}

/// Système d'effets de glassmorphisme - SRP: Responsable uniquement des effets visuels de base
/// OCP: Extensible via l'interface IGlassEffects
/// DIP: Dépend de l'abstraction BorderRadiusTokens
class GlassEffects implements IGlassEffects {

  /// Widget de carte avec effet de verre
  @override
  Widget glassCard({
    required Widget child,
    double blur = 10.0,
    double opacity = 0.1,
    Color color = Colors.white,
    BorderRadius? borderRadius,
    Border? border,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    List<BoxShadow>? boxShadow,
  }) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadiusTokens.radiusXl,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color.withValues(alpha: opacity),
              borderRadius: borderRadius ?? BorderRadiusTokens.radiusXl,
              border: border ?? Border.all(
                color: color.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: boxShadow,
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Fond avec effet de flou
  @override
  Widget blurredBackground({
    required Widget child,
    required Widget background,
    double blur = 20.0,
  }) {
    return Stack(
      children: [
        background,
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              color: Colors.black.withValues(alpha: 0.1),
            ),
          ),
        ),
        child,
      ],
    );
  }

  /// Effet de morphisme professionnel avec couleur unie
  @override
  Widget professionalMorphism({
    required Widget child,
    Color? backgroundColor,
    double blur = 15.0,
    double opacity = 0.15,
    BorderRadius? borderRadius,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadiusTokens.radiusXl,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: (backgroundColor ?? Colors.white).withValues(alpha: opacity),
            borderRadius: borderRadius ?? BorderRadiusTokens.radiusXl,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  /// Surface avec effet de reflet professionnel
  @override
  Widget professionalReflectiveSurface({
    required Widget child,
    double reflectionOpacity = 0.08,
    Color? reflectionColor,
    BorderRadius? borderRadius,
  }) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 40, // Fixed height instead of full gradient
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius != null
                ? BorderRadius.only(
                    topLeft: borderRadius.topLeft,
                    topRight: borderRadius.topRight,
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
              color: (reflectionColor ?? Colors.white).withValues(alpha: reflectionOpacity),
            ),
          ),
        ),
      ],
    );
  }

  /// Modal dialog avec effet de glassmorphisme
  Widget glassModal({
    required Widget child,
    double blur = 15.0,
    double opacity = 0.05,
    Color backgroundColor = Colors.black,
    double backgroundOpacity = 0.5,
    bool barrierDismissible = true,
    VoidCallback? onDismiss,
  }) {
    return Stack(
      children: [
        GestureDetector(
          onTap: barrierDismissible ? onDismiss : null,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: backgroundColor.withValues(alpha: backgroundOpacity),
          ),
        ),
        Center(
          child: glassCard(
            child: child,
            blur: blur,
            opacity: opacity,
            padding: const EdgeInsets.all(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Bottom sheet avec effet de glassmorphisme
  Widget glassBottomSheet({
    required Widget child,
    double blur = 12.0,
    double opacity = 0.08,
    double height = 400,
    bool enableDragHandle = true,
  }) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadiusTokens.radiusTopLg,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: opacity),
              borderRadius: BorderRadiusTokens.radiusTopLg,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                if (enableDragHandle)
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadiusTokens.radiusXs,
                    ),
                  ),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Menu déroulant avec effet de glassmorphisme
  Widget glassDropdown({
    required Widget child,
    double blur = 8.0,
    double opacity = 0.1,
    double? width,
    double? height,
    Alignment alignment = Alignment.topLeft,
  }) {
    return Align(
      alignment: alignment,
      child: SizedBox(
        width: width ?? 200,
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadiusTokens.radiusSm,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: opacity),
                borderRadius: BorderRadiusTokens.radiusSm,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  /// Toast notification avec effet de glassmorphisme
  Widget glassToast({
    required Widget child,
    double blur = 6.0,
    double opacity = 0.12,
    ToastPosition position = ToastPosition.top,
  }) {
    return Positioned(
      top: position == ToastPosition.top ? 80 : null,
      bottom: position == ToastPosition.bottom ? 80 : null,
      left: 16,
      right: 16,
      child: glassCard(
        child: child,
        blur: blur,
        opacity: opacity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}