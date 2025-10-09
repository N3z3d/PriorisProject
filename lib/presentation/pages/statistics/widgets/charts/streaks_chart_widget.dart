import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Données nécessaires pour représenter un streak d'habitude dans le graphique.
class StreakChartEntry {
  final String name;
  final double streakLength;
  final String category;

  const StreakChartEntry({
    required this.name,
    required this.streakLength,
    required this.category,
  });
}

/// Graphique en barres personnalisé pour visualiser l'évolution des séries.
class StreaksChartWidget extends StatelessWidget {
  final List<StreakChartEntry> entries;
  final Duration? period;

  const StreaksChartWidget({
    super.key,
    required this.entries,
    this.period,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = entries.isEmpty
        ? 0.0
        : entries.map((entry) => entry.streakLength).reduce(math.max);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '�Y"� �%volution des SǸries',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (period != null) ...[
              const SizedBox(height: 4),
              Text(
                'Observations sur ${period!.inDays} jours glissants.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withOpacity(0.7),
                    ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: entries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.self_improvement, color: Colors.grey, size: 32),
                          SizedBox(height: 8),
                          Text(
                            'Aucune série enregistrée',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 600),
                      tween: Tween(begin: 0, end: 1),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return CustomPaint(
                          painter: _StreakBarPainter(
                            entries: entries,
                            maxValue: maxValue,
                            animationValue: value,
                            axisColor: Theme.of(context).dividerColor,
                            barColor: Theme.of(context).colorScheme.primary,
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            if (entries.isNotEmpty) _HabitLabels(entries: entries),
          ],
        ),
      ),
    );
  }
}

class _HabitLabels extends StatelessWidget {
  final List<StreakChartEntry> entries;

  const _HabitLabels({required this.entries});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        );

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: entries.map((entry) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              entry.name,
              style: textStyle,
            ),
            Text(
              '${entry.streakLength.toStringAsFixed(0)} jours',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.color
                        ?.withOpacity(0.6),
                  ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _StreakBarPainter extends CustomPainter {
  final List<StreakChartEntry> entries;
  final double maxValue;
  final double animationValue;
  final Color axisColor;
  final Color barColor;

  _StreakBarPainter({
    required this.entries,
    required this.maxValue,
    required this.animationValue,
    required this.axisColor,
    required this.barColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;
    final axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 1.5;

    // Axe horizontal de base.
    canvas.drawLine(Offset(0, size.height - 1), Offset(size.width, size.height - 1), axisPaint);

    if (entries.isEmpty || maxValue <= 0) {
      return;
    }

    final barSpacing = size.width / (entries.length * 2);
    final barWidth = barSpacing;
    final gradient = LinearGradient(
      colors: [
        barColor.withOpacity(0.85),
        barColor.withOpacity(0.55),
      ],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final normalizedValue = (entry.streakLength / maxValue).clamp(0.0, 1.0);
      final barHeight = normalizedValue * size.height * animationValue;

      final left = (i * 2 + 0.5) * barSpacing;
      final top = size.height - barHeight;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, barWidth, barHeight),
        const Radius.circular(8),
      );

      paint.shader = gradient.createShader(rect.outerRect);
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StreakBarPainter oldDelegate) {
    return oldDelegate.entries != entries ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.barColor != barColor ||
        oldDelegate.axisColor != axisColor;
  }
}
