import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/services/id_generation_service.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/lists/models/task_sort_field.dart';
import 'package:prioris/presentation/pages/lists/widgets/list_detail_header.dart';
import 'package:prioris/presentation/pages/lists/widgets/list_empty_state.dart';
import 'package:prioris/presentation/pages/lists/widgets/list_contextual_fab.dart';
import 'package:prioris/presentation/pages/lists/widgets/list_items_list_view.dart';
import 'package:prioris/presentation/pages/lists/widgets/list_search_bar.dart';
import 'package:prioris/presentation/pages/lists/widgets/list_sort_toolbar.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/domain/services/duplicate_detection_service.dart';
import 'package:prioris/infrastructure/services/import_interrupt_service.dart';
import 'package:prioris/presentation/pages/lists/services/list_detail_item_service.dart';
import 'package:prioris/presentation/pages/lists/services/list_items_sorter.dart';
import 'package:prioris/presentation/widgets/dialogs/bulk_add_dialog.dart';
import 'package:prioris/presentation/widgets/dialogs/duplicate_warning_dialog.dart';

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

class _DuplicateCancelException extends BulkAddCancelException {}

class _ListDetailPageState extends ConsumerState<ListDetailPage> {
  String _searchQuery = '';
  TaskSortField _sortField = TaskSortField.elo;
  bool _isAscending = false;
  late final int _baseRandomSeed;
  late int _randomSeed;
  @override
  void initState() {
    super.initState();
    _baseRandomSeed = ListItemsSorter.normalizeSeed(widget.list.id.hashCode);
    _randomSeed = _baseRandomSeed;
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForPendingImport());
  }

  ListDetailItemService get _itemService => ListDetailItemService(
        context: context,
        ref: ref,
        listId: widget.list.id,
      );

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
    final sortedItems = const ListItemsSorter().sort(
      filteredItems,
      _sortField,
      isAscending: _isAscending,
      randomSeed: _randomSeed,
    );
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
                _randomSeed = _sortField == TaskSortField.random
                    ? ListItemsSorter.reshuffleSeed(_baseRandomSeed)
                    : _baseRandomSeed;
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
            onEdit: _itemService.showRenameItemDialog,
            onDelete: _itemService.confirmDeleteItem,
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

  void _checkForPendingImport() {
    final pending = ImportInterruptService.instance.peekPendingResume(widget.list.id);
    if (pending == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final itemsToResume = pending.pendingItems;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          children: [
            Expanded(
              child: Text(l10n.importResumeBanner(
                  pending.current, pending.total, itemsToResume.length)),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ImportInterruptService.instance.consumePendingResume();
              },
              child: Text(l10n.importResumeIgnore,
                  style: const TextStyle(color: Colors.white70)),
            ),
          ],
        ),
        action: SnackBarAction(
          label: l10n.importResumeConfirm,
          onPressed: () {
            ImportInterruptService.instance.consumePendingResume();
            _showBulkAddDialogWithItems(itemsToResume);
          },
        ),
        duration: const Duration(days: 1),
        backgroundColor: AppTheme.warningColor,
      ));
    });
  }

  Future<void> _showBulkAddDialog() => _openBulkAddDialog();

  Future<void> _showBulkAddDialogWithItems(List<String> items) =>
      _openBulkAddDialog(initialItems: items);

  Future<void> _openBulkAddDialog({List<String>? initialItems}) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    int skippedCount = 0;

    final count = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BulkAddDialog(
        listId: widget.list.id,
        listName: widget.list.name,
        initialItems: initialItems,
        onSubmit: (itemTitles, onProgress) async {
          final stateList = ref.read(listsControllerProvider).findListById(widget.list.id);
          final existing = (stateList != null && stateList.items.isNotEmpty)
              ? stateList.items
              : widget.list.items;
          final result =
              const DuplicateDetectionService().detect(existing, itemTitles);

          var titlesToAdd = itemTitles;

          if (result.hasDuplicates && context.mounted) {
            final choice = await showDialog<DuplicateChoice>(
              context: context,
              builder: (_) => DuplicateWarningDialog(
                duplicateTitles: result.duplicateTitles,
                totalCount: itemTitles.length,
              ),
            );

            if (!context.mounted) throw _DuplicateCancelException();
            if (choice == null || choice == DuplicateChoice.cancel) {
              throw _DuplicateCancelException();
            }
            if (choice == DuplicateChoice.skipDuplicates) {
              skippedCount = result.duplicateTitles.length;
              titlesToAdd = result.uniqueTitles;
            }
            // DuplicateChoice.addAll → titlesToAdd reste inchangé
          }

          if (titlesToAdd.isEmpty) throw _DuplicateCancelException();

          final idService = IdGenerationService();
          final ids = idService.generateBatchIds(titlesToAdd.length);
          final items = titlesToAdd.asMap().entries.map((entry) {
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

          await ref
              .read(listsControllerProvider.notifier)
              .addMultipleItems(widget.list.id, items, onProgress: onProgress);
          onProgress(titlesToAdd.length, titlesToAdd.length);
        },
      ),
    );

    if (count != null && count > 0 && context.mounted) {
      final message = skippedCount > 0
          ? l10n.bulkAddImportSuccessWithSkipped(count, skippedCount)
          : l10n.bulkAddImportSuccess(count);
      messenger.showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
      ));
    }
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

  void _handleItemAction(String action, ListItem item) {
    switch (action) {
      case 'rename':
        _itemService.showRenameItemDialog(item);
        break;
      case 'move':
        _itemService.showMoveItemDialog(item);
        break;
      case 'duplicate':
        _itemService.duplicateItem(item);
        break;
    }
  }
}
