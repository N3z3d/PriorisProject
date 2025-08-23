import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/providers/prioritization_providers.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/dialogs/list_selection_dialog.dart';
import 'package:prioris/presentation/widgets/dialogs/task_edit_dialog.dart';
import 'package:prioris/domain/core/value_objects/list_prioritization_settings.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';
import 'duel/widgets/export.dart';

// Provider pour masquer/afficher les scores ELO
final hideEloScoresProvider = StateProvider<bool>((ref) => false);

// Provider pour les paramètres de priorisation des listes
final listPrioritizationSettingsProvider = StateProvider<ListPrioritizationSettings>((ref) => 
    ListPrioritizationSettings.defaultSettings());

class DuelPage extends ConsumerStatefulWidget {
  const DuelPage({super.key});

  @override
  ConsumerState<DuelPage> createState() => _DuelPageState();
}

class _DuelPageState extends ConsumerState<DuelPage> 
    with AutomaticKeepAliveClientMixin {
  List<Task>? _currentDuel;
  bool _isLoading = false;
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Déplacer l'accès aux providers après l'initialisation complète
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeData();
      }
    });
  }

  /// Initialise les données nécessaires pour la priorisation
  Future<void> _initializeData() async {
    try {
      print('🔍 DEBUG: Initialisation des données pour priorisation');
      
      // CORRECTION: Attendre explicitement que les listes soient chargées
      await ref.read(listsControllerProvider.notifier).loadLists();
      
      // Vérifier que les listes sont bien chargées
      final listsState = ref.read(listsControllerProvider);
      print('🔍 DEBUG: Après chargement explicite - ${listsState.lists.length} listes');
      
      // Attendre un délai pour s'assurer que l'état est propagé
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Ensuite charger le duel avec les listes disponibles
      await _loadNewDuel();
    } catch (e) {
      print('🔍 DEBUG: Erreur lors de l\'initialisation: $e');
      // En cas d'erreur, charger quand même le duel avec les Tasks classiques
      await _loadNewDuel();
    }
  }

  // Suppression de didChangeDependencies qui causait des rechargements en boucle

  @override
  Widget build(BuildContext context) {
    super.build(context); // Nécessaire pour AutomaticKeepAliveClientMixin
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// Construit l'AppBar avec actions
  PreferredSizeWidget _buildAppBar() {
    final hideElo = ref.watch(hideEloScoresProvider);
    
    return AppBar(
      title: const Text('Prioriser'),
      flexibleSpace: _buildAppBarBackground(),
      actions: _buildAppBarActions(hideElo),
    );
  }

  /// Construit le background de l'AppBar
  Widget _buildAppBarBackground() {
    return Container(
      decoration: BoxDecoration(
        // Remplacé par un fond uni professionnel avec une légère ombre
        color: AppTheme.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  /// Construit les actions de l'AppBar
  List<Widget> _buildAppBarActions(bool hideElo) {
    return [
      IconButton(
        onPressed: () {
          ref.read(hideEloScoresProvider.notifier).state = !hideElo;
        },
        icon: Icon(hideElo ? Icons.visibility : Icons.visibility_off),
        tooltip: hideElo ? 'Afficher les scores ELO' : 'Masquer les scores ELO',
      ),
      IconButton(
        onPressed: _showListSelectionDialog,
        icon: const Icon(Icons.tune),
        tooltip: 'Paramètres des listes',
      ),
      IconButton(
        onPressed: _loadNewDuel,
        icon: const Icon(Icons.refresh),
        tooltip: 'Nouveau duel',
      ),
    ];
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentDuel == null || _currentDuel!.length < 2) {
      return _buildNoTasksState();
    }

    return _buildDuelInterface();
  }

  Widget _buildNoTasksState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNoTasksIcon(),
          const SizedBox(height: 16),
          _buildNoTasksTitle(),
          const SizedBox(height: 8),
          _buildNoTasksSubtitle(),
        ],
      ),
    );
  }

  /// Construit l'icône pour l'état sans tâches
  Widget _buildNoTasksIcon() {
    return Icon(
      Icons.psychology,
      size: 80,
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
    );
  }

  /// Construit le titre pour l'état sans tâches
  Widget _buildNoTasksTitle() {
    return Text(
      'Pas assez de tâches',
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }

  /// Construit le sous-titre pour l'état sans tâches
  Widget _buildNoTasksSubtitle() {
    return Text(
      'Ajoutez au moins 2 tâches pour commencer à les prioriser',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDuelInterface() {
    final task1 = _currentDuel![0];
    final task2 = _currentDuel![1];
    final hideElo = ref.watch(hideEloScoresProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPsychologyHeader(),
          const SizedBox(height: 32),
          _buildDuelCards(task1, task2, hideElo),
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  /// Construit l'en-tête psychologique explicatif du duel
  Widget _buildPsychologyHeader() {
    return const DuelHeaderWidget();
  }

  /// Construit la zone de duel avec les deux cartes de tâches et le séparateur VS
  Widget _buildDuelCards(Task task1, Task task2, bool hideElo) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: DuelTaskCard(
              task: task1,
              onTap: () => _selectWinner(task1, task2),
              onEdit: () => _showEditTaskDialog(task1),
              hideElo: hideElo,
            ),
          ),
          const VsSeparatorWidget(),
          Expanded(
            flex: 5,
            child: DuelTaskCard(
              task: task2,
              onTap: () => _selectWinner(task2, task1),
              onEdit: () => _showEditTaskDialog(task2),
              hideElo: hideElo,
            ),
          ),
        ],
      ),
    );
  }

  /// Construit le bouton pour passer le duel actuel
  /// Construit les boutons d'action (Passer et Aléatoire)
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton.icon(
          onPressed: _loadNewDuel,
          icon: const Icon(Icons.skip_next),
          label: const Text('Passer ce duel'),
        ),
        ElevatedButton.icon(
          onPressed: _selectRandomTask,
          icon: const Icon(Icons.shuffle),
          label: const Text('Aléatoire'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      ],
    );
  }

  /// Affiche le dialogue d'édition de tâche
  void _showEditTaskDialog(Task task) {
    showDialog(
      context: context,
      builder: (context) => TaskEditDialog(
        initialTask: task,
        onSubmit: (updatedTask) async {
          await _handleTaskUpdate(updatedTask);
        },
      ),
    );
  }

  /// Gère la mise à jour d'une tâche
  Future<void> _handleTaskUpdate(Task updatedTask) async {
    try {
      final taskRepository = ref.read(taskRepositoryProvider);
      await taskRepository.updateTask(updatedTask);
      
      // Invalider les caches
      ref.invalidate(tasksSortedByEloProvider);
      ref.invalidate(allPrioritizationTasksProvider);
      
      // Recharger le duel avec les données mises à jour
      await _loadNewDuel();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tâche "${updatedTask.title}" mise à jour avec succès'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Charge un nouveau duel en utilisant le service unifié
  Future<void> _loadNewDuel() async {
    // Éviter les rechargements multiples simultanés
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      print('🔍 DEBUG: Début de _loadNewDuel');
      
      // Utiliser le nouveau service unifié de priorisation
      final unifiedService = ref.read(unifiedPrioritizationServiceProvider);
      final allTasks = await unifiedService.getTasksForPrioritization();
      print('🔍 DEBUG: Tasks classiques trouvées: ${allTasks.length}');
      
      // Vérifier s'il y a aussi des ListItems à inclure
      final listsState = ref.read(listsControllerProvider);
      print('🔍 DEBUG: Listes disponibles: ${listsState.lists.length}');
      
      if (listsState.lists.isNotEmpty) {
        // Combiner les Task avec les ListItem convertis
        final allListItems = listsState.lists.expand((list) => list.items).toList();
        print('🔍 DEBUG: Items de liste trouvés: ${allListItems.length}');
        
        final listItemTasks = unifiedService.getListItemsAsTasks(allListItems);
        print('🔍 DEBUG: Items convertis en tasks: ${listItemTasks.length}');
        
        // Fusionner toutes les tâches
        allTasks.addAll(listItemTasks);
      }
      
      final incompleteTasks = allTasks.where((task) => !task.isCompleted).toList();
      print('🔍 DEBUG: Total tasks: ${allTasks.length}, Incomplètes: ${incompleteTasks.length}');
      
      // CORRECTION: Limiter le nombre de tâches pour éviter la surcharge
      const maxTasksForPrioritization = 50;
      List<Task> tasksForDuel = incompleteTasks;
      
      if (incompleteTasks.length > maxTasksForPrioritization) {
        print('🔍 DEBUG: Limitation à $maxTasksForPrioritization tâches pour les performances');
        tasksForDuel = incompleteTasks.take(maxTasksForPrioritization).toList();
      }
      
      if (tasksForDuel.length >= 2) {
        tasksForDuel.shuffle();
        _currentDuel = tasksForDuel.take(2).toList();
      } else {
        _currentDuel = null;
      }
    } catch (e) {
      _currentDuel = null;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Sélectionne une tâche aléatoire (mode aléatoire)
  Future<void> _selectRandomTask() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Utiliser le service unifié pour la sélection aléatoire
      final unifiedService = ref.read(unifiedPrioritizationServiceProvider);
      final allTasks = await unifiedService.getTasksForPrioritization();
      
      // Ajouter les ListItems convertis
      final listsState = ref.read(listsControllerProvider);
      if (listsState.lists.isNotEmpty) {
        final allListItems = listsState.lists.expand((list) => list.items).toList();
        final listItemTasks = unifiedService.getListItemsAsTasks(allListItems);
        allTasks.addAll(listItemTasks);
      }
      
      final incompleteTasks = allTasks.where((task) => !task.isCompleted).toList();
      
      if (incompleteTasks.isNotEmpty) {
        // Sélection aléatoire simple
        final random = DateTime.now().millisecondsSinceEpoch;
        final selectedIndex = random % incompleteTasks.length;
        final selectedTask = incompleteTasks[selectedIndex];
        
        // Afficher la tâche sélectionnée
        _showRandomTaskSelected(selectedTask);
      } else {
        _currentDuel = null;
      }
    } catch (e) {
      _currentDuel = null;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Affiche le dialog de sélection des listes
  Future<void> _showListSelectionDialog() async {
    final currentSettings = ref.read(listPrioritizationSettingsProvider);
    
    // Récupérer les vraies listes depuis le ListsController avec watch pour la réactivité
    final listsState = ref.read(listsControllerProvider);
    
    // S'assurer que les listes sont chargées
    if (listsState.lists.isEmpty && !listsState.isLoading) {
      // Afficher un indicateur de chargement pendant le chargement des listes
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
                SizedBox(width: 16),
                Text('Chargement des listes...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      await ref.read(listsControllerProvider.notifier).loadLists();
    }
    
    final updatedListsState = ref.read(listsControllerProvider);
    
    // Gestion des erreurs de chargement
    if (updatedListsState.error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des listes: ${updatedListsState.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    
    // Vérifier s'il y a des listes disponibles
    if (updatedListsState.lists.isEmpty) {
      _showNoListsDialog();
      return;
    }
    
    // Transformer les CustomList en format attendu par le dialog
    final availableLists = updatedListsState.lists.map((customList) => {
      'id': customList.id,
      'title': customList.name,
    }).toList();

    if (mounted) {
      await showListSelectionDialog(
        context,
        currentSettings: currentSettings,
        availableLists: availableLists,
        onSettingsChanged: (newSettings) {
          ref.read(listPrioritizationSettingsProvider.notifier).state = newSettings;
          // TODO: Sauvegarder en base de données
          _loadNewDuel(); // Recharger le duel avec les nouvelles préférences
        },
      );
    }
  }

  /// Affiche la tâche sélectionnée aléatoirement
  void _showRandomTaskSelected(Task task) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🎲 Tâche sélectionnée aléatoirement :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(task.title),
              if (task.description != null) ...[
                const SizedBox(height: 2),
                Text(
                  task.description!,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ],
          ),
          backgroundColor: Theme.of(context).primaryColor,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Terminer',
            textColor: Colors.white,
            onPressed: () {
              // TODO: Marquer la tâche comme terminée
            },
          ),
        ),
      );
    }
  }

  /// Affiche un dialog informatif quand aucune liste n'est disponible
  void _showNoListsDialog() {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: Icon(
            Icons.list_alt_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text('Aucune liste disponible'),
          content: const Text(
            'Vous devez d\'abord créer des listes pour pouvoir les sélectionner dans le mode priorisation.\n\n'
            'Rendez-vous dans l\'onglet "Listes" pour créer votre première liste.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigation vers l'onglet des listes
                // Utiliser DefaultTabController ou le contrôleur de navigation approprié
                // Pour l'instant, on affiche juste un message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Naviguez vers l\'onglet "Listes" pour créer vos listes'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              child: const Text('Aller aux listes'),
            ),
          ],
        ),
      );
    }
  }

  /// Sélectionne le gagnant d'un duel en utilisant le service unifié
  void _selectWinner(Task winner, Task loser) async {
    setState(() => _isLoading = true);
    
    try {
      // Utiliser le service unifié pour mettre à jour les scores ELO
      final unifiedService = ref.read(unifiedPrioritizationServiceProvider);
      final duelResult = await unifiedService.updateEloScoresFromDuel(winner, loser);
      
      // Invalider les caches pour rafraîchir les autres pages
      ref.invalidate(tasksSortedByEloProvider);
      ref.invalidate(allPrioritizationTasksProvider);
      
      // Afficher le résultat
      if (mounted) {
        _showDuelResult(duelResult.winner, duelResult.loser);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    // Charger un nouveau duel après un délai
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _loadNewDuel();
      }
    });
  }

  void _showDuelResult(Task winner, Task loser) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '"${winner.title}" prioritaire sur "${loser.title}"',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.secondaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }
} 