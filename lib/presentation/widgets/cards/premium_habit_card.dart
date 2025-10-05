import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/theme/premium_exports.dart';
import 'components/export.dart';

/// Version premium de la HabitCard avec toutes les fonctionnalités avancées
///
/// Responsabilité: Orchestrer l'affichage d'une carte d'habitude avec composants
class PremiumHabitCard extends StatefulWidget {
  final Habit habit;
  final dynamic todayValue;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(dynamic value)? onRecordValue;
  final bool showLoading;
  final bool enablePremiumEffects;

  const PremiumHabitCard({
    super.key,
    required this.habit,
    required this.todayValue,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onRecordValue,
    this.showLoading = false,
    this.enablePremiumEffects = true,
  });

  @override
  State<PremiumHabitCard> createState() => _PremiumHabitCardState();
}

class _PremiumHabitCardState extends State<PremiumHabitCard> {
  bool _showSuccessParticles = false;
  int _currentStreak = 0;

  @override
  void initState() {
    super.initState();
    _currentStreak = widget.habit.habitCurrentStreak;
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = _isHabitCompletedToday();
    final progress = _calculateProgress();
    final enableEffects = widget.enablePremiumEffects && context.supportsPremiumEffects;

    return Stack(
      children: [
        PremiumUISystem.premiumCard(
          enableHaptics: enableEffects,
          enablePhysics: enableEffects,
          enableGlass: false,
          showLoading: widget.showLoading,
          skeletonType: SkeletonType.habitCard,
          onTap: widget.onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HabitCardHeader(
                habit: widget.habit,
                currentStreak: _currentStreak,
                isCompleted: isCompleted,
                enableEffects: enableEffects,
              ),
              const SizedBox(height: 12),
              _buildTitleSection(),
              const SizedBox(height: 16),
              HabitCardProgress(
                habit: widget.habit,
                progress: progress,
                enableEffects: enableEffects,
              ),
              const SizedBox(height: 16),
              HabitCardActions(
                isCompleted: isCompleted,
                onComplete: _handleComplete,
                onShowMenu: _showActionMenu,
                enableEffects: enableEffects,
              ),
            ],
          ),
        ),
        if (enableEffects)
          HabitSuccessParticles(
            showParticles: _showSuccessParticles,
            currentStreak: _currentStreak,
            onComplete: () => setState(() => _showSuccessParticles = false),
          ),
      ],
    );
  }


  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.habit.description ?? 'Aucune description',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }



  Future<void> _handleComplete() async {
    final enableEffects = widget.enablePremiumEffects && context.supportsPremiumEffects;

    if (enableEffects) {
      await PremiumHapticService.instance.habitCompleted();

      if ((_currentStreak + 1) % 7 == 0) {
        await Future.delayed(const Duration(milliseconds: 500));
        await PremiumHapticService.instance.streakMilestone(_currentStreak + 1);
      }

      setState(() => _showSuccessParticles = true);
    }

    if (context.mounted) {
      context.showPremiumSuccess(
        'Habitude accomplie !',
        type: (_currentStreak + 1) % 7 == 0
          ? SuccessType.milestone
          : SuccessType.standard,
      );
    }

    widget.onRecordValue?.call(true);
  }

  void _showActionMenu() {
    HabitActionMenu.show(
      context,
      habit: widget.habit,
      onEdit: widget.onEdit,
      onDelete: _showDeleteConfirmation,
      onHistory: () {
        // TODO: Implémenter historique
      },
    );
  }

  void _showDeleteConfirmation() {
    HabitDeleteConfirmation.show(
      context,
      habitName: widget.habit.name,
      onDelete: () {
        widget.onDelete?.call();
      },
    );
  }

  bool _isHabitCompletedToday() {
    return widget.todayValue != null &&
           widget.todayValue == widget.habit.targetValue;
  }

  double _calculateProgress() {
    if (widget.todayValue == null) return 0.0;
    if (widget.habit.targetValue == null) return 1.0;

    final current = widget.todayValue as num;
    final target = widget.habit.targetValue as num;

    return (current / target).clamp(0.0, 1.0);
  }
}