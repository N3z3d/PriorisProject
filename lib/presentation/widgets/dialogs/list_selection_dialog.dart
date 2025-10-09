import 'package:flutter/material.dart';
import 'package:prioris/domain/core/value_objects/list_prioritization_settings.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Dialog pour sélectionner quelles listes participent au mode prioriser
/// 
/// Permet aux utilisateurs d'activer/désactiver des listes entières
/// (ex: désactiver une liste de courses qui ne nécessite pas de priorisation)
class ListSelectionDialog extends StatefulWidget {
  /// Paramètres actuels de priorisation
  final ListPrioritizationSettings currentSettings;
  
  /// Listes disponibles sous forme [{'id': String, 'title': String}]
  final List<Map<String, String>> availableLists;
  
  /// Callback appelé quand les paramètres changent
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
  late ListPrioritizationSettings _workingSettings;

  @override
  void initState() {
    super.initState();
    
    // Si on est en mode "toutes activées", on initialise avec toutes les listes
    if (widget.currentSettings.isAllListsEnabled) {
      final allListIds = widget.availableLists.map((list) => list['id']!).toList();
      _workingSettings = ListPrioritizationSettings.withAllLists(allListIds);
    } else {
      _workingSettings = widget.currentSettings;
    }
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
              'Sélectionner les listes à prioriser',
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
    final isEnabled = _workingSettings.isListEnabled(listId);
    final theme = Theme.of(context);

    return ListTile(
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
        isEnabled ? 'Participera aux duels' : 'Exclue des duels',
        style: TextStyle(
          color: isEnabled
              ? AppTheme.primaryColor.withOpacity(0.7)
              : theme.colorScheme.onSurface.withOpacity(0.4),
          fontSize: 12,
        ),
      ),
      trailing: Switch(
        value: isEnabled,
        onChanged: (value) => _toggleList(listId, value),
        activeColor: AppTheme.primaryColor,
      ),
      onTap: () => _toggleList(listId, !isEnabled),
    );
  }

  void _toggleList(String listId, bool enable) {
    setState(() {
      final allListIds = widget.availableLists.map((list) => list['id']!).toList();
      _workingSettings = enable
          ? _workingSettings.enableList(listId)
          : _workingSettings.disableListWithContext(listId, allListIds);
    });
  }

  Widget _buildActions() {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    widget.onSettingsChanged(_workingSettings);
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