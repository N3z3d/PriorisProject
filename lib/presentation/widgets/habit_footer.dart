import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Widget affichant le footer d'une habitude (catégorie et récurrence)
class HabitFooter extends StatelessWidget {
  /// Habitude à afficher
  final Habit habit;

  const HabitFooter({
    super.key,
    required this.habit,
  });

  /// Retourne le texte de récurrence
  String _getRecurrenceText() {
    if (habit.recurrenceType == null) return 'Quotidien';
    
    switch (habit.recurrenceType!) {
      case RecurrenceType.dailyInterval:
        final days = habit.intervalDays ?? 1;
        return days == 1 ? 'Quotidien' : 'Tous les $days jours';
      
      case RecurrenceType.weeklyDays:
        final weekdays = habit.weekdays ?? [];
        if (weekdays.isEmpty) return 'Aucun jour';
        final dayNames = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
        final selectedDays = weekdays.map((i) => dayNames[i]).join(', ');
        return selectedDays;
      
      case RecurrenceType.timesPerWeek:
        final times = habit.timesTarget ?? 1;
        return '$times fois/semaine';
      
      case RecurrenceType.timesPerDay:
        final times = habit.timesTarget ?? 1;
        return '$times fois/jour';
      
      // 🗓️ Fréquences Avancées
      case RecurrenceType.monthly:
        return 'Mensuel (1er)';
      
      case RecurrenceType.monthlyDay:
        final day = habit.monthlyDay ?? 1;
        return 'Mensuel ($day)';
      
      case RecurrenceType.quarterly:
        return 'Trimestriel';
      
      case RecurrenceType.yearly:
        final month = habit.yearlyMonth ?? 1;
        final day = habit.yearlyDay ?? 1;
        return 'Annuel ($day/$month)';
      
      // ⏰ Fréquences Temporelles
      case RecurrenceType.hourlyInterval:
        final hours = habit.hourlyInterval ?? 1;
        return 'Toutes les ${hours}h';
      
      case RecurrenceType.timesPerHour:
        final times = habit.timesTarget ?? 1;
        return '$times fois/heure';
      
      case RecurrenceType.weekends:
        return 'Weekend seulement';
      
      case RecurrenceType.weekdays:
        return 'Semaine seulement';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Catégorie
        if (habit.category?.isNotEmpty == true)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSM,
              vertical: AppTheme.spacingXS,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            ),
            child: Text(
              habit.category!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        
        const Spacer(),
        
        // Récurrence
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingSM,
            vertical: AppTheme.spacingXS,
          ),
          decoration: BoxDecoration(
            color: AppTheme.textTertiary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.repeat,
                size: 12,
                color: AppTheme.textTertiary,
              ),
              const SizedBox(width: AppTheme.spacingXS),
              Text(
                _getRecurrenceText(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 

