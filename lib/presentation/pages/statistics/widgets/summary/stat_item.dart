import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Widget affichant un élément de statistique avec une icône, une valeur et un label
/// 
/// Ce widget est utilisé pour afficher des métriques individuelles dans les sections
/// de statistiques des habitudes et des tâches.
class StatItem extends StatelessWidget {
  /// Valeur numérique ou textuelle à afficher
  final String value;
  
  /// Label descriptif de la métrique
  final String label;
  
  /// Icône à afficher au-dessus de la valeur
  final IconData icon;

  /// Constructeur du widget StatItem
  /// 
  /// [value] : La valeur à afficher (ex: "12", "78%", "15 j")
  /// [label] : Le label descriptif (ex: "Habitudes actives", "Taux moyen")
  /// [icon] : L'icône à afficher (ex: Icons.check_circle_outline)
  const StatItem({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon, 
            color: AppTheme.primaryColor, 
            size: 28
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 
