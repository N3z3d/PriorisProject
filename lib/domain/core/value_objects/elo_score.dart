import 'dart:math';

/// Value Object représentant un score ELO
/// 
/// Le score ELO est un système de classement utilisé pour calculer les niveaux relatifs
/// de compétence des joueurs dans des jeux à somme nulle tels que les échecs.
/// Dans Prioris, il est utilisé pour prioriser les tâches et habitudes.
class EloScore {
  static const double _defaultScore = 1200.0;
  static const double _minScore = 0.0;
  static const double _maxScore = 3000.0;
  static const double _defaultKFactor = 32.0;
  
  final double value;

  const EloScore._(this.value);

  /// Crée un score ELO avec une valeur par défaut
  factory EloScore.initial() => const EloScore._(_defaultScore);

  /// Crée un score ELO avec une valeur spécifique
  factory EloScore.fromValue(double value) {
    if (value < _minScore || value > _maxScore) {
      throw ArgumentError('Le score ELO doit être entre $_minScore et $_maxScore');
    }
    return EloScore._(value);
  }

  /// Calcule la probabilité de victoire contre un autre score ELO
  double calculateWinProbability(EloScore opponent) {
    return 1.0 / (1.0 + pow(10.0, (opponent.value - value) / 400.0));
  }

  /// Met à jour le score ELO après un duel
  EloScore updateAfterDuel({
    required EloScore opponent,
    required bool won,
    double kFactor = _defaultKFactor,
  }) {
    final expectedScore = calculateWinProbability(opponent);
    final actualScore = won ? 1.0 : 0.0;
    final newValue = value + kFactor * (actualScore - expectedScore);
    
    return EloScore.fromValue(newValue.clamp(_minScore, _maxScore));
  }

  /// Détermine la catégorie du score ELO
  EloCategory get category {
    if (value >= 1600) return EloCategory.expert;
    if (value >= 1400) return EloCategory.advanced;
    if (value >= 1200) return EloCategory.intermediate;
    if (value >= 1000) return EloCategory.beginner;
    return EloCategory.novice;
  }

  /// Retourne le score formaté comme entier
  int get asInt => value.round();

  /// Opérateurs de comparaison
  bool operator >(EloScore other) => value > other.value;
  bool operator <(EloScore other) => value < other.value;
  bool operator >=(EloScore other) => value >= other.value;
  bool operator <=(EloScore other) => value <= other.value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EloScore && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'EloScore(${value.toStringAsFixed(0)})';

  /// Sérialisation JSON
  Map<String, dynamic> toJson() => {'value': value};

  /// Désérialisation JSON
  factory EloScore.fromJson(Map<String, dynamic> json) {
    return EloScore.fromValue(json['value'] as double);
  }
}

/// Énumération des catégories de score ELO
enum EloCategory {
  novice('Novice', 0, 999),
  beginner('Débutant', 1000, 1199),
  intermediate('Intermédiaire', 1200, 1399),
  advanced('Avancé', 1400, 1599),
  expert('Expert', 1600, 3000);

  const EloCategory(this.label, this.minScore, this.maxScore);

  final String label;
  final int minScore;
  final int maxScore;

  /// Retourne la couleur associée à la catégorie
  String get colorCode {
    switch (this) {
      case EloCategory.novice:
        return '#9E9E9E'; // Gris
      case EloCategory.beginner:
        return '#4CAF50'; // Vert
      case EloCategory.intermediate:
        return '#2196F3'; // Bleu
      case EloCategory.advanced:
        return '#9C27B0'; // Violet
      case EloCategory.expert:
        return '#FF9800'; // Orange
    }
  }

  /// Retourne l'icône associée à la catégorie
  String get iconName {
    switch (this) {
      case EloCategory.novice:
        return 'star_border';
      case EloCategory.beginner:
        return 'star_half';
      case EloCategory.intermediate:
        return 'star';
      case EloCategory.advanced:
        return 'stars';
      case EloCategory.expert:
        return 'military_tech';
    }
  }
}