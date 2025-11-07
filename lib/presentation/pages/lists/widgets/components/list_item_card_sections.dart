part of '../list_item_card.dart';

class _ListItemCardView extends StatelessWidget {
  const _ListItemCardView({
    required this.item,
    required this.isSyncing,
    required this.actionsAnimation,
    required this.onToggleCompletion,
    required this.onEdit,
    required this.onDelete,
    required this.onMenuAction,
    required this.onCardTap,
    required this.onLongPress,
    required this.onHideActions,
  });

  final ListItem item;
  final bool isSyncing;
  final Animation<double> actionsAnimation;
  final VoidCallback? onToggleCompletion;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final void Function(String action)? onMenuAction;
  final VoidCallback onCardTap;
  final VoidCallback onLongPress;
  final VoidCallback onHideActions;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: _cardDecoration(),
      child: InkWell(
        onTap: onCardTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: const BoxDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _MetadataRow(item: item),
              _ActionFooter(
                item: item,
                actionsAnimation: actionsAnimation,
                onToggleCompletion: onToggleCompletion,
                onEdit: onEdit,
                onDelete: onDelete,
                onMenuAction: onMenuAction,
                onHideActions: onHideActions,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumStatusIndicator(
            status: item.isCompleted ? StatusType.completed : StatusType.pending,
            showLabel: false,
            enableAnimation: false,
            enableHaptics: false,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(child: _HeaderSection(item: item, isSyncing: isSyncing)),
          const SizedBox(width: 12),
          _TrailingSection(
            item: item,
            isSyncing: isSyncing,
            actionsAnimation: actionsAnimation,
            onEdit: onEdit,
            onDelete: onDelete,
            onMenuAction: onMenuAction,
            onHideActions: onHideActions,
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppTheme.surfaceColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 12,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.item,
    required this.isSyncing,
  });

  final ListItem item;
  final bool isSyncing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        if (item.description?.isNotEmpty ?? false) ...[
          const SizedBox(height: 6),
          Text(
            item.description!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
        if (item.category?.isNotEmpty ?? false) ...[
          const SizedBox(height: 12),
          _CategoryBadge(
            category: item.category!,
            eloScore: item.eloScore,
          ),
        ],
        if (isSyncing) ...const [
          SizedBox(height: 12),
          _SyncIndicator(),
        ],
      ],
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({required this.item});

  final ListItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _MetadataChip(
            icon: Icons.calendar_today,
            label: item.createdAt != null
                ? '${item.createdAt!.day}/${item.createdAt!.month}/${item.createdAt!.year}'
                : 'Non dat\u00E9e',
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({
    required this.category,
    required this.eloScore,
  });

  final String category;
  final double eloScore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        category,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.grey100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

