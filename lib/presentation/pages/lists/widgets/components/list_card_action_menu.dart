import 'package:flutter/material.dart';
import 'package:prioris/l10n/app_localizations.dart';

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
      itemBuilder: (context) => _buildMenuItems(context),
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

  List<PopupMenuEntry<String>> _buildMenuItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      if (onEdit != null) _buildEditMenuItem(l10n),
      if (onArchive != null) _buildArchiveMenuItem(l10n),
      if (onDelete != null) _buildDeleteMenuItem(l10n),
    ];
  }

  PopupMenuItem<String> _buildEditMenuItem(AppLocalizations l10n) {
    return PopupMenuItem(
      value: 'edit',
      child: Row(
        children: [
          const Icon(Icons.edit, size: 16),
          const SizedBox(width: 8),
          Text(l10n.edit),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildArchiveMenuItem(AppLocalizations l10n) {
    return PopupMenuItem(
      value: 'archive',
      child: Row(
        children: [
          const Icon(Icons.archive, size: 16),
          const SizedBox(width: 8),
          Text(l10n.archiveAction),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildDeleteMenuItem(AppLocalizations l10n) {
    return PopupMenuItem(
      value: 'delete',
      child: Row(
        children: [
          const Icon(Icons.delete, size: 16, color: Colors.red),
          const SizedBox(width: 8),
          Text(l10n.delete, style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}
