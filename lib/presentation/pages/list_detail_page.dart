import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/services/id_generation_service.dart';
import 'package:prioris/domain/services/text/text_normalization_service.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/lists/models/task_sort_field.dart';
import 'package:prioris/presentation/pages/lists/widgets/list_detail_header.dart';
import 'package:prioris/presentation/pages/lists/widgets/list_empty_state.dart';
import 'package:prioris/presentation/pages/lists/widgets/list_contextual_fab.dart';
import 'package:prioris/presentation/pages/lists/widgets/list_items_list_view.dart';
import 'package:prioris/presentation/pages/lists/widgets/list_search_bar.dart';
import 'package:prioris/presentation/pages/lists/widgets/list_sort_toolbar.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/dialogs/bulk_add_dialog.dart';
import 'package:uuid/uuid.dart';

/// Page de dÃ©tail d'une liste personnalisÃ©e
///
/// Affiche les Ã©lÃ©ments d'une liste avec la possibilitÃ© de:
/// - Ajouter de nouveaux Ã©lÃ©ments
/// - Modifier/supprimer des Ã©lÃ©ments existants
/// - Rechercher dans les Ã©lÃ©ments
/// - Trier les Ã©lÃ©ments
class ListDetailPage extends ConsumerStatefulWidget {
  final CustomList list;
  const ListDetailPage({
    super.key,
    required this.list,
  });
  @override
  ConsumerState<ListDetailPage> createState() => _ListDetailPageState();
}

class _ListDetailPageState extends ConsumerState<ListDetailPage> {
  String _searchQuery = '';
  TaskSortField _sortField = TaskSortField.elo;
  bool _isAscending = false;
  late final int _baseRandomSeed;
  late int _randomSeed;
  @override
  void initState() {
    super.initState();
    _baseRandomSeed = _normalizeSeed(widget.list.id.hashCode);
    _randomSeed = _baseRandomSeed;
  }

  @override
  Widget build(BuildContext context) {
    // ARCHITECTURE FIX: Utiliser directement le provider stable
    // Les repositories sont prÃ©-initialisÃ©s donc pas de risque de null
    final listsState = ref.watch(listsControllerProvider);
    final currentList = listsState.findListById(widget.list.id);
    // ARCHITECTURE FIX: Utiliser la liste de l'Ã©tat ou celle passÃ©e en paramÃ¨tre
    // Mais ne PAS dÃ©clencher de rechargement qui causait les pertes de donnÃ©es
    final effectiveList = currentList ?? widget.list;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(effectiveList),
      body: _buildBody(effectiveList),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Construit l'AppBar
  PreferredSizeWidget _buildAppBar(CustomList currentList) {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      title: Text(
        currentList.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
      backgroundColor: AppTheme.surfaceColor,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: AppTheme.textPrimary),
          onPressed: () => _showEditListDialog(currentList),
          tooltip: l10n?.listEditTooltip ?? 'Modifier la liste',
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: AppTheme.textSecondary),
          onPressed: () => _showDeleteConfirmation(currentList),
          tooltip: l10n?.listDeleteTooltip ?? 'Supprimer la liste',
        ),
      ],
    );
  }

  /// Construit le corps de la page
  Widget _buildBody(CustomList currentList) {
    return Column(
      children: [
        // Header avec statistiques
        ListDetailHeader(list: currentList),
        // Barre de recherche
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListSearchBar(
            searchQuery: _searchQuery,
            onSearchChanged: _updateSearchQuery,
          ),
        ),
        // Liste des Ã©lÃ©ments
        Expanded(
          child: _buildItemsList(currentList),
        ),
      ],
    );
  }

  /// Construit la liste des Ã©lÃ©ments
  Widget _buildItemsList(CustomList currentList) {
    final filteredItems = _filterItems(currentList);
    final syncingItems = ref.watch(
      listsControllerProvider.select((state) => state.syncingItemIds),
    );
    if (filteredItems.isEmpty) {
      return ListEmptyState(
        searchQuery: _searchQuery,
      );
    }
    final sortedItems = _applySorting(filteredItems);
    return Column(
      children: [
        ListSortToolbar(
          sortField: _sortField,
          isAscending: _isAscending,
          itemCount: sortedItems.length,
          onSortChanged: (field) {
            setState(() {
              // FIX: When selecting random, shuffle immediately
              // When re-selecting random (already selected), reshuffle
              if (field == TaskSortField.random) {
                if (_sortField == TaskSortField.random) {
                  // Already random: reshuffle
                  _reshuffleRandomSeed();
                } else {
                  // First time selecting random: reset to base seed
                  _resetRandomSeed();
                }
              }
              _sortField = field;
              if (field == TaskSortField.elo) {
                _isAscending = false;
              }
            });
          },
          onToggleAscending: () {
            setState(() {
              _isAscending = !_isAscending;
            });
          },
        ),
        Expanded(
          child: ListItemsListView(
            items: sortedItems,
            syncingItems: syncingItems,
            onEdit: _showRenameItemDialog,
            onDelete: _confirmDeleteItem,
            onToggleCompletion: _toggleItemCompletion,
            onMenuAction: _handleItemAction,
          ),
        ),
      ],
    );
  }

  /// Construit le bouton d'action flottant avec design premium
  Widget _buildFloatingActionButton() {
    final currentList =
        ref.watch(listByIdProvider(widget.list.id)) ?? widget.list;
    final filteredItems = _filterItems(currentList);
    final l10n = AppLocalizations.of(context);
    return ListContextualFab(
      list: currentList,
      baseLabel: l10n?.bulkAddDefaultTitle ?? 'Ajouter des éléments',
      searchQuery: _searchQuery,
      filteredItems: filteredItems,
      onPressed: _showBulkAddDialog,
    );
  }

  /// Filtre les Ã©lÃ©ments selon la requÃªte de recherche
  List<ListItem> _filterItems(CustomList currentList) {
    return currentList.items.where((item) {
      return _itemMatchesSearch(item);
    }).toList();
  }

  /// VÃ©rifie si un Ã©lÃ©ment correspond Ã  la recherche
  bool _itemMatchesSearch(ListItem item) {
    if (_searchQuery.isEmpty) return true;
    final query = _searchQuery.toLowerCase();
    return _checkSearchMatches(item, query);
  }

  /// VÃ©rifie les correspondances de recherche
  bool _checkSearchMatches(ListItem item, String query) {
    return item.title.toLowerCase().contains(query) ||
        item.description?.toLowerCase().contains(query) == true;
  }

  /// Met Ã  jour la requÃªte de recherche
  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  /// Affiche le dialogue d'ajout en lot
  void _showBulkAddDialog() {
    showDialog(
      context: context,
      builder: (context) => BulkAddDialog(
        onSubmit: (itemTitles) {
          // Generate unique IDs using centralized service
          final idService = IdGenerationService();
          final ids = idService.generateBatchIds(itemTitles.length);
          final items = itemTitles.asMap().entries.map((entry) {
            final index = entry.key;
            final title = entry.value;
            final createdAt = DateTime.now().add(Duration(microseconds: index));
            return ListItem(
              id: ids[index],
              title: title,
              listId: widget.list.id,
              isCompleted: false,
              createdAt: createdAt,
            );
          }).toList();
          ref
              .read(listsControllerProvider.notifier)
              .addMultipleItemsToList(widget.list.id, items);
        },
      ),
    );
  }

  /// Affiche le dialogue d'Ã©dition de liste
  void _showEditListDialog(CustomList list) {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: list.name);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.listEditDialogTitle ?? 'Modifier la liste'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n?.listEditNameLabel ?? 'Nom de la liste',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n?.cancel ?? 'Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty || newName == list.name) {
                Navigator.of(context).pop();
                return;
              }
              final updated =
                  list.copyWith(name: newName, updatedAt: DateTime.now());
              await ref
                  .read(listsControllerProvider.notifier)
                  .updateList(updated);
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n?.listEditSaved ?? 'Liste mise Ã  jour.',
                    ),
                  ),
                );
              }
            },
            child: Text(l10n?.save ?? 'Enregistrer'),
          ),
        ],
      ),
    );
  }

  /// Affiche la confirmation de suppression de liste
  void _showDeleteConfirmation(CustomList list) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.listDeleteDialogTitle ?? 'Supprimer la liste'),
        content: Text(
          l10n?.listDeleteDialogMessage(list.name) ??
              'Êtes-vous sûr de vouloir supprimer "${list.name}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n?.cancel ?? 'Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteList(list);
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

  /// Supprime la liste
  void _deleteList(CustomList list) {
    ref.read(listsControllerProvider.notifier).deleteList(list.id);
    Navigator.of(context).pop(); // Retour Ã  la page prÃ©cÃ©dente
  }

  /// Confirme la suppression d'un Ã©lÃ©ment
  void _confirmDeleteItem(ListItem item) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(l10n?.listConfirmDeleteItemTitle ?? 'Supprimer l\'Ã©lÃ©ment'),
        content: Text(
          l10n?.listConfirmDeleteItemMessage(item.title) ??
              'ÃŠtes-vous sÃ»r de vouloir supprimer "${item.title}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n?.cancel ?? 'Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
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

  /// Supprime un ?l?ment
  /// Supprime un Ã©lÃ©ment
  void _deleteItem(ListItem item) {
    ref
        .read(listsControllerProvider.notifier)
        .removeItemFromList(widget.list.id, item.id);
  }

  Future<void> _toggleItemCompletion(ListItem item) async {
    final updatedItem = item.isCompleted
        ? item.copyWith(
            isCompleted: false,
            forceCompletedAtNull: true,
          )
        : item.copyWith(
            isCompleted: true,
            completedAt: DateTime.now(),
          );
    await ref
        .read(listsControllerProvider.notifier)
        .updateListItem(widget.list.id, updatedItem);
  }

  List<ListItem> _applySorting(List<ListItem> items) {
    final sorted = [...items];
    switch (_sortField) {
      case TaskSortField.elo:
        sorted.sort((a, b) => _isAscending
            ? a.eloScore.compareTo(b.eloScore)
            : b.eloScore.compareTo(a.eloScore));
        break;
      case TaskSortField.name:
        // FIX: Use TextNormalizationService for accent-insensitive sorting
        const normalizer = TextNormalizationService();
        sorted.sort((a, b) {
          final comparison =
              normalizer.compareIgnoringAccents(a.title, b.title);
          return _isAscending ? comparison : -comparison;
        });
        break;
      case TaskSortField.random:
        final random = Random(_randomSeed);
        for (var i = sorted.length - 1; i > 0; i--) {
          final j = random.nextInt(i + 1);
          final tmp = sorted[i];
          sorted[i] = sorted[j];
          sorted[j] = tmp;
        }
        break;
    }
    return sorted;
  }

  void _handleItemAction(String action, ListItem item) {
    switch (action) {
      case 'rename':
        _showRenameItemDialog(item);
        break;
      case 'move':
        _showMoveItemDialog(item);
        break;
      case 'duplicate':
        _duplicateItem(item);
        break;
    }
  }

  int _normalizeSeed(int rawSeed) {
    final normalized = rawSeed & 0x7fffffff;
    return normalized == 0 ? 1 : normalized;
  }

  void _resetRandomSeed() {
    _randomSeed = _baseRandomSeed;
  }

  void _reshuffleRandomSeed() {
    final salt = DateTime.now().microsecondsSinceEpoch & 0x7fffffff;
    _randomSeed = _normalizeSeed(_baseRandomSeed ^ salt);
  }

  Future<void> _showRenameItemDialog(ListItem item) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: item.title);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n?.cancel ?? "Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(l10n?.save ?? "Enregistrer"),
          ),
        ],
      ),
    );
    if (result == null || result.isEmpty || result == item.title) return;
    final updated = item.copyWith(title: result);
    await ref
        .read(listsControllerProvider.notifier)
        .updateListItem(widget.list.id, updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.listRenameSaved ?? "Élément renommé."),
        ),
      );
    }
  }

  Future<void> _showMoveItemDialog(ListItem item) async {
    final l10n = AppLocalizations.of(context);
    final listsState = ref.read(listsControllerProvider);
    final available =
        listsState.lists.where((list) => list.id != widget.list.id).toList();
    if (available.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.listMoveNoOtherList ?? "Aucune autre liste disponible",
          ),
        ),
      );
      return;
    }
    String targetId = available.first.id;
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.listMoveDialogTitle ?? "Déplacer l'élément"),
        content: DropdownButtonFormField<String>(
          value: targetId,
          decoration: InputDecoration(
            labelText: l10n?.listMoveDialogLabel ?? "Liste de destination",
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
            if (value != null) {
              targetId = value;
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n?.cancel ?? "Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(targetId),
            child: Text(l10n?.move ?? "Déplacer"),
          ),
        ],
      ),
    );
    if (selected == null || selected == widget.list.id) return;
    final controller = ref.read(listsControllerProvider.notifier);
    final updated = item.copyWith(listId: selected, forceCompletedAtNull: true);
    await controller.removeListItem(widget.list.id, item.id);
    await controller.addListItem(selected, updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.listMoveSaved ?? "Élément déplacé."),
        ),
      );
    }
  }

  Future<void> _duplicateItem(ListItem item) async {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(listsControllerProvider.notifier);
    final duplicated = item.copyWith(
      id: const Uuid().v4(),
      title: "${item.title} (copie)",
      isCompleted: false,
      forceCompletedAtNull: true,
    );
    await controller.addListItem(widget.list.id, duplicated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.listDuplicateSaved ?? "Élément dupliqué."),
        ),
      );
    }
  }
}
