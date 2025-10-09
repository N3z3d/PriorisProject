import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/presentation/widgets/dialogs/bulk_add_dialog.dart';
import 'package:prioris/presentation/widgets/buttons/premium_fab.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';
import 'package:prioris/presentation/pages/lists/widgets/list_detail_header.dart';
import 'package:prioris/presentation/pages/lists/widgets/list_search_bar.dart';
import 'package:prioris/presentation/pages/lists/widgets/list_empty_state.dart';
import 'package:prioris/presentation/pages/lists/widgets/list_item_card.dart';

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
    final items = _filterItems(currentList);

    if (items.isEmpty) {
      return ListEmptyState(
        searchQuery: _searchQuery,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListItemCard(
          item: items[index],
          onEdit: () => _showEditItemDialog(items[index]),
          onDelete: () => _confirmDeleteItem(items[index]),
        );
      },
    );
  }

  /// Construit le bouton d'action flottant avec design premium
  Widget _buildFloatingActionButton() {
    final currentList = ref.watch(listByIdProvider(widget.list.id)) ?? widget.list;
    final contextualText = _getContextualButtonText(currentList);
    
    return PremiumFAB(
      heroTag: "list_detail_fab",
      text: "Ajouter des tâches", // Texte par défaut
      contextualText: contextualText, // Texte adapté au contexte
      icon: Icons.add,
      onPressed: _showBulkAddDialog,
      backgroundColor: AppTheme.primaryColor,
      enableAnimations: true,
      enableHaptics: true,
    );
  }

  /// Génère le texte contextuel selon l'état de la liste
  String _getContextualButtonText(CustomList currentList) {
    final itemCount = currentList.items.length;
    final filteredItems = _filterItems(currentList);
    
    // Liste vide
    if (itemCount == 0) {
      return "Créer vos premiers éléments";
    }
    
    // Recherche active avec résultats
    if (_searchQuery.isNotEmpty && filteredItems.isNotEmpty) {
      return "Ajouter à cette recherche";
    }
    
    // Recherche active sans résultats
    if (_searchQuery.isNotEmpty && filteredItems.isEmpty) {
      return "Créer nouvel élément";
    }
    
    // Liste avec peu d'éléments (< 3)
    if (itemCount < 3) {
      return "Ajouter plus d'éléments";
    }
    
    // Liste normale avec plusieurs éléments
    return "Ajouter de nouveaux éléments";
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
          ref.read(listsControllerProvider.notifier)
             .addMultipleItemsToList(widget.list.id, itemTitles);
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

  /// Affiche le dialogue d'édition d'élément
  void _showEditItemDialog(ListItem item) {
    // Pending: Implémenter le dialogue d'édition d'élément
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
    ref.read(listsControllerProvider.notifier)
       .removeItemFromList(widget.list.id, item.id);
  }


}