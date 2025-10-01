import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/indicators/premium_status_indicator.dart';

/// Premium Metrics Dashboard with sophisticated cards and animations
///
/// Features:
/// - Glassmorphism metric cards with subtle animations
/// - Color-coded performance indicators
/// - Responsive grid layout
/// - Premium micro-interactions
/// - Accessibility-compliant design
class PremiumMetricsDashboard extends StatefulWidget {
  final Map<String, dynamic> metrics;
  final bool enableAnimations;

  const PremiumMetricsDashboard({
    super.key,
    required this.metrics,
    this.enableAnimations = true,
  });

  @override
  State<PremiumMetricsDashboard> createState() => _PremiumMetricsDashboardState();
}

class _PremiumMetricsDashboardState extends State<PremiumMetricsDashboard>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    final metricCount = _getMetricCards().length;
    _controllers = List.generate(
      metricCount,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 100)),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ));
    }).toList();

    if (widget.enableAnimations) {
      for (int i = 0; i < _controllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 150), () {
          if (mounted) {
            _controllers[i].forward();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metricCards = _getMetricCards();

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: metricCards.length,
          itemBuilder: (context, index) {
            return widget.enableAnimations
                ? AnimatedBuilder(
                    animation: _animations[index],
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _animations[index].value,
                        child: Opacity(
                          opacity: _animations[index].value,
                          child: metricCards[index],
                        ),
                      );
                    },
                  )
                : metricCards[index];
          },
        );
      },
    );
  }

  int _getCrossAxisCount(double width) {
    if (width > 900) return 4;
    if (width > 600) return 3;
    if (width > 400) return 2;
    return 1;
  }

  List<Widget> _getMetricCards() {
    return [
      _buildMetricCard(
        title: 'Tâches terminées',
        value: widget.metrics['completedTasks']?.toString() ?? '0',
        subtitle: 'cette semaine',
        icon: Icons.check_circle_rounded,
        color: AppTheme.successColor,
        trend: _calculateTrend('completedTasks'),
      ),
      _buildMetricCard(
        title: 'Tâches en cours',
        value: widget.metrics['activeTasks']?.toString() ?? '0',
        subtitle: 'actuellement',
        icon: Icons.play_circle_outline_rounded,
        color: AppTheme.primaryColor,
        trend: _calculateTrend('activeTasks'),
      ),
      _buildMetricCard(
        title: 'Taux de réussite',
        value: '${widget.metrics['completionRate']?.toStringAsFixed(1) ?? '0.0'}%',
        subtitle: 'performance globale',
        icon: Icons.trending_up_rounded,
        color: AppTheme.accentSecondary,
        trend: _calculateTrend('completionRate'),
      ),
      _buildMetricCard(
        title: 'Habitudes actives',
        value: widget.metrics['activeHabits']?.toString() ?? '0',
        subtitle: 'en développement',
        icon: Icons.repeat_rounded,
        color: AppTheme.accentColor,
        trend: _calculateTrend('activeHabits'),
      ),
      _buildMetricCard(
        title: 'Score ELO moyen',
        value: widget.metrics['averageElo']?.toStringAsFixed(0) ?? '1000',
        subtitle: 'performance',
        icon: Icons.star_rounded,
        color: AppTheme.warningColor,
        trend: _calculateTrend('averageElo'),
      ),
      _buildMetricCard(
        title: 'Streak actuel',
        value: widget.metrics['currentStreak']?.toString() ?? '0',
        subtitle: 'jours consécutifs',
        icon: Icons.local_fire_department_rounded,
        color: AppTheme.errorColor,
        trend: _calculateTrend('currentStreak'),
      ),
    ];
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required TrendDirection trend,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          ...AppTheme.cardShadow,
        ],
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Add navigation to detailed view
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    _buildTrendIndicator(trend, color),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendIndicator(TrendDirection trend, Color baseColor) {
    IconData icon;
    Color color;

    switch (trend) {
      case TrendDirection.up:
        icon = Icons.trending_up_rounded;
        color = AppTheme.successColor;
        break;
      case TrendDirection.down:
        icon = Icons.trending_down_rounded;
        color = AppTheme.errorColor;
        break;
      case TrendDirection.stable:
        icon = Icons.trending_flat_rounded;
        color = AppTheme.grey500;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        icon,
        color: color,
        size: 16,
      ),
    );
  }

  TrendDirection _calculateTrend(String metricKey) {
    // Mock trend calculation - in real app, compare with previous period
    final value = widget.metrics[metricKey];
    if (value == null) return TrendDirection.stable;

    final hash = metricKey.hashCode % 3;
    switch (hash) {
      case 0:
        return TrendDirection.up;
      case 1:
        return TrendDirection.down;
      default:
        return TrendDirection.stable;
    }
  }
}

enum TrendDirection {
  up,
  down,
  stable,
}