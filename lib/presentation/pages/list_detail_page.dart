import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/services/id_generation_service.dart';
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

/// Page de détail d'une liste personnalisée
///
/// Affiche les éléments d'une liste avec la possibilité de:
/// - Ajouter de nouveaux éléments
/// - Modifier/supprimer des éléments existants
/// - Rechercher dans les éléments
/// - Trier les éléments
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
    // Les repositories sont pré-initialisés donc pas de risque de null
    final listsState = ref.watch(listsControllerProvider);
    final currentList = listsState.findListById(widget.list.id);

    // ARCHITECTURE FIX: Utiliser la liste de l'état ou celle passée en paramètre
    // Mais ne PAS déclencher de rechargement qui causait les pertes de données
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
          tooltip: 'Modifier la liste',
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: AppTheme.textSecondary),
          onPressed: () => _showDeleteConfirmation(currentList),
          tooltip: 'Supprimer la liste',
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

        // Liste des éléments
        Expanded(
          child: _buildItemsList(currentList),
        ),
      ],
    );
  }

  /// Construit la liste des éléments
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
              _sortField = field;
              if (field == TaskSortField.elo) {
                _isAscending = false;
              } else if (field == TaskSortField.random) {
                _resetRandomSeed();
              }
            });
          },
          onToggleAscending: () {
            setState(() {
              _isAscending = !_isAscending;
            });
          },
          onShuffleRequested: () => setState(_reshuffleRandomSeed),
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

    return ListContextualFab(
      list: currentList,
      baseLabel: "Ajouter des tâches",
      searchQuery: _searchQuery,
      filteredItems: filteredItems,
      onPressed: _showBulkAddDialog,
    );
  }

  /// Filtre les éléments selon la requête de recherche
  List<ListItem> _filterItems(CustomList currentList) {
    return currentList.items.where((item) {
      return _itemMatchesSearch(item);
    }).toList();
  }

  /// Vérifie si un élément correspond à la recherche
  bool _itemMatchesSearch(ListItem item) {
    if (_searchQuery.isEmpty) return true;

    final query = _searchQuery.toLowerCase();
    return _checkSearchMatches(item, query);
  }

  /// Vérifie les correspondances de recherche
  bool _checkSearchMatches(ListItem item, String query) {
    return item.title.toLowerCase().contains(query) ||
        item.description?.toLowerCase().contains(query) == true;
  }

  /// Met à jour la requête de recherche
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

  /// Affiche le dialogue d'édition de liste
  void _showEditListDialog(CustomList list) {
    // Pending: Implémenter le dialogue d'édition de liste
  }

  /// Affiche la confirmation de suppression de liste
  void _showDeleteConfirmation(CustomList list) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la liste'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${list.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteList(list);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Supprime la liste
  void _deleteList(CustomList list) {
    ref.read(listsControllerProvider.notifier).deleteList(list.id);
    Navigator.of(context).pop(); // Retour à la page précédente
  }

  /// Confirme la suppression d'un élément
  void _confirmDeleteItem(ListItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'élément'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${item.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteItem(item);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Supprime un élément
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
        sorted.sort((a, b) => _isAscending
            ? a.title.toLowerCase().compareTo(b.title.toLowerCase())
            : b.title.toLowerCase().compareTo(a.title.toLowerCase()));
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
    final controller = TextEditingController(text: item.title);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renommer la tâche'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nom de la tâche',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Enregistrer'),
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
        const SnackBar(content: Text('Tâche renommée ✅')),
      );
    }
  }

  Future<void> _showMoveItemDialog(ListItem item) async {
    final listsState = ref.read(listsControllerProvider);
    final available =
        listsState.lists.where((list) => list.id != widget.list.id).toList();

    if (available.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune autre liste disponible')),
      );
      return;
    }

    String targetId = available.first.id;
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déplacer la tâche'),
        content: DropdownButtonFormField<String>(
          value: targetId,
          decoration: const InputDecoration(
            labelText: 'Liste de destination',
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
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(targetId),
            child: const Text('Déplacer'),
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
        const SnackBar(content: Text('Tâche déplacée ✅')),
      );
    }
  }

  Future<void> _duplicateItem(ListItem item) async {
    final controller = ref.read(listsControllerProvider.notifier);
    final duplicated = item.copyWith(
      id: const Uuid().v4(),
      title: '${item.title} (copie)',
      isCompleted: false,
      forceCompletedAtNull: true,
    );
    await controller.addListItem(widget.list.id, duplicated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tâche dupliquée ✅')),
      );
    }
  }
}

