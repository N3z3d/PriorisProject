import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/widgets/common/forms/common_button.dart';
import 'package:prioris/presentation/widgets/common/layouts/common_loading_state.dart';
import 'package:prioris/presentation/widgets/common/lists/virtualized_list.dart';
import 'package:prioris/presentation/widgets/dialogs/dialogs.dart';
import 'package:prioris/presentation/widgets/dialogs/quick_add_dialog.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/domain/models/core/builders/custom_list_builder.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/common/displays/daily_overview_widget.dart';

/// Page principale pour la gestion des listes personnalisées
/// 
/// Cette page affiche toutes les listes de l'utilisateur avec une interface
/// simple et épurée similaire à la page des tâches.
class ListsPage extends ConsumerStatefulWidget {
  const ListsPage({super.key});

  @override
  ConsumerState<ListsPage> createState() => _ListsPageState();
}

class _ListsPageState extends ConsumerState<ListsPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    // Charger les listes au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(listsControllerProvider.notifier).loadLists();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listsState = ref.watch(listsControllerProvider);
    final isLoading = ref.watch(listsLoadingProvider);
    final error = ref.watch(listsErrorProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Mes Listes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 1,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppTheme.dividerColor,
      ),
      body: isLoading
          ? const CommonLoadingState(message: 'Chargement des listes...')
          : error != null
              ? _buildErrorState(error)
              : Column(
                  children: [
                    const DailyOverviewWidget(),
                    Expanded(child: _buildListsContent(listsState)),
                  ],
                ),
      floatingActionButton: Semantics(
        label: 'Créer une nouvelle liste',
        button: true,
        child: FloatingActionButton(
          heroTag: "lists_fab",
          onPressed: _showCreateListDialog,
          backgroundColor: AppTheme.primaryColor,
          tooltip: 'Créer une nouvelle liste',
          child: const Icon(Icons.add, color: Colors.white, semanticLabel: 'Ajouter'),
        ),
      ),
    );
  }

  /// Construit l'état d'erreur
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Erreur',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.red[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          CommonButton(
            text: 'Réessayer',
            icon: Icons.refresh,
            onPressed: () => ref.read(listsControllerProvider.notifier).loadLists(),
          ),
        ],
      ),
    );
  }

  /// Construit le contenu principal des listes
  Widget _buildListsContent(ListsState state) {
    final filteredLists = state.filteredLists;

    if (filteredLists.isEmpty) {
      return _buildEmptyState();
    }

    return VirtualizedList<CustomList>(
      items: filteredLists,
      padding: const EdgeInsets.all(16),
      itemExtent: 120.0, // Hauteur fixe pour optimiser le scrolling
      cacheExtent: 500, // Cache étendu pour une meilleure fluidité
      itemBuilder: (context, list, index) {
        return _buildListCard(list);
      },
      emptyWidget: _buildEmptyState(),
    );
  }

  /// Construit l'état vide
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.list_alt_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Aucune liste',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez votre première liste pour commencer',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          CommonButton(
            text: 'Ajouter une liste',
            icon: Icons.add,
            onPressed: _showCreateListDialog,
          ),
        ],
      ),
    );
  }

  /// Construit une carte de liste simplifiée
  Widget _buildListCard(CustomList list) {
    final progress = _calculateProgress(list);
    final completedCount = list.getCompletedItems().length;
    final totalCount = list.items.length;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusTokens.modal),
      child: Container(
        decoration: BoxDecoration(
          // Fond professionnel au lieu du gradient
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadiusTokens.modal,
          border: Border.all(
            color: AppTheme.dividerColor.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
        child: GestureDetector(
          onTap: () => _navigateToListDetail(list),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: progress == 1.0 
                  ? Colors.green 
                  : _getColorForType(list.type),
              child: Icon(
                _getIconForType(list.type),
                color: Colors.white,
              ),
            ),
            title: Text(
              list.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (list.description?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      list.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildTypeChip(list.type),
                    const SizedBox(width: 8),
                    _buildProgressChip(completedCount, totalCount),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleListAction(value, list),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Modifier'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Supprimer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construit un chip pour le type de liste
  Widget _buildTypeChip(ListType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColorForType(type).withValues(alpha: 0.1),
        borderRadius: BorderRadiusTokens.card,
      ),
      child: Text(
        type.displayName,
        style: TextStyle(
          fontSize: 12,
          color: _getColorForType(type),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Construit un chip pour la progression
  Widget _buildProgressChip(int completed, int total) {
    final progress = total > 0 ? completed / total : 0.0;
    Color color;
    if (progress == 1.0) {
      color = Colors.green;
    } else if (progress >= 0.5) {
      color = Colors.orange;
    } else {
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadiusTokens.card,
      ),
      child: Text(
        '$completed/$total',
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Calcule la progression d'une liste
  double _calculateProgress(CustomList list) {
    if (list.items.isEmpty) return 0.0;
    final completedCount = list.items.where((item) => item.isCompleted).length;
    return completedCount / list.items.length;
  }

  /// Gère les actions de la liste (modifier, supprimer)
  void _handleListAction(String action, CustomList list) {
    if (action == 'edit') {
      _editList(list);
    } else if (action == 'delete') {
      _deleteList(list);
    }
  }

  /// Retourne l'icône pour un type de liste
  IconData _getIconForType(ListType type) {
    switch (type) {
      case ListType.TRAVEL:
        return Icons.flight;
      case ListType.SHOPPING:
        return Icons.shopping_cart;
      case ListType.MOVIES:
        return Icons.movie;
      case ListType.BOOKS:
        return Icons.book;
      case ListType.RESTAURANTS:
        return Icons.restaurant;
      case ListType.PROJECTS:
        return Icons.work;
      case ListType.CUSTOM:
        return Icons.list;
    }
  }

  /// Retourne la couleur pour un type de liste
  Color _getColorForType(ListType type) {
    switch (type) {
      case ListType.TRAVEL:
        return AppTheme.accentColor;
      case ListType.SHOPPING:
        return AppTheme.successColor;
      case ListType.MOVIES:
        return AppTheme.secondaryColor;
      case ListType.BOOKS:
        return AppTheme.infoColor;
      case ListType.RESTAURANTS:
        return AppTheme.warningColor;
      case ListType.PROJECTS:
        return AppTheme.primaryColor;
      case ListType.CUSTOM:
        return AppTheme.textSecondary;
    }
  }



  /// Affiche le dialogue de création rapide de liste
  void _showCreateListDialog() {
    showDialog(
      context: context,
      builder: (context) => QuickAddDialog(
        title: 'Nouvelle Liste',
        hintText: 'Nom de la liste...',
        onSubmit: (title) async {
          final messenger = ScaffoldMessenger.of(context);
          try {
            // Création rapide avec titre uniquement
            final newList = CustomListBuilder()
              .withName(title)
              .withDescription('')
              .withType(ListType.CUSTOM)
              .withItems([])
              .build();
            
            await ref.read(listsControllerProvider.notifier).createList(newList);
            if (context.mounted) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text('Liste "$title" créée avec succès !'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text('Erreur lors de la création : $e'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            }
          }
        },
      ),
    );
  }

  /// Navigue vers la page de détail d'une liste
  void _navigateToListDetail(CustomList list) {
    Navigator.of(context).pushNamed(
      '/list-detail',
      arguments: {'list': list},
    );
  }

  /// Édite une liste
  void _editList(CustomList list) {
    showDialog(
      context: context,
      builder: (context) => CustomListFormDialog(
        initialList: list,
        onSubmit: (updatedList) async {
          final navigator = Navigator.of(context);
          final messenger = ScaffoldMessenger.of(context);
          try {
            await ref.read(listsControllerProvider.notifier).updateList(updatedList);
            if (context.mounted) {
              navigator.pop();
              messenger.showSnackBar(
                SnackBar(
                  content: Text('Liste "${updatedList.name}" modifiée avec succès !'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text('Erreur lors de la modification : $e'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            }
          }
        },
      ),
    );
  }

  /// Supprime une liste
  void _deleteList(CustomList list) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la liste'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${list.name}" ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final messenger = ScaffoldMessenger.of(context);
              try {
                await ref.read(listsControllerProvider.notifier).deleteList(list.id);
                if (context.mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Liste "${list.name}" supprimée avec succès !'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la suppression : $e'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }


} 
