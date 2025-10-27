import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

class ListsOverviewBanner extends StatelessWidget {
  final int totalLists;
  final int totalItems;

  const ListsOverviewBanner({
    super.key,
    required this.totalLists,
    required this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: _BannerContainer(
        icon: _buildIcon(),
        content: _buildContent(theme),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.view_list,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Organisez vos listes en un coup d\'oeil',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$totalLists listes | $totalItems éléments actifs',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _BannerContainer extends StatelessWidget {
  const _BannerContainer({
    required this.icon,
    required this.content,
  });

  final Widget icon;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _decoration(),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 16),
          Expanded(child: content),
        ],
      ),
    );
  }

  BoxDecoration _decoration() {
    return BoxDecoration(
      color: AppTheme.surfaceColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppTheme.dividerColor.withValues(alpha: 0.3),
      ),
      boxShadow: const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.03),
          blurRadius: 12,
          offset: Offset(0, 6),
        ),
      ],
    );
  }
}
