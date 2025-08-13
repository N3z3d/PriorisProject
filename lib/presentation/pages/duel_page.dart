import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import '../../data/repositories/task_repository.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'duel/widgets/export.dart';

// Provider pour masquer/afficher les scores ELO
final hideEloScoresProvider = StateProvider<bool>((ref) => false);

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
        _loadNewDuel();
      }
    });
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
          _buildSkipButton(),
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
              hideElo: hideElo,
            ),
          ),
          const VsSeparatorWidget(),
          Expanded(
            flex: 5,
            child: DuelTaskCard(
              task: task2,
              onTap: () => _selectWinner(task2, task1),
              hideElo: hideElo,
            ),
          ),
        ],
      ),
    );
  }

  /// Construit le bouton pour passer le duel actuel
  Widget _buildSkipButton() {
    return TextButton.icon(
      onPressed: _loadNewDuel,
      icon: const Icon(Icons.skip_next),
      label: const Text('Passer ce duel'),
    );
  }

  Future<void> _loadNewDuel() async {
    // Éviter les rechargements multiples simultanés
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      final allTasks = await ref.read(tasksSortedByEloProvider.future);
      final incompleteTasks = allTasks.where((task) => !task.isCompleted).toList();
      
      if (incompleteTasks.length >= 2) {
        incompleteTasks.shuffle();
        _currentDuel = incompleteTasks.take(2).toList();
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

  void _selectWinner(Task winner, Task loser) async {
    setState(() => _isLoading = true);
    
    final repository = ref.read(taskRepositoryProvider);
    await repository.updateEloScores(winner, loser);
    
    // Invalider le cache pour rafraîchir les autres pages
    ref.invalidate(tasksSortedByEloProvider);
    
    // Afficher le résultat
    if (mounted) {
      _showDuelResult(winner, loser);
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

