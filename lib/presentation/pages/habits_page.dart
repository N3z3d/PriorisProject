import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/habits_state_provider.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/pages/habits/controllers/habits_controller.dart';
import 'package:prioris/presentation/pages/habits/components/habits_header.dart';
import 'package:prioris/presentation/pages/habits/components/habits_body.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Refactored HabitsPage following SOLID principles and Clean Architecture
/// - Single Responsibility: Only handles page structure and coordination
/// - Open/Closed: Extensible through component injection
/// - Liskov Substitution: Components are interchangeable
/// - Interface Segregation: Focused component interfaces
/// - Dependency Inversion: Depends on abstractions, not concretions
class HabitsPage extends ConsumerStatefulWidget {
  const HabitsPage({super.key});

  @override
  ConsumerState<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends ConsumerState<HabitsPage> with TickerProviderStateMixin {
  late HabitsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(habitsControllerProvider(this).notifier);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final habits = ref.watch(reactiveHabitsProvider);
        final isLoading = ref.watch(habitsLoadingProvider);
        final error = ref.watch(habitsErrorProvider);
        final controllerState = ref.watch(habitsControllerProvider(this));

        // Auto-load habits if needed
        _autoLoadHabitsIfNeeded(habits, isLoading, error);

        // Handle action results
        _handleActionResults(context, controllerState);

        return Scaffold(
          body: Column(
            children: [
              HabitsHeader(tabController: _controller.tabController),
              Expanded(
                child: HabitsBody(
                  tabController: _controller.tabController,
                  habits: habits,
                  isLoading: isLoading,
                  error: error,
                  onAddHabit: _controller.addHabit,
                  onDeleteHabit: _showDeleteConfirmation,
                  onRecordHabit: _controller.recordHabit,
                  onNavigateToAdd: _controller.navigateToAddTab,
                ),
              ),
            ],
          ),
          floatingActionButton: _buildFloatingActionButton(context),
        );
      },
    );
  }

  void _autoLoadHabitsIfNeeded(List<Habit> habits, bool isLoading, String? error) {
    if (habits.isEmpty && !isLoading && error == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(habitsStateProvider.notifier).loadHabits();
      });
    }
  }

  void _handleActionResults(BuildContext context, HabitsControllerState state) {
    if (state.lastActionMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.lastActionMessage!),
            backgroundColor: state.actionResult == ActionResult.success
                ? AppTheme.successColor
                : AppTheme.errorColor,
          ),
        );
        _controller.clearLastAction();
      });
    }
  }

  void _showDeleteConfirmation(String habitId, String habitName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'habitude'),
        content: Text('Êtes-vous sûr de vouloir supprimer "$habitName" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _controller.deleteHabit(habitId, habitName);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    // Hide FAB on desktop (>= 768px), show only on mobile
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    if (isDesktop) return null;

    return FloatingActionButton(
      heroTag: 'habits_fab',
      onPressed: _controller.navigateToAddTab,
      backgroundColor: AppTheme.accentColor,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

