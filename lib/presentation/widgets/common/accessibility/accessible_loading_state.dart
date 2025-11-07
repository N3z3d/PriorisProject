import 'package:flutter/material.dart';
import 'package:prioris/presentation/styles/ui_color_utils.dart';

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
  final Color errorColor;

  const AccessibleLoadingState({
    super.key,
    required this.isLoading,
    this.error,
    required this.child,
    this.loadingMessage,
    this.errorPrefix = 'Erreur',
    this.errorColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    if (error != null) {
      content = _buildErrorContent(content);
    }

    if (isLoading) {
      content = _buildLoadingContent(content);
    }

    return content;
  }

  Widget _buildErrorContent(Widget content) {
    return Column(
      children: [
        _buildErrorContainer(),
        content,
      ],
    );
  }

  Widget _buildErrorContainer() {
    return Semantics(
      liveRegion: true,
      label: '$errorPrefix: $error',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: _buildErrorDecoration(),
        child: _buildErrorRow(),
      ),
    );
  }

  BoxDecoration _buildErrorDecoration() {
    return BoxDecoration(
      color: tone(errorColor, level: 50),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: tone(errorColor, level: 200)),
    );
  }

  Widget _buildErrorRow() {
    return Row(
      children: [
        Icon(
          Icons.error_outline,
          color: tone(errorColor, level: 600),
          size: 20,
          semanticLabel: 'Icône d\'erreur',
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            error!,
            style: TextStyle(
              color: tone(errorColor, level: 800),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingContent(Widget content) {
    return Semantics(
      liveRegion: true,
      label: loadingMessage ?? 'Chargement en cours, veuillez patienter',
      child: Stack(
        children: [
          Opacity(
            opacity: 0.5,
            child: content,
          ),
          _buildLoadingIndicator(),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: _buildLoadingDecoration(),
        child: _buildLoadingColumn(),
      ),
    );
  }

  BoxDecoration _buildLoadingDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildLoadingColumn() {
    return Column(
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
    );
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
