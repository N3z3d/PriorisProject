import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/repositories/task_repository.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/pages/statistics/controllers/statistics_controller.dart';
import 'package:prioris/presentation/pages/statistics/widgets/smart/period_selector.dart';
import 'package:prioris/presentation/pages/statistics/widgets/summary/overview_tab_widget.dart';
import 'package:prioris/presentation/pages/statistics/widgets/tabs/habits_tab_widget.dart';
import 'package:prioris/presentation/pages/statistics/widgets/tabs/tasks_tab_widget.dart';

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late StatisticsController _statisticsController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _statisticsController = StatisticsController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _statisticsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          '📊 Statistiques',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryVariant,
              ],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          // Fix: Using AppTheme.grey100 instead of white70 for better contrast
          unselectedLabelColor: AppTheme.grey100.withValues(alpha: 0.8),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Vue d\'ensemble'),
            Tab(text: 'Habitudes'),
            Tab(text: 'Tâches'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Sélecteur de période
          PeriodSelector(
            selectedPeriod: _statisticsController.selectedPeriod,
            onPeriodChanged: (period) {
              _statisticsController.setPeriod(period);
              setState(() {});
            },
          ),
          // Contenu des onglets
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Vue d'ensemble
                FutureBuilder<Map<String, dynamic>>(
                  future: _loadData(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final data = snapshot.data!;
                      return OverviewTabWidget(
                        selectedPeriod: _statisticsController.selectedPeriod,
                        habits: data['habits'] as List<Habit>,
                        tasks: data['tasks'] as List<Task>,
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
                // Habitudes
                FutureBuilder<List<Habit>>(
                  future: _loadHabits(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return HabitsTabWidget(
                        habits: snapshot.data!,
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
                // Tâches
                FutureBuilder<List<Task>>(
                  future: _loadTasks(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return TasksTabWidget(
                        tasks: snapshot.data!,
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _loadData() async {
    final habitRepo = ref.read(habitRepositoryProvider);
    final taskRepo = ref.read(taskRepositoryProvider);
    
    final habits = await habitRepo.getAllHabits();
    final tasks = await taskRepo.getAllTasks();
    
    return {
      'habits': habits,
      'tasks': tasks,
    };
  }

  Future<List<Habit>> _loadHabits() async {
    final habitRepo = ref.read(habitRepositoryProvider);
    return await habitRepo.getAllHabits();
  }

  Future<List<Task>> _loadTasks() async {
    final taskRepo = ref.read(taskRepositoryProvider);
    return await taskRepo.getAllTasks();
  }
} 

