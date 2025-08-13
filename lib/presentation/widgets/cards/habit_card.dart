import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/mixins/animation_lifecycle_mixin.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/buttons/action_button.dart';
import 'package:prioris/presentation/widgets/habit_footer.dart';
import 'package:prioris/presentation/widgets/dialogs/habit_record_dialog.dart';
import 'package:prioris/presentation/widgets/badges/habit_type_badge.dart';
import 'package:prioris/presentation/widgets/progress/habit_progress_bar.dart';

class HabitCard extends StatefulWidget {
  final Habit habit;
  final dynamic todayValue;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(dynamic value)? onRecordValue;

  const HabitCard({
    super.key,
    required this.habit,
    required this.todayValue,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onRecordValue,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard>
    with TickerProviderStateMixin, AnimationLifecycleMixin<HabitCard> {
  late AnimationController _animationController;
  late AnimationController _progressController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;
  bool _isHovered = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.normalAnimation,
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: AppTheme.slowAnimation,
      vsync: this,
    );
    
    // Enregistrer les controllers pour la gestion du cycle de vie
    registerAnimationController(_animationController);
    registerAnimationController(_progressController);
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppTheme.defaultCurve,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: _getProgressValue(),
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));
    
    // Démarrer l'animation de progression
    _progressController.forward();
  }

  @override
  void dispose() {
    // Le mixin gère la disposition des controllers
    super.dispose();
  }

  double _getProgressValue() {
    if (widget.habit.type == HabitType.binary) {
      return widget.todayValue == true ? 1.0 : 0.0;
    } else {
      if (widget.habit.targetValue == null || widget.habit.targetValue == 0) return 0.0;
      final currentValue = widget.todayValue as double? ?? 0.0;
      return (currentValue / widget.habit.targetValue!).clamp(0.0, 1.0);
    }
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return AppTheme.successColor;
    if (progress >= 0.7) return AppTheme.warningColor;
    if (progress > 0) return AppTheme.infoColor;
    return AppTheme.textTertiary;
  }

  void _showRecordDialog() {
    if (widget.onRecordValue == null) return;
    
    setState(() => _isRecording = true);
    
    if (widget.habit.type == HabitType.binary) {
      // Pour les habitudes binaires, on toggle directement
      final newValue = !(widget.todayValue == true);
      widget.onRecordValue!(newValue);
      setState(() => _isRecording = false);
      
      // Animer la progression
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: newValue ? 1.0 : 0.0,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ));
      _progressController.reset();
      _progressController.forward();
      
      // Feedback haptique
      HapticFeedback.lightImpact();
    } else {
      // Pour les habitudes quantitatives, afficher un dialog
      _showQuantitativeDialog();
    }
  }

  void _showQuantitativeDialog() {
    showDialog(
      context: context,
      builder: (context) => HabitRecordDialog(
        habit: widget.habit,
        currentValue: widget.todayValue,
        onSave: (value) {
          if (widget.onRecordValue != null) {
            widget.onRecordValue!(value);
            
            // Animer la progression
            _progressAnimation = Tween<double>(
              begin: _progressAnimation.value,
              end: _getProgressValue(),
            ).animate(CurvedAnimation(
              parent: _progressController,
              curve: Curves.easeOutCubic,
            ));
            _progressController.reset();
            _progressController.forward();
            
            // Feedback haptique
            HapticFeedback.lightImpact();
          }
        },
      ),
    ).then((_) => setState(() => _isRecording = false));
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityAwareAnimationWidget(
      onVisibilityChanged: (visible) {
        onVisibilityChanged(visible);
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => _animationController.forward(),
          onTapUp: (_) => _animationController.reverse(),
          onTapCancel: () => _animationController.reverse(),
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: AnimatedContainer(
                duration: AppTheme.fastAnimation,
                curve: AppTheme.defaultCurve,
                margin: EdgeInsets.only(
                  bottom: AppTheme.spacingMD,
                  left: _isHovered ? AppTheme.spacingSM : 0,
                  right: _isHovered ? AppTheme.spacingSM : 0,
                ),
                decoration: BoxDecoration(
                  color: _getProgressValue() >= 1.0
                      ? AppTheme.successColor.withValues(alpha: 0.05)
                      : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                  border: Border.all(
                    color: _isHovered
                        ? AppTheme.primaryColor.withValues(alpha: 0.3)
                                                  : AppTheme.grey300,
                    width: _isHovered ? 2 : 1,
                  ),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                  child: Material(
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingLG),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // En-tête avec type et actions
                          Row(
                            children: [
                              HabitTypeBadge(type: widget.habit.type),
                              
                              const Spacer(),
                              
                              // Actions
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.onRecordValue != null)
                                    ActionButton(
                                      icon: _isRecording 
                                          ? Icons.hourglass_empty 
                                          : (widget.habit.type == HabitType.binary
                                              ? (widget.todayValue == true ? Icons.check_circle : Icons.add_circle_outline)
                                              : Icons.edit),
                                      color: _getProgressColor(_getProgressValue()),
                                      onTap: _showRecordDialog,
                                      tooltip: widget.habit.type == HabitType.binary
                                          ? (widget.todayValue == true ? 'Marquer comme non fait' : 'Marquer comme fait')
                                          : 'Enregistrer une valeur',
                                      isLoading: _isRecording,
                                    ),
                                  
                                  if (widget.onEdit != null)
                                    ActionButton(
                                      icon: Icons.edit_outlined,
                                      color: AppTheme.infoColor,
                                      onTap: widget.onEdit!,
                                      tooltip: 'Modifier',
                                    ),
                                  
                                  if (widget.onDelete != null)
                                    ActionButton(
                                      icon: Icons.delete_outline,
                                      color: AppTheme.errorColor,
                                      onTap: widget.onDelete!,
                                      tooltip: 'Supprimer',
                                    ),
                                ],
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: AppTheme.spacingMD),
                          
                          // Titre de l'habitude
                          Text(
                            widget.habit.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          
                          if (widget.habit.description?.isNotEmpty == true) ...[
                            const SizedBox(height: AppTheme.spacingSM),
                            Text(
                              widget.habit.description!,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          
                          const SizedBox(height: AppTheme.spacingLG),
                          
                          // Barre de progression
                          HabitProgressBar(
                            habit: widget.habit,
                            todayValue: widget.todayValue,
                            progressAnimation: _progressAnimation,
                          ),
                          
                          const SizedBox(height: AppTheme.spacingMD),
                          
                          // Footer avec catégorie et récurrence
                          HabitFooter(habit: widget.habit),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
            },
          ),
        ),
      ),
    );
  }
} 

