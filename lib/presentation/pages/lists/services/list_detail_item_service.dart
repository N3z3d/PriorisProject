import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

class ListDetailItemService {
  const ListDetailItemService({
    required this.context,
    required this.ref,
    required this.listId,
  });

  final BuildContext context;
  final WidgetRef ref;
  final String listId;

  Future<void> showMoveItemDialog(ListItem item) async {
    final l10n = AppLocalizations.of(context);
    final listsState = ref.read(listsControllerProvider);
    final available =
        listsState.lists.where((list) => list.id != listId).toList();
    if (available.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.listMoveNoOtherList ?? 'Aucune autre liste disponible',
          ),
        ),
      );
      return;
    }
    String targetId = available.first.id;
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.listMoveDialogTitle ?? "Déplacer l'élément"),
        content: DropdownButtonFormField<String>(
          value: targetId,
          decoration: InputDecoration(
            labelText: l10n?.listMoveDialogLabel ?? 'Liste de destination',
          ),
          items: available
              .map(
                (list) => DropdownMenuItem(
                  value: list.id,
                  child: Text(list.name),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) targetId = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n?.cancel ?? 'Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(targetId),
            child: Text(l10n?.move ?? 'Déplacer'),
          ),
        ],
      ),
    );
    if (selected == null || selected == listId) return;
    final controller = ref.read(listsControllerProvider.notifier);
    final updated = item.copyWith(listId: selected, forceCompletedAtNull: true);
    await controller.removeListItem(listId, item.id);
    await controller.addListItem(selected, updated);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.listMoveSaved ?? 'Élément déplacé.'),
        ),
      );
    }
  }

  Future<void> showRenameItemDialog(ListItem item) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: item.title);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.listRenameDialogTitle ?? "Renommer l'élément"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n?.listRenameDialogLabel ?? "Nom de l'élément",
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n?.cancel ?? 'Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: Text(l10n?.save ?? 'Enregistrer'),
          ),
        ],
      ),
    );
    if (result == null || result.isEmpty || result == item.title) return;
    final updated = item.copyWith(title: result);
    await ref
        .read(listsControllerProvider.notifier)
        .updateListItem(listId, updated);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.listRenameSaved ?? 'Élément renommé.'),
        ),
      );
    }
  }

  void confirmDeleteItem(ListItem item) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.listConfirmDeleteItemTitle ?? "Supprimer l'élément"),
        content: Text(
          l10n?.listConfirmDeleteItemMessage(item.title) ??
              'Êtes-vous sûr de vouloir supprimer "${item.title}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n?.cancel ?? 'Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteItem(item);
            },
            child: Text(
              l10n?.listDeleteConfirm ?? 'Supprimer',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> duplicateItem(ListItem item) async {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(listsControllerProvider.notifier);
    final duplicated = item.copyWith(
      id: const Uuid().v4(),
      title: '${item.title} (copie)',
      isCompleted: false,
      forceCompletedAtNull: true,
    );
    await controller.addListItem(listId, duplicated);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.listDuplicateSaved ?? 'Élément dupliqué.'),
        ),
      );
    }
  }

  void _deleteItem(ListItem item) {
    ref
        .read(listsControllerProvider.notifier)
        .removeItemFromList(listId, item.id);
  }
}
