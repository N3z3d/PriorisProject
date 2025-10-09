import '../../../core/services/domain_service.dart';
import '../../aggregates/custom_list_aggregate.dart';
import '../../value_objects/list_item.dart';

/// Completion pattern analyzer
///
/// Examines completion history to detect trends and predict the next
/// items a user is likely to complete.
///
/// SOLID:
/// - SRP: focuses on completion analytics only
/// - OCP: extendable via inheritance without modification
/// - DIP: relies on LoggableDomainService abstraction
class CompletionPatternAnalyzer extends LoggableDomainService {
  @override
  String get serviceName => 'CompletionPatternAnalyzer';

  /// Analyse completion patterns and produce actionable metrics
  CompletionPatterns analyzeCompletionPatterns(CustomListAggregate list) {
    return executeOperation(() {
      log("Analysing completion patterns for ${list.name}");

      final completedItems = list.getCompletedItems();
      if (completedItems.isEmpty) {
        return CompletionPatterns.empty();
      }

      final incompleteItems = list.getIncompleteItems();
      final metrics = _buildCompletionMetrics(completedItems);
      final preferredCategories = _selectPreferredCategories(metrics.completedByCategory);
      final averageElo = _calculateAverage(metrics.completedElos);
      final averageCompletionTime = _calculateAverageCompletionTime(completedItems);
      final nextCandidates = _selectNextCandidates(
        incompleteItems,
        averageElo,
        preferredCategories,
      );

      log('Preferred categories detected: ${preferredCategories.join(', ')}');

      return CompletionPatterns(
        preferredCategories: preferredCategories,
        averageEloCompleted: averageElo,
        averageCompletionTime: averageCompletionTime,
        nextLikelyCandidates: nextCandidates,
        completionVelocity: _calculateCompletionVelocity(list),
        stuckItems: _identifyStuckItems(incompleteItems),
      );
    });
  }

  _CompletionMetrics _buildCompletionMetrics(List<ListItem> completedItems) {
    final completedByCategory = <String, int>{};
    final completedElos = <double>[];

    for (final item in completedItems) {
      final category = item.category;
      if (category != null) {
        completedByCategory[category] = (completedByCategory[category] ?? 0) + 1;
      }
      completedElos.add(item.eloScore.value);
    }

    return _CompletionMetrics(
      completedByCategory: completedByCategory,
      completedElos: completedElos,
    );
  }

  List<String> _selectPreferredCategories(Map<String, int> completedByCategory) {
    final categories = completedByCategory.entries
        .where((entry) => entry.value >= 2)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return categories.map((entry) => entry.key).toList();
  }

  double _calculateAverage(List<double> values) {
    if (values.isEmpty) {
      return 0.0;
    }
    final total = values.reduce((a, b) => a + b);
    return total / values.length;
  }

  Duration _calculateAverageCompletionTime(List<ListItem> completedItems) {
    final completionTimes = completedItems
        .where((item) => item.completionTime != null)
        .map((item) => item.completionTime!.inMinutes)
        .toList();

    if (completionTimes.isEmpty) {
      return Duration.zero;
    }

    final totalMinutes = completionTimes.reduce((a, b) => a + b);
    return Duration(minutes: totalMinutes ~/ completionTimes.length);
  }

  List<ListItem> _selectNextCandidates(
    List<ListItem> incompleteItems,
    double averageCompletedElo,
    List<String> preferredCategories,
  ) {
    return incompleteItems
        .where((item) {
          final eloWithinRange = item.eloScore.value <= averageCompletedElo + 100;
          final matchesPreferredCategory =
              item.category != null && preferredCategories.contains(item.category);
          return eloWithinRange || matchesPreferredCategory;
        })
        .take(3)
        .toList();
  }

  /// Calculate completion velocity (items per day over the last week)
  double _calculateCompletionVelocity(CustomListAggregate list) {
    final completedItems = list.getCompletedItems();
    if (completedItems.isEmpty) return 0.0;

    final now = DateTime.now();
    final recentCompletions = completedItems
        .where((item) =>
            item.completedAt != null &&
            now.difference(item.completedAt!).inDays <= 7)
        .length;

    return recentCompletions / 7.0;
  }

  /// Identify stuck items (not completed after two weeks)
  List<ListItem> _identifyStuckItems(List<ListItem> incompleteItems) {
    final now = DateTime.now();
    return incompleteItems
        .where((item) => now.difference(item.createdAt).inDays > 14)
        .toList();
  }
}

class _CompletionMetrics {
  final Map<String, int> completedByCategory;
  final List<double> completedElos;

  const _CompletionMetrics({
    required this.completedByCategory,
    required this.completedElos,
  });
}

/// Completion patterns for a list
class CompletionPatterns {
  final List<String> preferredCategories;
  final double averageEloCompleted;
  final Duration averageCompletionTime;
  final List<ListItem> nextLikelyCandidates;
  final double completionVelocity;
  final List<ListItem> stuckItems;

  const CompletionPatterns({
    required this.preferredCategories,
    required this.averageEloCompleted,
    required this.averageCompletionTime,
    required this.nextLikelyCandidates,
    required this.completionVelocity,
    required this.stuckItems,
  });

  factory CompletionPatterns.empty() {
    return const CompletionPatterns(
      preferredCategories: [],
      averageEloCompleted: 0.0,
      averageCompletionTime: Duration.zero,
      nextLikelyCandidates: [],
      completionVelocity: 0.0,
      stuckItems: [],
    );
  }
}
