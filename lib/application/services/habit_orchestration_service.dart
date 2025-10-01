/// **HABIT ORCHESTRATION SERVICE** - CQRS Coordinator
///
/// **LOT 5** : Service orchestrateur qui remplace la God Class HabitApplicationService
/// **Responsabilité unique** : Coordination des Commands/Queries habitudes uniquement
/// **Taille** : <200 lignes (contrainte CLAUDE.md respectée)
/// **Architecture** : CQRS + Coordinator Pattern + Dependency Injection

import '../commands/habits/create_habit_command.dart';
import '../commands/habits/record_habit_command.dart';
import '../commands/habits/update_habit_command.dart';
import '../commands/habits/delete_habit_command.dart';
import '../queries/habits/get_habit_query.dart';
import '../queries/habits/get_habits_query.dart';
import '../queries/habits/get_todays_habits_query.dart';
import '../queries/habits/get_habit_analytics_query.dart';
import '../queries/habits/get_habit_statistics_query.dart';
import 'application_service.dart';
import '../../domain/habit/aggregates/habit_aggregate.dart';
import '../../domain/habit/repositories/habit_repository.dart';
import '../../domain/habit/services/habit_analytics_service.dart';
import '../../domain/core/value_objects/export.dart';
import '../../domain/core/specifications/export.dart';

/// **Service d'orchestration des habitudes**
///
/// **SRP** : Coordination uniquement - délègue aux Commands/Queries spécialisées
/// **OCP** : Extensible via injection de nouveaux handlers
/// **DIP** : Dépend d'abstractions (repositories et services injectés)
/// **CQRS** : Sépare clairement Commands (modification) et Queries (lecture)
class HabitOrchestrationService extends ApplicationService {
  final HabitRepository _habitRepository;
  final HabitAnalyticsService _analyticsService;

  /// **Constructeur avec injection de dépendances** (DIP)
  HabitOrchestrationService(this._habitRepository, this._analyticsService);

  @override
  String get serviceName => 'HabitOrchestrationService';

  // === COMMANDS (Modifications) ===

  /// Orchestre la création d'une habitude
  Future<OperationResult<HabitAggregate>> createHabit(CreateHabitCommand command) async {
    return await safeExecute(() async {
      command.validate();

      final habit = HabitAggregate.create(
        name: command.name,
        description: command.description,
        type: command.type,
        category: command.category,
        targetValue: command.targetValue,
        unit: command.unit,
        recurrenceType: command.recurrenceType,
        intervalDays: command.intervalDays,
        weekdays: command.weekdays,
        timesTarget: command.timesTarget,
      );

      await _habitRepository.save(habit);

      return OperationResult.success(
        habit,
        message: 'Habitude créée avec succès',
        metadata: {
          'type': command.type.name,
          'category': command.category,
          'hasTarget': command.targetValue != null,
        },
      );
    }, 'createHabit', aggregates: []);
  }

  /// Orchestre l'enregistrement d'une habitude
  Future<OperationResult<HabitAggregate>> recordHabit(RecordHabitCommand command) async {
    return await safeExecute(() async {
      command.validate();

      final habit = await _habitRepository.findById(command.habitId);
      if (habit == null) {
        throw ResourceNotFoundException('Habit', command.habitId);
      }

      final date = command.date ?? DateTime.now();
      var milestone = false;
      var targetReached = false;

      if (habit.type == HabitType.binary) {
        if (command.value is! bool) {
          throw BusinessValidationException(
            'Type de valeur incorrect',
            ['Une habitude binaire nécessite une valeur booléenne'],
            operationName: 'RecordHabit',
          );
        }
        habit.markCompleted(command.value as bool, date: date);
      } else {
        if (command.value is! double) {
          throw BusinessValidationException(
            'Type de valeur incorrect',
            ['Une habitude quantitative nécessite une valeur numérique'],
            operationName: 'RecordHabit',
          );
        }
        habit.recordValue(command.value as double, date: date);
        targetReached = habit.targetValue != null &&
                       (command.value as double) >= habit.targetValue!;
      }

      // Vérifier les milestones de streak
      final newStreak = habit.getCurrentStreak();
      milestone = [3, 7, 14, 30, 100, 365].contains(newStreak);

      await _habitRepository.save(habit);

      final warnings = <String>[];
      if (targetReached) {
        warnings.add('Objectif atteint !');
      }
      if (milestone) {
        warnings.add('Milestone de $newStreak jours atteint !');
      }

      return OperationResult.success(
        habit,
        message: 'Habitude enregistrée avec succès',
        warnings: warnings,
        metadata: {
          'value': command.value,
          'streak': newStreak,
          'targetReached': targetReached,
          'milestone': milestone,
        },
      );
    }, 'recordHabit', aggregates: []);
  }

  /// Orchestre la mise à jour d'une habitude
  Future<OperationResult<HabitAggregate>> updateHabit(UpdateHabitCommand command) async {
    return await safeExecute(() async {
      command.validate();

      final habit = await _habitRepository.findById(command.habitId);
      if (habit == null) {
        throw ResourceNotFoundException('Habit', command.habitId);
      }

      final changes = <String>[];

      if (command.name != null && command.name != habit.name) {
        habit.updateName(command.name!);
        changes.add('nom');
      }

      if (command.targetValue != null && command.targetValue != habit.targetValue) {
        if (habit.type != HabitType.quantitative) {
          throw BusinessValidationException(
            'Impossible de définir une valeur cible',
            ['Seules les habitudes quantitatives peuvent avoir une valeur cible'],
            operationName: 'UpdateHabit',
          );
        }
        habit.updateTargetValue(command.targetValue);
        changes.add('valeur cible');
      }

      if (changes.isNotEmpty) {
        await _habitRepository.save(habit);
      }

      return OperationResult.success(
        habit,
        message: changes.isEmpty
          ? 'Aucune modification nécessaire'
          : 'Habitude mise à jour: ${changes.join(", ")}',
        metadata: {'changes': changes},
      );
    }, 'updateHabit', aggregates: []);
  }

  /// Orchestre la suppression d'une habitude
  Future<OperationResult<void>> deleteHabit(DeleteHabitCommand command) async {
    return await safeExecute(() async {
      command.validate();

      final habit = await _habitRepository.findById(command.habitId);
      if (habit == null) {
        throw ResourceNotFoundException('Habit', command.habitId);
      }

      await _habitRepository.delete(command.habitId);

      return OperationResult.success(
        null,
        message: 'Habitude supprimée avec succès',
        metadata: {
          'deletedHabit': habit.name,
          'finalStreak': habit.getCurrentStreak(),
          'successRate': habit.getSuccessRate(),
        },
      );
    }, 'deleteHabit');
  }

  // === QUERIES (Lectures) ===

  /// Orchestre la lecture d'une habitude
  Future<OperationResult<HabitAggregate>> getHabit(GetHabitQuery query) async {
    return await safeExecute(() async {
      query.validate();

      final habit = await _habitRepository.findById(query.habitId);
      if (habit == null) {
        throw BusinessValidationException(
          'Habitude non trouvée',
          ['L\'habitude avec l\'ID ${query.habitId} n\'existe pas'],
          operationName: 'getHabit',
        );
      }

      return OperationResult.success(habit);
    }, 'getHabit', aggregates: []);
  }

  /// Orchestre la lecture de plusieurs habitudes avec filtres
  Future<OperationResult<List<HabitAggregate>>> getHabits(GetHabitsQuery query) async {
    return await safeExecute(() async {
      query.validate();

      // Construire la spécification basée sur les critères
      var specification = Specifications.alwaysTrue<HabitAggregate>();

      if (query.category != null) {
        specification = specification.and(
          HabitSpecifications.hasCategory(query.category!),
        );
      }

      if (query.type != null) {
        specification = specification.and(
          query.type == HabitType.binary
            ? HabitSpecifications.isBinary()
            : HabitSpecifications.isQuantitative(),
        );
      }

      if (query.completedToday != null) {
        specification = specification.and(
          query.completedToday!
            ? HabitSpecifications.completedToday()
            : HabitSpecifications.incompleteToday(),
        );
      }

      if (query.minStreak != null) {
        specification = specification.and(
          HabitSpecifications.hasStreakAbove(query.minStreak!),
        );
      }

      if (query.minSuccessRate != null) {
        specification = specification.and(
          HabitSpecifications.hasSuccessRateAbove(query.minSuccessRate!),
        );
      }

      if (query.searchText != null && query.searchText!.isNotEmpty) {
        specification = specification.and(
          HabitSpecifications.containsText(query.searchText!),
        );
      }

      final habits = await _habitRepository.findBySpecification(specification);

      // Appliquer la limite si spécifiée
      final limitedHabits = query.limit != null
        ? habits.take(query.limit!).toList()
        : habits;

      return OperationResult.success(
        limitedHabits,
        metadata: {
          'totalFound': habits.length,
          'returned': limitedHabits.length,
          'hasMore': query.limit != null && habits.length > query.limit!,
        },
      );
    }, 'getHabits');
  }

  /// Orchestre la lecture des habitudes du jour
  Future<OperationResult<List<HabitAggregate>>> getTodaysHabits(GetTodaysHabitsQuery query) async {
    return await safeExecute(() async {
      final todaysHabits = await _habitRepository.findTodaysTasks();

      final completed = todaysHabits.where((h) => h.isCompletedToday()).length;
      final total = todaysHabits.length;

      return OperationResult.success(
        todaysHabits,
        message: '$completed/$total habitude(s) complétée(s) aujourd\'hui',
        metadata: {
          'completed': completed,
          'remaining': total - completed,
          'completionRate': total > 0 ? completed / total : 0.0,
        },
      );
    }, 'getTodaysHabits');
  }

  /// Orchestre la lecture des analytics d'une habitude
  Future<OperationResult<Map<String, dynamic>>> getHabitAnalytics(GetHabitAnalyticsQuery query) async {
    return await safeExecute(() async {
      query.validate();

      final habit = await _habitRepository.findById(query.habitId);
      if (habit == null) {
        throw ResourceNotFoundException('Habit', query.habitId);
      }

      final analysisWindow = query.analysisWindow ?? 30;

      final consistency = _analyticsService.analyzeConsistency(habit, days: analysisWindow);
      final patterns = _analyticsService.analyzePatterns(habit, days: analysisWindow * 2);
      final prediction = _analyticsService.predictSuccess(habit, analysisWindow: analysisWindow);

      return OperationResult.success({
        'consistency': {
          'completionRate': consistency.completionRate,
          'currentStreak': consistency.currentStreak,
          'level': consistency.consistency.label,
          'variability': consistency.variabilityScore,
        },
        'patterns': {
          'bestDays': patterns.bestDays,
          'worstDays': patterns.worstDays,
          'trend': patterns.trend.label,
          'predictability': patterns.predictability,
        },
        'prediction': {
          'overallProbability': prediction.overallProbability,
          'confidenceLevel': prediction.confidenceLevel,
          'keyFactors': prediction.keyFactors,
        },
      }, message: 'Analyse générée avec succès');
    }, 'getHabitAnalytics');
  }

  /// Orchestre la lecture des statistiques globales
  Future<OperationResult<HabitStatistics>> getHabitStatistics(GetHabitStatisticsQuery query) async {
    return await safeExecute(() async {
      final statistics = await _habitRepository.getStatistics(dateRange: query.dateRange);

      return OperationResult.success(
        statistics,
        metadata: {
          'period': query.dateRange?.label ?? 'Toutes les données',
          'dataPoints': statistics.totalHabits,
        },
      );
    }, 'getHabitStatistics');
  }
}