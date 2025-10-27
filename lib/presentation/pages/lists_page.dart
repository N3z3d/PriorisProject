import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/presentation/widgets/common/layouts/common_loading_state.dart';
import 'package:prioris/presentation/widgets/common/lists/virtualized_list.dart';
import 'package:prioris/presentation/pages/lists/models/lists_state.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/pages/lists/widgets/lists_error_state.dart';
import 'package:prioris/presentation/pages/lists/widgets/lists_no_data_state.dart';
import 'package:prioris/presentation/pages/lists/widgets/simple_list_card.dart';
import 'package:prioris/presentation/pages/lists/services/lists_dialog_service.dart';
import 'package:prioris/presentation/pages/lists/widgets/lists_overview_banner.dart';

/// Page principale pour la gestion des listes personnalisées
///
/// **Responsabilité** : Composer l'interface et coordonner les interactions
/// **SRP Compliant** : Se concentre sur la composition, délègue les détails
/// **MVVM Pattern** : Utilise le controller pour la logique métier
class ListsPage extends ConsumerStatefulWidget {
  const ListsPage({super.key});

  @override
  ConsumerState<ListsPage> createState() => _ListsPageState();
}

class _ListsPageState extends ConsumerState<ListsPage>
    with SingleTickerProviderStateMixin {
  late ListsDialogService _dialogService;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dialogService = ListsDialogService(context: context, ref: ref);
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Initialise le chargement des données
  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(listsControllerProvider.notifier);
      final currentState = ref.read(listsControllerProvider);

      if (currentState.lists.isEmpty && !currentState.isLoading) {
        controller.forceReloadFromPersistence();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final listsState = ref.watch(listsControllerProvider);
    final isLoading = ref.watch(listsLoadingProvider);
    final error = ref.watch(listsErrorProvider);

    return Scaffold(
      backgroundColor: AppTheme.subtleBackgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(isLoading, error, listsState),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Construit l'AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
    );
  }

  /// Construit le corps de la page
  Widget _buildBody(bool isLoading, String? error, ListsState state) {
    if (isLoading) {
      return const CommonLoadingState(message: 'Chargement des listes...');
    }

    if (error != null) {
      return ListsErrorState(
        errorMessage: error,
        onRetry: () => ref.read(listsControllerProvider.notifier).loadLists(),
      );
    }

    return Column(
      children: [
        ListsOverviewBanner(
          totalLists: state.totalListsCount,
          totalItems: state.totalItemsCount,
        ),
        Expanded(child: _buildListsContent(state)),
      ],
    );
  }

  /// Construit le bouton d'action flottant
  Widget _buildFloatingActionButton() {
    return Semantics(
      label: 'Créer une nouvelle liste',
      button: true,
      child: FloatingActionButton(
        heroTag: "lists_fab",
        onPressed: () => _dialogService.showCreateListDialog(),
        backgroundColor: AppTheme.primaryColor,
        tooltip: 'Créer une nouvelle liste',
        child: const Icon(
          Icons.add,
          color: Colors.white,
          semanticLabel: 'Ajouter',
        ),
      ),
    );
  }

  /// Construit le contenu principal des listes
  Widget _buildListsContent(ListsState state) {
    final filteredLists = state.filteredLists;

    if (filteredLists.isEmpty) {
      return ListsNoDataState(
        onCreateList: () => _dialogService.showCreateListDialog(),
      );
    }

    return VirtualizedList<CustomList>(
      items: filteredLists,
      padding: const EdgeInsets.all(16),
      itemExtent: 120.0,
      cacheExtent: 500,
      itemBuilder: (context, list, index) => _buildListCard(list),
      emptyWidget: ListsNoDataState(
        onCreateList: () => _dialogService.showCreateListDialog(),
      ),
    );
  }

  /// Construit une carte de liste simplifiée
  Widget _buildListCard(CustomList list) {
    return SimpleListCard(
      list: list,
      onTap: () => _navigateToListDetail(list),
      onAction: (action) => _handleListAction(action, list),
    );
  }

  /// Gère les actions de la liste (modifier, supprimer)
  void _handleListAction(String action, CustomList list) {
    switch (action) {
      case 'edit':
        _dialogService.showEditListDialog(list);
        break;
      case 'delete':
        _dialogService.showDeleteConfirmationDialog(list);
        break;
    }
  }

  /// Navigue vers la page de détail d'une liste
  void _navigateToListDetail(CustomList list) {
    Navigator.of(context).pushNamed(
      '/list-detail',
      arguments: {'list': list},
    );
  }
} 
