import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/presentation/widgets/dialogs/dialogs.dart';
import 'package:prioris/presentation/widgets/dialogs/bulk_add_dialog.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/glassmorphism.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';
import 'package:prioris/presentation/pages/lists/widgets/list_detail_header.dart';
import 'package:prioris/presentation/pages/lists/widgets/list_search_bar.dart';
import 'package:prioris/presentation/pages/lists/widgets/list_empty_state.dart';
import 'package:prioris/presentation/pages/lists/widgets/list_item_card.dart';

/// Page de détail d'une liste personnalisée
/// 
/// Cette page affiche les éléments d'une liste spécifique avec des fonctionnalités
/// de gestion CRUD, tri, filtrage et progression visuelle.
class ListDetailPage extends ConsumerStatefulWidget {
  /// La liste à afficher
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

  @override
  Widget build(BuildContext context) {
    // Écouter les changements de la liste spécifique
    final currentList = ref.watch(listByIdProvider(widget.list.id));
    
    // Si la liste n'existe plus, revenir en arrière
    if (currentList == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(currentList),
      body: _buildBody(currentList),
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
      surfaceTintColor: Colors.transparent,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: AppTheme.textSecondary),
          onPressed: () => _showEditListDialog(currentList),
          tooltip: 'Modifier la liste',
        ),
      ],
    );
  }

  // Supprimé: la méthode _buildAppBarBackground n'est plus nécessaire

  /// Construit le corps de la page
  Widget _buildBody(CustomList currentList) {
    return CustomScrollView(
      slivers: [
        _buildHeader(currentList),
        _buildSearchBar(),
        _buildItemsList(currentList),
      ],
    );
  }

  /// Construit le header avec statistiques
  Widget _buildHeader(CustomList currentList) {
    return SliverToBoxAdapter(
      child: ListDetailHeader(list: currentList),
    );
  }

  /// Construit la barre de recherche
  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: ListSearchBar(
        searchQuery: _searchQuery,
        onSearchChanged: (query) {
          setState(() {
            _searchQuery = query;
          });
        },
      ),
    );
  }

  /// Construit la liste des éléments
  Widget _buildItemsList(CustomList currentList) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildItemsListDelegate(context, index, currentList),
          childCount: _getItemsListChildCount(currentList),
        ),
      ),
    );
  }

  /// Délégué pour construire les éléments de la liste
  Widget? _buildItemsListDelegate(BuildContext context, int index, CustomList currentList) {
    final items = _filterAndSortItems(currentList);
    
    if (items.isEmpty) {
      return ListEmptyState(searchQuery: _searchQuery);
    }
    
    if (index >= items.length) return null;
    
    return _buildItemCard(items[index]);
  }

  /// Construit une carte d'élément
  Widget _buildItemCard(ListItem item) {
    return ListItemCard(
      item: item,
      onToggleCompletion: () => _toggleItemCompletion(item),
      onEdit: () => _showEditItemDialog(item),
      onDelete: () => _showDeleteItemDialog(item),
    );
  }

  /// Calcule le nombre d'enfants pour la liste
  int _getItemsListChildCount(CustomList currentList) {
    final items = _filterAndSortItems(currentList);
    return items.isEmpty ? 1 : items.length;
  }

  /// Construit le bouton d'action flottant avec design glassmorphisme
  Widget _buildFloatingActionButton() {
    return Glassmorphism.glassFAB(
      heroTag: "list_detail_fab",
      onPressed: _showBulkAddDialog,
      backgroundColor: AppTheme.primaryColor,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Ajouter',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Filtre et trie les éléments selon les critères sélectionnés
  List<ListItem> _filterAndSortItems(CustomList currentList) {
    final filteredItems = _filterItems(currentList);
    return _sortItems(filteredItems);
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
    final matchesTitle = item.title.toLowerCase().contains(query);
    final matchesDescription = item.description?.toLowerCase().contains(query) ?? false;
    final matchesCategory = item.category?.toLowerCase().contains(query) ?? false;
    
    return matchesTitle || matchesDescription || matchesCategory;
  }

  /// Trie les éléments par ELO
  List<ListItem> _sortItems(List<ListItem> items) {
    items.sort((a, b) => b.eloScore.compareTo(a.eloScore));
    return items;
  }

  /// Affiche le dialogue d'ajout en masse d'éléments
  void _showBulkAddDialog() {
    showDialog(
      context: context,
      builder: (context) => BulkAddDialog(
        title: 'Ajouter à "${widget.list.name}"',
        hintText: 'Titre de l\'élément...',
        onSubmit: (items) async {
          await _handleAddMultipleItems(items);
        },
      ),
    );
  }

  /// Gère l'ajout d'un nouvel élément
  Future<void> _handleAddItem(ListItem newItem) async {
    await _performItemAction(
      () => ref.read(listsControllerProvider.notifier).addItemToList(widget.list.id, newItem),
      '${newItem.title} ajouté à la liste',
    );
  }

  /// Gère l'ajout de plusieurs éléments
  Future<void> _handleAddMultipleItems(List<String> itemTitles) async {
    if (itemTitles.isEmpty) return;
    
    await _performItemAction(
      () => ref.read(listsControllerProvider.notifier).addMultipleItemsToList(widget.list.id, itemTitles),
      itemTitles.length == 1 
        ? '${itemTitles.first} ajouté à la liste'
        : '${itemTitles.length} éléments ajoutés à la liste',
    );
  }

  /// Affiche le dialogue d'édition d'élément
  void _showEditItemDialog(ListItem item) {
    showDialog(
      context: context,
      builder: (context) => ListItemFormDialog(
        initialItem: item,
        listId: widget.list.id,
        onSubmit: (updatedItem) async {
          await _handleEditItem(updatedItem);
        },
      ),
    );
  }

  /// Gère la modification d'un élément
  Future<void> _handleEditItem(ListItem updatedItem) async {
    await _performItemAction(
      () => ref.read(listsControllerProvider.notifier).updateListItem(widget.list.id, updatedItem),
      '${updatedItem.title} modifié avec succès',
    );
  }

  /// Affiche le dialogue de suppression d'élément
  void _showDeleteItemDialog(ListItem item) {
    showDialog(
      context: context,
      builder: (context) => _buildDeleteDialog(item),
    );
  }

  /// Construit le dialogue de suppression
  Widget _buildDeleteDialog(ListItem item) {
    return AlertDialog(
      title: const Text('Supprimer l\'élément'),
      content: Text('Êtes-vous sûr de vouloir supprimer "${item.title}" ?'),
      actions: _buildDeleteDialogActions(item),
    );
  }

  /// Construit les actions du dialogue de suppression
  List<Widget> _buildDeleteDialogActions(ListItem item) {
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Annuler'),
      ),
      TextButton(
        onPressed: () => _confirmDeleteItem(item),
        style: TextButton.styleFrom(
          foregroundColor: Colors.red,
        ),
        child: const Text('Supprimer'),
      ),
    ];
  }

  /// Confirme la suppression d'un élément
  void _confirmDeleteItem(ListItem item) {
    Navigator.of(context).pop();
    _handleDeleteItem(item);
  }

  /// Gère la suppression d'un élément
  Future<void> _handleDeleteItem(ListItem item) async {
    await _performItemAction(
      () => ref.read(listsControllerProvider.notifier).removeItemFromList(widget.list.id, item.id),
      '${item.title} supprimé de la liste',
    );
  }

  /// Affiche le dialogue d'édition de liste
  void _showEditListDialog(CustomList currentList) {
    showDialog(
      context: context,
      builder: (context) => ListFormDialog(
        initialList: currentList,
        onSubmit: (updatedList) async {
          await _handleEditList(updatedList);
        },
      ),
    );
  }

  /// Gère la modification de la liste
  Future<void> _handleEditList(CustomList updatedList) async {
    await _performItemAction(
      () => ref.read(listsControllerProvider.notifier).updateList(updatedList),
      'Liste "${updatedList.name}" modifiée avec succès',
    );
  }

  /// Bascule l'état de complétion d'un élément
  void _toggleItemCompletion(ListItem item) {
    final updatedItem = _createToggledItem(item);
    _handleItemCompletionToggle(updatedItem);
  }

  /// Crée un élément avec l'état de complétion basculé
  ListItem _createToggledItem(ListItem item) {
    return item.copyWith(
      isCompleted: !item.isCompleted,
      completedAt: !item.isCompleted ? DateTime.now() : null,
    );
  }

  /// Gère le basculement de l'état de complétion
  Future<void> _handleItemCompletionToggle(ListItem updatedItem) async {
    await _performItemAction(
      () => ref.read(listsControllerProvider.notifier).updateListItem(widget.list.id, updatedItem),
      updatedItem.isCompleted 
        ? '${updatedItem.title} marqué comme terminé'
        : '${updatedItem.title} marqué comme non terminé',
    );
  }

  /// Exécute une action sur un élément avec gestion d'erreur
  Future<void> _performItemAction(Future<void> Function() action, String successMessage) async {
    try {
      await action();
      _showSuccessMessage(successMessage);
    } catch (e) {
      _showErrorMessage('Erreur: $e');
    }
  }

  /// Affiche un message de succès
  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Affiche un message d'erreur
  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
} 