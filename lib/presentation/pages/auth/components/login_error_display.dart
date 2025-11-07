import 'package:flutter/material.dart';
import 'package:prioris/presentation/styles/ui_color_utils.dart';

/// Widget d'affichage des erreurs de connexion
///
/// **SRP** : Affiche uniquement le message d'erreur si présent
class LoginErrorDisplay extends StatelessWidget {
  final String? errorMessage;
  final Color errorColor;

  const LoginErrorDisplay({
    super.key,
    this.errorMessage,
    this.errorColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: tone(errorColor, level: 50),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: tone(errorColor, level: 300)),
        ),
        child: Text(
          errorMessage!,
          style: TextStyle(color: tone(errorColor, level: 700)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
