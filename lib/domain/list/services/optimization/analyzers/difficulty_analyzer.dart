import '../../../core/services/domain_service.dart';
import '../../aggregates/custom_list_aggregate.dart';

/// Analyseur de difficulté des listes
///
/// Analyse l'équilibre de difficulté d'une liste et fournit des recommandations
/// pour maintenir un équilibre optimal entre tâches faciles, moyennes et difficiles.
///
/// SOLID:
/// - SRP: Responsabilité unique d'analyse de difficulté
/// - OCP: Extensible via héritage sans modification
/// - DIP: Dépend de l'abstraction LoggableDomainService
class DifficultyAnalyzer extends LoggableDomainService {
  @override
  String get serviceName => 'DifficultyAnalyzer';

  /// Calcule le score de difficulté optimal pour une liste
  DifficultyBalance calculateOptimalDifficulty(CustomListAggregate list) {
    return executeOperation(() {
      log('Calcul de l\'équilibre de difficulté pour ${list.name}');

      final items = list.items.where((item) => !item.isCompleted).toList();

      if (items.isEmpty) {
        return DifficultyBalance(
          easyCount: 0,
          mediumCount: 0,
          hardCount: 0,
          balance: DifficultyBalanceType.perfect,
          recommendation: 'Liste complétée!',
        );
      }

      // Catégoriser les éléments par difficulté (basé sur ELO)
      final easyItems = items.where((item) => item.eloScore.value < 1200).length;
      final mediumItems = items
          .where((item) =>
              item.eloScore.value >= 1200 && item.eloScore.value < 1400)
          .length;
      final hardItems = items.where((item) => item.eloScore.value >= 1400).length;

      // Ratios optimaux: 40% facile, 40% moyen, 20% difficile
      final totalItems = items.length;
      final optimalEasy = (totalItems * 0.4).round();
      final optimalMedium = (totalItems * 0.4).round();
      final optimalHard = (totalItems * 0.2).round();

      // Analyser l'équilibre actuel
      final easyDiff = (easyItems - optimalEasy).abs();
      final mediumDiff = (mediumItems - optimalMedium).abs();
      final hardDiff = (hardItems - optimalHard).abs();

      final totalDiff = easyDiff + mediumDiff + hardDiff;

      DifficultyBalanceType balanceType;
      String recommendation;

      if (totalDiff <= 2) {
        balanceType = DifficultyBalanceType.perfect;
        recommendation = 'Équilibre optimal maintenu!';
      } else if (easyItems > optimalEasy + 2) {
        balanceType = DifficultyBalanceType.tooEasy;
        recommendation = 'Ajouter des défis plus complexes';
      } else if (hardItems > optimalHard + 2) {
        balanceType = DifficultyBalanceType.tooHard;
        recommendation = 'Ajouter des tâches plus accessibles';
      } else {
        balanceType = DifficultyBalanceType.unbalanced;
        recommendation = 'Rééquilibrer la distribution des difficultés';
      }

      log('Équilibre analysé - Facile: $easyItems, Moyen: $mediumItems, Difficile: $hardItems');

      return DifficultyBalance(
        easyCount: easyItems,
        mediumCount: mediumItems,
        hardCount: hardItems,
        balance: balanceType,
        recommendation: recommendation,
      );
    });
  }
}

/// Représente l'équilibre de difficulté d'une liste
class DifficultyBalance {
  final int easyCount;
  final int mediumCount;
  final int hardCount;
  final DifficultyBalanceType balance;
  final String recommendation;

  const DifficultyBalance({
    required this.easyCount,
    required this.mediumCount,
    required this.hardCount,
    required this.balance,
    required this.recommendation,
  });
}

/// Types d'équilibre de difficulté
enum DifficultyBalanceType {
  perfect,
  tooEasy,
  tooHard,
  unbalanced,
}
