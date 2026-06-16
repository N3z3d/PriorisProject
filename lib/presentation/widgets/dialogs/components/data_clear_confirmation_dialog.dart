import 'package:flutter/material.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/styles/ui_color_utils.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Dialogue de confirmation pour l'effacement des données
///
/// Double confirmation pour action destructive (WCAG 3.2.5)
class DataClearConfirmationDialog extends StatelessWidget {
  final Color warningColor;

  const DataClearConfirmationDialog({
    super.key,
    this.warningColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusTokens.modal,
        ),
        title: _buildTitle(l10n),
        content: _buildContent(l10n),
        actions: _buildActions(context),
      ),
    );
  }

  Widget _buildTitle(AppLocalizations l10n) {
    return Semantics(
      header: true,
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: tone(warningColor, level: 600),
            size: 24,
            semanticLabel: l10n.clearConfirmWarningLabel,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.clearConfirmTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.clearConfirmBody1,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.clearConfirmBody2,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      _buildCancelButton(context),
      const SizedBox(width: 8),
      _buildConfirmButton(context),
    ];
  }

  Widget _buildCancelButton(BuildContext context) {
    return Focus(
      autofocus: true,
      child: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(AppLocalizations.of(context)!.cancel),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Semantics(
      hint: AppLocalizations.of(context)!.clearConfirmHint,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop(); // Fermer cette dialog
          Navigator.of(context).pop('logout_clear_data'); // Résultat final
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: warningColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(44, 44),
        ),
        child: Text(AppLocalizations.of(context)!.clearDataAndSignOut),
      ),
    );
  }
}
