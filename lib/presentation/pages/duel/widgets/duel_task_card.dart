import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Card size variants for different duel layouts
enum DuelCardSize {
  /// Standard size for 2-card duels (280px min height)
  standard,
  /// Compact size for 3-card duels (220-260px height)
  compact3,
  /// Ultra-compact size for 4-card duels (lighter height)
  compact4,
}

/// Premium interactive card with sophisticated animations and glassmorphism
class DuelTaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback onTap;
  final bool hideElo;
  final VoidCallback? onEdit;
  final DuelCardSize cardSize;

  const DuelTaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.hideElo,
    this.onEdit,
    this.cardSize = DuelCardSize.standard,
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
    final constraints = _getConstraints(widget.cardSize);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHovered(true),
      onExit: (_) {
        _setHovered(false);
        _setPressed(false);
      },
      child: Semantics(
        button: true,
        enabled: true,
        label: 'Choisir la tache: ${widget.task.title}',
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          child: _buildAnimatedCard(constraints),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard(BoxConstraints constraints) {
    final scale = _isPressed ? 0.96 : (_isHovered ? 1.04 : 1.0);
    final rotation = _isHovered ? 0.002 : 0.0;

    return AnimatedScale(
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
          constraints: constraints,
          alignment: Alignment.center,
          decoration: _buildCardDecoration(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                if (_isHovered) _buildHoverShimmer(),
                Container(
                  alignment: Alignment.center,
                  padding: _getPadding(widget.cardSize),
                  child: _CardContent(
                    task: widget.task,
                    hideElo: widget.hideElo,
                    onEdit: widget.onEdit,
                    isHovered: _isHovered,
                    cardSize: widget.cardSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: AppTheme.surfaceColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        width: _isHovered ? 2.5 : 1.5,
        color: _isHovered
            ? AppTheme.primaryColor.withValues(alpha: 0.6)
            : AppTheme.dividerColor.withValues(alpha: 0.3),
      ),
      boxShadow: [
        BoxShadow(
          color: _isHovered
              ? AppTheme.primaryColor.withValues(alpha: 0.15)
              : Colors.black.withValues(alpha: 0.06),
          blurRadius: _isHovered ? 32 : 16,
          offset: Offset(0, _isHovered ? 16 : 8),
          spreadRadius: _isHovered ? 2 : 0,
        ),
      ],
    );
  }

  Widget _buildHoverShimmer() {
    return AnimatedBuilder(
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
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Returns adaptive constraints based on card size variant
  BoxConstraints _getConstraints(DuelCardSize size) {
    switch (size) {
      case DuelCardSize.standard:
        return const BoxConstraints(
          maxWidth: 380,
          minHeight: 260,
          maxHeight: 320,
        );
      case DuelCardSize.compact3:
        return const BoxConstraints(
          maxWidth: 280,
          minHeight: 200,
          maxHeight: 280,
        );
      case DuelCardSize.compact4:
        return const BoxConstraints(
          maxWidth: 240,
          minHeight: 180,
          maxHeight: 240,
        );
    }
  }

  /// Returns adaptive padding based on card size variant
  EdgeInsets _getPadding(DuelCardSize size) {
    switch (size) {
      case DuelCardSize.standard:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 28);
      case DuelCardSize.compact3:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
      case DuelCardSize.compact4:
        return const EdgeInsets.symmetric(horizontal: 10, vertical: 10);
    }
  }
}

class _CardContent extends StatelessWidget {
  final Task task;
  final bool hideElo;
  final VoidCallback? onEdit;
  final bool isHovered;
  final DuelCardSize cardSize;

  const _CardContent({
    required this.task,
    required this.hideElo,
    required this.onEdit,
    required this.isHovered,
    required this.cardSize,
  });

  @override
  Widget build(BuildContext context) {
    if (onEdit == null) {
      return Center(child: _buildContentColumn(context));
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Center(child: _buildContentColumn(context)),
        _buildEditButton(),
      ],
    );
  }

  bool get _hasDescription =>
      task.description != null && task.description!.trim().isNotEmpty;

  Widget _buildEditButton() {
    return Positioned(
      top: 0,
      right: 0,
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
    );
  }

  Widget _buildContentColumn(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      key: const ValueKey('duel-card-content-column'),
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildTitle(textTheme),
        if (!hideElo) ...[const SizedBox(height: 6), _buildElo(textTheme)],
        if (_hasDescription) ...[SizedBox(height: _getDescriptionSpacing()), _buildDescription(textTheme)],
        SizedBox(height: _getMetadataSpacing()),
        _MetadataSection(task: task, isHovered: isHovered),
      ],
    );
  }

  Widget _buildTitle(TextTheme textTheme) {
    return Tooltip(
      message: task.title,
      child: Text(
        task.title,
        maxLines: _getTitleMaxLines(),
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: _getTitleFontSize(),
          color: AppTheme.textPrimary,
          height: 1.35,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  Widget _buildElo(TextTheme textTheme) {
    return Text(
      'ELO ${task.eloScore.toStringAsFixed(0)}',
      style: textTheme.bodySmall?.copyWith(
        color: AppTheme.textSecondary.withValues(alpha: 0.75),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildDescription(TextTheme textTheme) {
    return Tooltip(
      message: task.description!.trim(),
      child: Text(
        task.description!.trim(),
        maxLines: _getDescriptionMaxLines(),
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: textTheme.bodyMedium?.copyWith(
          color: AppTheme.textSecondary.withValues(alpha: 0.95),
          height: 1.5,
          fontSize: _getDescriptionFontSize(),
          letterSpacing: 0.1,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Adaptive typography based on card size
  double _getTitleFontSize() {
    switch (cardSize) {
      case DuelCardSize.standard:
        return 18;
      case DuelCardSize.compact3:
        return 14;
      case DuelCardSize.compact4:
        return 12;
    }
  }

  int _getTitleMaxLines() {
    switch (cardSize) {
      case DuelCardSize.standard:
        return 3;
      case DuelCardSize.compact3:
      case DuelCardSize.compact4:
        return 2;
    }
  }

  double _getDescriptionFontSize() {
    switch (cardSize) {
      case DuelCardSize.standard:
        return 13;
      case DuelCardSize.compact3:
        return 11.5;
      case DuelCardSize.compact4:
        return 9.5;
    }
  }

  int _getDescriptionMaxLines() {
    switch (cardSize) {
      case DuelCardSize.standard:
        return 2;
      case DuelCardSize.compact3:
      case DuelCardSize.compact4:
        return 1;
    }
  }

  /// Adaptive spacing based on card size
  double _getDescriptionSpacing() {
    switch (cardSize) {
      case DuelCardSize.standard:
        return 8;
      case DuelCardSize.compact3:
        return 5;
      case DuelCardSize.compact4:
        return 3;
    }
  }

  double _getMetadataSpacing() {
    switch (cardSize) {
      case DuelCardSize.standard:
        return 12;
      case DuelCardSize.compact3:
        return 8;
      case DuelCardSize.compact4:
        return 3;
    }
  }
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
