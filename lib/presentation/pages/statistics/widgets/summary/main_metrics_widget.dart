import 'package:flutter/material.dart';
import 'package:prioris/presentation/pages/statistics/widgets/summary/metric_card.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Widget affichant les métriques principales de performance globale
/// (taux habitudes, taux tâches, série actuelle, points totaux)
///
/// Utilise un FutureBuilder pour gérer le chargement asynchrone des données.
class MainMetricsWidget extends StatelessWidget {
  /// Future retournant les métriques principales (clé/valeur)
  final Future<Map<String, dynamic>> metricsFuture;

  const MainMetricsWidget({
    super.key,
    required this.metricsFuture,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: metricsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingState();
        }
        final metrics = snapshot.data!;
        return _buildMetricsCard(metrics);
      },
    );
  }

  /// Construit l'état de chargement des métriques
  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  /// Construit la carte principale contenant les métriques
  Widget _buildMetricsCard(Map<String, dynamic> metrics) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusTokens.card),
      child: Container(
        decoration: _buildCardDecoration(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildTopMetricsRow(metrics),
            const SizedBox(height: 12),
            _buildBottomMetricsRow(metrics),
          ],
        ),
      ),
    );
  }

  /// Construit la décoration du conteneur de métriques
  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadiusTokens.card,
      // Style professionnel avec fond unis
      color: const Color(0xFF6B73FF),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF6B73FF).withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Construit l'en-tête de la section métriques
  Widget _buildHeader() {
    return const Text(
      '🎯 Performance Globale',
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Construit la rangée supérieure de métriques (taux habitudes et tâches)
  Widget _buildTopMetricsRow(Map<String, dynamic> metrics) {
    return Row(
      children: [
        Expanded(
          child: MetricCard(
            value: '${metrics['habitSuccessRate']}%',
            label: 'Taux habitudes',
            icon: Icons.trending_up,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MetricCard(
            value: '${metrics['taskCompletionRate']}%',
            label: 'Taux tâches',
            icon: Icons.task_alt,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  /// Construit la rangée inférieure de métriques (série et points)
  Widget _buildBottomMetricsRow(Map<String, dynamic> metrics) {
    return Row(
      children: [
        Expanded(
          child: MetricCard(
            value: '${metrics['currentStreak']}',
            label: 'Série actuelle',
            icon: Icons.local_fire_department,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MetricCard(
            value: '${metrics['totalPoints']}',
            label: 'Points totaux',
            icon: Icons.stars,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
} 
