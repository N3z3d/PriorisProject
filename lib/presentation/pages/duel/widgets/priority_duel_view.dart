import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:prioris/domain/core/value_objects/duel_settings.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/duel/widgets/components/priority_duel_action_bar.dart';
import 'package:prioris/presentation/pages/duel/widgets/components/priority_duel_arena.dart';
import 'package:prioris/presentation/pages/duel/widgets/components/priority_duel_instruction.dart';
import 'package:prioris/presentation/pages/duel/widgets/components/priority_duel_settings_bar.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/common/headers/unified_page_header.dart';

/// New priority duel experience with centred grid and action bar.
class PriorityDuelView extends StatefulWidget {
  final List<Task> tasks;
  final bool hideEloScores;
  final DuelMode mode;
  final int cardsPerRound;
  final Future<void> Function(Task winner, Task loser) onSelectTask;
  final Future<void> Function(List<Task> orderedTasks) onSubmitRanking;
  final Future<void> Function() onSkip;
  final Future<void> Function() onRandom;
  final Future<void> Function() onToggleElo;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onConfigureLists;
  final ValueChanged<DuelMode> onModeChanged;
  final ValueChanged<int> onCardsPerRoundChanged;
  final bool hasAvailableLists;
  final int? remainingDuelsToday;

  const PriorityDuelView({
    super.key,
    required this.tasks,
    required this.hideEloScores,
    required this.mode,
    required this.cardsPerRound,
    required this.onSelectTask,
    required this.onSubmitRanking,
    required this.onSkip,
    required this.onRandom,
    required this.onToggleElo,
    required this.onRefresh,
    required this.onConfigureLists,
    required this.onModeChanged,
    required this.onCardsPerRoundChanged,
    required this.hasAvailableLists,
    this.remainingDuelsToday,
  }) : assert(
            tasks.length >= 2, 'PriorityDuelView requires at least two tasks');

  @override
  State<PriorityDuelView> createState() => _PriorityDuelViewState();
}

class _PriorityDuelViewState extends State<PriorityDuelView> {
  late List<Task> _rankingOrder;

  @override
  void initState() {
    super.initState();
    _rankingOrder = List<Task>.from(widget.tasks);
  }

  @override
  void didUpdateWidget(PriorityDuelView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mode != oldWidget.mode ||
        !_haveSameTaskIds(widget.tasks, oldWidget.tasks)) {
      _rankingOrder = List<Task>.from(widget.tasks);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localized = AppLocalizations.of(context)!;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPageHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final content = _buildMainContent(localized);
                  if (!_shouldEnableScroll(constraints)) {
                    return content;
                  }
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: SizedBox(
                        height: math.max(
                          constraints.maxHeight,
                          _minimumContentHeight(),
                        ),
                        child: content,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader() {
    final localized = AppLocalizations.of(context)!;
    final modeLabel = widget.mode == DuelMode.winner
        ? localized.duelModeWinner
        : localized.duelModeRanking;
    final subtitle =
        localized.duelModeSummary(modeLabel, widget.cardsPerRound);

    return UnifiedPageHeader(
      icon: Icons.psychology,
      title: 'Duel',
      subtitle: subtitle,
      iconColor: AppTheme.accentColor,
      actions: [
        IconButton(
          onPressed: () => widget.onToggleElo(),
          tooltip:
              widget.hideEloScores ? localized.duelShowElo : localized.duelHideElo,
          icon: Icon(
            widget.hideEloScores
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            size: 22,
          ),
        ),
        IconButton(
          onPressed: () => widget.onSkip(),
          tooltip: localized.duelSkipAction,
          icon: const Icon(Icons.refresh_rounded, size: 20),
        ),
        IconButton(
          onPressed: () => widget.onRandom(),
          tooltip: localized.duelRandomAction,
          icon: const Icon(Icons.casino_rounded, size: 20),
        ),
        IconButton(
          onPressed: widget.hasAvailableLists ? () => widget.onConfigureLists() : null,
          tooltip: widget.hasAvailableLists
              ? localized.duelConfigureLists
              : localized.duelNoAvailableLists,
          icon: const Icon(Icons.tune_rounded, size: 22),
        ),
      ],
    );
  }

  Widget _buildSettingsBar() {
    return PriorityDuelSettingsBar(
      mode: widget.mode,
      cardsPerRound: widget.cardsPerRound,
      disableCardSelector: false, // Always enabled per spec
      onModeChanged: widget.onModeChanged,
      onCardsChanged: widget.onCardsPerRoundChanged,
    );
  }

  Column _buildMainContent(AppLocalizations localized) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSettingsBar(),
        const SizedBox(height: 16),
        PriorityDuelInstruction(mode: widget.mode),
        const SizedBox(height: 20),
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: _buildArena(),
          ),
        ),
        const SizedBox(height: 20),
        _buildActionBar(),
        const SizedBox(height: 8),
        if (widget.remainingDuelsToday != null)
          _buildRemainingDuels(localized),
      ],
    );
  }

  bool _shouldEnableScroll(BoxConstraints constraints) {
    if (constraints.maxHeight.isInfinite || constraints.maxWidth.isInfinite) {
      return true;
    }
    final hasDenseLayout =
        widget.mode == DuelMode.ranking || widget.tasks.length >= 3;
    final requiredWidth = hasDenseLayout ? 980.0 : 760.0;
    final requiredHeight = _minimumContentHeight();

    if (constraints.maxWidth < requiredWidth) {
      return true;
    }
    if (constraints.maxHeight < requiredHeight) {
      return true;
    }
    return false;
  }

  double _minimumContentHeight() {
    final hasDenseLayout =
        widget.mode == DuelMode.ranking || widget.tasks.length >= 3;
    return hasDenseLayout ? 820.0 : 720.0;
  }

  Widget _buildArena() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 940),
        child: PriorityDuelArena(
          mode: widget.mode,
          tasks: widget.mode == DuelMode.ranking ? _rankingOrder : widget.tasks,
          hideEloScores: widget.hideEloScores,
          onSelectTask: widget.onSelectTask,
          onReorderRanking: _handleRankingReorder,
        ),
      ),
    );
  }

  Widget _buildActionBar() {
    return PriorityDuelActionBar(
      mode: widget.mode,
      onSubmitRanking: () => widget.onSubmitRanking(_rankingOrder),
    );
  }

  Widget _buildRemainingDuels(AppLocalizations localized) {
    return Text(
      localized.duelRemainingDuels(widget.remainingDuelsToday!),
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary.withValues(alpha: 0.8),
            height: 1.4,
          ),
    );
  }

  void _handleRankingReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final task = _rankingOrder.removeAt(oldIndex);
      _rankingOrder.insert(newIndex, task);
    });
  }
}

bool _haveSameTaskIds(List<Task> a, List<Task> b) {
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i].id != b[i].id) {
      return false;
    }
  }
  return true;
}



