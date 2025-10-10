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
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        '📊 Statistiques',
        style: TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),
      ),
      backgroundColor: AppTheme.backgroundColor,
      foregroundColor: AppTheme.textPrimary,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: _buildTabBar(),
      ),
    );
  }

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
          Tab(text: 'Vue d\'ensemble'),
          Tab(text: 'Habitudes'),
          Tab(text: 'Tâches'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildPeriodSelector(),
        Expanded(
          child: _buildTabBarView(),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return PeriodSelector(
      selectedPeriod: _statisticsController.selectedPeriod,
      onPeriodChanged: (period) {
        _statisticsController.setPeriod(period);
        setState(() {});
      },
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildHabitsTab(),
        _buildTasksTab(),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return FutureBuilder<Map<String, dynamic>>(
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
    );
  }

  Widget _buildHabitsTab() {
    return FutureBuilder<List<Habit>>(
      future: _loadHabits(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return HabitsTabWidget(
            habits: snapshot.data!,
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildTasksTab() {
    return FutureBuilder<List<Task>>(
      future: _loadTasks(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return TasksTabWidget(
            tasks: snapshot.data!,
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
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

