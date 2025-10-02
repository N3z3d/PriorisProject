import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AgentStatus {
  idle,
  working,
  completed,
  error,
}

enum AgentType {
  task,
  habit,
  list,
  statistics,
  duel,
  cache,
  validation,
}

class AgentInfo {
  final String id;
  final String name;
  final AgentType type;
  final AgentStatus status;
  final DateTime lastActivity;
  final String? currentTask;
  final int completedTasks;
  final double performance;

  AgentInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.lastActivity,
    this.currentTask,
    this.completedTasks = 0,
    this.performance = 1.0,
  });

  AgentInfo copyWith({
    AgentStatus? status,
    DateTime? lastActivity,
    String? currentTask,
    int? completedTasks,
    double? performance,
  }) {
    return AgentInfo(
      id: id,
      name: name,
      type: type,
      status: status ?? this.status,
      lastActivity: lastActivity ?? this.lastActivity,
      currentTask: currentTask ?? this.currentTask,
      completedTasks: completedTasks ?? this.completedTasks,
      performance: performance ?? this.performance,
    );
  }
}

class AgentMonitoringService extends StateNotifier<Map<String, AgentInfo>> {
  AgentMonitoringService() : super({}) {
    _initializeAgents();
  }

  void _initializeAgents() {
    final now = DateTime.now();
    final taskAgent = _createTaskAgent(now);
    final habitAgent = _createHabitAgent(now);
    final listAgent = _createListAgent(now);
    final statsAgent = _createStatsAgent(now);
    final duelAgent = _createDuelAgent(now);
    final cacheAgent = _createCacheAgent(now);
    final validationAgent = _createValidationAgent(now);

    state = {
      taskAgent.id: taskAgent,
      habitAgent.id: habitAgent,
      listAgent.id: listAgent,
      statsAgent.id: statsAgent,
      duelAgent.id: duelAgent,
      cacheAgent.id: cacheAgent,
      validationAgent.id: validationAgent,
    };
  }

  /// Create task agent with initial configuration
  AgentInfo _createTaskAgent(DateTime now) {
    return AgentInfo(
      id: 'task-agent',
      name: 'Task Manager',
      type: AgentType.task,
      status: AgentStatus.idle,
      lastActivity: now,
      completedTasks: 0,
      performance: 0.95,
    );
  }

  /// Create habit agent with initial configuration
  AgentInfo _createHabitAgent(DateTime now) {
    return AgentInfo(
      id: 'habit-agent',
      name: 'Habit Tracker',
      type: AgentType.habit,
      status: AgentStatus.idle,
      lastActivity: now,
      completedTasks: 0,
      performance: 0.98,
    );
  }

  /// Create list agent with initial configuration
  AgentInfo _createListAgent(DateTime now) {
    return AgentInfo(
      id: 'list-agent',
      name: 'List Organizer',
      type: AgentType.list,
      status: AgentStatus.working,
      lastActivity: now,
      currentTask: 'Synchronizing lists',
      completedTasks: 15,
      performance: 0.92,
    );
  }

  /// Create statistics agent with initial configuration
  AgentInfo _createStatsAgent(DateTime now) {
    return AgentInfo(
      id: 'stats-agent',
      name: 'Statistics Analyzer',
      type: AgentType.statistics,
      status: AgentStatus.idle,
      lastActivity: now,
      completedTasks: 8,
      performance: 0.99,
    );
  }

  /// Create duel agent with initial configuration
  AgentInfo _createDuelAgent(DateTime now) {
    return AgentInfo(
      id: 'duel-agent',
      name: 'Duel Processor',
      type: AgentType.duel,
      status: AgentStatus.error,
      lastActivity: now,
      currentTask: 'RenderFlex layout error',
      completedTasks: 3,
      performance: 0.75,
    );
  }

  /// Create cache agent with initial configuration
  AgentInfo _createCacheAgent(DateTime now) {
    return AgentInfo(
      id: 'cache-agent',
      name: 'Cache Manager',
      type: AgentType.cache,
      status: AgentStatus.completed,
      lastActivity: now,
      completedTasks: 42,
      performance: 1.0,
    );
  }

  /// Create validation agent with initial configuration
  AgentInfo _createValidationAgent(DateTime now) {
    return AgentInfo(
      id: 'validation-agent',
      name: 'Data Validator',
      type: AgentType.validation,
      status: AgentStatus.idle,
      lastActivity: now,
      completedTasks: 27,
      performance: 0.96,
    );
  }

  void updateAgentStatus(String agentId, AgentStatus status, [String? task]) {
    final agent = state[agentId];
    if (agent != null) {
      state = {
        ...state,
        agentId: agent.copyWith(
          status: status,
          lastActivity: DateTime.now(),
          currentTask: task,
          completedTasks: status == AgentStatus.completed
              ? agent.completedTasks + 1
              : agent.completedTasks,
        ),
      };
    }
  }

  List<AgentInfo> get activeAgents {
    return state.values
        .where((agent) => agent.status == AgentStatus.working)
        .toList();
  }

  List<AgentInfo> get allAgents {
    return state.values.toList()
      ..sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
  }

  Map<AgentStatus, int> get statusSummary {
    final summary = <AgentStatus, int>{};
    for (final agent in state.values) {
      summary[agent.status] = (summary[agent.status] ?? 0) + 1;
    }
    return summary;
  }

  double get overallPerformance {
    if (state.isEmpty) return 0;
    final totalPerf = state.values.fold<double>(
      0,
      (sum, agent) => sum + agent.performance,
    );
    return totalPerf / state.length;
  }
}

final agentMonitoringProvider =
    StateNotifierProvider<AgentMonitoringService, Map<String, AgentInfo>>(
  (ref) => AgentMonitoringService(),
);

final activeAgentsProvider = Provider<List<AgentInfo>>((ref) {
  final service = ref.watch(agentMonitoringProvider.notifier);
  return service.activeAgents;
});

final agentStatusSummaryProvider = Provider<Map<AgentStatus, int>>((ref) {
  final service = ref.watch(agentMonitoringProvider.notifier);
  return service.statusSummary;
});

final overallPerformanceProvider = Provider<double>((ref) {
  final service = ref.watch(agentMonitoringProvider.notifier);
  return service.overallPerformance;
});