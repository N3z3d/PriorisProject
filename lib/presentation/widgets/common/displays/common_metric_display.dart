import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

class CommonMetricDisplay extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color? color;
  final bool isHighlighted;
  final double? iconSize;
  final double? valueFontSize;
  final double? labelFontSize;
  final Color? valueColor;
  final Color? labelColor;
  final double? spacing;
  final CrossAxisAlignment? crossAxisAlignment;
  final EdgeInsetsGeometry? padding;

  const CommonMetricDisplay({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.color,
    this.isHighlighted = false,
    this.iconSize,
    this.valueFontSize,
    this.labelFontSize,
    this.valueColor,
    this.labelColor,
    this.spacing,
    this.crossAxisAlignment,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final style = _MetricStyle(
      metricColor: color ?? AppTheme.primaryColor,
      iconSize: iconSize ?? 24.0,
      valueFontSize: valueFontSize ?? 24.0,
      labelFontSize: labelFontSize ?? 14.0,
      valueColor: valueColor,
      labelColor: labelColor ?? Colors.grey[600]!,
      spacing: spacing ?? 8.0,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      padding: padding ?? const EdgeInsets.all(16),
      highlighted: isHighlighted,
    );

    return Container(
      padding: style.padding,
      decoration: _buildDecoration(style),
      child: Column(
        crossAxisAlignment: style.crossAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: _buildContent(style),
      ),
    );
  }

  List<Widget> _buildContent(_MetricStyle style) {
    return [
      if (icon != null) ...[
        Icon(icon, size: style.iconSize, color: style.metricColor),
        SizedBox(height: style.spacing),
      ],
      Text(
        value,
        style: TextStyle(
          fontSize: style.valueFontSize,
          fontWeight: FontWeight.bold,
          color: style.valueTextColor,
        ),
        textAlign: TextAlign.center,
      ),
      Text(
        label,
        style: TextStyle(
          fontSize: style.labelFontSize,
          color: style.labelColor,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    ];
  }

  BoxDecoration? _buildDecoration(_MetricStyle style) {
    if (!style.highlighted) {
      return null;
    }
    return BoxDecoration(
      color: style.metricColor.withOpacity(0.1),
      borderRadius: BorderRadiusTokens.radiusMd,
      border: Border.all(
        color: style.metricColor.withOpacity(0.3),
        width: 1,
      ),
    );
  }
}

class _MetricStyle {
  final Color metricColor;
  final double iconSize;
  final double valueFontSize;
  final double labelFontSize;
  final Color? valueColor;
  final Color labelColor;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsetsGeometry padding;
  final bool highlighted;

  const _MetricStyle({
    required this.metricColor,
    required this.iconSize,
    required this.valueFontSize,
    required this.labelFontSize,
    required this.valueColor,
    required this.labelColor,
    required this.spacing,
    required this.crossAxisAlignment,
    required this.padding,
    required this.highlighted,
  });

  Color get valueTextColor => valueColor ?? (highlighted ? metricColor : Colors.black87);
}
