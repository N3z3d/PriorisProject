import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Widget affichant le badge de type d'habitude (Binaire/Quantitatif)
class HabitTypeBadge extends StatelessWidget {
  /// Type d'habitude à afficher
  final HabitType type;

  const HabitTypeBadge({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final isBinary = type == HabitType.binary;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSM,
        vertical: AppTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: isBinary
            ? AppTheme.successColor.withValues(alpha: 0.1)
            : AppTheme.infoColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        border: Border.all(
          color: isBinary
              ? AppTheme.successColor.withValues(alpha: 0.3)
              : AppTheme.infoColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isBinary ? Icons.check_box_outlined : Icons.timeline,
            size: 12,
            color: isBinary ? AppTheme.successColor : AppTheme.infoColor,
          ),
          const SizedBox(width: AppTheme.spacingXS),
          Text(
            isBinary ? 'Oui/Non' : 'Quantité',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isBinary ? AppTheme.successColor : AppTheme.infoColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
} 

