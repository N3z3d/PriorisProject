import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/pages/duel_page.dart';
import 'package:prioris/presentation/pages/habits_page.dart';
import 'package:prioris/presentation/pages/insights_page.dart';
import 'package:prioris/presentation/pages/lists_page.dart';
import 'package:prioris/presentation/pages/settings_page.dart';
import 'package:prioris/domain/services/ui/accessibility_service.dart';
import 'package:prioris/data/providers/auth_providers.dart';
import 'package:prioris/presentation/pages/home/models/navigation_item.dart';
import 'package:prioris/presentation/pages/home/widgets/desktop_sidebar.dart';
import 'package:prioris/presentation/pages/home/widgets/premium_bottom_nav.dart';

final currentPageProvider = StateProvider<int>((ref) => 0);

/// Page d'accueil principale avec navigation adaptative
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(currentPageProvider);
    final pages = _buildPages();
    final navigationItems = _getNavigationItems();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 768;

        if (isDesktop) {
          return _buildDesktopLayout(
            context,
            ref,
            currentPage,
            pages,
            navigationItems,
          );
        } else {
          return _buildMobileLayout(
            context,
            ref,
            currentPage,
            pages,
            navigationItems,
          );
        }
      },
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    WidgetRef ref,
    int currentPage,
    List<Widget> pages,
    List<NavigationItem> navigationItems,
  ) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Row(
        children: [
          DesktopSidebar(
            currentPage: currentPage,
            navigationItems: navigationItems,
            onNavigationTap: (index, item) =>
                _handleNavigationTap(ref, index, item),
          ),
          Expanded(
            child: Column(
              children: [
                _buildDesktopAppBar(context, ref, navigationItems, currentPage),
                Expanded(child: _buildBody(pages, currentPage)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    int currentPage,
    List<Widget> pages,
    List<NavigationItem> navigationItems,
  ) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(context, ref, navigationItems, currentPage),
      body: _buildBody(pages, currentPage),
      bottomNavigationBar: PremiumBottomNav(
        currentPage: currentPage,
        items: navigationItems,
        onNavigationTap: (index, item) => _handleNavigationTap(ref, index, item),
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

  List<NavigationItem> _getNavigationItems() {
    return [
      NavigationItem(
        icon: Icons.checklist_outlined,
        activeIcon: Icons.checklist,
        label: 'Listes',
        color: AppTheme.primaryColor,
      ),
      NavigationItem(
        icon: Icons.psychology_outlined,
        activeIcon: Icons.psychology,
        label: 'Priorisé',
        color: AppTheme.accentColor,
      ),
      NavigationItem(
        icon: Icons.trending_up_outlined,
        activeIcon: Icons.trending_up,
        label: 'Habitudes',
        color: AppTheme.warningColor,
      ),
      NavigationItem(
        icon: Icons.insights_outlined,
        activeIcon: Icons.insights,
        label: 'Insights',
        color: AppTheme.secondaryColor,
      ),
    ];
  }

  Widget _buildDesktopAppBar(
    BuildContext context,
    WidgetRef ref,
    List<NavigationItem> navigationItems,
    int currentPage,
  ) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: _buildAppBarActions(context, ref),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    List<NavigationItem> navigationItems,
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
          children: pages
              .map((page) => Semantics(
                    container: true,
                    child: page,
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _handleNavigationTap(
    WidgetRef ref,
    int index,
    NavigationItem item,
  ) {
    final accessibilityService = AccessibilityService();
    accessibilityService.announceToScreenReader('Navigation vers ${item.label}');
    ref.read(currentPageProvider.notifier).state = index;
  }
} 
