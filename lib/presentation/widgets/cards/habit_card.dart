import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/mixins/animation_lifecycle_mixin.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/habit_footer.dart';
import 'package:prioris/presentation/widgets/dialogs/habit_record_dialog.dart';
import 'package:prioris/presentation/widgets/progress/habit_progress_bar.dart';
import 'package:prioris/presentation/widgets/cards/habit_card/components/export.dart';
import 'package:prioris/presentation/widgets/cards/habit_card/decorations/habit_card_decoration.dart';

class HabitCard extends StatefulWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.todayValue,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onRecordValue,
  });

  final Habit habit;
  final dynamic todayValue;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(dynamic value)? onRecordValue;

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
      onVisibilityChanged: onVisibilityChanged,
      child: _buildInteractiveCard(),
    );
  }

  Widget _buildInteractiveCard() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        onTap: widget.onTap,
        child: _buildAnimatedCard(),
      ),
    );
  }

  Widget _buildAnimatedCard() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: _buildCardContainer(),
      ),
    );
  }

  Widget _buildCardContainer() {
    return AnimatedContainer(
      duration: AppTheme.fastAnimation,
      curve: AppTheme.defaultCurve,
      margin: _buildCardMargin(),
      decoration: HabitCardDecoration.create(
        isHovered: _isHovered,
        isCompleted: _getProgressValue() >= 1.0,
      ),
      child: _buildCardContent(),
    );
  }

  EdgeInsets _buildCardMargin() {
    return EdgeInsets.only(
      bottom: AppTheme.spacingMD,
      left: _isHovered ? AppTheme.spacingSM : 0,
      right: _isHovered ? AppTheme.spacingSM : 0,
    );
  }

  Widget _buildCardContent() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLG),
          child: _buildCardBody(),
        ),
      ),
    );
  }

  Widget _buildCardBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HabitCardHeader(
          habit: widget.habit,
          todayValue: widget.todayValue,
          progressColor: _getProgressColor(_getProgressValue()),
          onRecord: widget.onRecordValue != null ? _showRecordDialog : null,
          onEdit: widget.onEdit,
          onDelete: widget.onDelete,
          isRecording: _isRecording,
        ),
        const SizedBox(height: AppTheme.spacingMD),
        HabitCardContent(habit: widget.habit),
        const SizedBox(height: AppTheme.spacingLG),
        HabitProgressBar(
          habit: widget.habit,
          todayValue: widget.todayValue,
          progressAnimation: _progressAnimation,
        ),
        const SizedBox(height: AppTheme.spacingMD),
        HabitFooter(habit: widget.habit),
      ],
    );
  }
} 

