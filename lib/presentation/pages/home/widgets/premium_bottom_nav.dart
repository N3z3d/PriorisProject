import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/presentation/pages/home/models/navigation_item.dart';
import 'package:prioris/presentation/pages/home/widgets/premium_nav_item.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Barre de navigation inférieure premium avec design moderne
class PremiumBottomNav extends ConsumerWidget {
  const PremiumBottomNav({
    super.key,
    required this.currentPage,
    required this.items,
    required this.onNavigationTap,
  });

  final int currentPage;
  final List<NavigationItem> items;
  final Function(int, NavigationItem) onNavigationTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      container: true,
      label: 'Navigation principale',
      hint: 'Utilisez les flèches pour naviguer entre les sections',
      child: Container(
        decoration: _buildDecoration(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildNavigationItemsRow(),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      color: AppTheme.cardColor,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, -8),
          spreadRadius: -4,
        ),
      ],
    );
  }

  Widget _buildNavigationItemsRow() {
    return Row(
      children: items.asMap().entries.map((entry) {
        return Expanded(
          child: _buildNavigationItem(entry.key, entry.value),
        );
      }).toList(),
    );
  }

  Widget _buildNavigationItem(int index, NavigationItem item) {
    final isActive = currentPage == index;

    return PremiumNavItem(
      item: item,
      isActive: isActive,
      onTap: () => onNavigationTap(index, item),
    );
  }
}
