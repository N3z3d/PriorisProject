import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Widget affichant le graphique des séries d'habitudes (BarChart)
///
/// [habits] : Liste des habitudes pour calculer les séries
/// [habitNames] : Noms des habitudes à afficher sur l'axe X
/// [streakData] : Données des séries pour chaque habitude
class StreaksChartWidget extends StatelessWidget {
  final List<String> habitNames;
  final List<double> streakData;

  const StreaksChartWidget({
    super.key,
    required this.habitNames,
    required this.streakData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusTokens.card),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔥 Évolution des Séries',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < habitNames.length) {
                            return Text(
                              habitNames[value.toInt()],
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _buildBarGroups(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit les groupes de barres pour le graphique
  List<BarChartGroupData> _buildBarGroups() {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
      AppTheme.successColor,
    ];

    return List.generate(
      streakData.length,
      (index) => BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: streakData[index],
            color: colors[index % colors.length],
          ),
        ],
      ),
    );
  }
} 
