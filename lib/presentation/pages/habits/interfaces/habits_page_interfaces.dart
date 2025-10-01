/// SOLID Habits Page Interfaces
/// Following Interface Segregation Principle - separate interfaces for different UI concerns

import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';

/// Interface for habit page header components
abstract class IHabitsPageHeader {
  /// Build the contextual header with premium styling
  Widget buildHeader({required TabController tabController});

  /// Build the app bar for the habits page
  PreferredSizeWidget buildAppBar();
}

/// Interface for habit page body content
abstract class IHabitsPageBody {
  /// Build the main body content with tabs
  Widget buildBody({
    required List<Habit> habits,
    required bool isLoading,
    required String? error,
    required TabController tabController,
  });

  /// Build the habits tab content
  Widget buildHabitsTab({
    required List<Habit> habits,
    required bool isLoading,
    required String? error,
  });

  /// Build the add habit tab content
  Widget buildAddTab();
}

/// Interface for habit list components
abstract class IHabitsListView {
  /// Build the habits list with virtualization
  Widget buildHabitsList(List<Habit> habits);

  /// Build individual habit card
  Widget buildHabitCard(Habit habit);

  /// Build empty state when no habits exist
  Widget buildEmptyState();

  /// Build error state when loading fails
  Widget buildErrorState(Object error);
}

/// Interface for habit card components
abstract class IHabitCardBuilder {
  /// Build complete habit card
  Widget buildHabitCard(Habit habit);

  /// Build habit avatar/icon
  Widget buildHabitAvatar(Habit habit);

  /// Build habit title
  Widget buildHabitTitle(Habit habit);

  /// Build habit subtitle/description
  Widget buildHabitSubtitle(Habit habit);

  /// Build habit action menu
  Widget buildHabitMenu(Habit habit, {required VoidCallback onMenuSelected});

  /// Build habit progress indicator
  Widget buildHabitProgress(Habit habit);
}

/// Interface for habit actions and event handling
abstract class IHabitActionHandler {
  /// Handle habit action (record, edit, delete)
  void handleHabitAction(String action, Habit habit);

  /// Record a habit completion
  Future<void> recordHabit(Habit habit);

  /// Edit an existing habit
  Future<void> editHabit(Habit habit);

  /// Delete a habit with confirmation
  Future<void> deleteHabit(Habit habit);

  /// Add a new habit
  Future<void> addNewHabit();
}

/// Interface for habits page state management
abstract class IHabitsPageState {
  /// Get current habits list
  List<Habit> get habits;

  /// Get loading state
  bool get isLoading;

  /// Get error state
  String? get error;

  /// Load habits from data source
  Future<void> loadHabits();

  /// Refresh habits data
  Future<void> refreshHabits();

  /// Update specific habit
  Future<void> updateHabit(Habit habit);
}

/// Interface for habits page navigation
abstract class IHabitsPageNavigation {
  /// Navigate to habit detail page
  Future<void> navigateToHabitDetail(Habit habit);

  /// Navigate to habit creation page
  Future<void> navigateToHabitCreation();

  /// Navigate to habit statistics
  Future<void> navigateToHabitStatistics();

  /// Handle back navigation
  void handleBackNavigation();
}

/// Interface for habits page theme and styling
abstract class IHabitsPageTheme {
  /// Get contextual header decoration
  BoxDecoration getHeaderDecoration();

  /// Get premium card decoration
  BoxDecoration getCardDecoration();

  /// Get habit avatar decoration
  BoxDecoration getAvatarDecoration(Habit habit);

  /// Get theme colors for habit types
  Color getHabitTypeColor(String habitType);

  /// Get progress indicator theme
  ThemeData getProgressTheme();
}