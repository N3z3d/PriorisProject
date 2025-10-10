import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/data/providers/habits_state_provider.dart';
import 'package:prioris/presentation/pages/home_page.dart';

/// Page Insights refactorée selon les specs UX
/// - Tabs: "Aperçu | Tendances" (pas "Habitudes | Statistiques")
/// - Empty state cohérent: "Pas encore d'analyses"
/// - CTA unique: "Créer une habitude"
/// - Pas de FAB sur cette page
class InsightsPage extends ConsumerStatefulWidget {
  const InsightsPage({super.key});

  @override
  ConsumerState<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends ConsumerState<InsightsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTabBar(),
        Expanded(
          child: _buildTabBarView(),
        ),
      ],
    );
  }

  /// Construit la barre d'onglets Aperçu | Tendances (sans icônes)
  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: AppTheme.textTertiary,
        indicatorColor: AppTheme.primaryColor,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'Aperçu'),
          Tab(text: 'Tendances'),
        ],
      ),
    );
  }

  /// Construit le contenu des tabs avec empty states appropriés
  Widget _buildTabBarView() {
    final habits = ref.watch(reactiveHabitsProvider);
    final hasData = habits.isNotEmpty;

    return TabBarView(
      controller: _tabController,
      children: [
        hasData
            ? _buildOverviewTab()
            : _buildEmptyState(
                context,
                title: 'Pas encore d\'analyses',
                message: 'Créez votre première habitude pour voir vos progrès ici.',
              ),
        hasData
            ? _buildTrendsTab()
            : _buildEmptyState(
                context,
                title: 'Pas encore d\'analyses',
                message: 'Créez votre première habitude pour voir vos progrès ici.',
              ),
      ],
    );
  }

  /// Construit l'onglet Aperçu (statistiques principales)
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Aperçu des statistiques à venir',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construit l'onglet Tendances (graphiques)
  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Graphiques de tendances à venir',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construit un empty state cohérent (règle: un seul CTA)
  Widget _buildEmptyState(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insights_outlined,
              size: 80,
              color: AppTheme.textTertiary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildPrimaryCTA(context),
          ],
        ),
      ),
    );
  }

  /// CTA primaire unique: "Créer une habitude"
  Widget _buildPrimaryCTA(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => _navigateToHabits(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Créer une habitude',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Navigation vers la page Habitudes > Nouvelle
  void _navigateToHabits(BuildContext context) {
    // Change vers l'onglet Habitudes (index 2)
    ref.read(currentPageProvider.notifier).state = 2;
  }
}
