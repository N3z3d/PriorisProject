import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/dialogs/task_edit_dialog.dart';
import 'package:prioris/presentation/pages/home_page.dart';
import 'duel/controllers/duel_controller.dart';
import 'duel/widgets/export.dart';

/// Page Duel refactorisée appliquant MVVM et SRP
///
/// Responsabilité unique: Composer l'interface utilisateur
/// La logique métier est déléguée au DuelController
class DuelPage extends ConsumerStatefulWidget {
  const DuelPage({super.key});

  @override
  ConsumerState<DuelPage> createState() => _DuelPageState();
}

class _DuelPageState extends ConsumerState<DuelPage>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(duelControllerProvider.notifier).initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final state = ref.watch(duelControllerProvider);

    return Scaffold(
      appBar: _buildAppBar(state),
      body: _buildBody(state),
    );
  }

  /// Construit l'AppBar avec actions
  PreferredSizeWidget _buildAppBar(DuelState state) {
    return AppBar(
      title: const Text('Comparaison'),
      flexibleSpace: _buildAppBarBackground(),
      actions: [
        _buildEloVisibilityToggle(state),
        _buildSettingsButton(),
        _buildRefreshButton(),
      ],
    );
  }

  /// Background de l'AppBar
  Widget _buildAppBarBackground() {
    return Container(
      decoration: BoxDecoration(
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

  /// Bouton toggle visibilité ELO
  Widget _buildEloVisibilityToggle(DuelState state) {
    return IconButton(
      onPressed: () {
        ref.read(duelControllerProvider.notifier).toggleEloVisibility();
      },
      icon: Icon(state.hideEloScores ? Icons.visibility : Icons.visibility_off),
      tooltip: state.hideEloScores ? 'Afficher les scores ELO' : 'Masquer les scores ELO',
    );
  }

  /// Bouton paramètres (futur)
  Widget _buildSettingsButton() {
    return IconButton(
      onPressed: () {
        // Pending: Implémenter le dialogue de sélection de listes
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paramètres à venir')),
        );
      },
      icon: const Icon(Icons.tune),
      tooltip: 'Paramètres des listes',
    );
  }

  /// Bouton rafraîchir
  Widget _buildRefreshButton() {
    return IconButton(
      onPressed: () {
        ref.read(duelControllerProvider.notifier).loadNewDuel();
      },
      icon: const Icon(Icons.refresh),
      tooltip: 'Nouveau duel',
    );
  }

  /// Construit le corps de la page
  Widget _buildBody(DuelState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return _buildErrorState(state.errorMessage!);
    }

    if (state.currentDuel == null || state.currentDuel!.length < 2) {
      return _buildNoTasksState();
    }

    return _buildDuelInterface(state);
  }

  /// État d'erreur
  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(duelControllerProvider.notifier).loadNewDuel();
            },
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  /// État sans tâches - Onboarding informatif
  Widget _buildNoTasksState() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Vous avez besoin d\'au moins 2 tâches actives',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Choisissez une liste et sélectionnez 2 tâches ou plus pour lancer une comparaison.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to Lists page (index 0)
                  ref.read(currentPageProvider.notifier).state = 0;
                },
                icon: const Icon(Icons.add_task),
                label: const Text('Ajouter des tâches'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                // Navigate to Lists page to create new task
                ref.read(currentPageProvider.notifier).state = 0;
              },
              icon: const Icon(Icons.edit_note, size: 20),
              label: const Text('Créer une nouvelle tâche'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Interface du duel
  Widget _buildDuelInterface(DuelState state) {
    final task1 = state.currentDuel![0];
    final task2 = state.currentDuel![1];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDuelHeader(),
          const SizedBox(height: 32),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  flex: 5,
                  child: DuelTaskCard(
                    task: task1,
                    onTap: () => _selectWinner(task1, task2),
                    onEdit: () => _showEditTaskDialog(task1),
                    hideElo: state.hideEloScores,
                  ),
                ),
                _buildVsSeparator(),
                Expanded(
                  flex: 5,
                  child: DuelTaskCard(
                    task: task2,
                    onTap: () => _selectWinner(task2, task1),
                    onEdit: () => _showEditTaskDialog(task2),
                    hideElo: state.hideEloScores,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButtons(state),
        ],
      ),
    );
  }

  /// Boutons d'action
  Widget _buildActionButtons(DuelState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton.icon(
          onPressed: () {
            ref.read(duelControllerProvider.notifier).loadNewDuel();
          },
          icon: const Icon(Icons.skip_next),
          label: const Text('Passer ce duel'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            ref.read(duelControllerProvider.notifier).selectRandomTask();
          },
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

  /// Sélectionne le gagnant
  Future<void> _selectWinner(Task task1, Task task2) async {
    await ref.read(duelControllerProvider.notifier).selectWinner(task1, task2);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ "${task1.title}" priorisée'),
          backgroundColor: Colors.green,
          duration: const Duration(milliseconds: 1500),
        ),
      );
    }
  }

  /// Affiche le dialogue d'édition de tâche
  void _showEditTaskDialog(Task task) {
    showDialog(
      context: context,
      builder: (context) => TaskEditDialog(
        initialTask: task,
        onSubmit: (updatedTask) async {
          await ref.read(duelControllerProvider.notifier).updateTask(updatedTask);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Tâche "${updatedTask.title}" mise à jour'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }

  /// Construit le header du duel
  Widget _buildDuelHeader() {
    return const Column(
      children: [
        Icon(Icons.sports_mma, size: 48, color: Colors.blue),
        SizedBox(height: 8),
        Text(
          'Duel de Priorités',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          'Choisissez la tâche la plus importante',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  /// Construit le séparateur VS
  Widget _buildVsSeparator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Divider(color: Colors.grey[300])),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'VS',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey[300])),
        ],
      ),
    );
  }
}
