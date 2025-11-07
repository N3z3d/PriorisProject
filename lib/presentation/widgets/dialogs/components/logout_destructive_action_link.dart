import 'package:flutter/material.dart';
import 'package:prioris/presentation/styles/ui_color_utils.dart';

/// Lien d'action destructive pour effacer les données
///
/// Respecte WCAG 3.2.2 et 2.1.1 pour l'accessibilité
class LogoutDestructiveActionLink extends StatelessWidget {
  final VoidCallback onTap;
  final Color warningColor;

  const LogoutDestructiveActionLink({
    super.key,
    required this.onTap,
    this.warningColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      hint: 'Action irréversible - supprime toutes les données localement',
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber,
                size: 12,
                color: tone(warningColor, level: 600),
              ),
              const SizedBox(width: 4),
              Text(
                'Effacer toutes mes données de cet appareil',
                style: TextStyle(
                  fontSize: 12,
                  color: tone(warningColor, level: 600),
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
