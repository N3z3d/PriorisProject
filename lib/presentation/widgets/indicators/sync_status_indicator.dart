import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// État de synchronisation simplifié pour l'utilisateur
enum SyncDisplayStatus {
  /// Tout fonctionne normalement - pas d'indicateur
  normal,
  
  /// Mode hors ligne - indicateur discret  
  offline,
  
  /// Synchronisation en cours - animation subtile
  syncing,
  
  /// Données fusionnées automatiquement - notification temporaire
  merged,
  
  /// Erreur nécessitant attention - indicateur d'alerte
  attention,
}

/// Indicateur minimaliste du statut de synchronisation
/// 
/// PRINCIPE UX: N'affiche quelque chose que quand c'est nécessaire
/// - Normal: invisible
/// - Offline: petit dot orange discret
/// - Syncing: animation subtile
/// - Merged: notification temporaire
/// - Attention: indicateur rouge
class SyncStatusIndicator extends ConsumerWidget {
  final SyncDisplayStatus status;
  final String? message;
  final VoidCallback? onTap;

  const SyncStatusIndicator({
    super.key,
    required this.status,
    this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // PRINCIPE: Si tout va bien, ne rien afficher
    if (status == SyncDisplayStatus.normal) {
      return const SizedBox.shrink();
    }

    // ACCESSIBILITÉ : Texte de statut complet pour lecteurs d'écran
    final String accessibilityLabel = _getAccessibilityLabel();
    final bool isInteractive = onTap != null;

    return Semantics(
      // WCAG 4.1.3 : Messages de statut annoncés dynamiquement
      liveRegion: status == SyncDisplayStatus.syncing,
      label: accessibilityLabel,
      hint: isInteractive ? 'Appuyez pour plus de détails' : null,
      button: isInteractive,
      // WCAG 1.4.3 : Assurer contraste minimum
      child: GestureDetector(
        onTap: onTap,
        // WCAG 2.1.1 : Support navigation clavier
        child: isInteractive ? Focus(
          child: Builder(
            builder: (context) => _buildIndicatorContainer(context, accessibilityLabel),
          ),
        ) : _buildIndicatorContainer(context, accessibilityLabel),
      ),
    );
  }

  /// Construit le conteneur principal de l'indicateur
  Widget _buildIndicatorContainer(BuildContext context, String accessibilityLabel) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      // WCAG 2.4.7 : Assurer indicateur de focus visible
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadiusTokens.button,
        border: Border.all(
          color: Focus.of(context).hasFocus 
              ? _getIconColor().withOpacity(0.8)
              : _getBorderColor(),
          width: Focus.of(context).hasFocus ? 2 : 1,
        ),
      ),
      constraints: const BoxConstraints(
        // WCAG 2.5.5 : Taille tactile minimum 44x44px
        minWidth: 44,
        minHeight: 44,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIcon(),
          if (message != null) ...[
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                message!,
                style: TextStyle(
                  fontSize: 12,
                  color: _getTextColor(),
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIcon() {
    switch (status) {
      case SyncDisplayStatus.offline:
        return Semantics(
          // WCAG 1.1.1 : Alternative textuelle pour contenu non textuel
          label: 'Mode hors ligne',
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
        );
        
      case SyncDisplayStatus.syncing:
        return Semantics(
          label: 'Synchronisation en cours',
          child: SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(_getIconColor()),
              semanticsLabel: 'Synchronisation en cours',
            ),
          ),
        );
        
      case SyncDisplayStatus.merged:
        return Icon(
          Icons.merge_type,
          size: 14,
          color: _getIconColor(),
          semanticLabel: 'Données fusionnées automatiquement',
        );
        
      case SyncDisplayStatus.attention:
        return Icon(
          Icons.warning_rounded,
          size: 14,
          color: _getIconColor(),
          semanticLabel: 'Attention requise pour la synchronisation',
        );
        
      case SyncDisplayStatus.normal:
        return const SizedBox.shrink();
    }
  }

  Color _getBackgroundColor() {
    switch (status) {
      case SyncDisplayStatus.offline:
        return Colors.orange.withOpacity(0.1);
      case SyncDisplayStatus.syncing:
        return AppTheme.primaryColor.withOpacity(0.1);
      case SyncDisplayStatus.merged:
        return Colors.blue.withOpacity(0.1);
      case SyncDisplayStatus.attention:
        return Colors.red.withOpacity(0.1);
      case SyncDisplayStatus.normal:
        return Colors.transparent;
    }
  }

  Color _getBorderColor() {
    switch (status) {
      case SyncDisplayStatus.offline:
        return Colors.orange.withOpacity(0.3);
      case SyncDisplayStatus.syncing:
        return AppTheme.primaryColor.withOpacity(0.3);
      case SyncDisplayStatus.merged:
        return Colors.blue.withOpacity(0.3);
      case SyncDisplayStatus.attention:
        return Colors.red.withOpacity(0.3);
      case SyncDisplayStatus.normal:
        return Colors.transparent;
    }
  }

  Color _getIconColor() {
    switch (status) {
      case SyncDisplayStatus.offline:
        return Colors.orange;
      case SyncDisplayStatus.syncing:
        return AppTheme.primaryColor;
      case SyncDisplayStatus.merged:
        return Colors.blue;
      case SyncDisplayStatus.attention:
        return Colors.red;
      case SyncDisplayStatus.normal:
        return Colors.transparent;
    }
  }

  Color _getTextColor() {
    return _getIconColor();
  }

  /// WCAG 4.1.3 : Fournit un label d'accessibilité complet pour chaque statut
  String _getAccessibilityLabel() {
    final baseMessage = message ?? '';
    
    switch (status) {
      case SyncDisplayStatus.offline:
        return 'Statut de synchronisation: Mode hors ligne. ${baseMessage.isNotEmpty ? baseMessage : 'Les données sont disponibles localement'}';
      case SyncDisplayStatus.syncing:
        return 'Statut de synchronisation: Synchronisation en cours. ${baseMessage.isNotEmpty ? baseMessage : 'Veuillez patienter'}';
      case SyncDisplayStatus.merged:
        return 'Statut de synchronisation: Données fusionnées avec succès. ${baseMessage.isNotEmpty ? baseMessage : 'Toutes vos données sont à jour'}';
      case SyncDisplayStatus.attention:
        return 'Statut de synchronisation: Attention requise. ${baseMessage.isNotEmpty ? baseMessage : 'Vérifiez votre connexion'}';
      case SyncDisplayStatus.normal:
        return 'Synchronisation normale, aucune action requise';
    }
  }
}

/// Messages prédéfinis pour chaque statut
class SyncMessages {
  static const String offline = "Hors ligne";
  static const String syncing = "Sync...";
  static const String merged = "Données mises à jour";
  static const String attention = "Vérifier connexion";
  
  /// Messages contextuels selon l'action
  static String saving(String itemName) => "Sauvegarde de $itemName...";
  static String saved(String itemName) => "$itemName sauvegardé";
}

/// Widget utilitaire pour afficher des notifications temporaires
class TemporarySyncNotification extends StatefulWidget {
  final String message;
  final Duration duration;
  final VoidCallback? onDismiss;

  const TemporarySyncNotification({
    super.key,
    required this.message,
    this.duration = const Duration(seconds: 3),
    this.onDismiss,
  });

  @override
  State<TemporarySyncNotification> createState() => _TemporarySyncNotificationState();
}

class _TemporarySyncNotificationState extends State<TemporarySyncNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Afficher l'animation d'entrée
    _controller.forward();
    
    // Programmer la disparition automatique
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() async {
    await _controller.reverse();
    if (mounted) {
      widget.onDismiss?.call();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      // WCAG 4.1.3 : Annoncer les notifications temporaires
      liveRegion: true,
      label: 'Notification: ${widget.message}',
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.9),
              borderRadius: BorderRadiusTokens.card,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 18,
                  semanticLabel: 'Succès',
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}