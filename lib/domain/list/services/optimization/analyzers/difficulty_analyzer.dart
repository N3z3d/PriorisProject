import '../../../core/services/domain_service.dart';
import '../../aggregates/custom_list_aggregate.dart';
import '../../value_objects/list_item.dart';

/// Difficulty analyzer for custom lists.
///
/// Determines how balanced the remaining tasks are and provides
/// recommendations to maintain an accessible difficulty mix.
class DifficultyAnalyzer extends LoggableDomainService {
  @override
  String get serviceName => 'DifficultyAnalyzer';

  /// Calculates the optimal difficulty balance for a list.
  DifficultyBalance calculateOptimalDifficulty(CustomListAggregate list) {
    return executeOperation(() {
      log("Evaluating difficulty balance for ${list.name}");

      final activeItems = list.items.where((item) => !item.isCompleted).toList();
      if (activeItems.isEmpty) {
        return const DifficultyBalance(
          easyCount: 0,
          mediumCount: 0,
          hardCount: 0,
          balance: DifficultyBalanceType.perfect,
          recommendation: 'List already completed',
        );
      }

      final counts = _countByDifficulty(activeItems);
      final targets = _computeTargetDistribution(activeItems.length);
      final balance = _evaluateBalance(counts, targets);

      log(
        'Difficulty mix analysed - easy: ${counts.easy}, medium: ${counts.medium}, hard: ${counts.hard}',
      );

      return DifficultyBalance(
        easyCount: counts.easy,
        mediumCount: counts.medium,
        hardCount: counts.hard,
        balance: balance.type,
        recommendation: balance.recommendation,
      );
    });
  }

  _DifficultyCounts _countByDifficulty(List<ListItem> activeItems) {
    var easy = 0;
    var medium = 0;
    var hard = 0;

    for (final item in activeItems) {
      final score = item.eloScore.value;
      if (score < 1200) {
        easy++;
      } else if (score < 1400) {
        medium++;
      } else {
        hard++;
      }
    }

    return _DifficultyCounts(easy: easy, medium: medium, hard: hard);
  }

  _DifficultyTargets _computeTargetDistribution(int totalItems) {
    return _DifficultyTargets(
      easy: (totalItems * 0.4).round(),
      medium: (totalItems * 0.4).round(),
      hard: (totalItems * 0.2).round(),
    );
  }

  _BalanceResult _evaluateBalance(_DifficultyCounts counts, _DifficultyTargets targets) {
    final diffEasy = (counts.easy - targets.easy).abs();
    final diffMedium = (counts.medium - targets.medium).abs();
    final diffHard = (counts.hard - targets.hard).abs();
    final totalDiff = diffEasy + diffMedium + diffHard;

    if (totalDiff <= 2) {
      return const _BalanceResult(
        type: DifficultyBalanceType.perfect,
        recommendation: 'Difficulty mix is optimal',
      );
    }
    if (counts.easy > targets.easy + 2) {
      return const _BalanceResult(
        type: DifficultyBalanceType.tooEasy,
        recommendation: 'Add more challenging items to keep momentum',
      );
    }
    if (counts.hard > targets.hard + 2) {
      return const _BalanceResult(
        type: DifficultyBalanceType.tooHard,
        recommendation: 'Balance with easier wins to maintain confidence',
      );
    }
    return const _BalanceResult(
      type: DifficultyBalanceType.unbalanced,
      recommendation: 'Adjust the mix of task difficulties',
    );
  }
}

class _DifficultyCounts {
  final int easy;
  final int medium;
  final int hard;

  const _DifficultyCounts({required this.easy, required this.medium, required this.hard});
}

class _DifficultyTargets {
  final int easy;
  final int medium;
  final int hard;

  const _DifficultyTargets({required this.easy, required this.medium, required this.hard});
}

class _BalanceResult {
  final DifficultyBalanceType type;
  final String recommendation;

  const _BalanceResult({required this.type, required this.recommendation});
}

/// Represents the difficulty balance of a list.
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

/// Difficulty balance categories.
enum DifficultyBalanceType {
  perfect,
  tooEasy,
  tooHard,
  unbalanced,
}
