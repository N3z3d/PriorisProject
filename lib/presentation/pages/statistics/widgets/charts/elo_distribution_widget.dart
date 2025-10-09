import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/task.dart';

/// Widget affichant une distribution circulaire des scores ELO.
///
/// L'implémentation est basée sur un [CustomPainter] maison pour éviter
/// les dépendances tierces tout en conservant des animations fluides.
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
    final slices = _buildSlices(Theme.of(context));
    final total = slices.fold<int>(0, (acc, slice) => acc + slice.count);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '�Y"S Distribution ELO',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Répartition de la difficulté de vos tâches en fonction de leur score ELO.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: chartSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 600),
                          tween: Tween(begin: 0, end: 1),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return CustomPaint(
                              painter: _EloDistributionPainter(
                                slices: slices,
                                total: total,
                                animationValue: value,
                                backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.35),
                              ),
                            );
                          },
                        ),
                        if (total == 0)
                          Column(
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
                          )
                        else
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$total',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'tâches',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.color
                                          ?.withOpacity(0.6),
                                    ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _DistributionLegend(slices: slices, total: total),
                ),
              ],
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
      '1800+': 0,
    };

    for (final task in tasks) {
      final elo = task.eloScore;
      if (elo < 1200) {
        ranges['1000 - 1199'] = (ranges['1000 - 1199'] ?? 0) + 1;
      } else if (elo < 1400) {
        ranges['1200 - 1399'] = (ranges['1200 - 1399'] ?? 0) + 1;
      } else if (elo < 1600) {
        ranges['1400 - 1599'] = (ranges['1400 - 1599'] ?? 0) + 1;
      } else if (elo < 1800) {
        ranges['1600 - 1799'] = (ranges['1600 - 1799'] ?? 0) + 1;
      } else {
        ranges['1800+'] = (ranges['1800+'] ?? 0) + 1;
      }
    }

    final palette = _buildColorPalette(theme);
    var index = 0;

    return ranges.entries.map((entry) {
      final slice = _EloSlice(
        label: entry.key,
        count: entry.value,
        color: palette[index % palette.length],
      );
      index++;
      return slice;
    }).toList();
  }

  List<Color> _buildColorPalette(ThemeData theme) {
    final scheme = theme.colorScheme;
    return [
      scheme.primary,
      scheme.secondary,
      scheme.tertiary,
      scheme.error,
      scheme.primaryContainer,
    ].map((color) => color.withOpacity(0.9)).toList();
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
