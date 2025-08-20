import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Widget affichant le graphique d'évolution des performances (LineChart)
///
/// [data] : Liste des points à afficher (FlSpot) - ne doit pas être vide
/// [periodLabels] : Labels pour l'axe des X (ex: ['Lun', 'Mar', ...]) - doit correspondre à data.length
/// [title] : Titre du graphique (optionnel)
/// [height] : Hauteur du graphique (par défaut 200)
class ProgressChartWidget extends StatelessWidget {
  final List<FlSpot> data;
  final List<String> periodLabels;
  final String? title;
  final double height;

  const ProgressChartWidget({
    super.key,
    required this.data,
    required this.periodLabels,
    this.title,
    this.height = 200,
  }) : assert(data.length > 0, 'Data cannot be empty'),
       assert(data.length == periodLabels.length, 'Data and periodLabels must have same length');

  @override
  Widget build(BuildContext context) {
    // Calcul des bornes dynamiques
    final dataValues = data.map((spot) => spot.y).toList();
    final minValue = dataValues.reduce((a, b) => a < b ? a : b);
    final maxValue = dataValues.reduce((a, b) => a > b ? a : b);
    
    // Ajout de marge (10% de chaque côté)
    final range = maxValue - minValue;
    final margin = range > 0 ? range * 0.1 : 10;
    final dynamicMinY = (minValue - margin).clamp(0.0, double.infinity);
    final dynamicMaxY = maxValue + margin;

    return Semantics(
      label: 'Graphique d\'évolution des performances',
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusTokens.card),
        child: Padding(
          padding: EdgeInsets.all(AppTheme.isMobile(context) ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title ?? 'Évolution des Performances',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: height,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      drawHorizontalLine: true,
                      verticalInterval: 1,
                      horizontalInterval: 1,
                      getDrawingVerticalLine: (value) => FlLine(
                        color: AppTheme.grey300,
                        strokeWidth: 1,
                      ),
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: AppTheme.grey300,
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}%',
                              style: Theme.of(context).textTheme.bodySmall,
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < periodLabels.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  periodLabels[index],
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: AppTheme.grey300, width: 1),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: data,
                        isCurved: true,
                        color: AppTheme.primaryColor,
                        barWidth: 3,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: AppTheme.primaryColor,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.primaryColor.withOpacity(0.2),
                              AppTheme.primaryColor.withOpacity(0.05),
                            ],
                          ),
                        ),
                      ),
                    ],
                    minY: dynamicMinY,
                    maxY: dynamicMaxY,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
