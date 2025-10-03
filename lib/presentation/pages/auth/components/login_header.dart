import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Widget d'en-tête de la page de connexion
///
/// **SRP** : Affiche uniquement le logo et le titre
class LoginHeader extends StatelessWidget {
  final bool isSignUp;

  const LoginHeader({
    super.key,
    required this.isSignUp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.checklist_rtl,
          size: 64,
          color: AppTheme.lightTheme.primaryColor,
        ),
        const SizedBox(height: 16),
        Text(
          'Prioris',
          style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.lightTheme.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          isSignUp ? 'Créer un compte' : 'Connectez-vous',
          style: AppTheme.lightTheme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
