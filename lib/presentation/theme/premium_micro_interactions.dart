import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Système de micro-interactions premium pour une UX sophistiquée
class PremiumMicroInteractions {
  // ==================== CONSTANTES D'ANIMATION ====================
  static const Duration _fastTransition = Duration(milliseconds: 150);
  static const Duration _normalTransition = Duration(milliseconds: 250);
  static const Duration _slowTransition = Duration(milliseconds: 400);

  static const Curve _premiumCurve = Curves.easeOutCubic;
  static const Curve _elasticCurve = Curves.elasticOut;
  static const Curve _bounceCurve = Curves.bounceOut;

  // ==================== ANIMATIONS DE BOUTONS PREMIUM ====================

  /// Animation d'interaction pour boutons avec effet de scale subtil
  static Widget premiumButtonInteraction({
    required Widget child,
    required VoidCallback? onTap,
    double scaleEffect = 0.95,
    Duration duration = _fastTransition,
    Curve curve = _premiumCurve,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween<double>(begin: 1.0, end: 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTapDown: (_) {
              // Animation de pression
            },
            onTapUp: (_) {
              // Animation de relâchement
              onTap?.call();
            },
            onTapCancel: () {
              // Animation d'annulation
            },
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Animation d'élévation premium pour cartes
  static Widget elevatedCardAnimation({
    required Widget child,
    double baseElevation = 2,
    double hoverElevation = 8,
    Duration duration = _normalTransition,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: _premiumCurve,
      tween: Tween<double>(begin: baseElevation, end: baseElevation),
      builder: (context, elevation, child) {
        return Material(
          elevation: elevation,
          borderRadius: BorderRadius.circular(16),
          child: MouseRegion(
            onEnter: (_) {
              // Déclencher animation d'élévation
            },
            onExit: (_) {
              // Retour à l'état normal
            },
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // ==================== ANIMATIONS DE SHIMMER PREMIUM ====================

  /// Effet shimmer moderne pour les états de chargement
  static Widget premiumShimmer({
    required Widget child,
    Color? baseColor,
    Color? highlightColor,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    final effectiveBaseColor = baseColor ?? AppTheme.grey200;
    final effectiveHighlightColor = highlightColor ?? AppTheme.grey100;

    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: Curves.easeInOut,
      tween: Tween<double>(begin: -2, end: 2),
      builder: (context, progress, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                effectiveBaseColor,
                effectiveHighlightColor,
                effectiveBaseColor,
              ],
              stops: [
                (progress - 1).clamp(0.0, 1.0),
                progress.clamp(0.0, 1.0),
                (progress + 1).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: child,
    );
  }

  // ==================== TRANSITIONS DE PAGE PREMIUM ====================

  /// Transition de page sophistiquée avec parallax
  static PageRouteBuilder premiumPageTransition<T>({
    required Widget page,
    Duration duration = _normalTransition,
    Curve curve = _premiumCurve,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Animation de slide avec fade
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final slideTween = Tween<Offset>(begin: begin, end: end);
        final slideAnimation = animation.drive(slideTween.chain(
          CurveTween(curve: curve),
        ));

        // Animation de fade
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
          ),
        );

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }

  // ==================== ANIMATIONS DE FEEDBACK TACTILE ====================

  /// Feedback tactile visuel premium
  static Widget hapticFeedbackAnimation({
    required Widget child,
    required VoidCallback onTap,
    Color? rippleColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: (rippleColor ?? AppTheme.primaryColor).withValues(alpha: 0.1),
        highlightColor: (rippleColor ?? AppTheme.primaryColor).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }

  // ==================== ANIMATIONS DE NOTIFICATION PREMIUM ====================

  /// Notification flottante avec animation sophistiquée
  static void showPremiumNotification({
    required BuildContext context,
    required String message,
    IconData? icon,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: TweenAnimationBuilder<double>(
          duration: _normalTransition,
          curve: _elasticCurve,
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, progress, child) {
            return Transform.scale(
              scale: progress,
              child: Opacity(
                opacity: progress,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(16),
                  color: backgroundColor ?? AppTheme.cleanSurfaceColor,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.grey200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Text(
                            message,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    overlay.insert(entry);

    // Auto-suppression après délai
    Future.delayed(duration, () {
      entry.remove();
    });
  }

  // ==================== ANIMATIONS DE CHARGEMENT PREMIUM ====================

  /// Indicateur de chargement sophistiqué
  static Widget premiumLoadingIndicator({
    double size = 24,
    Color? color,
    double strokeWidth = 2.5,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeInOut,
        tween: Tween<double>(begin: 0.0, end: 1.0),
        builder: (context, progress, child) {
          return CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppTheme.primaryColor,
            ),
            backgroundColor: (color ?? AppTheme.primaryColor).withValues(alpha: 0.1),
          );
        },
      ),
    );
  }

  // ==================== ANIMATIONS DE RÉVÉLATION STAGGERED ====================

  /// Animation de révélation en cascade pour listes
  static Widget staggeredReveal({
    required List<Widget> children,
    Duration interval = const Duration(milliseconds: 100),
    Duration duration = _normalTransition,
    Curve curve = _premiumCurve,
  }) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;

        return TweenAnimationBuilder<double>(
          duration: duration + (interval * index),
          curve: curve,
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, progress, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - progress)),
              child: Opacity(
                opacity: progress,
                child: child,
              ),
            );
          },
          child: child,
        );
      }).toList(),
    );
  }
}