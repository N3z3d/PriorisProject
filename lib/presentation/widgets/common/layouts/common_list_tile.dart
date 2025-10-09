import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

class CommonListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? selectedColor;
  final Color? titleColor;
  final Color? subtitleColor;
  final EdgeInsetsGeometry? padding;

  const CommonListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.isSelected = false,
    this.selectedColor,
    this.titleColor,
    this.subtitleColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final style = _TileStyle(
      background: isSelected
          ? (selectedColor ?? AppTheme.primaryColor.withOpacity(0.08))
          : Colors.transparent,
      titleColor: titleColor ?? Colors.black87,
      subtitleColor: subtitleColor ?? Colors.grey[600]!,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );

    return Material(
      color: style.background,
      borderRadius: BorderRadiusTokens.radiusSm,
      child: InkWell(
        borderRadius: BorderRadiusTokens.radiusSm,
        onTap: onTap,
        child: Padding(
          padding: style.padding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _buildRowChildren(style),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRowChildren(_TileStyle style) {
    return [
      if (leading != null) ...[
        leading!,
        const SizedBox(width: 16),
      ],
      Expanded(child: _buildTextColumn(style)),
      if (trailing != null) ...[
        const SizedBox(width: 16),
        trailing!,
      ],
    ];
  }

  Widget _buildTextColumn(_TileStyle style) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: style.titleColor,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 13,
              color: style.subtitleColor,
            ),
          ),
        ],
      ],
    );
  }
}

class _TileStyle {
  final Color background;
  final Color titleColor;
  final Color subtitleColor;
  final EdgeInsetsGeometry padding;

  const _TileStyle({
    required this.background,
    required this.titleColor,
    required this.subtitleColor,
    required this.padding,
  });
}
