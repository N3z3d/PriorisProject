import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Helpers pour les types de listes
///
/// **SRP** : Fournit uniquement les icônes et couleurs par type
class ListTypeHelpers {
  ListTypeHelpers._();

  /// Retourne l'icône pour un type de liste
  static IconData getIcon(ListType type) {
    switch (type) {
      case ListType.SHOPPING:
        return Icons.shopping_cart;
      case ListType.TRAVEL:
        return Icons.flight;
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

  /// Retourne la couleur pour un type de liste
  static Color getColor(ListType type) {
    switch (type) {
      case ListType.SHOPPING:
        return Colors.blue;
      case ListType.TRAVEL:
        return Colors.green;
      case ListType.MOVIES:
        return Colors.purple;
      case ListType.BOOKS:
        return Colors.amber;
      case ListType.RESTAURANTS:
        return Colors.pink;
      case ListType.PROJECTS:
        return Colors.orange;
      case ListType.CUSTOM:
        return AppTheme.primaryColor;
    }
  }
}
