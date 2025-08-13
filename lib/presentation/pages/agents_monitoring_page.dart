import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/services/core/agent_monitoring_service.dart';

class AgentsMonitoringPage extends ConsumerWidget {
  const AgentsMonitoringPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agents = ref.watch(agentMonitoringProvider);
    final statusSummary = ref.watch(agentStatusSummaryProvider);
    final performance = ref.watch(overallPerformanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring des Agents'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(statusSummary, performance),
            const SizedBox(height: 20),
            const Text(
              'Statut des Agents',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: agents.length,
                itemBuilder: (context, index) {
                  final agent = agents.values.toList()[index];
                  return _buildAgentCard(agent);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      Map<AgentStatus, int> statusSummary, double performance) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Résumé Global',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusIndicator(
                  'Actifs',
                  statusSummary[AgentStatus.working] ?? 0,
                  Colors.green,
                ),
                _buildStatusIndicator(
                  'Inactifs',
                  statusSummary[AgentStatus.idle] ?? 0,
                  Colors.grey,
                ),
                _buildStatusIndicator(
                  'Complétés',
                  statusSummary[AgentStatus.completed] ?? 0,
                  Colors.blue,
                ),
                _buildStatusIndicator(
                  'Erreurs',
                  statusSummary[AgentStatus.error] ?? 0,
                  Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 15),
            LinearProgressIndicator(
              value: performance,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                performance > 0.8 ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Performance globale: ${(performance * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildAgentCard(AgentInfo agent) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(agent.status),
          child: Icon(
            _getAgentIcon(agent.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          agent.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              agent.currentTask ?? 'En attente',
              style: TextStyle(
                color: agent.currentTask != null ? Colors.black87 : Colors.grey,
              ),
            ),
            Text(
              'Tâches complétées: ${agent.completedTasks}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildStatusChip(agent.status),
            Text(
              'Perf: ${(agent.performance * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(AgentStatus status) {
    switch (status) {
      case AgentStatus.working:
        return Colors.green;
      case AgentStatus.idle:
        return Colors.grey;
      case AgentStatus.completed:
        return Colors.blue;
      case AgentStatus.error:
        return Colors.red;
    }
  }

  IconData _getAgentIcon(AgentType type) {
    switch (type) {
      case AgentType.task:
        return Icons.task_alt;
      case AgentType.habit:
        return Icons.repeat;
      case AgentType.list:
        return Icons.list_alt;
      case AgentType.statistics:
        return Icons.bar_chart;
      case AgentType.duel:
        return Icons.sports_mma;
      case AgentType.cache:
        return Icons.storage;
      case AgentType.validation:
        return Icons.verified_user;
    }
  }

  Widget _buildStatusChip(AgentStatus status) {
    String label;
    Color color;

    switch (status) {
      case AgentStatus.working:
        label = 'Actif';
        color = Colors.green;
        break;
      case AgentStatus.idle:
        label = 'Inactif';
        color = Colors.grey;
        break;
      case AgentStatus.completed:
        label = 'Terminé';
        color = Colors.blue;
        break;
      case AgentStatus.error:
        label = 'Erreur';
        color = Colors.red;
        break;
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}