import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/common/elo_badge.dart';

/// Premium interactive card with sophisticated animations and glassmorphism
class DuelTaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback onTap;
  final bool hideElo;
  final VoidCallback? onEdit;

  const DuelTaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.hideElo,
    this.onEdit,
  });

  @override
  State<DuelTaskCard> createState() => _DuelTaskCardState();
}

class _DuelTaskCardState extends State<DuelTaskCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _shimmerAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _setHovered(bool value) {
    if (_isHovered == value) return;
    setState(() => _isHovered = value);
    if (value) {
      _shimmerController.forward(from: 0);
    }
  }

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    // Premium animation values
    final scale = _isPressed ? 0.96 : (_isHovered ? 1.03 : 1.0);
    final rotation = _isHovered ? 0.002 : 0.0; // Subtle tilt
    final elevationBlur = _isHovered ? 32.0 : 20.0;
    final elevationOffset = _isHovered ? 20.0 : 12.0;

    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) {
        _setHovered(false);
        _setPressed(false);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: AnimatedRotation(
            turns: rotation,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              constraints: const BoxConstraints(
                maxWidth: 420,
                minWidth: 280,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  // Primary shadow (depth)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: _isHovered ? 0.15 : 0.08),
                    blurRadius: elevationBlur,
                    offset: Offset(0, elevationOffset),
                    spreadRadius: -4,
                  ),
                  // Secondary shadow (ambient)
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: _isHovered ? 0.08 : 0.0),
                    blurRadius: elevationBlur * 0.75,
                    offset: const Offset(0, 8),
                    spreadRadius: -2,
                  ),
                  // Tertiary shadow (glow effect)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Glassmorphism background layer
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.surfaceColor,
                            AppTheme.surfaceColor.withValues(alpha: 0.98),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Animated gradient border
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        width: _isHovered ? 1.5 : 1,
                        color: _isHovered
                            ? AppTheme.primaryColor.withValues(alpha: 0.4)
                            : AppTheme.dividerColor.withValues(alpha: 0.6),
                      ),
                      // Subtle gradient overlay on hover
                      gradient: _isHovered
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.primaryColor.withValues(alpha: 0.03),
                                AppTheme.accentColor.withValues(alpha: 0.02),
                              ],
                            )
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          // Shimmer effect on hover
                          if (_isHovered)
                            AnimatedBuilder(
                              animation: _shimmerAnimation,
                              builder: (context, child) {
                                return Positioned(
                                  left: _shimmerAnimation.value * 100,
                                  top: -50,
                                  bottom: -50,
                                  child: Transform.rotate(
                                    angle: 0.3,
                                    child: Container(
                                      width: 100,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withValues(alpha: 0),
                                            Colors.white.withValues(alpha: 0.15),
                                            Colors.white.withValues(alpha: 0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                          // Content
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 28,
                            ),
                            child: _CardContent(
                              task: widget.task,
                              hideElo: widget.hideElo,
                              onEdit: widget.onEdit,
                              isHovered: _isHovered,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  final Task task;
  final bool hideElo;
  final VoidCallback? onEdit;
  final bool isHovered;

  const _CardContent({
    required this.task,
    required this.hideElo,
    required this.onEdit,
    required this.isHovered,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (onEdit != null)
          Align(
            alignment: Alignment.topRight,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    size: 18,
                    color: AppTheme.primaryColor.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ),
        if (!hideElo) ...[
          EloBadge(score: task.eloScore),
          const SizedBox(height: 18),
        ],

        // Title with enhanced typography
        Tooltip(
          message: task.title,
          child: Text(
            task.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppTheme.textPrimary,
              height: 1.3,
              letterSpacing: -0.3,
            ),
          ),
        ),

        if (_hasDescription) ...[
          const SizedBox(height: 14),
          Tooltip(
            message: task.description!.trim(),
            child: Text(
              task.description!.trim(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary.withValues(alpha: 0.85),
                height: 1.5,
                fontSize: 13.5,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],

        const SizedBox(height: 22),
        _MetadataSection(task: task, isHovered: isHovered),
      ],
    );
  }

  bool get _hasDescription =>
      task.description != null && task.description!.trim().isNotEmpty;
}

class _MetadataSection extends StatelessWidget {
  final Task task;
  final bool isHovered;

  const _MetadataSection({
    required this.task,
    required this.isHovered,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (task.category != null && task.category!.trim().isNotEmpty) {
      chips.add(_MetadataChip(
        label: task.category!.trim(),
        color: AppTheme.primaryColor,
        background: AppTheme.primaryColor.withValues(alpha: 0.12),
        icon: Icons.folder_rounded,
        isHovered: isHovered,
      ));
    }

    if (task.dueDate != null) {
      final isOverdue = task.dueDate!.isBefore(DateTime.now());
      chips.add(_MetadataChip(
        label: _formatRelativeDate(task.dueDate!),
        color: isOverdue ? AppTheme.errorColor : AppTheme.accentColor,
        background: isOverdue
            ? AppTheme.errorColor.withValues(alpha: 0.12)
            : AppTheme.accentColor.withValues(alpha: 0.12),
        icon: isOverdue ? Icons.warning_rounded : Icons.schedule_rounded,
        isHovered: isHovered,
      ));
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 8,
      children: chips,
    );
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) return 'Aujourd\'hui';
    if (difference == 1) return 'Demain';
    if (difference > 1) return 'Dans $difference j';
    if (difference == -1) return 'Hier';
    if (difference < -1) return 'Il y a ${difference.abs()} j';

    return DateFormat.yMMMd().format(date);
  }
}

class _MetadataChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;
  final IconData icon;
  final bool isHovered;

  const _MetadataChip({
    required this.label,
    required this.color,
    required this.background,
    required this.icon,
    required this.isHovered,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: isHovered ? 0.3 : 0.15),
          width: 1,
        ),
        boxShadow: isHovered
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w600,
                  fontSize: 11.5,
                  letterSpacing: 0.3,
                ),
          ),
        ],
      ),
    );
  }
}
