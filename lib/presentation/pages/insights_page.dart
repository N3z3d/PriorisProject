import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/habits_state_provider.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/domain/services/calculation/habit_calculation_service.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/home_page.dart';
import 'package:prioris/presentation/pages/statistics/widgets/smart/smart_insights_widget.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/common/displays/premium_card.dart';
import 'package:prioris/presentation/widgets/common/headers/unified_page_header.dart';
import 'package:prioris/presentation/widgets/loading/advanced_loading_widget.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(habitsStateProvider.notifier).loadHabits();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(reactiveHabitsProvider);
    final isLoading = ref.watch(habitsLoadingProvider);
    final error = ref.watch(habitsErrorProvider);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        _buildPageHeader(habits.length, l10n),
        _buildTabBar(l10n),
        Expanded(
          child: error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: AdvancedErrorWidget(
                      message: error,
                      onRetry: () =>
                          ref.read(habitsStateProvider.notifier).loadHabits(),
                    ),
                  ),
                )
              : isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildTabBarView(habits, l10n),
        ),
      ],
    );
  }

  Widget _buildPageHeader(int habitCount, AppLocalizations l10n) {
    return UnifiedPageHeader(
      icon: Icons.insights,
      title: l10n.insightsHeaderTitle,
      subtitle: habitCount > 0
          ? l10n.insightsHeaderSubtitleWithHabits(habitCount)
          : l10n.insightsHeaderSubtitleEmpty,
      iconColor: AppTheme.secondaryColor,
    );
  }

  Widget _buildTabBar(AppLocalizations l10n) {
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
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        tabs: [
          Tab(text: l10n.insightsTabOverview),
          Tab(text: l10n.insightsTabTrends),
        ],
      ),
    );
  }

  Widget _buildTabBarView(List<Habit> habits, AppLocalizations l10n) {
    final hasData = habits.isNotEmpty;

    return TabBarView(
      controller: _tabController,
      children: [
        hasData
            ? _buildOverviewTab(habits, l10n)
            : _buildEmptyState(context, l10n),
        hasData
            ? _buildTrendsTab(habits, l10n)
            : _buildEmptyState(context, l10n),
      ],
    );
  }

  Widget _buildOverviewTab(List<Habit> habits, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SmartInsightsWidget(
        insights: HabitCalculationService.generateHabitInsights(habits),
      ),
    );
  }

  Widget _buildTrendsTab(List<Habit> habits, AppLocalizations l10n) {
    final successRate = HabitCalculationService.calculateSuccessRate(habits);
    final streak = HabitCalculationService.calculateCurrentStreak(habits);
    final todayRate = HabitCalculationService.calculateTodayCompletionRate(habits);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMetricCard(l10n.insightsTrendsSuccessRate, '$successRate%'),
          const SizedBox(height: 12),
          _buildMetricCard(l10n.insightsTrendsStreak, l10n.insightsTrendsStreakDays(streak)),
          const SizedBox(height: 12),
          _buildMetricCard(l10n.insightsTrendsToday, '$todayRate%'),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value) {
    return PremiumCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
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
              l10n.insightsEmptyTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.insightsEmptyBody,
              style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildPrimaryCTA(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryCTA(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => _navigateToHabits(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          l10n.insightsCtaCreateHabit,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _navigateToHabits() {
    ref.read(currentPageProvider.notifier).state = 2;
  }
}
