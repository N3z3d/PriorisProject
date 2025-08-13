import 'package:flutter/material.dart';
import 'package:prioris/domain/services/ui/accessibility_service.dart';

/// Widget pour gérer les annonces LiveRegion pour l'accessibilité
class LiveRegionAnnouncer extends StatefulWidget {
  /// Message à annoncer
  final String message;

  /// Type de politesse pour l'annonce
  final LiveRegionPoliteness politeness;

  /// Callback optionnel après l'annonce
  final VoidCallback? onAnnounced;

  const LiveRegionAnnouncer({
    super.key,
    required this.message,
    this.politeness = LiveRegionPoliteness.polite,
    this.onAnnounced,
  });

  @override
  State<LiveRegionAnnouncer> createState() => _LiveRegionAnnouncerState();
}

class _LiveRegionAnnouncerState extends State<LiveRegionAnnouncer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _announceMessage();
    });
  }

  @override
  void didUpdateWidget(LiveRegionAnnouncer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message != widget.message) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _announceMessage();
      });
    }
  }

  void _announceMessage() {
    if (widget.message.isNotEmpty) {
      final accessibilityService = AccessibilityService();
      accessibilityService.announceToScreenReader(widget.message);
      
      if (widget.onAnnounced != null) {
        widget.onAnnounced!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: ExcludeSemantics(
        child: Container(
          width: 1,
          height: 1,
          child: Text(
            widget.message,
            style: const TextStyle(fontSize: 0),
          ),
        ),
      ),
    );
  }
}

/// Énumération pour la politesse des annonces LiveRegion
enum LiveRegionPoliteness {
  /// Annonce polie (attend une pause)
  polite,
  
  /// Annonce assertive (interrompt)
  assertive,
  
  /// Annonce désactivée
  off,
}

/// Widget statique pour les annonces rapides
class QuickAnnouncer {
  static final AccessibilityService _accessibilityService = AccessibilityService();

  /// Annonce un message simple
  static void announce(String message) {
    if (message.isNotEmpty) {
      _accessibilityService.announceToScreenReader(message);
    }
  }

  /// Annonce un succès
  static void announceSuccess(String message) {
    announce('Succès: $message');
  }

  /// Annonce une erreur
  static void announceError(String message) {
    announce('Erreur: $message');
  }

  /// Annonce un avertissement
  static void announceWarning(String message) {
    announce('Attention: $message');
  }

  /// Annonce une information
  static void announceInfo(String message) {
    announce('Information: $message');
  }

  /// Annonce le changement d'état d'un élément
  static void announceStateChange(String element, String oldState, String newState) {
    announce('$element: état changé de $oldState à $newState');
  }

  /// Annonce le chargement
  static void announceLoading(String context) {
    announce('Chargement en cours: $context');
  }

  /// Annonce la fin du chargement
  static void announceLoadingComplete(String context) {
    announce('Chargement terminé: $context');
  }

  /// Annonce la navigation
  static void announceNavigation(String destination) {
    announce('Navigation vers $destination');
  }

  /// Annonce l'ouverture d'un dialogue
  static void announceDialogOpen(String title) {
    announce('Dialogue ouvert: $title');
  }

  /// Annonce la fermeture d'un dialogue
  static void announceDialogClose() {
    announce('Dialogue fermé');
  }
}