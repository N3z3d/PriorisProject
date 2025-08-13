import '../services/application_service.dart';
import '../../domain/habit/aggregates/habit_aggregate.dart';
import '../../domain/habit/repositories/habit_repository.dart';
import '../../domain/habit/services/habit_analytics_service.dart';
import '../../domain/core/value_objects/export.dart';
import '../../domain/core/specifications/export.dart';

/// Commands pour les cas d'usage des habitudes
class CreateHabitCommand extends Command {
  final String name;
  final String? description;
  final HabitType type;
  final String? category;
  final double? targetValue;
  final String? unit;
  final RecurrenceType? recurrenceType;
  final int? intervalDays;
  final List<int>? weekdays;
  final int? timesTarget;

  CreateHabitCommand({
    required this.name,
    this.description,
    required this.type,
    this.category,
    this.targetValue,
    this.unit,
    this.recurrenceType,
    this.intervalDays,
    this.weekdays,
    this.timesTarget,
  });

  @override
  void validate() {
    if (name.trim().isEmpty) {
      throw BusinessValidationException(
        'Le nom est requis',
        ['Le nom de l\'habitude ne peut pas être vide'],
        operationName: 'CreateHabit',
      );
    }

    if (name.length > 100) {
      throw BusinessValidationException(
        'Le nom est trop long',
        ['Le nom ne peut pas dépasser 100 caractères'],
        operationName: 'CreateHabit',
      );
    }

    if (type == HabitType.quantitative) {
      if (targetValue == null || targetValue! <= 0) {
        throw BusinessValidationException(
          'Valeur cible invalide',
          ['Une habitude quantitative doit avoir une valeur cible positive'],
          operationName: 'CreateHabit',
        );
      }

      if (unit == null || unit!.trim().isEmpty) {
        throw BusinessValidationException(
          'Unité requise',
          ['Une habitude quantitative doit avoir une unité'],
          operationName: 'CreateHabit',
        );
      }
    }

    if (weekdays != null) {
      for (final day in weekdays!) {
        if (day < 1 || day > 7) {
          throw BusinessValidationException(
            'Jour invalide',
            ['Les jours de la semaine doivent être entre 1 (lundi) et 7 (dimanche)'],
            operationName: 'CreateHabit',
          );
        }
      }
    }
  }
}

class RecordHabitCommand extends Command {
  final String habitId;
  final dynamic value; // bool pour binaire, double pour quantitatif
  final DateTime? date;

  RecordHabitCommand({
    required this.habitId,
    required this.value,
    this.date,
  });

  @override
  void validate() {
    if (habitId.trim().isEmpty) {
      throw BusinessValidationException(
        'ID d\'habitude requis',
        ['L\'identifiant de l\'habitude est requis'],
        operationName: 'RecordHabit',
      );
    }

    if (value is! bool && value is! double) {
      throw BusinessValidationException(
        'Valeur invalide',
        ['La valeur doit être un booléen ou un nombre'],
        operationName: 'RecordHabit',
      );
    }

    if (value is double && value < 0) {
      throw BusinessValidationException(
        'Valeur négative',
        ['La valeur quantitative ne peut pas être négative'],
        operationName: 'RecordHabit',
      );
    }
  }
}

class UpdateHabitCommand extends Command {
  final String habitId;
  final String? name;
  final String? description;
  final String? category;
  final double? targetValue;
  final String? unit;

  UpdateHabitCommand({
    required this.habitId,
    this.name,
    this.description,
    this.category,
    this.targetValue,
    this.unit,
  });

  @override
  void validate() {
    if (habitId.trim().isEmpty) {
      throw BusinessValidationException(
        'ID d\'habitude requis',
        ['L\'identifiant de l\'habitude est requis'],
        operationName: 'UpdateHabit',
      );
    }

    if (name != null && name!.trim().isEmpty) {
      throw BusinessValidationException(
        'Le nom ne peut pas être vide',
        ['Le nom de l\'habitude ne peut pas être vide'],
        operationName: 'UpdateHabit',
      );
    }

    if (targetValue != null && targetValue! <= 0) {
      throw BusinessValidationException(
        'Valeur cible invalide',
        ['La valeur cible doit être positive'],
        operationName: 'UpdateHabit',
      );
    }
  }
}

class DeleteHabitCommand extends Command {
  final String habitId;

  DeleteHabitCommand({required this.habitId});

  @override
  void validate() {
    if (habitId.trim().isEmpty) {
      throw BusinessValidationException(
        'ID d\'habitude requis',
        ['L\'identifiant de l\'habitude est requis'],
        operationName: 'DeleteHabit',
      );
    }
  }
}

/// Queries pour les cas d'usage des habitudes
class GetHabitQuery extends Query {
  final String habitId;

  GetHabitQuery({required this.habitId});

  @override
  void validate() {
    if (habitId.trim().isEmpty) {
      throw BusinessValidationException(
        'ID d\'habitude requis',
        ['L\'identifiant de l\'habitude est requis'],
        operationName: 'GetHabit',
      );
    }
  }
}

class GetHabitsQuery extends Query {
  final String? category;
  final HabitType? type;
  final bool? completedToday;
  final int? minStreak;
  final double? minSuccessRate;
  final int? limit;
  final String? searchText;

  GetHabitsQuery({
    this.category,
    this.type,
    this.completedToday,
    this.minStreak,
    this.minSuccessRate,
    this.limit,
    this.searchText,
  });

  @override
  void validate() {
    if (limit != null && limit! <= 0) {
      throw BusinessValidationException(
        'Limite invalide',
        ['La limite doit être supérieure à 0'],
        operationName: 'GetHabits',
      );
    }

    if (minStreak != null && minStreak! < 0) {
      throw BusinessValidationException(
        'Streak minimum invalide',
        ['Le streak minimum ne peut pas être négatif'],
        operationName: 'GetHabits',
      );
    }

    if (minSuccessRate != null && (minSuccessRate! < 0 || minSuccessRate! > 1)) {
      throw BusinessValidationException(
        'Taux de réussite invalide',
        ['Le taux de réussite minimum doit être entre 0 et 1'],
        operationName: 'GetHabits',
      );
    }
  }
}

class GetTodaysHabitsQuery extends Query {}

class GetHabitAnalyticsQuery extends Query {
  final String habitId;
  final int? analysisWindow;

  GetHabitAnalyticsQuery({
    required this.habitId,
    this.analysisWindow,
  });

  @override
  void validate() {
    if (habitId.trim().isEmpty) {
      throw BusinessValidationException(
        'ID d\'habitude requis',
        ['L\'identifiant de l\'habitude est requis'],
        operationName: 'GetHabitAnalytics',
      );
    }

    if (analysisWindow != null && analysisWindow! <= 0) {
      throw BusinessValidationException(
        'Fenêtre d\'analyse invalide',
        ['La fenêtre d\'analyse doit être positive'],
        operationName: 'GetHabitAnalytics',
      );
    }
  }
}

class GetHabitStatisticsQuery extends Query {
  final DateRange? dateRange;

  GetHabitStatisticsQuery({this.dateRange});
}

/// Service d'application pour les habitudes
class HabitApplicationService extends ApplicationService {
  final HabitRepository _habitRepository;
  final HabitAnalyticsService _analyticsService;

  HabitApplicationService(this._habitRepository, this._analyticsService);

  @override
  String get serviceName => 'HabitApplicationService';

  /// Crée une nouvelle habitude
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

  /// Enregistre l'exécution d'une habitude
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

  /// Met à jour une habitude
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

  /// Supprime une habitude
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

  /// Récupère une habitude par son ID
  Future<OperationResult<HabitAggregate>> getHabit(GetHabitQuery query) async {
    return await safeExecute(() async {
      query.validate();

      final habit = await _habitRepository.findById(query.habitId);
      if (habit == null) {
        throw ResourceNotFoundException('Habit', query.habitId);
      }

      return OperationResult.success(habit);
    }, 'getHabit');
  }

  /// Récupère des habitudes selon des critères
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

  /// Récupère les habitudes du jour
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

  /// Récupère l'analyse d'une habitude
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

  /// Récupère les statistiques des habitudes
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

  /// Génère des recommandations pour une habitude
  Future<OperationResult<List<HabitRecommendation>>> getHabitRecommendations(String habitId) async {
    return await safeExecute(() async {
      final habit = await _habitRepository.findById(habitId);
      if (habit == null) {
        throw ResourceNotFoundException('Habit', habitId);
      }

      final recommendations = _analyticsService.generateRecommendations(habit);

      return OperationResult.success(
        recommendations,
        message: '${recommendations.length} recommandation(s) générée(s)',
        metadata: {
          'highPriority': recommendations.where((r) => r.priority == RecommendationPriority.high).length,
          'mediumPriority': recommendations.where((r) => r.priority == RecommendationPriority.medium).length,
          'lowPriority': recommendations.where((r) => r.priority == RecommendationPriority.low).length,
        },
      );
    }, 'getHabitRecommendations');
  }

  /// Trouve les habitudes excellentes
  Future<OperationResult<List<HabitAggregate>>> getExcellentHabits() async {
    return await safeExecute(() async {
      final excellentHabits = await _habitRepository.findExcellentHabits();

      return OperationResult.success(
        excellentHabits,
        message: '${excellentHabits.length} habitude(s) excellente(s) trouvée(s)',
        metadata: {
          'count': excellentHabits.length,
          'averageStreak': excellentHabits.isEmpty ? 0 : 
            excellentHabits.map((h) => h.getCurrentStreak()).reduce((a, b) => a + b) / excellentHabits.length,
        },
      );
    }, 'getExcellentHabits');
  }

  /// Trouve les habitudes nécessitant de l'attention
  Future<OperationResult<List<HabitAggregate>>> getHabitsNeedingAttention() async {
    return await safeExecute(() async {
      final habitsNeedingAttention = await _habitRepository.findNeedingAttention();

      return OperationResult.success(
        habitsNeedingAttention,
        message: '${habitsNeedingAttention.length} habitude(s) nécessitant de l\'attention',
        metadata: {
          'count': habitsNeedingAttention.length,
          'struggling': habitsNeedingAttention.where((h) => h.getSuccessRate() < 0.5).length,
        },
      );
    }, 'getHabitsNeedingAttention');
  }
}