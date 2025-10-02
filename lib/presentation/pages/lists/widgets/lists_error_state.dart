import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/common/forms/common_button.dart';

/// Widget pour afficher l'état d'erreur dans la page des listes
///
/// **Responsabilité** : Afficher un message d'erreur avec possibilité de réessayer
/// **SRP Compliant** : Une seule raison de changer - modification de l'UI d'erreur
class ListsErrorState extends StatelessWidget {
  const ListsErrorState({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  final String errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Erreur',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red[500],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          CommonButton(
            text: 'Réessayer',
            icon: Icons.refresh,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
