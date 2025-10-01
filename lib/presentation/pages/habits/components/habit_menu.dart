import 'package:flutter/material.dart';

/// Menu component for habit actions following SRP
class HabitMenu extends StatelessWidget {
  final VoidCallback onRecord;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HabitMenu({
    super.key,
    required this.onRecord,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Afficher le menu',
      onSelected: (value) => _handleAction(value),
      itemBuilder: (context) => [
        _buildMenuItem('record', Icons.check_circle, 'Enregistrer'),
        _buildMenuItem('edit', Icons.edit, 'Modifier'),
        _buildMenuItem('delete', Icons.delete, 'Supprimer', isDestructive: true),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    IconData icon,
    String text, {
    bool isDestructive = false,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: isDestructive ? Colors.red : null),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: isDestructive ? Colors.red : null),
          ),
        ],
      ),
    );
  }

  void _handleAction(String action) {
    switch (action) {
      case 'record':
        onRecord();
        break;
      case 'edit':
        onEdit();
        break;
      case 'delete':
        onDelete();
        break;
    }
  }
}
