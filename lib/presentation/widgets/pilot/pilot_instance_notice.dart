import 'package:flutter/material.dart';
import 'package:prioris/core/config/app_config.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

class PilotInstanceNotice extends StatelessWidget {
  const PilotInstanceNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.instance;
    if (!config.hasExplicitPilotInstance) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.22),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBadge(l10n),
            const SizedBox(height: 12),
            Text(
              config.pilotInstanceName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            _buildSupportingText(
              context,
              l10n.settingsPilotStatusBody,
            ),
            const SizedBox(height: 6),
            _buildSupportingText(
              context,
              l10n.settingsPilotLimitsBody,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        l10n.pilotIdentityBadge,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSupportingText(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
            height: 1.35,
          ),
    );
  }
}
