import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/theme/premium_exports.dart';

/// Version premium de la HabitCard avec toutes les fonctionnalités avancées
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
        // Carte principale avec tous les effets premium
        PremiumUISystem.premiumCard(
          enableHaptics: enableEffects,
          enablePhysics: enableEffects,
          enableGlass: false, // Garde le style existant
          showLoading: widget.showLoading,
          skeletonType: SkeletonType.habitCard,
          onTap: widget.onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec icône et streak
              _buildHeader(isCompleted, enableEffects),
              
              const SizedBox(height: 12),
              
              // Titre et description
              _buildTitleSection(),
              
              const SizedBox(height: 16),
              
              // Barre de progression avec animation
              _buildProgressSection(progress, enableEffects),
              
              const SizedBox(height: 16),
              
              // Actions avec effets premium
              _buildActionsSection(isCompleted, enableEffects),
            ],
          ),
        ),
        
        // Effets de particules pour succès
        if (_showSuccessParticles && enableEffects)
          _buildSuccessParticles(),
      ],
    );
  }

  Widget _buildHeader(bool isCompleted, bool enableEffects) {
    return Row(
      children: [
        // Icône d'habitude avec animation
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: widget.habit.habitColor.withValues(alpha: 0.1),
            borderRadius: BorderRadiusTokens.radiusSm,
          ),
          child: Icon(
            widget.habit.habitIcon,
            color: widget.habit.habitColor,
            size: 24,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Titre et type
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.habit.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: widget.habit.habitColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadiusTokens.badge,
                ),
                child: Text(
                  widget.habit.type.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: widget.habit.habitColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Streak avec animation spéciale pour les milestones
        if (_currentStreak > 0)
          _buildStreakBadge(_currentStreak, enableEffects),
      ],
    );
  }

  Widget _buildStreakBadge(int streak, bool enableEffects) {
    final isMilestone = streak % 7 == 0 && streak > 0;
    
    Widget badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        // Suppression du gradient pour un style plus professionnel
        color: isMilestone 
          ? AppTheme.warningColor.withValues(alpha: 0.1)
          : widget.habit.habitColor.withValues(alpha: 0.1),
        borderRadius: BorderRadiusTokens.badge,
        border: isMilestone 
          ? Border.all(color: AppTheme.warningColor, width: 1)
          : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            color: isMilestone ? Colors.white : widget.habit.habitColor,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            streak.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isMilestone ? Colors.white : widget.habit.habitColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    // Animation spéciale pour les milestones
    if (isMilestone && enableEffects) {
      badge = MicroInteractions.pulseAnimation(
        duration: const Duration(seconds: 2),
        child: badge,
      );
    }

    return badge;
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

  Widget _buildProgressSection(double progress, bool enableEffects) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progression du jour',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: widget.habit.habitColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Barre de progression premium
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: widget.habit.habitColor.withValues(alpha: 0.1),
            borderRadius: BorderRadiusTokens.progressBar,
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                // Fond uni pour un style plus professionnel
                color: widget.habit.habitColor,
                borderRadius: BorderRadiusTokens.progressBar,
                boxShadow: progress > 0.5 ? [
                  BoxShadow(
                    color: widget.habit.habitColor.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection(bool isCompleted, bool enableEffects) {
    return Row(
      children: [
        // Bouton principal avec effets premium
        Expanded(
          child: PremiumUISystem.premiumButton(
            text: isCompleted ? 'Complété' : 'Marquer accompli',
            onPressed: isCompleted ? () {} : _handleComplete,
            icon: isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            style: isCompleted ? PremiumButtonStyle.secondary : PremiumButtonStyle.primary,
            enableHaptics: enableEffects,
            enablePhysics: enableEffects,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Menu d'actions
        HapticWrapper(
          enableHaptics: enableEffects,
          tapIntensity: HapticIntensity.light,
          onTap: _showActionMenu,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadiusTokens.button,
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Icon(Icons.more_vert, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessParticles() {
    if (_currentStreak > 0 && _currentStreak % 7 == 0) {
      // Milestone streak - feux d'artifice
      return ParticleEffects.fireworksEffect(
        trigger: _showSuccessParticles,
        onComplete: () => setState(() => _showSuccessParticles = false),
      );
    } else {
      // Accomplissement normal - sparkles
      return ParticleEffects.sparkleEffect(
        trigger: _showSuccessParticles,
        onComplete: () => setState(() => _showSuccessParticles = false),
      );
    }
  }

  void _handleComplete() async {
    final enableEffects = widget.enablePremiumEffects && context.supportsPremiumEffects;
    
    // Haptic feedback contextuel
    if (enableEffects) {
      await PremiumHapticService.instance.habitCompleted();
      
      // Feedback spécial pour les streaks milestones
      if ((_currentStreak + 1) % 7 == 0) {
        await Future.delayed(const Duration(milliseconds: 500));
        await PremiumHapticService.instance.streakMilestone(_currentStreak + 1);
      }
    }

    // Déclencher les effets de particules
    if (enableEffects) {
      setState(() {
        _showSuccessParticles = true;
      });
    }

    // Feedback visuel premium
    if (context.mounted) {
      context.showPremiumSuccess(
      'Habitude accomplie !',
      type: (_currentStreak + 1) % 7 == 0 
        ? SuccessType.milestone 
        : SuccessType.standard,
      );
    }

    // Appeler le callback
    widget.onRecordValue?.call(true);
  }

  void _showActionMenu() {
    context.showPremiumBottomSheet(
      Glassmorphism.glassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Actions pour ${widget.habit.name}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            _buildActionMenuItem(
              icon: Icons.edit,
              title: 'Modifier',
              onTap: () {
                Navigator.pop(context);
                widget.onEdit?.call();
              },
            ),
            
            _buildActionMenuItem(
              icon: Icons.history,
              title: 'Historique',
              onTap: () {
                Navigator.pop(context);
                // TODO: Ouvrir l'historique
              },
            ),
            
            _buildActionMenuItem(
              icon: Icons.delete,
              title: 'Supprimer',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return PremiumUISystem.premiumListItem(
      enableHaptics: true,
      enablePhysics: true,
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: color ?? Theme.of(context).iconTheme.color,
            size: 20,
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    context.showPremiumModal(
      Glassmorphism.glassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Supprimer l\'habitude ?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cette action est irréversible. Toutes les données liées à cette habitude seront perdues.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: PremiumUISystem.premiumButton(
                    text: 'Annuler',
                    onPressed: () => Navigator.pop(context),
                    style: PremiumButtonStyle.outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PremiumUISystem.premiumButton(
                    text: 'Supprimer',
                    onPressed: () {
                      Navigator.pop(context);
                      PremiumHapticService.instance.error();
                      context.showPremiumError('Habitude supprimée');
                      widget.onDelete?.call();
                    },
                    style: PremiumButtonStyle.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isHabitCompletedToday() {
    // TODO: Implémenter la logique réelle
    return widget.todayValue != null && widget.todayValue == widget.habit.targetValue;
  }

  double _calculateProgress() {
    if (widget.todayValue == null) return 0.0;
    if (widget.habit.targetValue == null) return 1.0;
    
    final current = widget.todayValue as num;
    final target = widget.habit.targetValue as num;
    
    return (current / target).clamp(0.0, 1.0);
  }
}