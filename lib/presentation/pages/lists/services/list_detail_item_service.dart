import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/l10n/app_localizations.dart';

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
}
