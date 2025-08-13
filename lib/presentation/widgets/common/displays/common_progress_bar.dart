import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Widget de barre de progression réutilisable pour toute l'application
class CommonProgressBar extends StatelessWidget {
  /// Valeur courante de la progression (obligatoire)
  final double value;

  /// Valeur maximale (défaut: 100)
  final double? maxValue;

  /// Label optionnel à afficher à gauche ou au-dessus
  final String? label;

  /// Couleur personnalisée de la barre
  final Color? color;

  /// Hauteur de la barre (défaut: 12)
  final double? height;

  /// Afficher le pourcentage à droite
  final bool showPercentage;

  /// Rayon de bordure
  final BorderRadius? borderRadius;

  /// Padding autour du widget
  final EdgeInsetsGeometry? padding;

  /// Constructeur
  const CommonProgressBar({
    super.key,
    required this.value,
    this.maxValue,
    this.label,
    this.color,
    this.height,
    this.showPercentage = false,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final double max = maxValue ?? 100.0;
    final double percent = (max == 0) ? 0 : (value / max).clamp(0.0, 1.0);
    final Color barColor = color ?? AppTheme.primaryColor;
    final double barHeight = height ?? 12.0;
    final BorderRadius radius = borderRadius ?? BorderRadiusTokens.progressBar;

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: radius,
                  child: Container(
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: radius,
                    ),
                    child: Stack(
                      children: [
                        FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: percent,
                          child: Container(
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius: radius,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (showPercentage) ...[
                const SizedBox(width: 12),
                Text(
                  '${(percent * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
} 
