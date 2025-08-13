import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

/// Service de gestion du focus pour l'accessibilité
class FocusManagementService {
  static final FocusManagementService _instance = FocusManagementService._internal();
  factory FocusManagementService() => _instance;
  FocusManagementService._internal();

  final Map<String, FocusNode> _focusNodes = {};
  FocusNode? _previousFocus;

  /// Crée ou récupère un FocusNode par clé
  FocusNode getFocusNode(String key) {
    return _focusNodes.putIfAbsent(key, () => FocusNode());
  }

  /// Sauvegarde le focus actuel avant d'ouvrir une modale
  void savePreviousFocus(BuildContext context) {
    _previousFocus = FocusScope.of(context).focusedChild;
  }

  /// Restaure le focus précédent après fermeture d'une modale
  void restorePreviousFocus() {
    if (_previousFocus != null && _previousFocus!.context != null) {
      _previousFocus!.requestFocus();
    }
  }

  /// Déplace le focus vers le prochain élément
  void focusNext(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  /// Déplace le focus vers l'élément précédent
  void focusPrevious(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  /// Retourne le focus au premier élément de la page
  void resetFocus(BuildContext context) {
    FocusScope.of(context).unfocus();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (context.mounted) {
        FocusScope.of(context).nextFocus();
      }
    });
  }

  /// Trap le focus dans un dialog ou modal
  Widget trapFocus({
    required Widget child,
    required BuildContext context,
  }) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: child,
    );
  }

  /// Widget pour gérer le focus automatiquement
  Widget autoFocus({
    required Widget child,
    bool autofocus = true,
    String? semanticLabel,
  }) {
    return Focus(
      autofocus: autofocus,
      child: Semantics(
        label: semanticLabel,
        child: child,
      ),
    );
  }

  /// Indicateur visuel de focus amélioré
  Widget enhancedFocusIndicator({
    required Widget child,
    required FocusNode focusNode,
    Color? focusColor,
    double focusWidth = 2.0,
  }) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, _) {
        return Container(
          decoration: focusNode.hasFocus
              ? BoxDecoration(
                  border: Border.all(
                    color: focusColor ?? Theme.of(context).primaryColor,
                    width: focusWidth,
                  ),
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          child: child,
        );
      },
    );
  }

  /// Gestionnaire de raccourcis clavier pour la navigation
  Widget keyboardNavigationHandler({
    required Widget child,
    VoidCallback? onEscape,
    VoidCallback? onEnter,
    VoidCallback? onTab,
  }) {
    return CallbackShortcuts(
      bindings: {
        if (onEscape != null)
          LogicalKeySet(LogicalKeyboardKey.escape): onEscape,
        if (onEnter != null)
          LogicalKeySet(LogicalKeyboardKey.enter): onEnter,
        if (onTab != null)
          LogicalKeySet(LogicalKeyboardKey.tab): onTab,
      },
      child: child,
    );
  }

  /// Ordre de traversal personnalisé pour les éléments
  Widget customTraversalOrder({
    required List<Widget> children,
    required List<int> order,
  }) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Column(
        children: List.generate(children.length, (index) {
          final orderIndex = order.indexOf(index);
          return FocusTraversalOrder(
            order: NumericFocusOrder(orderIndex.toDouble()),
            child: children[index],
          );
        }),
      ),
    );
  }

  /// Annonce pour les lecteurs d'écran
  void announceForAccessibility(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Créer un groupe de focus avec label
  Widget focusGroup({
    required Widget child,
    required String label,
    String? hint,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      container: true,
      child: FocusTraversalGroup(
        child: child,
      ),
    );
  }

  /// Crée un FocusableActionDetector avec les callbacks d'accessibilité
  Widget createFocusableAction({
    required Widget child,
    required VoidCallback? onPressed,
    String? tooltip,
    bool enabled = true,
    FocusNode? focusNode,
  }) {
    return FocusableActionDetector(
      focusNode: focusNode,
      enabled: enabled,
      onShowFocusHighlight: (bool highlighted) {
        // Callback pour afficher/masquer l'indicateur de focus
      },
      onShowHoverHighlight: (bool highlighted) {
        // Callback pour afficher/masquer l'indicateur de survol
      },
      mouseCursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.space): const ActivateIntent(),
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (ActivateIntent intent) {
            if (enabled && onPressed != null) {
              onPressed();
            }
            return null;
          },
        ),
      },
      child: Tooltip(
        message: tooltip ?? '',
        child: child,
      ),
    );
  }

  /// Skip link pour navigation rapide
  Widget createSkipLink({
    required String text,
    required GlobalKey targetKey,
  }) {
    return Positioned(
      top: -100,
      left: 0,
      child: Focus(
        onFocusChange: (hasFocus) {
          // Affiche le skip link quand il a le focus
        },
        child: ElevatedButton(
          onPressed: () {
            if (targetKey.currentContext != null) {
              Scrollable.ensureVisible(
                targetKey.currentContext!,
                duration: const Duration(milliseconds: 300),
              );
            }
          },
          child: Text(text),
        ),
      ),
    );
  }

  /// Demande le focus sur un élément spécifique avec délai
  void requestFocusWithDelay(BuildContext context, FocusNode focusNode, {Duration delay = const Duration(milliseconds: 100)}) {
    Future.delayed(delay, () {
      if (focusNode.context != null && context.mounted) {
        FocusScope.of(context).requestFocus(focusNode);
      }
    });
  }

  /// Nettoie les FocusNodes
  void dispose() {
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    _focusNodes.clear();
  }
}