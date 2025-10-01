/// SOLID Habits Page Header Component
/// Single Responsibility: Handle header UI and styling only

import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import '../interfaces/habits_page_interfaces.dart';

/// Concrete implementation of habits page header
/// Follows Single Responsibility Principle - only handles header UI
class HabitsPageHeader implements IHabitsPageHeader {
  final IHabitsPageTheme _themeProvider;

  const HabitsPageHeader({
    required IHabitsPageTheme themeProvider,
  }) : _themeProvider = themeProvider;

  @override
  Widget buildHeader({required TabController tabController}) {
    return Container(
      decoration: _themeProvider.getHeaderDecoration(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderTitle(),
              const SizedBox(height: 16),
              _buildTabBar(tabController),
            ],
          ),
        ),
      ),
    );
  }

  @override
  PreferredSizeWidget buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      toolbarHeight: 0, // Hide the toolbar since we have custom header
    );
  }

  /// Build the premium header title section
  Widget _buildHeaderTitle() {
    return Row(
      children: [
        // Premium icon with gradient
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF6366f1), // Indigo-500
                Color(0xFF8b5cf6), // Violet-500
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366f1).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.track_changes_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),

        const SizedBox(width: 16),

        // Title with premium styling
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mes Habitudes',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Créez et suivez vos habitudes quotidiennes',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build the premium styled tab bar
  Widget _buildTabBar(TabController tabController) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorPadding: const EdgeInsets.all(2),
        labelColor: const Color(0xFF1e293b),
        unselectedLabelColor: Colors.white.withOpacity(0.8),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.list_rounded, size: 18),
            text: 'Habitudes',
          ),
          Tab(
            icon: Icon(Icons.add_circle_rounded, size: 18),
            text: 'Ajouter',
          ),
        ],
      ),
    );
  }
}

/// Header theme provider implementation
class HabitsPageThemeProvider implements IHabitsPageTheme {
  @override
  BoxDecoration getHeaderDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1e293b), // Slate-800
          Color(0xFF0f172a), // Slate-900
        ],
        stops: [0.0, 1.0],
      ),
    );
  }

  @override
  BoxDecoration getCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(BorderRadiusTokens.lg),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
      border: Border.all(
        color: Colors.grey.withOpacity(0.1),
        width: 1,
      ),
    );
  }

  @override
  BoxDecoration getAvatarDecoration(Habit habit) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          getHabitTypeColor(habit.type?.name ?? 'default'),
          getHabitTypeColor(habit.type?.name ?? 'default').withOpacity(0.7),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: getHabitTypeColor(habit.type?.name ?? 'default').withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  @override
  Color getHabitTypeColor(String habitType) {
    switch (habitType.toLowerCase()) {
      case 'health':
        return const Color(0xFF10b981); // Emerald-500
      case 'productivity':
        return const Color(0xFF3b82f6); // Blue-500
      case 'mindfulness':
        return const Color(0xFF8b5cf6); // Violet-500
      case 'social':
        return const Color(0xFFf59e0b); // Amber-500
      case 'learning':
        return const Color(0xFFef4444); // Red-500
      default:
        return const Color(0xFF6b7280); // Gray-500
    }
  }

  @override
  ThemeData getProgressTheme() {
    return ThemeData(
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF6366f1),
        linearTrackColor: Color(0xFFe2e8f0),
      ),
    );
  }
}