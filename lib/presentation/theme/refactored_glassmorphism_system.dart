/// Système de glassmorphisme refactorisé selon les principes SOLID
///
/// Ce barrel file maintient la compatibilité avec l'ancienne API tout en
/// exposant la nouvelle architecture SOLID.
///
/// Architecture SOLID:
/// - SRP: Chaque classe a une seule responsabilité
/// - OCP: Extensible via des interfaces sans modification
/// - LSP: Les implémentations sont substituables
/// - ISP: Interfaces séparées par domaine
/// - DIP: Dépendances vers des abstractions
library glassmorphism_system;

import 'package:flutter/material.dart';

// Exports des modules SOLID
export 'glass/glass_effects.dart';
export 'glass/glass_components.dart';
export 'glass/fluid_animations.dart';
export 'glass/animation_widgets.dart';

import 'glass/glass_effects.dart';
import 'glass/glass_components.dart';
import 'glass/fluid_animations.dart';
import 'glass/animation_widgets.dart';

/// Façade SOLID pour le système de glassmorphisme - Facade Pattern
/// SRP: Responsable uniquement de fournir une interface unifiée
/// DIP: Dépend des abstractions des modules spécialisés
class GlassmorphismSystem {
  static final GlassEffects _effects = GlassEffects();
  static final GlassComponents _components = GlassComponents();

  // Délégation vers GlassEffects - Méthodes statiques
  static Widget glassCard({
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
  }) => _effects.glassCard(
    child: child,
    blur: blur,
    opacity: opacity,
    color: color,
    borderRadius: borderRadius,
    border: border,
    padding: padding,
    margin: margin,
    width: width,
    height: height,
    boxShadow: boxShadow,
  );

  static Widget blurredBackground({
    required Widget child,
    required Widget background,
    double blur = 20.0,
  }) => _effects.blurredBackground(
    child: child,
    background: background,
    blur: blur,
  );

  static Widget professionalMorphism({
    required Widget child,
    Color? backgroundColor,
    double blur = 15.0,
    double opacity = 0.15,
    BorderRadius? borderRadius,
  }) => _effects.professionalMorphism(
    child: child,
    backgroundColor: backgroundColor,
    blur: blur,
    opacity: opacity,
    borderRadius: borderRadius,
  );

  static Widget professionalReflectiveSurface({
    required Widget child,
    double reflectionOpacity = 0.08,
    Color? reflectionColor,
    BorderRadius? borderRadius,
  }) => _effects.professionalReflectiveSurface(
    child: child,
    reflectionOpacity: reflectionOpacity,
    reflectionColor: reflectionColor,
    borderRadius: borderRadius,
  );

  static Widget glassModal({
    required Widget child,
    double blur = 15.0,
    double opacity = 0.05,
    Color backgroundColor = Colors.black,
    double backgroundOpacity = 0.5,
    bool barrierDismissible = true,
    VoidCallback? onDismiss,
  }) => _effects.glassModal(
    child: child,
    blur: blur,
    opacity: opacity,
    backgroundColor: backgroundColor,
    backgroundOpacity: backgroundOpacity,
    barrierDismissible: barrierDismissible,
    onDismiss: onDismiss,
  );

  static Widget glassBottomSheet({
    required Widget child,
    double blur = 12.0,
    double opacity = 0.08,
    double height = 400,
    bool enableDragHandle = true,
  }) => _effects.glassBottomSheet(
    child: child,
    blur: blur,
    opacity: opacity,
    height: height,
    enableDragHandle: enableDragHandle,
  );

  static Widget glassDropdown({
    required Widget child,
    double blur = 8.0,
    double opacity = 0.1,
    double? width,
    double? height,
    Alignment alignment = Alignment.topLeft,
  }) => _effects.glassDropdown(
    child: child,
    blur: blur,
    opacity: opacity,
    width: width,
    height: height,
    alignment: alignment,
  );

  static Widget glassToast({
    required Widget child,
    double blur = 6.0,
    double opacity = 0.12,
    ToastPosition position = ToastPosition.top,
  }) => _effects.glassToast(
    child: child,
    blur: blur,
    opacity: opacity,
    position: position,
  );

  // Délégation vers GlassComponents
  static Widget glassButton({
    required Widget child,
    required VoidCallback onPressed,
    Color color = Colors.white,
    double blur = 10.0,
    double opacity = 0.2,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
  }) => _components.glassButton(
    child: child,
    onPressed: onPressed,
    color: color,
    blur: blur,
    opacity: opacity,
    padding: padding,
    borderRadius: borderRadius,
  );

  static Widget glassFAB({
    required VoidCallback onPressed,
    required Widget child,
    Color? backgroundColor,
    double elevation = 6.0,
    String? heroTag,
  }) => _components.glassFAB(
    onPressed: onPressed,
    child: child,
    backgroundColor: backgroundColor,
    elevation: elevation,
    heroTag: heroTag,
  );

  // Délégation vers FluidAnimationFactory
  static Widget waveAnimation({
    required Widget child,
    Duration? duration,
    double? amplitude,
    AnimationConfig? config,
  }) => FluidAnimationFactory.createWave(
    child: child,
    duration: duration,
    amplitude: amplitude,
    config: config,
  );

  static Widget floatAnimation({
    required Widget child,
    Duration? duration,
    double? offset,
    AnimationConfig? config,
  }) => FluidAnimationFactory.createFloat(
    child: child,
    duration: duration,
    offset: offset,
    config: config,
  );

  static Widget gentleRotationAnimation({
    required Widget child,
    Duration? duration,
    double? angle,
    AnimationConfig? config,
  }) => FluidAnimationFactory.createGentleRotation(
    child: child,
    duration: duration,
    angle: angle,
    config: config,
  );
}

/// Classe de compatibilité pour maintenir l'API existante
/// @deprecated Utilisez GlassmorphismSystem à la place
/// Cette classe sera supprimée dans une version future
class Glassmorphism {
  // Délégation vers le nouveau système pour compatibilité ascendante
  static Widget glassCard({
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
  }) => GlassmorphismSystem.glassCard(
    child: child,
    blur: blur,
    opacity: opacity,
    color: color,
    borderRadius: borderRadius,
    border: border,
    padding: padding,
    margin: margin,
    width: width,
    height: height,
    boxShadow: boxShadow,
  );

  static Widget blurredBackground({
    required Widget child,
    required Widget background,
    double blur = 20.0,
  }) => GlassmorphismSystem.blurredBackground(
    child: child,
    background: background,
    blur: blur,
  );

  static Widget glassModal({
    required Widget child,
    double blur = 15.0,
    double opacity = 0.05,
    Color backgroundColor = Colors.black,
    double backgroundOpacity = 0.5,
    bool barrierDismissible = true,
    VoidCallback? onDismiss,
  }) => GlassmorphismSystem.glassModal(
    child: child,
    blur: blur,
    opacity: opacity,
    backgroundColor: backgroundColor,
    backgroundOpacity: backgroundOpacity,
    barrierDismissible: barrierDismissible,
    onDismiss: onDismiss,
  );

  static Widget glassBottomSheet({
    required Widget child,
    double blur = 12.0,
    double opacity = 0.08,
    double height = 400,
    bool enableDragHandle = true,
  }) => GlassmorphismSystem.glassBottomSheet(
    child: child,
    blur: blur,
    opacity: opacity,
    height: height,
    enableDragHandle: enableDragHandle,
  );

  static Widget glassDropdown({
    required Widget child,
    double blur = 8.0,
    double opacity = 0.1,
    double? width,
    double? height,
    Alignment alignment = Alignment.topLeft,
  }) => GlassmorphismSystem.glassDropdown(
    child: child,
    blur: blur,
    opacity: opacity,
    width: width,
    height: height,
    alignment: alignment,
  );

  static Widget glassToast({
    required Widget child,
    double blur = 6.0,
    double opacity = 0.12,
    ToastPosition position = ToastPosition.top,
  }) => GlassmorphismSystem.glassToast(
    child: child,
    blur: blur,
    opacity: opacity,
    position: position,
  );

  static Widget professionalMorphism({
    required Widget child,
    Color? backgroundColor,
    double blur = 15.0,
    double opacity = 0.15,
    BorderRadius? borderRadius,
  }) => GlassmorphismSystem.professionalMorphism(
    child: child,
    backgroundColor: backgroundColor,
    blur: blur,
    opacity: opacity,
    borderRadius: borderRadius,
  );

  static Widget glassButton({
    required Widget child,
    required VoidCallback onPressed,
    Color color = Colors.white,
    double blur = 10.0,
    double opacity = 0.2,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
  }) => GlassmorphismSystem.glassButton(
    child: child,
    onPressed: onPressed,
    color: color,
    blur: blur,
    opacity: opacity,
    padding: padding,
    borderRadius: borderRadius,
  );

  static Widget professionalReflectiveSurface({
    required Widget child,
    double reflectionOpacity = 0.08,
    Color? reflectionColor,
    BorderRadius? borderRadius,
  }) => GlassmorphismSystem.professionalReflectiveSurface(
    child: child,
    reflectionOpacity: reflectionOpacity,
    reflectionColor: reflectionColor,
    borderRadius: borderRadius,
  );

  static Widget glassFAB({
    required VoidCallback onPressed,
    required Widget child,
    Color? backgroundColor,
    double elevation = 6.0,
    String? heroTag,
  }) => GlassmorphismSystem.glassFAB(
    onPressed: onPressed,
    child: child,
    backgroundColor: backgroundColor,
    elevation: elevation,
    heroTag: heroTag,
  );
}

/// Classe de compatibilité pour FluidAnimations
/// @deprecated Utilisez FluidAnimationFactory directement à la place
/// Cette classe sera supprimée dans une version future
class FluidAnimationsLegacy {
  static Widget wave({
    required Widget child,
    Duration? duration,
    double? amplitude,
    AnimationConfig? config,
  }) => FluidAnimationFactory.createWave(
    child: child,
    duration: duration,
    amplitude: amplitude,
    config: config,
  );

  static Widget float({
    required Widget child,
    Duration? duration,
    double? offset,
    AnimationConfig? config,
  }) => FluidAnimationFactory.createFloat(
    child: child,
    duration: duration,
    offset: offset,
    config: config,
  );

  static Widget gentleRotation({
    required Widget child,
    Duration? duration,
    double? angle,
    AnimationConfig? config,
  }) => FluidAnimationFactory.createGentleRotation(
    child: child,
    duration: duration,
    angle: angle,
    config: config,
  );
}