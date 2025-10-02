import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/common/forms/common_button.dart';

/// Widget pour afficher l'état vide dans la page des listes
///
/// **Responsabilité** : Afficher un message encourageant à créer la première liste
/// **SRP Compliant** : Une seule raison de changer - modification de l'UI vide
class ListsNoDataState extends StatelessWidget {
  const ListsNoDataState({
    super.key,
    required this.onCreateList,
  });

  final VoidCallback onCreateList;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.list_alt_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Aucune liste',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez votre première liste pour commencer',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          CommonButton(
            text: 'Ajouter une liste',
            icon: Icons.add,
            onPressed: onCreateList,
          ),
        ],
      ),
    );
  }
}
