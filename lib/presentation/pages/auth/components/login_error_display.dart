import 'package:flutter/material.dart';

/// Widget d'affichage des erreurs de connexion
///
/// **SRP** : Affiche uniquement le message d'erreur si présent
class LoginErrorDisplay extends StatelessWidget {
  final String? errorMessage;

  const LoginErrorDisplay({
    super.key,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade300),
        ),
        child: Text(
          errorMessage!,
          style: TextStyle(color: Colors.red.shade700),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
