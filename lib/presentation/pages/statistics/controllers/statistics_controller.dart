import 'package:flutter/foundation.dart';

import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import '../services/statistics_calculation_service.dart';

/// Controller centralisant la gestion d'état et le chargement des statistiques
/// pour la page Statistiques. Respecte le principe de responsabilité unique.
class StatisticsController extends ChangeNotifier {
  String _selectedPeriod = '7_days';
  Map<String, dynamic>? _mainMetrics;
  bool _isLoading = false;

  String get selectedPeriod => _selectedPeriod;
  Map<String, dynamic>? get mainMetrics => _mainMetrics;
  bool get isLoading => _isLoading;

  /// Change la période sélectionnée et recharge les métriques
  void setPeriod(String period) {
    if (_selectedPeriod != period) {
      _selectedPeriod = period;
      notifyListeners();
    }
  }

  /// Charge les métriques principales à partir des données fournies
  Future<void> loadMainMetrics(List<Habit> habits, List<Task> tasks) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 100)); // Simule async
    _mainMetrics = {
      'habitSuccessRate': StatisticsCalculationService.calculateHabitSuccessRate(habits),
      'taskCompletionRate': StatisticsCalculationService.calculateTaskCompletionRate(tasks),
      'currentStreak': StatisticsCalculationService.calculateCurrentStreak(habits),
      'totalPoints': StatisticsCalculationService.calculateTotalPoints(habits, tasks),
    };
    _isLoading = false;
    notifyListeners();
  }

  /// Réinitialise les métriques (utile pour les tests ou le reset UI)
  void reset() {
    _mainMetrics = null;
    _isLoading = false;
    notifyListeners();
  }
} 
