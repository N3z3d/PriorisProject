/// Ajustement ELO basé sur la performance
///
/// Value Object immuable représentant un ajustement de score ELO
/// recommandé suite à l'évaluation de la performance d'une tâche.
class EloAdjustment {
  final double adjustment;
  final String reason;
  final double performanceRatio;
  final double originalElo;
  final double newElo;

  const EloAdjustment({
    required this.adjustment,
    required this.reason,
    required this.performanceRatio,
    required this.originalElo,
    required this.newElo,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EloAdjustment &&
          runtimeType == other.runtimeType &&
          adjustment == other.adjustment &&
          reason == other.reason &&
          performanceRatio == other.performanceRatio &&
          originalElo == other.originalElo &&
          newElo == other.newElo;

  @override
  int get hashCode =>
      adjustment.hashCode ^
      reason.hashCode ^
      performanceRatio.hashCode ^
      originalElo.hashCode ^
      newElo.hashCode;

  @override
  String toString() {
    return 'EloAdjustment(${adjustment > 0 ? '+' : ''}${adjustment.toStringAsFixed(1)}: $reason)';
  }
}
