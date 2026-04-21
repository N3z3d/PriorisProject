import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/common/forms/common_button.dart';

/// Widget pour afficher l'etat vide dans la page des listes.
class ListsNoDataState extends StatelessWidget {
  const ListsNoDataState({
    super.key,
    required this.onCreateList,
  });

  final VoidCallback onCreateList;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                    'Ajoutez votre premiere liste pour commencer',
                    textAlign: TextAlign.center,
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
            ),
          ),
        );
      },
    );
  }
}
