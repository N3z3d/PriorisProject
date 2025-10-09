import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

class CommonProgressBar extends StatelessWidget {
  final double value;
  final double? maxValue;
  final String? label;
  final Color? color;
  final double? height;
  final bool showPercentage;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const CommonProgressBar({
    super.key,
    required this.value,
    this.maxValue,
    this.label,
    this.color,
    this.height,
    this.showPercentage = false,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final config = _ProgressConfig(
      max: (maxValue ?? 100.0).clamp(0.0, double.infinity),
      value: value,
      color: color ?? AppTheme.primaryColor,
      height: height ?? 12.0,
      radius: borderRadius ?? BorderRadiusTokens.progressBar,
    );

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._buildLabelSection(),
          _buildProgressRow(config),
        ],
      ),
    );
  }

  List<Widget> _buildLabelSection() {
    if (label == null) {
      return const [];
    }
    return [
      Text(
        label!,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 4),
    ];
  }

  Widget _buildProgressRow(_ProgressConfig config) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _buildProgressBar(config)),
        if (showPercentage) ...[
          const SizedBox(width: 12),
          _buildPercentageLabel(config.percent),
        ],
      ],
    );
  }

  Widget _buildProgressBar(_ProgressConfig config) {
    return ClipRRect(
      borderRadius: config.radius,
      child: Container(
        height: config.height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: config.radius,
        ),
        child: Stack(
          children: [
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: config.percent,
              child: Container(
                decoration: BoxDecoration(
                  color: config.color,
                  borderRadius: config.radius,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentageLabel(double percent) {
    return Text(
      '${(percent * 100).toStringAsFixed(0)}%',
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: Colors.black87,
      ),
    );
  }
}

class _ProgressConfig {
  final double max;
  final double value;
  final Color color;
  final double height;
  final BorderRadius radius;

  const _ProgressConfig({
    required this.max,
    required this.value,
    required this.color,
    required this.height,
    required this.radius,
  });

  double get percent {
    if (max == 0) {
      return 0.0;
    }
    return (value / max).clamp(0.0, 1.0);
  }
}
