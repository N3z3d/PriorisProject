import 'package:flutter/material.dart';

/// Action menu component for list card
///
/// Provides edit, archive, and delete actions via popup menu.
class ListCardActionMenu extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onArchive;

  const ListCardActionMenu({
    super.key,
    this.onEdit,
    this.onDelete,
    this.onArchive,
  });

  bool get hasActions => onEdit != null || onDelete != null || onArchive != null;

  @override
  Widget build(BuildContext context) {
    if (!hasActions) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      onSelected: _handleMenuSelection,
      itemBuilder: (context) => _buildMenuItems(),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'edit':
        onEdit?.call();
        break;
      case 'archive':
        onArchive?.call();
        break;
      case 'delete':
        onDelete?.call();
        break;
    }
  }

  List<PopupMenuEntry<String>> _buildMenuItems() {
    return [
      if (onEdit != null) _buildEditMenuItem(),
      if (onArchive != null) _buildArchiveMenuItem(),
      if (onDelete != null) _buildDeleteMenuItem(),
    ];
  }

  PopupMenuItem<String> _buildEditMenuItem() {
    return const PopupMenuItem(
      value: 'edit',
      child: Row(
        children: [
          Icon(Icons.edit, size: 16),
          SizedBox(width: 8),
          Text('Modifier'),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildArchiveMenuItem() {
    return const PopupMenuItem(
      value: 'archive',
      child: Row(
        children: [
          Icon(Icons.archive, size: 16),
          SizedBox(width: 8),
          Text('Archiver'),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildDeleteMenuItem() {
    return const PopupMenuItem(
      value: 'delete',
      child: Row(
        children: [
          Icon(Icons.delete, size: 16, color: Colors.red),
          SizedBox(width: 8),
          Text('Supprimer', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}
