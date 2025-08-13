import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Widget représentant le séparateur "VS" entre deux tâches dans le duel
/// 
/// Ce widget affiche un séparateur visuellement attractif avec design professionnel,
/// ombres et animation pour séparer les deux cartes de tâches en compétition.
class VsSeparatorWidget extends StatelessWidget {
  const VsSeparatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: _buildVsDecoration(),
          child: _buildVsText(),
        ),
      ),
    );
  }

  /// Construit la décoration du séparateur VS avec style professionnel
  BoxDecoration _buildVsDecoration() {
    return BoxDecoration(
      // Fond professionnel uni
      color: AppTheme.primaryColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
      border: Border.all(color: AppTheme.dividerColor, width: 1),
    );
  }

  /// Construit le texte "VS" avec style dramatique
  Widget _buildVsText() {
    return Text(
      'VS',
      style: TextStyle(
        fontWeight: FontWeight.w700,
        color: Colors.white,
        fontSize: 18,
        letterSpacing: 3,
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.2),
            offset: const Offset(0.5, 0.5),
            blurRadius: 1,
          ),
        ],
      ),
    );
  }
} 