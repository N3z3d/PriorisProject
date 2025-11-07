import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';
import 'package:prioris/presentation/styles/ui_color_utils.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Dialogue de déconnexion amélioré qui donne le choix à l'utilisateur
/// sur ce qui arrive à ses données locales
class EnhancedLogoutDialog extends ConsumerWidget {
  final Color neutralColor;

  const EnhancedLogoutDialog({
    super.key,
    this.neutralColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusTokens.radiusLg,
      ),
      title: _buildDialogTitle(),
      content: _buildDialogContent(),
      actions: _buildDialogActions(context),
    );
  }

  Widget _buildDialogTitle() {
    return const Row(
      children: [
        Icon(Icons.logout, color: AppTheme.primaryColor),
        SizedBox(width: 12),
        Text('Se déconnecter'),
      ],
    );
  }

  Widget _buildDialogContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Que souhaitez-vous faire avec vos données locales ?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        _buildInfoBox(),
      ],
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadiusTokens.radiusMd,
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Vos listes sont stockées localement sur cet appareil',
              style: TextStyle(fontSize: 13, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDialogActions(BuildContext context) {
    return [
      _buildCancelButton(context),
      const SizedBox(width: 8),
      _buildKeepDataButton(context),
      const SizedBox(width: 8),
      _buildClearDataButton(context),
    ];
  }

  Widget _buildCancelButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () => Navigator.of(context).pop(false),
      icon: const Icon(Icons.cancel_outlined, size: 18),
      label: const Text('Annuler'),
      style: TextButton.styleFrom(
        foregroundColor: tone(neutralColor, level: 600),
      ),
    );
  }

  Widget _buildKeepDataButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.of(context).pop('keep_data'),
      icon: const Icon(Icons.save_outlined, size: 18),
      label: const Text('Garder mes données'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusTokens.radiusMd,
        ),
      ),
    );
  }

  Widget _buildClearDataButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.of(context).pop('clear_data'),
      icon: const Icon(Icons.delete_sweep, size: 18),
      label: const Text('Effacer mes données'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusTokens.radiusMd,
        ),
      ),
    );
  }
}

/// Méthode helper pour afficher le dialogue et gérer la déconnexion
class LogoutHelper {
  static Future<void> showLogoutOptions(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const EnhancedLogoutDialog(),
    );

    if (result == null) return; // Annulé
    
    if (result == 'keep_data') {
      await _performLogout(ref, clearData: false);
      print('🔒 Déconnexion avec conservation des données');
    } else if (result == 'clear_data') {
      await _performLogout(ref, clearData: true);
      print('🗑️ Déconnexion avec effacement des données');
    }
  }

  static Future<void> _performLogout(WidgetRef ref, {required bool clearData}) async {
    try {
      if (clearData) {
        // Effacer les données locales avant la déconnexion
        final listsController = ref.read(listsControllerProvider.notifier);
        await listsController.clearAllData();
        print('✅ Données locales effacées');
      }
      
      // Pending: Implémenter la déconnexion authentification
      // final authController = ref.read(authControllerProvider.notifier);
      // await authController.signOut();
      
      print('✅ Déconnexion réussie');
      
    } catch (e) {
      print('❌ Erreur lors de la déconnexion: $e');
      // Pending: Afficher une erreur à l'utilisateur
    }
  }
}
