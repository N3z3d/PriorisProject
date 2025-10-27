import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/list_prioritization_settings_provider.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';
import 'package:prioris/domain/core/value_objects/duel_settings.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/duel/controllers/duel_controller.dart';
import 'package:prioris/presentation/pages/duel/widgets/priority_duel_view.dart';
import 'package:prioris/presentation/pages/lists/models/lists_state.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/dialogs/list_selection_dialog.dart';

class DuelPage extends ConsumerStatefulWidget {
  const DuelPage({super.key});

  @override
  ConsumerState<DuelPage> createState() => _DuelPageState();
}

class _DuelPageState extends ConsumerState<DuelPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

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

    final duelState = ref.watch(duelControllerProvider);
    final listsState = ref.watch(listsControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.subtleBackgroundColor,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        child: _buildStateView(
          duelState: duelState,
          listsState: listsState,
        ),
      ),
    );
  }

  Widget _buildStateView({
    required DuelState duelState,
    required ListsState listsState,
  }) {
    if (duelState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (duelState.errorMessage != null) {
      return _DuelErrorView(
        message: _l10n.duelErrorMessage,
        technicalDetails: duelState.errorMessage!,
      );
    }

    final duel = duelState.currentDuel;
    if (duel == null || duel.length < 2) {
      return _DuelEmptyView(
        title: _l10n.duelNotEnoughTasksTitle,
        message: _l10n.duelNotEnoughTasksMessage,
      );
    }

    return PriorityDuelView(
      tasks: duel,
      hideEloScores: duelState.hideEloScores,
      mode: duelState.settings.mode,
      cardsPerRound: duelState.settings.cardsPerRound,
      onSelectTask: _selectWinner,
      onSubmitRanking: _submitRanking,
      onSkip: _skipDuel,
      onRandom: _selectRandomTask,
      onToggleElo: _toggleEloVisibility,
      onRefresh: _loadNewDuel,
      onConfigureLists: _openListSelectionDialog,
      onModeChanged: _changeMode,
      onCardsPerRoundChanged: _changeCardsPerRound,
      hasAvailableLists: listsState.lists.isNotEmpty,
      remainingDuelsToday: null,
    );
  }

  Future<void> _skipDuel() async {
    await _loadNewDuel();
  }

  Future<void> _loadNewDuel() {
    return ref.read(duelControllerProvider.notifier).loadNewDuel();
  }

  Future<void> _toggleEloVisibility() {
    return ref.read(duelControllerProvider.notifier).toggleEloVisibility();
  }

  Future<void> _selectRandomTask() {
    return ref.read(duelControllerProvider.notifier).selectRandomTask();
  }

  Future<void> _selectWinner(Task winner, Task loser) async {
    await ref.read(duelControllerProvider.notifier).selectWinner(winner, loser);

    if (!mounted) return;
    _showToast(_l10n.duelPreferenceSaved);
  }

  Future<void> _submitRanking(List<Task> orderedTasks) async {
    await ref.read(duelControllerProvider.notifier).submitRanking(orderedTasks);
    if (!mounted) return;
    _showToast('Classement enregistré');
  }

  Future<void> _changeMode(DuelMode mode) {
    return ref.read(duelControllerProvider.notifier).updateMode(mode);
  }

  Future<void> _changeCardsPerRound(int cards) {
    return ref.read(duelControllerProvider.notifier).updateCardsPerRound(cards);
  }

  Future<void> _openListSelectionDialog() async {
    final listsState = ref.read(listsControllerProvider);

    if (listsState.lists.isEmpty) {
      if (!mounted) return;
      _showToast(_l10n.duelNoAvailableListsForPrioritization);
      return;
    }

    final currentSettings = ref.read(listPrioritizationSettingsProvider);
    final notifier = ref.read(listPrioritizationSettingsProvider.notifier);

    final availableLists = listsState.lists
        .map((list) => {
              'id': list.id,
              'title': list.name,
            })
        .toList();

    await showListSelectionDialog(
      context,
      currentSettings: currentSettings,
      availableLists: availableLists,
      onSettingsChanged: (updatedSettings) async {
        await notifier.update(updatedSettings);
        if (mounted) {
          _showToast(_l10n.duelListsUpdated);
        }
      },
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1600),
      ),
    );
  }
}

class _DuelErrorView extends StatelessWidget {
  final String message;
  final String technicalDetails;

  const _DuelErrorView({
    required this.message,
    required this.technicalDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 72,
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              technicalDetails,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary.withValues(alpha: 0.8),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DuelEmptyView extends StatelessWidget {
  final String title;
  final String message;

  const _DuelEmptyView({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.psychology_alt_outlined,
              size: 72,
              color: AppTheme.primaryColor.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
