import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import '../widgets/export.dart';

/// Service specialise pour la construction des composants UI du duel - SOLID COMPLIANT
///
/// SOLID COMPLIANCE:
/// - SRP: Responsabilite unique pour la construction des composants visuels
/// - OCP: Extensible via factory methods et builders personnalises
/// - LSP: Compatible avec les interfaces de construction UI
/// - ISP: Interface focalisee sur les operations de UI building uniquement
/// - DIP: Depend des abstractions des widgets specialises
///
/// Features:
/// - Construction modulaire de l'AppBar et ses actions
/// - Creation des composants de duel (cartes, separateur)
/// - Gestion des etats visuels (loading, empty, duel)
/// - Styling coherent avec le theme de l'application
/// - Composants reutilisables et configurables
///
/// CONSTRAINTS: <200 lignes
class DuelUIComponentsBuilder {

  /// Construit l'AppBar du duel avec fond et actions
  PreferredSizeWidget buildAppBar({
    required BuildContext context,
    required bool hideEloScores,
    required VoidCallback onToggleEloVisibility,
    required VoidCallback onShowListSettings,
    required VoidCallback onRefreshDuel,
  }) {
    return AppBar(
      title: const Text('Prioriser'),
      flexibleSpace: _buildAppBarBackground(context),
      actions: _buildAppBarActions(
        context: context,
        hideEloScores: hideEloScores,
        onToggleEloVisibility: onToggleEloVisibility,
        onShowListSettings: onShowListSettings,
        onRefreshDuel: onRefreshDuel,
      ),
    );
  }

  /// Construit le corps principal selon l'etat actuel
  Widget buildBody({
    required BuildContext context,
    required bool isLoading,
    required List<Task>? currentDuel,
    required bool hideEloScores,
    required Function(Task winner, Task loser) onWinnerSelected,
    required Function(Task task) onEditTask,
    required VoidCallback onSkipDuel,
    required VoidCallback onRandomSelection,
  }) {
    if (isLoading) {
      return _buildLoadingState(context);
    }

    if (currentDuel == null || currentDuel.length < 2) {
      return _buildNoTasksState(context);
    }

    return _buildDuelInterface(
      context: context,
      task1: currentDuel[0],
      task2: currentDuel[1],
      hideEloScores: hideEloScores,
      onWinnerSelected: onWinnerSelected,
      onEditTask: onEditTask,
      onSkipDuel: onSkipDuel,
      onRandomSelection: onRandomSelection,
    );
  }

  /// Construit l'etat de chargement
  Widget buildLoadingState(BuildContext context) {
    return _buildLoadingState(context);
  }

  /// Construit l'etat sans taches disponibles
  Widget buildNoTasksState(BuildContext context) {
    return _buildNoTasksState(context);
  }

  /// Construit l'interface de duel complete
  Widget buildDuelInterface({
    required BuildContext context,
    required Task task1,
    required Task task2,
    required bool hideEloScores,
    required Function(Task winner, Task loser) onWinnerSelected,
    required Function(Task task) onEditTask,
    required VoidCallback onSkipDuel,
    required VoidCallback onRandomSelection,
  }) {
    return _buildDuelInterface(
      context: context,
      task1: task1,
      task2: task2,
      hideEloScores: hideEloScores,
      onWinnerSelected: onWinnerSelected,
      onEditTask: onEditTask,
      onSkipDuel: onSkipDuel,
      onRandomSelection: onRandomSelection,
    );
  }

  // === PRIVATE UI BUILDERS ===

  /// Construit le background de l'AppBar avec style premium
  Widget _buildAppBarBackground(BuildContext context) {
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

  /// Construit les actions de l'AppBar
  List<Widget> _buildAppBarActions({
    required BuildContext context,
    required bool hideEloScores,
    required VoidCallback onToggleEloVisibility,
    required VoidCallback onShowListSettings,
    required VoidCallback onRefreshDuel,
  }) {
    return [
      IconButton(
        onPressed: onToggleEloVisibility,
        icon: Icon(hideEloScores ? Icons.visibility : Icons.visibility_off),
        tooltip: hideEloScores ? 'Afficher Elo' : 'Masquer Elo',
      ),
      IconButton(
        onPressed: onShowListSettings,
        icon: const Icon(Icons.tune),
        tooltip: 'Parametres des listes',
      ),
      IconButton(
        onPressed: onRefreshDuel,
        icon: const Icon(Icons.refresh),
        tooltip: 'Nouveau duel',
      ),
    ];
  }

  /// Construit l'etat de chargement avec indicateur centre
  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  /// Construit l'etat sans taches avec icone et message
  Widget _buildNoTasksState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.psychology,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Pas assez de taches',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez au moins 2 taches pour commencer a les prioriser',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Construit l'interface complete de duel
  Widget _buildDuelInterface({
    required BuildContext context,
    required Task task1,
    required Task task2,
    required bool hideEloScores,
    required Function(Task winner, Task loser) onWinnerSelected,
    required Function(Task task) onEditTask,
    required VoidCallback onSkipDuel,
    required VoidCallback onRandomSelection,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // En-tete psychologique
          const DuelHeaderWidget(),
          const SizedBox(height: 32),

          // Zone de duel avec cartes et separateur
          Expanded(
            child: Column(
              children: [
                Expanded(
                  flex: 5,
                  child: DuelTaskCard(
                    task: task1,
                    onTap: () => onWinnerSelected(task1, task2),
                    onEdit: () => onEditTask(task1),
                    hideElo: hideEloScores,
                  ),
                ),
                const VsSeparatorWidget(),
                Expanded(
                  flex: 5,
                  child: DuelTaskCard(
                    task: task2,
                    onTap: () => onWinnerSelected(task2, task1),
                    onEdit: () => onEditTask(task2),
                    hideElo: hideEloScores,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Boutons d'action
          _buildActionButtons(
            context: context,
            onSkipDuel: onSkipDuel,
            onRandomSelection: onRandomSelection,
          ),
        ],
      ),
    );
  }

  /// Construit les boutons d'action (Passer et Aleatoire)
  Widget _buildActionButtons({
    required BuildContext context,
    required VoidCallback onSkipDuel,
    required VoidCallback onRandomSelection,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton.icon(
          onPressed: onSkipDuel,
          icon: const Icon(Icons.skip_next),
          label: const Text('Passer ce duel'),
        ),
        ElevatedButton.icon(
          onPressed: onRandomSelection,
          icon: const Icon(Icons.shuffle),
          label: const Text('Aleatoire'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      ],
    );
  }
}
