import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Widget de chargement avancé avec animations et feedbacks visuels
/// 
/// Fournit des indicateurs de chargement sophistiqués avec :
/// - Animations fluides et personnalisables
/// - Messages contextuels
/// - Indicateurs de progression
/// - Thèmes adaptatifs
class AdvancedLoadingWidget extends StatefulWidget {
  final String? message;
  final double? progress;
  final bool showProgress;
  final LoadingType type;
  final Color? color;
  final double size;

  const AdvancedLoadingWidget({
    super.key,
    this.message,
    this.progress,
    this.showProgress = false,
    this.type = LoadingType.CIRCULAR,
    this.color,
    this.size = 40.0,
  });

  @override
  State<AdvancedLoadingWidget> createState() => _AdvancedLoadingWidgetState();
}

class _AdvancedLoadingWidgetState extends State<AdvancedLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.primaryColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: _buildLoadingIndicator(color),
              ),
            );
          },
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (widget.showProgress && widget.progress != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              value: widget.progress,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(widget.progress! * 100).toInt()}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingIndicator(Color color) {
    switch (widget.type) {
      case LoadingType.CIRCULAR:
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CircularProgressIndicator(
            strokeWidth: 3.0,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        );
      case LoadingType.DOTS:
        return _buildDotsLoader(color);
      case LoadingType.PULSE:
        return _buildPulseLoader(color);
      case LoadingType.WAVE:
        return _buildWaveLoader(color);
    }
  }

  Widget _buildDotsLoader(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final delay = index * 0.2;
            final animationValue = (_animationController.value + delay) % 1.0;
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.3 + (0.7 * animationValue)),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildPulseLoader(Color color) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: widget.size * 0.6,
              height: widget.size * 0.6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaveLoader(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final delay = index * 0.1;
            final animationValue = (_animationController.value + delay) % 1.0;
            final height = 4.0 + (12.0 * animationValue);
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 3,
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadiusTokens.radiusXs,
              ),
            );
          },
        );
      }),
    );
  }
}

/// Types d'indicateurs de chargement disponibles
enum LoadingType {
  CIRCULAR('Circulaire'),
  DOTS('Points'),
  PULSE('Pulsation'),
  WAVE('Onde');

  const LoadingType(this.displayName);
  final String displayName;
}

/// Widget de feedback d'erreur avancé
class AdvancedErrorWidget extends StatelessWidget {
  final String message;
  final String? details;
  final VoidCallback? onRetry;
  final ErrorType type;

  const AdvancedErrorWidget({
    super.key,
    required this.message,
    this.details,
    this.onRetry,
    this.type = ErrorType.GENERIC,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadiusTokens.card,
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getErrorIcon(),
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (details != null) ...[
            const SizedBox(height: 8),
            Text(
              details!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getErrorIcon() {
    switch (type) {
      case ErrorType.NETWORK:
        return Icons.wifi_off;
      case ErrorType.PERMISSION:
        return Icons.lock;
      case ErrorType.NOT_FOUND:
        return Icons.search_off;
      case ErrorType.GENERIC:
        return Icons.error_outline;
    }
  }
}

/// Types d'erreurs
enum ErrorType {
  NETWORK('Réseau'),
  PERMISSION('Permission'),
  NOT_FOUND('Non trouvé'),
  GENERIC('Générique');

  const ErrorType(this.displayName);
  final String displayName;
}

/// Widget de succès avec animation
class SuccessWidget extends StatefulWidget {
  final String message;
  final VoidCallback? onDismiss;

  const SuccessWidget({
    super.key,
    required this.message,
    this.onDismiss,
  });

  @override
  State<SuccessWidget> createState() => _SuccessWidgetState();
}

class _SuccessWidgetState extends State<SuccessWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();

    if (widget.onDismiss != null) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _animationController.reverse().then((_) {
            widget.onDismiss?.call();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadiusTokens.card,
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} 
