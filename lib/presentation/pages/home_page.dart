import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/pages/duel_page.dart';
import 'package:prioris/presentation/pages/habits_page.dart';
import 'package:prioris/presentation/pages/insights_page.dart';
import 'package:prioris/presentation/pages/lists_page.dart';
import 'package:prioris/presentation/pages/settings_page.dart';
import 'package:prioris/domain/services/ui/accessibility_service.dart';
import 'package:prioris/data/providers/auth_providers.dart';

final currentPageProvider = StateProvider<int>((ref) => 0);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(currentPageProvider);
    final pages = _buildPages();
    final navigationItems = _getNavigationItems();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(context, ref, navigationItems, currentPage),
      body: _buildBody(pages, currentPage),
      bottomNavigationBar: _buildPremiumBottomNav(
        context,
        ref,
        currentPage,
        navigationItems,
      ),
    );
  }

  List<Widget> _buildPages() {
    return [
      const ListsPage(),
      const DuelPage(),
      const HabitsPage(),
      const InsightsPage(),
    ];
  }

  List<_NavigationItem> _getNavigationItems() {
    return [
      _NavigationItem(
        icon: Icons.checklist_outlined,
        activeIcon: Icons.checklist,
        label: 'Listes',
        color: AppTheme.primaryColor,
      ),
      _NavigationItem(
        icon: Icons.psychology_outlined,
        activeIcon: Icons.psychology,
        label: 'Priorisé',
        color: AppTheme.accentColor,
      ),
      _NavigationItem(
        icon: Icons.trending_up_outlined,
        activeIcon: Icons.trending_up,
        label: 'Habitudes',
        color: AppTheme.warningColor,
      ),
      _NavigationItem(
        icon: Icons.insights_outlined,
        activeIcon: Icons.insights,
        label: 'Insights',
        color: AppTheme.secondaryColor,
      ),
    ];
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    List<_NavigationItem> navigationItems,
    int currentPage,
  ) {
    return AppBar(
      backgroundColor: AppTheme.cardColor,
      elevation: 0,
      title: _buildAppBarTitle(navigationItems[currentPage].label),
      actions: _buildAppBarActions(context, ref),
    );
  }

  Widget _buildAppBarTitle(String label) {
    return Semantics(
      header: true,
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context, WidgetRef ref) {
    return [
      _buildLogoutButton(ref),
      _buildSettingsButton(context),
    ];
  }

  Widget _buildLogoutButton(WidgetRef ref) {
    return Semantics(
      label: 'Se déconnecter',
      button: true,
      hint: 'Déconnecte l\'utilisateur actuel',
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        child: IconButton(
          icon: const Icon(Icons.logout_outlined),
          tooltip: 'Déconnexion',
          iconSize: 24,
          onPressed: () {
            print('🔒 Déconnexion simple');
            ref.read(authControllerProvider).signOut();
          },
        ),
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return Semantics(
      label: 'Ouvrir les paramètres',
      button: true,
      hint: 'Ouvre la page des paramètres de l\'application',
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        child: IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Paramètres',
          iconSize: 24,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsPage(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(List<Widget> pages, int currentPage) {
    return SafeArea(
      child: Semantics(
        container: true,
        label: 'Contenu principal',
        child: IndexedStack(
          index: currentPage,
          children: pages.map((page) => Semantics(
            container: true,
            child: page,
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildPremiumBottomNav(
    BuildContext context,
    WidgetRef ref,
    int currentPage,
    List<_NavigationItem> items,
  ) {
    return Semantics(
      container: true,
      label: 'Navigation principale',
      hint: 'Utilisez les flèches pour naviguer entre les sections',
      child: Container(
        decoration: _buildBottomNavDecoration(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildNavigationItemsRow(ref, currentPage, items),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBottomNavDecoration() {
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

  Widget _buildNavigationItemsRow(
    WidgetRef ref,
    int currentPage,
    List<_NavigationItem> items,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: items.asMap().entries.map((entry) {
        return _buildNavigationItem(
          ref,
          currentPage,
          entry.key,
          entry.value,
        );
      }).toList(),
    );
  }

  Widget _buildNavigationItem(
    WidgetRef ref,
    int currentPage,
    int index,
    _NavigationItem item,
  ) {
    final isActive = currentPage == index;

    return _PremiumNavItem(
      item: item,
      isActive: isActive,
      onTap: () => _handleNavigationTap(ref, index, item),
    );
  }

  void _handleNavigationTap(WidgetRef ref, int index, _NavigationItem item) {
    final accessibilityService = AccessibilityService();
    accessibilityService.announceToScreenReader('Navigation vers ${item.label}');
    ref.read(currentPageProvider.notifier).state = index;
  }
}

class _NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  const _NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}

class _PremiumNavItem extends StatefulWidget {
  final _NavigationItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _PremiumNavItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_PremiumNavItem> createState() => _PremiumNavItemState();
}

class _PremiumNavItemState extends State<_PremiumNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isActive) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(_PremiumNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildAccessibleContainer(
      child: _buildFocusableActionDetector(
        child: _buildInkWellButton(
          child: _buildAnimatedContent(),
        ),
      ),
    );
  }

  /// Construit le conteneur avec support d'accessibilité
  Widget _buildAccessibleContainer({required Widget child}) {
    return Semantics(
      button: true,
      label: widget.item.label,
      selected: widget.isActive,
      hint: widget.isActive
          ? 'Section actuelle'
          : 'Appuyez pour naviguer vers ${widget.item.label}',
      child: Container(
        constraints: BoxConstraints(
          minWidth: AccessibilityService.minTouchTargetSize,
          minHeight: AccessibilityService.minTouchTargetSize,
        ),
        child: child,
      ),
    );
  }

  /// Construit le détecteur d'actions focalisable avec raccourcis clavier
  Widget _buildFocusableActionDetector({required Widget child}) {
    return FocusableActionDetector(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.space): const ActivateIntent(),
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (ActivateIntent intent) {
            widget.onTap();
            return null;
          },
        ),
      },
      child: child,
    );
  }

  /// Construit le bouton InkWell avec effets visuels
  Widget _buildInkWellButton({required Widget child}) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadiusTokens.radiusMd,
      focusColor: widget.item.color.withValues(alpha: 0.2),
      hoverColor: widget.item.color.withValues(alpha: 0.1),
      splashColor: widget.item.color.withValues(alpha: 0.3),
      child: child,
    );
  }

  /// Construit le contenu animé du bouton
  Widget _buildAnimatedContent() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIconSection(),
              const SizedBox(height: 4),
              _buildLabelSection(),
              _buildActiveIndicator(),
            ],
          ),
        );
      },
    );
  }

  /// Construit la section icône avec effet de glow
  Widget _buildIconSection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        _buildIconBackground(),
        _buildAnimatedIcon(),
      ],
    );
  }

  /// Construit l'arrière-plan de l'icône avec effet glow
  Widget _buildIconBackground() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 32,
      decoration: BoxDecoration(
        color: widget.isActive
            ? widget.item.color.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadiusTokens.radiusLg,
      ),
    );
  }

  /// Construit l'icône animée avec transformation d'échelle
  Widget _buildAnimatedIcon() {
    return Transform.scale(
      scale: _scaleAnimation.value,
      child: Icon(
        widget.isActive ? widget.item.activeIcon : widget.item.icon,
        size: 24,
        color: widget.isActive
            ? widget.item.color
            : AppTheme.textTertiary,
      ),
    );
  }

  /// Construit la section label avec style animé
  Widget _buildLabelSection() {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: TextStyle(
        fontSize: 12,
        fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
        color: widget.isActive
            ? widget.item.color
            : AppTheme.textTertiary,
      ),
      child: Text(widget.item.label),
    );
  }

  /// Construit l'indicateur d'état actif
  Widget _buildActiveIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: widget.isActive ? 24 : 0,
      height: 2,
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: widget.item.color,
        borderRadius: BorderRadiusTokens.radiusNone,
      ),
    );
  }
} 
