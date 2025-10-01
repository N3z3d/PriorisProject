import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets\indicators/sync_status_indicator.dart';

/// Premium Sync Style Service - Manages colors, styles and visual properties
///
/// SOLID COMPLIANCE:
/// - SRP: Single responsibility for styling logic only
/// - OCP: Open for extension through SyncDisplayStatus enum
/// - LSP: Provides consistent styling interface
/// - ISP: Focused interface for style calculations only
/// - DIP: Depends on Flutter's styling abstractions
///
/// CONSTRAINTS: <100 lines (currently ~90 lines)
class PremiumSyncStyleService {
  /// Singleton instance for consistent styling across the app
  static final PremiumSyncStyleService instance = PremiumSyncStyleService._();
  PremiumSyncStyleService._();

  /// Get adaptive blur intensity based on status
  double getAdaptiveBlurIntensity(SyncDisplayStatus status, bool adaptiveBlur) {
    if (!adaptiveBlur) return 8.0;

    switch (status) {
      case SyncDisplayStatus.offline:
        return 6.0;
      case SyncDisplayStatus.syncing:
        return 10.0;
      case SyncDisplayStatus.merged:
        return 8.0;
      case SyncDisplayStatus.attention:
        return 12.0;
      case SyncDisplayStatus.normal:
        return 0.0;
    }
  }

  /// Get glass opacity for glassmorphism effect
  double getGlassOpacity(SyncDisplayStatus status) {
    switch (status) {
      case SyncDisplayStatus.offline:
        return 0.15;
      case SyncDisplayStatus.syncing:
        return 0.18;
      case SyncDisplayStatus.merged:
        return 0.12;
      case SyncDisplayStatus.attention:
        return 0.20;
      case SyncDisplayStatus.normal:
        return 0.0;
    }
  }

  /// Get primary color for status
  Color getGlassColor(BuildContext context, SyncDisplayStatus status) {
    switch (status) {
      case SyncDisplayStatus.offline:
        return Colors.orange;
      case SyncDisplayStatus.syncing:
        return Theme.of(context).primaryColor;
      case SyncDisplayStatus.merged:
        return Colors.blue;
      case SyncDisplayStatus.attention:
        return Colors.red;
      case SyncDisplayStatus.normal:
        return Colors.transparent;
    }
  }

  /// Get border color with opacity
  Color getBorderColor(BuildContext context, SyncDisplayStatus status) {
    return getGlassColor(context, status).withOpacity(0.3);
  }

  /// Get border width
  double getBorderWidth(SyncDisplayStatus status) {
    return status == SyncDisplayStatus.attention ? 1.5 : 1.0;
  }

  /// Get shadow color
  Color getShadowColor(BuildContext context, SyncDisplayStatus status) {
    return getGlassColor(context, status).withOpacity(0.2);
  }

  /// Get shadow blur radius
  double getShadowBlur(SyncDisplayStatus status) {
    switch (status) {
      case SyncDisplayStatus.attention:
        return 16.0;
      case SyncDisplayStatus.syncing:
        return 12.0;
      default:
        return 8.0;
    }
  }

  /// Get text color
  Color getTextColor(BuildContext context, SyncDisplayStatus status) {
    return getGlassColor(context, status);
  }

  /// Get semantic accessibility label
  String getAccessibilityLabel(SyncDisplayStatus status, String? message) {
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