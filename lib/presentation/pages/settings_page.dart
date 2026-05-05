import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/consent_providers.dart';
import 'package:prioris/domain/services/core/consent_service.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/routes/app_routes.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/selectors/language_selector.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(l10n),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: l10n.settingsGeneralSectionTitle,
            children: [
              const CompactLanguageSelector(),
              _buildSettingTile(
                icon: Icons.info_outline,
                title: l10n.version,
                subtitle: '1.0.0',
                onTap: () {},
              ),
              _buildSettingTile(
                icon: Icons.help_outline,
                title: l10n.help,
                subtitle: l10n.settingsHelpSubtitle,
                onTap: () => _showFeatureInDevelopment(context, l10n),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: l10n.settingsPrivacySectionTitle,
            children: [
              _buildSettingTile(
                icon: Icons.privacy_tip_outlined,
                title: l10n.settingsPrivacyPolicyTile,
                subtitle: l10n.settingsPrivacyPolicySubtitle,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.privacyPolicy),
              ),
              _buildSettingTile(
                icon: Icons.lock_open_outlined,
                title: l10n.settingsRevokeConsentTile,
                subtitle: l10n.settingsRevokeConsentSubtitle,
                onTap: () => _showRevokeConsentDialog(context, l10n, ref),
                showChevron: false,
              ),
              _buildSettingTile(
                icon: Icons.delete_forever_outlined,
                title: l10n.settingsDeleteAccountTile,
                subtitle: l10n.settingsDeleteAccountSubtitle,
                onTap: () => _showDeleteAccountDialog(context, l10n),
                showChevron: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      backgroundColor: AppTheme.cardColor,
      elevation: 0,
      title: Text(
        l10n.settings,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settingsDeleteAccountDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.settingsDeleteAccountDialogBody),
            const SizedBox(height: 8),
            const SelectableText(
              ConsentService.consentContactEmail,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await Clipboard.setData(
                  const ClipboardData(text: ConsentService.consentContactEmail),
                );
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.settingsDeleteAccountEmailCopied)),
                  );
                }
              } catch (_) {
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              }
            },
            child: Text(l10n.settingsDeleteAccountDialogCopyEmail),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  void _showRevokeConsentDialog(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settingsRevokeConsentDialogTitle),
        content: Text(l10n.settingsRevokeConsentDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.settingsRevokeConsentDialogCancel),
          ),
          TextButton(
            onPressed: () async {
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              try {
                await ref.read(consentProvider.notifier).revoke();
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.settingsRevokeConsentError)),
                  );
                }
              }
            },
            child: Text(
              l10n.settingsRevokeConsentDialogConfirm,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeatureInDevelopment(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settingsFeatureInDevelopment)),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadiusTokens.card,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showChevron = true,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadiusTokens.button,
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: showChevron
          ? Icon(Icons.chevron_right, color: AppTheme.textTertiary)
          : null,
      onTap: onTap,
    );
  }
}
