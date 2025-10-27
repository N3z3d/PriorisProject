import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/indicators/premium_status_indicator.dart';

/// Tableau de bord premium affichant les métriques clés de productivité.
class PremiumMetricsDashboard extends StatefulWidget {
  final Map<String, dynamic> metrics;
  final bool enableAnimations;

  const PremiumMetricsDashboard({
    super.key,
    required this.metrics,
    this.enableAnimations = true,
  });

  @override
  State<PremiumMetricsDashboard> createState() =>
      _PremiumMetricsDashboardState();
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
    final metricCount = _metricDefinitions().length;
    _controllers = List.generate(
      metricCount,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 100)),
        vsync: this,
      ),
    );

    _animations = _controllers
        .map(
          (controller) => CurvedAnimation(
            parent: controller,
            curve: Curves.elasticOut,
          ).drive(Tween<double>(begin: 0, end: 1)),
        )
        .toList();

    if (widget.enableAnimations) {
      for (var i = 0; i < _controllers.length; i++) {
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
    final configs = _metricCardConfigs();
    final cards = configs.map(_buildCardFromConfig).toList();

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
          itemCount: cards.length,
          itemBuilder: (context, index) {
            return widget.enableAnimations
                ? AnimatedBuilder(
                    animation: _animations[index],
                    builder: (context, child) {
                      final value = _animations[index].value;
                      return Transform.scale(
                        scale: value,
                        child: Opacity(opacity: value, child: child),
                      );
                    },
                    child: cards[index],
                  )
                : cards[index];
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

  Widget _buildCardFromConfig(_MetricCardConfig config) {
    return _buildMetricCard(
      title: config.title,
      value: config.value,
      subtitle: config.subtitle,
      icon: config.icon,
      color: config.color,
      trend: config.trend,
    );
  }

  List<_MetricCardConfig> _metricCardConfigs() {
    final metrics = widget.metrics;
    return _metricDefinitions()
        .map(
          (definition) => _MetricCardConfig(
            title: definition.title,
            subtitle: definition.subtitle,
            icon: definition.icon,
            color: definition.color,
            trend: _calculateTrend(definition.trendKey),
            value: definition.valueBuilder(metrics),
          ),
        )
        .toList();
  }

  List<_MetricDefinition> _metricDefinitions() {
    return [
      ..._productivityDefinitions(),
      ..._engagementDefinitions(),
    ];
  }

  List<_MetricDefinition> _productivityDefinitions() {
    return [
      _MetricDefinition(
        title: 'Tâches terminées',
        subtitle: 'cette semaine',
        icon: Icons.check_circle_rounded,
        color: AppTheme.successColor,
        trendKey: 'completedTasks',
        valueBuilder: _stringValue('completedTasks'),
      ),
      _MetricDefinition(
        title: 'Tâches en cours',
        subtitle: 'actuellement',
        icon: Icons.play_circle_outline_rounded,
        color: AppTheme.primaryColor,
        trendKey: 'activeTasks',
        valueBuilder: _stringValue('activeTasks'),
      ),
      _MetricDefinition(
        title: 'Taux de réussite',
        subtitle: 'performance globale',
        icon: Icons.trending_up_rounded,
        color: AppTheme.accentSecondary,
        trendKey: 'completionRate',
        valueBuilder: _numericValue(
          'completionRate',
          fractionDigits: 1,
          suffix: '%',
        ),
      ),
    ];
  }

  List<_MetricDefinition> _engagementDefinitions() {
    return [
      _MetricDefinition(
        title: 'Habitudes actives',
        subtitle: 'en développement',
        icon: Icons.repeat_rounded,
        color: AppTheme.accentColor,
        trendKey: 'activeHabits',
        valueBuilder: _stringValue('activeHabits'),
      ),
      _MetricDefinition(
        title: 'Score ELO moyen',
        subtitle: 'performance',
        icon: Icons.star_rounded,
        color: AppTheme.warningColor,
        trendKey: 'averageElo',
        valueBuilder: _numericValue('averageElo'),
      ),
      _MetricDefinition(
        title: 'Streak actuel',
        subtitle: 'jours consécutifs',
        icon: Icons.local_fire_department_rounded,
        color: AppTheme.errorColor,
        trendKey: 'currentStreak',
        valueBuilder: _stringValue('currentStreak', suffix: ' jours'),
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
            // Navigation vers une vue détaillée si besoin.
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
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const Spacer(),
                    _buildTrendIndicator(trend),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  value,
                  style: const TextStyle(
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

  Widget _buildTrendIndicator(TrendDirection trend) {
    late final IconData icon;
    late final Color color;

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
      child: Icon(icon, color: color, size: 16),
    );
  }

TrendDirection _calculateTrend(String metricKey) {
  final value = widget.metrics[metricKey];
  if (value == null) return TrendDirection.stable;

  switch (metricKey.hashCode % 3) {
      case 0:
        return TrendDirection.up;
      case 1:
        return TrendDirection.down;
      default:
        return TrendDirection.stable;
    }
  }
}

enum TrendDirection { up, down, stable }

class _MetricCardConfig {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final TrendDirection trend;

  const _MetricCardConfig({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.trend,
  });
}

class _MetricDefinition {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String trendKey;
  final String Function(Map<String, dynamic>) valueBuilder;

  const _MetricDefinition({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.trendKey,
    required this.valueBuilder,
  });
}

String Function(Map<String, dynamic>) _stringValue(
  String key, {
  String suffix = '',
}) {
  return (metrics) {
    final value = metrics[key];
    final text = value == null ? '0' : value.toString();
    return '$text$suffix';
  };
}

String Function(Map<String, dynamic>) _numericValue(
  String key, {
  int fractionDigits = 0,
  String suffix = '',
}) {
  return (metrics) {
    final value = metrics[key];
    if (value is num) {
      final formatted = fractionDigits > 0
          ? value.toStringAsFixed(fractionDigits)
          : value.toStringAsFixed(0);
      return '$formatted$suffix';
    }
    return '0$suffix';
  };
}
