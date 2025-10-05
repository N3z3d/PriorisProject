import '../aggregates/task_aggregate.dart';

/// Résultat d'un duel entre deux tâches
///
/// Value Object immuable représentant le résultat d'un affrontement
/// entre deux tâches avec les changements d'ELO associés.
class DuelResult {
  final TaskAggregate winner;
  final TaskAggregate loser;
  final double winnerEloChange;
  final double loserEloChange;
  final double winProbability;

  const DuelResult({
    required this.winner,
    required this.loser,
    required this.winnerEloChange,
    required this.loserEloChange,
    required this.winProbability,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DuelResult &&
          runtimeType == other.runtimeType &&
          winner.id == other.winner.id &&
          loser.id == other.loser.id &&
          winnerEloChange == other.winnerEloChange &&
          loserEloChange == other.loserEloChange &&
          winProbability == other.winProbability;

  @override
  int get hashCode =>
      winner.id.hashCode ^
      loser.id.hashCode ^
      winnerEloChange.hashCode ^
      loserEloChange.hashCode ^
      winProbability.hashCode;

  @override
  String toString() {
    return 'DuelResult(winner: ${winner.title}, loser: ${loser.title}, changes: +${winnerEloChange.toStringAsFixed(1)}/-${loserEloChange.abs().toStringAsFixed(1)})';
  }
}
