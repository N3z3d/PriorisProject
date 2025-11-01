import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// En-tete de page unifie utilise dans toute l'application
///
/// Reference : ListsOverviewBanner - "Organisez vos listes en un coup d'il"
/// Structure : Icone + Titre + Sous-titre avec style coherent
class UnifiedPageHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final List<Widget>? actions;

  const UnifiedPageHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    this.iconBackgroundColor,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? AppTheme.primaryColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        decoration: _buildDecoration(),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            _buildIcon(effectiveIconColor),
            const SizedBox(width: 16),
            Expanded(child: _buildContent(theme)),
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(width: 12),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 4,
                children: actions!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (iconBackgroundColor ?? color).withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  BoxDecoration _buildDecoration() {
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
