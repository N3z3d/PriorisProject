import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/buttons/premium_fab.dart';

class ListContextualFab extends StatelessWidget {
  static bool animationsForcedDisabled = false;

  final CustomList list;
  final String baseLabel;
  final String searchQuery;
  final List<ListItem> filteredItems;
  final VoidCallback onPressed;
  final bool enableAnimations;

  const ListContextualFab({
    super.key,
    required this.list,
    required this.baseLabel,
    required this.searchQuery,
    required this.filteredItems,
    required this.onPressed,
    this.enableAnimations = true,
  });

  @override
  Widget build(BuildContext context) {
    final useAnimations = enableAnimations && !animationsForcedDisabled;

    return PremiumFAB(
      heroTag: 'list_detail_fab',
      text: baseLabel,
      contextualText: _computeContextualText(),
      icon: Icons.add,
      onPressed: onPressed,
      backgroundColor: AppTheme.primaryColor,
      enableAnimations: useAnimations,
      enableHaptics: true,
    );
  }

  String _computeContextualText() {
    final itemCount = list.items.length;
    final hasSearch = searchQuery.trim().isNotEmpty;

    if (itemCount == 0) {
      return 'Creer vos premiers elements';
    }

    if (hasSearch && filteredItems.isNotEmpty) {
      return 'Ajouter a cette recherche';
    }

    if (hasSearch && filteredItems.isEmpty) {
      return 'Creer nouvel element';
    }

    if (itemCount < 3) {
      return 'Ajouter plus d''elements';
    }

    return 'Ajouter de nouveaux elements';
  }
}
