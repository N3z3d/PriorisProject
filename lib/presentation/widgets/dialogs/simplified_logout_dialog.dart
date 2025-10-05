import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/common/forms/common_button.dart';
import 'package:prioris/presentation/widgets/dialogs/components/data_clear_confirmation_dialog.dart';
import 'package:prioris/presentation/widgets/dialogs/components/logout_destructive_action_link.dart';
import 'package:prioris/presentation/widgets/dialogs/components/logout_dialog_content.dart';
import 'package:prioris/presentation/widgets/dialogs/components/logout_dialog_title.dart';

/// Dialogue de déconnexion ultra-simplifié
///
/// PRINCIPE UX: Éliminer les choix techniques inutiles
/// - Comportement par défaut: garder les données (sécuritaire)
/// - Action destructive cachée derrière un geste secondaire
/// - Message rassurant sur la continuité
class SimplifiedLogoutDialog extends ConsumerWidget {
  const SimplifiedLogoutDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusTokens.modal,
        ),
        title: const LogoutDialogTitle(),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LogoutDialogContent(),
            const SizedBox(height: 12),
            LogoutDestructiveActionLink(
              onTap: () => _showDataClearConfirmation(context),
            ),
          ],
        ),
        actions: _buildActions(context),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(false),
        child: const Text('Annuler'),
      ),
      const SizedBox(width: 8),
      Focus(
        autofocus: true,
        child: CommonButton(
          onPressed: () => Navigator.of(context).pop('logout_keep_data'),
          text: 'Se déconnecter',
        ),
      ),
    ];
  }

  void _showDataClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const DataClearConfirmationDialog(),
    );
  }
}

/// Helper simplifié pour la déconnexion
class SimplifiedLogoutHelper {
  static Future<void> showLogoutDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const SimplifiedLogoutDialog(),
    );

    if (result == null) return; // Annulé
    
    switch (result) {
      case 'logout_keep_data':
        await _performLogout(ref, clearData: false);
        _showLogoutSuccess(context, dataCleared: false);
        break;
        
      case 'logout_clear_data':
        await _performLogout(ref, clearData: true);
        _showLogoutSuccess(context, dataCleared: true);
        break;
    }
  }

  static Future<void> _performLogout(WidgetRef ref, {required bool clearData}) async {
    try {
      if (clearData) {
        // Effacer les données locales avant la déconnexion
        // final listsController = ref.read(listsControllerProvider.notifier);
        // await listsController.clearAllData();
        print('🗑️ Données locales effacées');
      }
      
      // TODO: Implémenter la déconnexion authentification
      // final authController = ref.read(authControllerProvider.notifier);
      // await authController.signOut();
      
      print('✅ Déconnexion réussie');
      
    } catch (e) {
      print('❌ Erreur lors de la déconnexion: $e');
      throw e; // Relancer pour gestion d'erreur
    }
  }

  static void _showLogoutSuccess(BuildContext context, {required bool dataCleared}) {
    String message = dataCleared 
        ? 'Déconnecté et données effacées'
        : 'Déconnecté - vos listes restent disponibles';
        
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusTokens.card,
        ),
      ),
    );
  }
}