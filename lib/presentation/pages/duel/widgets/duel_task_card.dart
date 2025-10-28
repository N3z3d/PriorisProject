import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/common/elo_badge.dart';

/// Interactive card used in the duel grid with hover/press feedback.
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

class _DuelTaskCardState extends State<DuelTaskCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  void _setHovered(bool value) {
    if (_isHovered == value) return;
    setState(() => _isHovered = value);
  }

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final scale = _isPressed ? 0.98 : (_isHovered ? 1.02 : 1.0);
    final shadowOpacity = _isHovered ? 0.14 : 0.08;

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
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            constraints: const BoxConstraints(
              maxWidth: 420,
              minWidth: 280,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _isHovered
                    ? AppTheme.primaryColor.withValues(alpha: 0.25)
                    : AppTheme.dividerColor.withValues(alpha: 0.9),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: shadowOpacity),
                  blurRadius: _isHovered ? 28 : 18,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: _CardContent(
              task: widget.task,
              hideElo: widget.hideElo,
              onEdit: widget.onEdit,
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

  const _CardContent({
    required this.task,
    required this.hideElo,
    required this.onEdit,
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
            child: IconButton(
              onPressed: onEdit,
              padding: EdgeInsets.zero,
              splashRadius: 20,
              tooltip: AppLocalizations.of(context)?.edit ?? 'Modifier',
              icon: const Icon(Icons.edit, size: 20),
            ),
          ),
        if (!hideElo) ...[
          EloBadge(score: task.eloScore),
          const SizedBox(height: 16),
        ],
        Tooltip(
          message: task.title,
          child: Text(
            task.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.2,
            ),
          ),
        ),
        if (_hasDescription) ...[
          const SizedBox(height: 12),
          Tooltip(
            message: task.description!.trim(),
            child: Text(
              task.description!.trim(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary.withValues(alpha: 0.85),
                height: 1.4,
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        _MetadataSection(task: task),
      ],
    );
  }

  bool get _hasDescription =>
      task.description != null && task.description!.trim().isNotEmpty;
}

class _MetadataSection extends StatelessWidget {
  final Task task;

  const _MetadataSection({required this.task});

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (task.category != null && task.category!.trim().isNotEmpty) {
      chips.add(_MetadataChip(
        label: task.category!.trim(),
        color: AppTheme.primaryColor,
        background: AppTheme.primaryColor.withValues(alpha: 0.1),
      ));
    }

    if (task.dueDate != null) {
      chips.add(_MetadataChip(
        label: _formatRelativeDate(task.dueDate!),
        color: task.dueDate!.isBefore(DateTime.now())
            ? AppTheme.errorColor
            : AppTheme.accentColor,
        background: task.dueDate!.isBefore(DateTime.now())
            ? AppTheme.errorColor.withValues(alpha: 0.12)
            : AppTheme.accentColor.withValues(alpha: 0.12),
      ));
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 6,
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

  const _MetadataChip({
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
      ),
    );
  }
}

