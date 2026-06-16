import 'package:flutter/material.dart';
import 'package:prioris/domain/core/value_objects/list_prioritization_settings.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Dialog pour sélectionner quelles listes participent au mode prioriser
class ListSelectionDialog extends StatefulWidget {
  final ListPrioritizationSettings currentSettings;
  final List<Map<String, String>> availableLists;
  final void Function(ListPrioritizationSettings) onSettingsChanged;

  const ListSelectionDialog({
    super.key,
    required this.currentSettings,
    required this.availableLists,
    required this.onSettingsChanged,
  });

  @override
  State<ListSelectionDialog> createState() => _ListSelectionDialogState();
}

class _ListSelectionDialogState extends State<ListSelectionDialog> {
  late Set<String> _checkedIds;

  @override
  void initState() {
    super.initState();
    final Set<String> allListIds = widget.availableLists.map((list) => list['id']!).toSet();
    _checkedIds = widget.currentSettings.isAllListsEnabled
        ? Set<String>.from(allListIds)
        : Set<String>.from(widget.currentSettings.enabledListIds).intersection(allListIds);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadiusTokens.radiusMd,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: _buildListSelection(),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(BorderRadiusTokens.md),
          topRight: Radius.circular(BorderRadiusTokens.md),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.checklist_outlined,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.listSelectionTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSelection() {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: widget.availableLists.length,
      itemBuilder: (context, index) {
        final listData = widget.availableLists[index];
        return _buildListTile(context, listData);
      },
    );
  }

  Widget _buildListTile(BuildContext context, Map<String, String> listData) {
    final listId = listData['id']!;
    final listTitle = listData['title']!;
    final isEnabled = _checkedIds.contains(listId);
    final theme = Theme.of(context);

    return ListTile(
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(
        isEnabled ? Icons.list_alt : Icons.list_alt_outlined,
        color: isEnabled
            ? AppTheme.primaryColor
            : theme.colorScheme.onSurface.withOpacity(0.4),
      ),
      title: Text(
        listTitle,
        style: TextStyle(
          color: isEnabled
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurface.withOpacity(0.6),
          fontWeight: isEnabled ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        isEnabled
            ? AppLocalizations.of(context)!.listSelectionEnabled
            : AppLocalizations.of(context)!.listSelectionDisabled,
        style: TextStyle(
          color: isEnabled
              ? AppTheme.primaryColor.withOpacity(0.7)
              : theme.colorScheme.onSurface.withOpacity(0.4),
          fontSize: 12,
        ),
      ),
      trailing: Checkbox(
        value: isEnabled,
        onChanged: (value) => _toggleList(listId, value ?? false),
        activeColor: AppTheme.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onTap: () => _toggleList(listId, !isEnabled),
    );
  }

  void _toggleList(String listId, bool enable) {
    setState(() {
      if (enable) {
        _checkedIds.add(listId);
      } else {
        _checkedIds.remove(listId);
      }
    });
  }

  Widget _buildActions() {
    final canSave = _checkedIds.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!canSave)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                AppLocalizations.of(context)!.listSelectionRequireOne,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: canSave ? _saveSettings : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(AppLocalizations.of(context)!.save),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    final allListIds = widget.availableLists.map((list) => list['id']!).toSet();
    final ListPrioritizationSettings newSettings;
    if (_checkedIds.containsAll(allListIds)) {
      newSettings = ListPrioritizationSettings.defaultSettings();
    } else {
      newSettings = ListPrioritizationSettings(enabledListIds: Set.from(_checkedIds));
    }
    widget.onSettingsChanged(newSettings);
    Navigator.of(context).pop();
  }
}

/// Fonction helper pour afficher le dialog
Future<void> showListSelectionDialog(
  BuildContext context, {
  required ListPrioritizationSettings currentSettings,
  required List<Map<String, String>> availableLists,
  required void Function(ListPrioritizationSettings) onSettingsChanged,
}) {
  return showDialog(
    context: context,
    builder: (context) => ListSelectionDialog(
      currentSettings: currentSettings,
      availableLists: availableLists,
      onSettingsChanged: onSettingsChanged,
    ),
  );
}
