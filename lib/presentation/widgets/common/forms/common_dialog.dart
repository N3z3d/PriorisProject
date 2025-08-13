import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/services/focus_management_service.dart';
import 'package:prioris/domain/services/ui/accessibility_service.dart';

/// Widget de dialogue réutilisable pour toute l'application
class CommonDialog extends StatelessWidget {
  /// Titre du dialogue
  final String title;

  /// Contenu principal du dialogue
  final Widget content;

  /// Actions (boutons) personnalisées
  final List<Widget>? actions;

  /// Autoriser la fermeture en cliquant en dehors
  final bool barrierDismissible;

  /// Largeur maximale du dialogue
  final double? maxWidth;

  /// FocusNode pour gestion du focus
  final FocusNode? focusNode;

  /// Callback de fermeture
  final VoidCallback? onClose;

  /// Constructeur
  const CommonDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.barrierDismissible = true,
    this.maxWidth,
    this.focusNode,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService();
    final focusService = FocusManagementService();
    
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: FocusTraversalGroup(
        child: Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            // Gérer la touche Escape
            if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
              if (barrierDismissible) {
                Navigator.of(context).pop();
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: AlertDialog(
            title: Semantics(
              header: true,
              child: Text(
                title, 
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            content: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth ?? 400),
              child: Semantics(
                container: true,
                child: content,
              ),
            ),
            actions: actions != null 
                ? [
                    Semantics(
                      container: true,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: actions!,
                      ),
                    ),
                  ] 
                : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusTokens.modal,
            ),
            backgroundColor: Theme.of(context).dialogBackgroundColor,
            elevation: 8,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 40,
            ),
          ),
        ),
      ),
    );
  }

  /// Affiche le dialogue via showDialog avec gestion du focus
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    bool barrierDismissible = true,
    double? maxWidth,
    VoidCallback? onClose,
  }) {
    final focusService = FocusManagementService();
    final accessibilityService = AccessibilityService();
    
    // Sauvegarder le focus actuel
    focusService.savePreviousFocus(context);
    
    // Annoncer l'ouverture du dialog
    accessibilityService.announceToScreenReader(
      'Dialog ouvert: $title',
    );
    
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black54,
      builder: (ctx) => CommonDialog(
        title: title,
        content: content,
        actions: actions,
        barrierDismissible: barrierDismissible,
        maxWidth: maxWidth,
        onClose: onClose,
      ),
    ).then((result) {
      // Restaurer le focus précédent
      focusService.restorePreviousFocus();
      
      // Annoncer la fermeture
      accessibilityService.announceToScreenReader('Dialog fermé');
      
      if (onClose != null) onClose();
      return result;
    });
  }
} 
