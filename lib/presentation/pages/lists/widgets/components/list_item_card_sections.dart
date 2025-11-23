part of '../list_item_card.dart';

class _ListItemCardView extends StatelessWidget {
  const _ListItemCardView({
    required this.item,
    required this.isSyncing,
    required this.isHovered,
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
  final bool isHovered;
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
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: _cardDecoration(),
      child: InkWell(
        onTap: onCardTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _HeaderSection(item: item, isSyncing: isSyncing)),
          const SizedBox(width: 10),
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
      color: isHovered
          ? AppTheme.surfaceColor.withValues(alpha: 0.97)
          : AppTheme.surfaceColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isHovered
            ? AppTheme.dividerColor.withValues(alpha: 0.8)
            : AppTheme.dividerColor.withValues(alpha: 0.6),
        width: 1,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A000000),
          blurRadius: 6,
          offset: Offset(0, 4),
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
          const SizedBox(height: 4),
          Text(
            item.description!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.35,
            ),
          ),
        ],
        if (item.category?.isNotEmpty ?? false) ...[
          const SizedBox(height: 8),
          _CategoryBadge(
            category: item.category!,
            eloScore: item.eloScore,
          ),
        ],
        if (isSyncing) ...const [
          SizedBox(height: 8),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          _MetadataChip(item: item),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.25),
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
  const _MetadataChip({required this.item});

  final ListItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final created = item.createdAt;
    final formattedDate =
        created != null ? DateFormat.yMd(localeTag).format(created) : null;
    final label = formattedDate != null
        ? l10n?.listItemDateLabel(formattedDate) ?? 'Ajouté le $formattedDate'
        : l10n?.listItemDateUnknown ?? 'Sans date';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.grey50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.dividerColor.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today, size: 14, color: AppTheme.textSecondary),
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
