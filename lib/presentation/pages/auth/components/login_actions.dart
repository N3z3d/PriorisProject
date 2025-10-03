import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/common/forms/common_button.dart';
import 'package:prioris/presentation/widgets/dialogs/forgot_password_dialog.dart';

/// Widget contenant les actions de la page de connexion
///
/// **SRP** : Gère uniquement les boutons d'action (submit, toggle, forgot password)
class LoginActions extends StatelessWidget {
  final bool isLoading;
  final bool isSignUp;
  final VoidCallback onSubmit;
  final VoidCallback onToggleMode;

  const LoginActions({
    super.key,
    required this.isLoading,
    required this.isSignUp,
    required this.onSubmit,
    required this.onToggleMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommonButton(
          onPressed: isLoading ? null : onSubmit,
          text: isLoading
              ? 'Chargement...'
              : (isSignUp ? 'Créer le compte' : 'Se connecter'),
          isLoading: isLoading,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: onToggleMode,
          child: Text(
            isSignUp
                ? 'Déjà un compte ? Se connecter'
                : 'Pas de compte ? Créer un compte',
          ),
        ),
        if (!isSignUp) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => _showForgotPasswordDialog(context),
            child: const Text('Mot de passe oublié ?'),
          ),
        ],
      ],
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ForgotPasswordDialog(),
    );
  }
}
