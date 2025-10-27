import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/task.dart';

/// Widget affichant une distribution circulaire des scores ELO.
///
/// L'implémentation repose sur un [CustomPainter] interne afin d'éviter toute
/// dépendance externe tout en conservant un rendu fluide.
class EloDistributionWidget extends StatelessWidget {
  final List<Task> tasks;
  final double chartSize;

  const EloDistributionWidget({
    super.key,
    required this.tasks,
    this.chartSize = 180,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final slices = _buildSlices(theme);
    final total = slices.fold<int>(0, (sum, slice) => sum + slice.count);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(theme: theme),
            const SizedBox(height: 20),
            _ChartSection(
              chartSize: chartSize,
              slices: slices,
              total: total,
            ),
          ],
        ),
      ),
    );
  }

  List<_EloSlice> _buildSlices(ThemeData theme) {
    final ranges = <String, int>{
      '1000 - 1199': 0,
      '1200 - 1399': 0,
      '1400 - 1599': 0,
      '1600 - 1799': 0,
      '1800 - 1999': 0,
      '2000 +': 0,
    };

    for (final task in tasks) {
      final score = task.eloScore ?? 1000;
      if (score < 1200) {
        ranges['1000 - 1199'] = ranges['1000 - 1199']! + 1;
      } else if (score < 1400) {
        ranges['1200 - 1399'] = ranges['1200 - 1399']! + 1;
      } else if (score < 1600) {
        ranges['1400 - 1599'] = ranges['1400 - 1599']! + 1;
      } else if (score < 1800) {
        ranges['1600 - 1799'] = ranges['1600 - 1799']! + 1;
      } else if (score < 2000) {
        ranges['1800 - 1999'] = ranges['1800 - 1999']! + 1;
      } else {
        ranges['2000 +'] = ranges['2000 +']! + 1;
      }
    }

    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      const Color(0xFF6C63FF),
      const Color(0xFF4CD4A0),
      const Color(0xFFFFA36C),
    ];

    var index = 0;
    return ranges.entries.map((entry) {
      final slice = _EloSlice(
        label: entry.key,
        count: entry.value,
        color: colors[index % colors.length],
      );
      index++;
      return slice;
    }).toList();
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🎯 Distribution ELO',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Répartition de la difficulté de vos tâches en fonction de leur score ELO.',
          style: subtitleStyle,
        ),
      ],
    );
  }
}

class _ChartSection extends StatelessWidget {
  const _ChartSection({
    required this.chartSize,
    required this.slices,
    required this.total,
  });

  final double chartSize;
  final List<_EloSlice> slices;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _AnimatedChart(
            chartSize: chartSize,
            slices: slices,
            total: total,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _DistributionLegend(slices: slices, total: total),
        ),
      ],
    );
  }
}

class _AnimatedChart extends StatelessWidget {
  const _AnimatedChart({
    required this.chartSize,
    required this.slices,
    required this.total,
  });

  final double chartSize;
  final List<_EloSlice> slices;
  final int total;

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context)
        .colorScheme
        .surfaceVariant
        .withOpacity(0.35);

    return SizedBox(
      height: chartSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0, end: 1),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return CustomPaint(
                painter: _EloDistributionPainter(
                  slices: slices,
                  total: total,
                  animationValue: value,
                  backgroundColor: background,
                ),
              );
            },
          ),
          total == 0 ? const _EmptyChartState() : _ChartTotal(total: total),
        ],
      ),
    );
  }
}

class _ChartTotal extends StatelessWidget {
  const _ChartTotal({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$total',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'tâches',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.textTheme.labelMedium?.color?.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

class _EmptyChartState extends StatelessWidget {
  const _EmptyChartState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.inbox, size: 36, color: Colors.grey),
        SizedBox(height: 8),
        Text(
          'Aucune tâche',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _DistributionLegend extends StatelessWidget {
  final List<_EloSlice> slices;
  final int total;

  const _DistributionLegend({
    required this.slices,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    if (slices.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: slices.map((slice) {
        final percentage = total == 0 ? 0.0 : (slice.count / total) * 100;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: slice.color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  slice.label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Text(
                '${slice.count}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(width: 8),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withOpacity(0.6),
                    ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _EloDistributionPainter extends CustomPainter {
  final List<_EloSlice> slices;
  final int total;
  final double animationValue;
  final Color backgroundColor;

  _EloDistributionPainter({
    required this.slices,
    required this.total,
    required this.animationValue,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = radius * 0.35;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    if (total == 0 || animationValue <= 0) {
      return;
    }

    var startAngle = -math.pi / 2;
    for (final slice in slices) {
      if (slice.count == 0) continue;

      final sweepAngle = (slice.count / total) * 2 * math.pi * animationValue;
      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _EloDistributionPainter oldDelegate) {
    return oldDelegate.slices != slices ||
        oldDelegate.total != total ||
        oldDelegate.animationValue != animationValue;
  }
}

class _EloSlice {
  final String label;
  final int count;
  final Color color;

  const _EloSlice({
    required this.label,
    required this.count,
    required this.color,
  });
}
