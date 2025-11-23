import 'package:flutter/material.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/lists/models/task_sort_field.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

class ListSortToolbar extends StatelessWidget {
  final TaskSortField sortField;
  final bool isAscending;
  final int itemCount;
  final ValueChanged<TaskSortField> onSortChanged;
  final VoidCallback onToggleAscending;

  const ListSortToolbar({
    super.key,
    required this.sortField,
    required this.isAscending,
    required this.itemCount,
    required this.onSortChanged,
    required this.onToggleAscending,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(child: _buildSortDropdown(l10n)),
          const SizedBox(width: 12),
          _buildAscendingButton(l10n),
          const SizedBox(width: 12),
          Text(
            l10n.itemsCount(itemCount),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortDropdown(AppLocalizations l10n) {
    return DropdownButtonFormField<TaskSortField>(
      value: sortField,
      decoration: InputDecoration(
        labelText: l10n.sortBy,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        DropdownMenuItem(
          value: TaskSortField.elo,
          child: Text(l10n.scoreElo),
        ),
        DropdownMenuItem(
          value: TaskSortField.name,
          child: Text(l10n.name),
        ),
        DropdownMenuItem(
          value: TaskSortField.random,
          child: Text(l10n.random),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          onSortChanged(value);
        }
      },
    );
  }

  Widget _buildAscendingButton(AppLocalizations l10n) {
    final isRandom = sortField == TaskSortField.random;
    return IconButton(
      tooltip: isAscending ? l10n.orderAscending : l10n.orderDescending,
      onPressed: isRandom ? null : onToggleAscending,
      icon: Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward),
    );
  }
}
