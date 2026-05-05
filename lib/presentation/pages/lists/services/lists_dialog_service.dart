import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/models/core/builders/custom_list_builder.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/widgets/dialogs/quick_add_dialog.dart';
import 'package:prioris/presentation/widgets/dialogs/dialogs.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';

/// Service pour gérer les dialogues de la page des listes
///
/// **Responsabilité** : Centraliser la logique d'affichage des dialogues
/// **SRP Compliant** : Se concentre uniquement sur la gestion des dialogues
/// **DIP Compliant** : Dépend de l'abstraction (WidgetRef) pas de l'implémentation
class ListsDialogService {
  const ListsDialogService({
    required this.context,
    required this.ref,
  });

  final BuildContext context;
  final WidgetRef ref;

  /// Affiche le dialogue de création rapide de liste
  Future<void> showCreateListDialog() async {
    final l10n = AppLocalizations.of(context)!;
    return showDialog(
      context: context,
      builder: (dialogContext) => QuickAddDialog(
        title: l10n.listCreateDialogTitle,
        hintText: 'Nom de la liste...',
        onSubmit: (title) => _handleCreateList(title),
      ),
    );
  }

  /// Affiche le dialogue de modification de liste
  Future<void> showEditListDialog(CustomList list) async {
    return showDialog(
      context: context,
      builder: (dialogContext) => CustomListFormDialog(
        initialList: list,
        onSubmit: (updatedList) => _handleUpdateList(updatedList),
      ),
    );
  }

  /// Affiche le dialogue de confirmation de suppression
  Future<void> showDeleteConfirmationDialog(CustomList list) async {
    final l10n = AppLocalizations.of(context)!;
    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.listDeleteDialogTitle),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${list.name}" ? '
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _handleDeleteList(list);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  /// Gère la création d'une nouvelle liste
  Future<void> _handleCreateList(String title) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final newList = CustomListBuilder()
        .withName(title)
        .withDescription('')
        .withType(ListType.CUSTOM)
        .withItems([])
        .build();

      await ref.read(listsControllerProvider.notifier).createList(newList);

      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.listCreatedSuccess(title)),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.of(context).pushNamed(
          '/list-detail',
          arguments: {'list': newList},
        );
      }
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.listCreateError),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  /// Gère la mise à jour d'une liste
  Future<void> _handleUpdateList(CustomList updatedList) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await ref.read(listsControllerProvider.notifier).updateList(updatedList);

      if (context.mounted) {
        navigator.pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.listUpdatedSuccess(updatedList.name)),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.listEditError(e.toString())),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  /// Gère la suppression d'une liste
  Future<void> _handleDeleteList(CustomList list) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      await ref.read(listsControllerProvider.notifier).deleteList(list.id);

      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.listDeletedSuccess(list.name)),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.listDeleteError(e.toString())),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
