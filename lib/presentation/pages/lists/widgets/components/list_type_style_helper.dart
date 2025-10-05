import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Helper class for list type visual styling
///
/// Provides consistent icons and colors for each list type.
class ListTypeStyleHelper {
  const ListTypeStyleHelper._();

  /// Returns the appropriate icon for a given list type
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

  /// Returns the appropriate color for a given list type
  static Color getColorForType(ListType type) {
    switch (type) {
      case ListType.TRAVEL:
        return Colors.blue;
      case ListType.SHOPPING:
        return Colors.green;
      case ListType.MOVIES:
        return Colors.purple;
      case ListType.BOOKS:
        return Colors.orange;
      case ListType.RESTAURANTS:
        return Colors.red;
      case ListType.PROJECTS:
        return Colors.indigo;
      case ListType.CUSTOM:
        return AppTheme.primaryColor;
    }
  }
}
