import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/common/forms/common_button.dart';

/// Widget d'état vide commun réutilisable pour toute l'application
/// 
/// Ce widget fournit une interface unifiée pour tous les états vides
/// avec support pour titre, sous-titre, icône et action.
class CommonEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionLabel;
  final double? iconSize;
  final Color? iconColor;
  final double? titleFontSize;
  final Color? titleColor;
  final double? spacing;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;

  const CommonEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.onAction,
    this.actionLabel,
    this.iconSize,
    this.iconColor,
    this.titleFontSize,
    this.titleColor,
    this.spacing,
    this.alignment,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment ?? Alignment.center,
      padding: padding ?? const EdgeInsets.all(32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ..._buildIcon(),
            _buildTitle(),
            ..._buildSubtitle(),
            ..._buildAction(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildIcon() {
    if (icon == null) {
      return const [];
    }

    return [
      Icon(
        icon,
        size: iconSize ?? 64.0,
        color: iconColor ?? Colors.grey[400],
      ),
      SizedBox(height: spacing ?? 16.0),
    ];
  }

  Widget _buildTitle() {
    return Text(
      title,
      style: TextStyle(
        fontSize: titleFontSize ?? 18,
        fontWeight: FontWeight.w600,
        color: titleColor ?? Colors.grey[600],
      ),
      textAlign: TextAlign.center,
    );
  }

  List<Widget> _buildSubtitle() {
    if (subtitle == null) {
      return const [];
    }

    return [
      SizedBox(height: (spacing ?? 16.0) / 2),
      Text(
        subtitle!,
        style: TextStyle(
          fontSize: (titleFontSize ?? 18) - 2,
          color: Colors.grey[500],
        ),
        textAlign: TextAlign.center,
      ),
    ];
  }

  List<Widget> _buildAction() {
    if (onAction == null || actionLabel == null) {
      return const [];
    }

    return [
      SizedBox(height: spacing ?? 16.0),
      CommonButton(
        text: actionLabel!,
        onPressed: onAction,
      ),
    ];
  }
}
