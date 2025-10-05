import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Widget de titre pour le dialogue de déconnexion simplifié
///
/// Respecte WCAG 1.3.1 et 2.4.3 pour l'accessibilité
class LogoutDialogTitle extends StatelessWidget {
  const LogoutDialogTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadiusTokens.button,
            ),
            child: Icon(
              Icons.logout,
              color: AppTheme.primaryColor,
              size: 24,
              semanticLabel: 'Icône de déconnexion',
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Se déconnecter',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
