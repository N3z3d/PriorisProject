import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/pages/home/models/navigation_item.dart';
import 'package:prioris/domain/services/ui/accessibility_service.dart';

/// Barre latérale de navigation pour desktop
class DesktopSidebar extends ConsumerWidget {
  final int currentPage;
  final List<NavigationItem> navigationItems;
  final Function(int, NavigationItem) onNavigationTap;

  const DesktopSidebar({
    super.key,
    required this.currentPage,
    required this.navigationItems,
    required this.onNavigationTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 240,
      decoration: _buildDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          Expanded(
            child: _buildNavigationItems(),
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      color: AppTheme.cardColor,
      border: Border(
        right: BorderSide(
          color: Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          _buildLogo(),
          const SizedBox(width: 12),
          _buildTitle(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.track_changes_rounded,
        color: Colors.white,
        size: 22,
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Prioris',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildNavigationItems() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: navigationItems.length,
      itemBuilder: (context, index) => _buildNavigationItem(index),
    );
  }

  Widget _buildNavigationItem(int index) {
    final item = navigationItems[index];
    final isActive = currentPage == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Semantics(
        label: item.label,
        selected: isActive,
        button: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleTap(index, item),
            borderRadius: BorderRadius.circular(10),
            child: _buildItemContainer(item, isActive),
          ),
        ),
      ),
    );
  }

  Widget _buildItemContainer(NavigationItem item, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isActive
            ? item.color.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildItemIcon(item, isActive),
          const SizedBox(width: 12),
          _buildItemLabel(item, isActive),
        ],
      ),
    );
  }

  Widget _buildItemIcon(NavigationItem item, bool isActive) {
    return Icon(
      isActive ? item.activeIcon : item.icon,
      color: isActive ? item.color : AppTheme.textSecondary,
      size: 22,
    );
  }

  Widget _buildItemLabel(NavigationItem item, bool isActive) {
    return Text(
      item.label,
      style: TextStyle(
        fontSize: 15,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
        color: isActive ? item.color : AppTheme.textSecondary,
      ),
    );
  }

  void _handleTap(int index, NavigationItem item) {
    onNavigationTap(index, item);
  }
}
