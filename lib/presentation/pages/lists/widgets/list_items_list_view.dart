import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/presentation/pages/lists/widgets/list_item_card.dart';

class ListItemsListView extends StatelessWidget {
  const ListItemsListView({
    super.key,
    required this.items,
    required this.syncingItems,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleCompletion,
    required this.onMenuAction,
  });

  final List<ListItem> items;
  final Set<String> syncingItems;
  final ValueChanged<ListItem> onEdit;
  final ValueChanged<ListItem> onDelete;
  final ValueChanged<ListItem> onToggleCompletion;
  final void Function(String action, ListItem item) onMenuAction;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: ListItemCard(
            item: item,
            isSyncing: syncingItems.contains(item.id),
            onEdit: () => onEdit(item),
            onDelete: () => onDelete(item),
            onToggleCompletion: () => onToggleCompletion(item),
            onMenuAction: (action) => onMenuAction(action, item),
          ),
        );
      },
    );
  }
}
