import 'package:flutter/material.dart';
import 'package:prioris/presentation/pages/lists/models/task_sort_field.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

class ListSortToolbar extends StatelessWidget {
  final TaskSortField sortField;
  final bool isAscending;
  final int itemCount;
  final ValueChanged<TaskSortField> onSortChanged;
  final VoidCallback onToggleAscending;
  final VoidCallback onShuffleRequested;

  const ListSortToolbar({
    super.key,
    required this.sortField,
    required this.isAscending,
    required this.itemCount,
    required this.onSortChanged,
    required this.onToggleAscending,
    required this.onShuffleRequested,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(child: _buildSortDropdown()),
          const SizedBox(width: 12),
          _buildAscendingButton(),
          if (sortField == TaskSortField.random) ...[
            const SizedBox(width: 8),
            _buildShuffleButton(),
          ],
          const SizedBox(width: 12),
          Text(
            '$itemCount éléments',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortDropdown() {
    return DropdownButtonFormField<TaskSortField>(
      value: sortField,
      decoration: const InputDecoration(
        labelText: 'Trier par',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: const [
        DropdownMenuItem(
          value: TaskSortField.elo,
          child: Text('Score Élo'),
        ),
        DropdownMenuItem(
          value: TaskSortField.name,
          child: Text('Nom'),
        ),
        DropdownMenuItem(
          value: TaskSortField.random,
          child: Text('Aléatoire'),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          onSortChanged(value);
        }
      },
    );
  }

  Widget _buildAscendingButton() {
    final isRandom = sortField == TaskSortField.random;
    return IconButton(
      tooltip: isAscending ? 'Ordre croissant' : 'Ordre décroissant',
      onPressed: isRandom ? null : onToggleAscending,
      icon: Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward),
    );
  }

  Widget _buildShuffleButton() {
    return IconButton(
      tooltip: 'Remélanger',
      onPressed: onShuffleRequested,
      icon: const Icon(Icons.casino),
    );
  }
}
