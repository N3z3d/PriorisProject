import 'package:flutter/material.dart';

/// Lien d'action destructive pour effacer les données
///
/// Respecte WCAG 3.2.2 et 2.1.1 pour l'accessibilité
class LogoutDestructiveActionLink extends StatelessWidget {
  final VoidCallback onTap;

  const LogoutDestructiveActionLink({
    super.key,
    required this.onTap,
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
                color: Colors.red.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                'Effacer toutes mes données de cet appareil',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade600,
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
