import '../../core/value_objects/export.dart';

/// Statistiques ELO pour un ensemble de tâches
///
/// Value Object immuable fournissant une vue d'ensemble statistique
/// de la distribution des scores ELO dans un groupe de tâches.
class EloStatistics {
  final int count;
  final double average;
  final double median;
  final double minimum;
  final double maximum;
  final double standardDeviation;
  final Map<EloCategory, int> distribution;

  const EloStatistics({
    required this.count,
    required this.average,
    required this.median,
    required this.minimum,
    required this.maximum,
    required this.standardDeviation,
    required this.distribution,
  });

  factory EloStatistics.empty() {
    return const EloStatistics(
      count: 0,
      average: 0,
      median: 0,
      minimum: 0,
      maximum: 0,
      standardDeviation: 0,
      distribution: {},
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EloStatistics &&
          runtimeType == other.runtimeType &&
          count == other.count &&
          average == other.average &&
          median == other.median &&
          minimum == other.minimum &&
          maximum == other.maximum &&
          standardDeviation == other.standardDeviation;

  @override
  int get hashCode =>
      count.hashCode ^
      average.hashCode ^
      median.hashCode ^
      minimum.hashCode ^
      maximum.hashCode ^
      standardDeviation.hashCode;

  @override
  String toString() {
    return 'EloStatistics(count: $count, average: ${average.toStringAsFixed(1)}, range: ${minimum.toStringAsFixed(0)}-${maximum.toStringAsFixed(0)})';
  }
}

/// Extension pour calculer la racine carrée sécurisée
extension SafeSquareRoot on double {
  double get squareRoot => this < 0 ? 0 : this;
}
