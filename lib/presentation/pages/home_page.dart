import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/pages/duel_page.dart';
import 'package:prioris/presentation/pages/habits_page.dart';
import 'package:prioris/presentation/pages/statistics_page.dart';
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
    
    final pages = [
      const ListsPage(), // Listes et tâches
      const DuelPage(),
      const HabitsPage(), // Habitudes séparées
      const StatisticsPage(), // Statistiques/Insights
    ];

    final navigationItems = [
      _NavigationItem(
        icon: Icons.checklist_outlined,
        activeIcon: Icons.checklist,
        label: 'Listes',
        color: AppTheme.primaryColor,
      ),
      _NavigationItem(
        icon: Icons.psychology_outlined,
        activeIcon: Icons.psychology,
        label: 'Prioriser',
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

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.cardColor,
        elevation: 0,
        title: Semantics(
          header: true,
          child: Text(
            navigationItems[currentPage].label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
        actions: [
          // Bouton de déconnexion
          Semantics(
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
                onPressed: () async {
                  final authController = ref.read(authControllerProvider);
                  await authController.signOut();
                },
              ),
            ),
          ),
          
          // Bouton paramètres
          Semantics(
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
          ),
        ],
      ),
      body: SafeArea(
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
      ),
      bottomNavigationBar: _buildPremiumBottomNav(
        context,
        ref,
        currentPage,
        navigationItems,
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
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isActive = currentPage == index;

                return _PremiumNavItem(
                  item: item,
                  isActive: isActive,
                  onTap: () {
                    final accessibilityService = AccessibilityService();
                    
                    // Annoncer le changement de page
                    accessibilityService.announceToScreenReader(
                      'Navigation vers ${item.label}'
                    );
                    
                    ref.read(currentPageProvider.notifier).state = index;
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
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
    // final accessibilityService = AccessibilityService(); // TODO: Utiliser le service
    
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
        child: FocusableActionDetector(
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
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadiusTokens.radiusMd,
            focusColor: widget.item.color.withValues(alpha: 0.2),
            hoverColor: widget.item.color.withValues(alpha: 0.1),
            splashColor: widget.item.color.withValues(alpha: 0.3),
            child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background glow effect
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48,
                        height: 32,
                        decoration: BoxDecoration(
                          color: widget.isActive
                              ? widget.item.color.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadiusTokens.radiusLg,
                        ),
                      ),
                      // Icon
                      Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Icon(
                          widget.isActive ? widget.item.activeIcon : widget.item.icon,
                          size: 24,
                          color: widget.isActive
                              ? widget.item.color
                              : AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Label
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
                      color: widget.isActive
                          ? widget.item.color
                          : AppTheme.textTertiary,
                    ),
                    child: Text(widget.item.label),
                  ),
                  // Active indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: widget.isActive ? 24 : 0,
                    height: 2,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: widget.item.color,
                      borderRadius: BorderRadiusTokens.radiusNone,
                    ),
                  ),
                ],
              ),
            );
          },
            ),
          ),
        ),
      ),
    );
  }
} 
