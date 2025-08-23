import 'package:flutter/material.dart';

/// Widget wrapper pour rendre les états de chargement accessibles
/// 
/// WCAG 2.1 AA Compliance:
/// - 4.1.3 : Messages de statut annoncés automatiquement
/// - 1.4.13 : Contenu qui apparaît au survol ou au focus
/// - 2.2.2 : Pause, arrêt, masquer
class AccessibleLoadingState extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final Widget child;
  final String? loadingMessage;
  final String? errorPrefix;

  const AccessibleLoadingState({
    super.key,
    required this.isLoading,
    this.error,
    required this.child,
    this.loadingMessage,
    this.errorPrefix = 'Erreur',
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    // WCAG 4.1.3 : Annoncer les erreurs avec région live
    if (error != null) {
      content = Column(
        children: [
          Semantics(
            liveRegion: true,
            label: '$errorPrefix: $error',
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade600,
                    size: 20,
                    semanticLabel: 'Icône d\'erreur',
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error!,
                      style: TextStyle(
                        color: Colors.red.shade800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          child,
        ],
      );
    }

    // WCAG 4.1.3 : Annoncer l'état de chargement
    if (isLoading) {
      content = Semantics(
        liveRegion: true,
        label: loadingMessage ?? 'Chargement en cours, veuillez patienter',
        child: Stack(
          children: [
            // Contenu en arrière-plan avec opacité réduite
            Opacity(
              opacity: 0.5,
              child: content,
            ),
            // Indicateur de chargement accessible
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        semanticsLabel: loadingMessage ?? 'Chargement en cours',
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      loadingMessage ?? 'Chargement...',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return content;
  }
}

/// Widget pour annoncer des changements d'état dynamiques
class AccessibleStatusAnnouncement extends StatefulWidget {
  final String? message;
  final bool isVisible;
  final Duration duration;

  const AccessibleStatusAnnouncement({
    super.key,
    this.message,
    this.isVisible = true,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<AccessibleStatusAnnouncement> createState() => _AccessibleStatusAnnouncementState();
}

class _AccessibleStatusAnnouncementState extends State<AccessibleStatusAnnouncement> {
  bool _shouldAnnounce = false;

  @override
  void didUpdateWidget(AccessibleStatusAnnouncement oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Déclencher l'annonce si le message a changé
    if (oldWidget.message != widget.message && widget.message != null) {
      setState(() {
        _shouldAnnounce = true;
      });
      
      // Arrêter l'annonce après la durée spécifiée
      Future.delayed(widget.duration, () {
        if (mounted) {
          setState(() {
            _shouldAnnounce = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible || widget.message == null || !_shouldAnnounce) {
      return const SizedBox.shrink();
    }

    return Semantics(
      // WCAG 4.1.3 : Région live pour annonces de statut
      liveRegion: true,
      label: widget.message!,
      child: Container(
        height: 1,
        width: 1,
        child: Text(
          widget.message!,
          style: const TextStyle(
            fontSize: 1,
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }
}