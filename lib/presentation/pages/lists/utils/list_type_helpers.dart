import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Utilities that expose presentation metadata for [ListType].
class ListTypeHelpers {
  ListTypeHelpers._();

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
      case ListType.TODO:
        return Icons.check_circle_outline;
      case ListType.IDEAS:
        return Icons.lightbulb_outline;
      case ListType.CUSTOM:
        return Icons.list;
    }
  }

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
      case ListType.TODO:
        return AppTheme.accentColor;
      case ListType.IDEAS:
        return AppTheme.infoColor;
      case ListType.CUSTOM:
        return AppTheme.textSecondary;
    }
  }

  static String getDescriptionForType(ListType type) {
    switch (type) {
      case ListType.TRAVEL:
        return 'Destinations et voyages';
      case ListType.SHOPPING:
        return 'Articles \u00E0 acheter';
      case ListType.MOVIES:
        return 'Films \u00E0 voir';
      case ListType.BOOKS:
        return 'Livres \u00E0 lire';
      case ListType.RESTAURANTS:
        return 'Restaurants \u00E0 essayer';
      case ListType.PROJECTS:
        return 'Projets en cours';
      case ListType.TODO:
        return 'T\u00E2ches quotidiennes';
      case ListType.IDEAS:
        return 'Id\u00E9es et inspirations';
      case ListType.CUSTOM:
        return 'Liste personnalis\u00E9e';
    }
  }
}
