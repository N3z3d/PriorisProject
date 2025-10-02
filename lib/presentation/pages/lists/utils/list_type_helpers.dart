import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Utilitaires pour la gestion des types de listes
///
/// **Responsabilité** : Fournir des mappings icônes/couleurs pour les types
/// **SRP Compliant** : Centralise toute la logique de présentation des types
/// **OCP Compliant** : Facile d'étendre pour de nouveaux types
class ListTypeHelpers {
  /// Empêche l'instanciation (classe utilitaire)
  ListTypeHelpers._();

  /// Retourne l'icône associée à un type de liste
  static IconData getIconForType(ListType type) {
    switch (type) {
      case ListType.TRAVEL:
        return Icons.flight;
      case ListType.SHOPPING:
        return Icons.shopping_cart;
      case ListType.MOVIES:
        return Icons.movie;
      case ListType.BOOKS:
        return Icons.book;
      case ListType.RESTAURANTS:
        return Icons.restaurant;
      case ListType.PROJECTS:
        return Icons.work;
      case ListType.CUSTOM:
        return Icons.list;
    }
  }

  /// Retourne la couleur associée à un type de liste
  static Color getColorForType(ListType type) {
    switch (type) {
      case ListType.TRAVEL:
        return AppTheme.accentColor;
      case ListType.SHOPPING:
        return AppTheme.successColor;
      case ListType.MOVIES:
        return AppTheme.secondaryColor;
      case ListType.BOOKS:
        return AppTheme.infoColor;
      case ListType.RESTAURANTS:
        return AppTheme.warningColor;
      case ListType.PROJECTS:
        return AppTheme.primaryColor;
      case ListType.CUSTOM:
        return AppTheme.textSecondary;
    }
  }

  /// Retourne une description lisible du type
  static String getDescriptionForType(ListType type) {
    switch (type) {
      case ListType.TRAVEL:
        return 'Destinations et voyages';
      case ListType.SHOPPING:
        return 'Articles à acheter';
      case ListType.MOVIES:
        return 'Films à voir';
      case ListType.BOOKS:
        return 'Livres à lire';
      case ListType.RESTAURANTS:
        return 'Restaurants à essayer';
      case ListType.PROJECTS:
        return 'Projets en cours';
      case ListType.CUSTOM:
        return 'Liste personnalisée';
    }
  }
}
