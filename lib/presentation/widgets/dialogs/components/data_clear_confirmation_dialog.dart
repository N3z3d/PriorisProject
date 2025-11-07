import 'package:flutter/material.dart';
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
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusTokens.modal,
        ),
        title: _buildTitle(),
        content: _buildContent(),
        actions: _buildActions(context),
      ),
    );
  }

  Widget _buildTitle() {
    return Semantics(
      header: true,
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: tone(warningColor, level: 600),
            size: 24,
            semanticLabel: 'Avertissement - Action destructive',
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Effacer les données',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cette action supprimera définitivement toutes vos listes de cet appareil.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Vous ne pourrez pas annuler cette action.',
          style: TextStyle(
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
        child: const Text('Annuler'),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Semantics(
      hint: 'Action irréversible - confirmez pour effacer définitivement toutes les données',
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
        child: const Text('Effacer et se déconnecter'),
      ),
    );
  }
}
