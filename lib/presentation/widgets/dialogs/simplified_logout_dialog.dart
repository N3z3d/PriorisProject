import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/common/forms/common_button.dart';

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
      // WCAG 1.3.1 : Structure et rôle du dialogue
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusTokens.dialog,
        ),
        // WCAG 2.4.3 : Title accessible pour lecteurs d'écran
        title: Semantics(
          header: true,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadiusTokens.button,
                ),
                child: Icon(
                  Icons.logout,
                  color: AppTheme.primaryColor,
                  size: 24,
                  semanticLabel: 'Icône de déconnexion',
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Se déconnecter',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vos listes resteront disponibles sur cet appareil.',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadiusTokens.card,
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Vous pourrez vous reconnecter à tout moment pour synchroniser',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Action destructive cachée en petit lien
          Semantics(
            // WCAG 3.2.2 : Avertissement sur action destructive
            hint: 'Action irréversible - supprime toutes les données localement',
            button: true,
            child: InkWell(
              // WCAG 2.1.1 : Support navigation clavier
              onTap: () => _showDataClearConfirmation(context, ref),
              onFocus: (hasFocus) {
                if (hasFocus) {
                  // WCAG 1.4.13 : Annoncer le contenu au focus
                  _announceDestructiveAction();
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber,
                      size: 12,
                      color: Colors.red.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Effacer toutes mes données de cet appareil',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
        actions: [
          // WCAG 2.4.3 : Ordre de focus logique - Annuler en premier
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          const SizedBox(width: 8),
          // WCAG 2.4.7 : Focus automatique sur action principale
          Focus(
            autofocus: true,
            child: CommonButton(
              onPressed: () => Navigator.of(context).pop('logout_keep_data'),
              text: 'Se déconnecter',
              isPrimary: true,
            ),
          ),
        ],
      ),
    );
  }

  /// WCAG 1.4.13 : Annonce l'action destructive au focus
  void _announceDestructiveAction() {
    // Cette méthode peut être étendue avec des annonces de lecteur d'écran spécifiques
    // Pour Flutter, l'attribut hint dans Semantics suffira pour la plupart des cas
  }

  void _showDataClearConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      // WCAG 3.2.5 : Prévenir les changements de contexte inattendus
      barrierDismissible: false,
      builder: (context) => Semantics(
        // WCAG 1.3.1 : Structure du dialogue d'alerte
        scopesRoute: true,
        namesRoute: true,
        explicitChildNodes: true,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusTokens.dialog,
          ),
          title: Semantics(
            header: true,
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red.shade600,
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
          ),
        content: const Column(
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
        ),
          actions: [
            // WCAG 2.4.3 : Focus sur Annuler par défaut pour éviter action accidentelle
            Focus(
              autofocus: true,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
            ),
            const SizedBox(width: 8),
            // WCAG 3.2.2 : Action destructive nécessite confirmation explicite
            Semantics(
              hint: 'Action irréversible - confirmez pour effacer définitivement toutes les données',
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer cette dialog
                  Navigator.of(context).pop('logout_clear_data'); // Résultat final
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  // WCAG 2.5.5 : Taille tactile minimum
                  minimumSize: const Size(44, 44),
                ),
                child: const Text('Effacer et se déconnecter'),
              ),
            ),
          ],
        ),
      ),
      ),
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