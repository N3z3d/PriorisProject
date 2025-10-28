import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Badge unifié pour afficher le score Élo
/// Utilisé dans les cartes de duel et le mode classement
class EloBadge extends StatelessWidget {
  final double score;
  final bool compact;

  const EloBadge({
    super.key,
    required this.score,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _resolveColor(score);
    final padding = compact
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 4)
        : const EdgeInsets.symmetric(horizontal: 14, vertical: 6);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(compact ? 12 : 14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        score.toStringAsFixed(0),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: compact ? 11 : 13,
              color: color,
              letterSpacing: 0.5,
            ),
      ),
    );
  }

  static Color _resolveColor(double score) {
    if (score >= 1400) {
      return AppTheme.secondaryColor;
    }
    if (score >= 1200) {
      return AppTheme.accentColor;
    }
    return AppTheme.grey400;
  }
}
