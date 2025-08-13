/// Value Object représentant la progression d'une tâche, habitude ou liste
/// 
/// La progression est calculée de manière uniforme à travers l'application
/// et fournit des métriques standardisées pour le suivi des performances.
class Progress {
  final double percentage;
  final int completed;
  final int total;
  final DateTime? lastUpdated;

  const Progress._({
    required this.percentage,
    required this.completed,
    required this.total,
    this.lastUpdated,
  });

  /// Crée une progression basée sur des éléments complétés/total
  factory Progress.fromCounts({
    required int completed,
    required int total,
    DateTime? lastUpdated,
  }) {
    if (completed < 0) {
      throw ArgumentError('Le nombre d\'éléments complétés ne peut pas être négatif');
    }
    if (total < 0) {
      throw ArgumentError('Le nombre total d\'éléments ne peut pas être négatif');
    }
    if (completed > total) {
      throw ArgumentError('Le nombre d\'éléments complétés ne peut pas dépasser le total');
    }

    final percentage = total == 0 ? 0.0 : (completed / total);
    
    return Progress._(
      percentage: percentage,
      completed: completed,
      total: total,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  /// Crée une progression basée sur un pourcentage
  factory Progress.fromPercentage({
    required double percentage,
    DateTime? lastUpdated,
  }) {
    if (percentage < 0.0 || percentage > 1.0) {
      throw ArgumentError('Le pourcentage doit être entre 0.0 et 1.0');
    }

    return Progress._(
      percentage: percentage,
      completed: (percentage * 100).round(),
      total: 100,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  /// Crée une progression vide (0%)
  factory Progress.empty() {
    return Progress.fromCounts(completed: 0, total: 0);
  }

  /// Crée une progression complète (100%)
  factory Progress.complete({
    int total = 1,
    DateTime? lastUpdated,
  }) {
    return Progress.fromCounts(
      completed: total,
      total: total,
      lastUpdated: lastUpdated,
    );
  }

  /// Retourne le pourcentage formaté (0-100)
  double get percentageDisplay => percentage * 100;

  /// Détermine le statut de la progression
  ProgressStatus get status {
    if (percentage == 0.0) return ProgressStatus.notStarted;
    if (percentage == 1.0) return ProgressStatus.completed;
    if (percentage >= 0.8) return ProgressStatus.almostDone;
    if (percentage >= 0.5) return ProgressStatus.halfWay;
    return ProgressStatus.inProgress;
  }

  /// Détermine si la progression est complète
  bool get isComplete => percentage >= 1.0;

  /// Détermine si la progression a commencé
  bool get hasStarted => percentage > 0.0;

  /// Calcule les éléments restants
  int get remaining => total - completed;

  /// Met à jour la progression avec de nouveaux éléments complétés
  Progress updateCompleted(int newCompleted) {
    return Progress.fromCounts(
      completed: newCompleted.clamp(0, total),
      total: total,
      lastUpdated: DateTime.now(),
    );
  }

  /// Met à jour le total d'éléments
  Progress updateTotal(int newTotal) {
    if (newTotal < completed) {
      throw ArgumentError('Le nouveau total ne peut pas être inférieur aux éléments complétés');
    }

    return Progress.fromCounts(
      completed: completed,
      total: newTotal,
      lastUpdated: DateTime.now(),
    );
  }

  /// Combine cette progression avec une autre
  Progress combineWith(Progress other) {
    return Progress.fromCounts(
      completed: completed + other.completed,
      total: total + other.total,
      lastUpdated: DateTime.now(),
    );
  }

  /// Compare cette progression avec une autre
  int compareTo(Progress other) {
    return percentage.compareTo(other.percentage);
  }

  /// Détermine si cette progression est supérieure à une autre
  bool isHigherThan(Progress other) => percentage > other.percentage;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Progress &&
        other.percentage == percentage &&
        other.completed == completed &&
        other.total == total;
  }

  @override
  int get hashCode => Object.hash(percentage, completed, total);

  @override
  String toString() {
    return 'Progress(${percentageDisplay.toStringAsFixed(1)}%, $completed/$total)';
  }

  /// Sérialisation JSON
  Map<String, dynamic> toJson() => {
    'percentage': percentage,
    'completed': completed,
    'total': total,
    'lastUpdated': lastUpdated?.toIso8601String(),
  };

  /// Désérialisation JSON
  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress.fromCounts(
      completed: json['completed'] as int,
      total: json['total'] as int,
      lastUpdated: json['lastUpdated'] != null 
        ? DateTime.parse(json['lastUpdated'] as String)
        : null,
    );
  }
}

/// Énumération des statuts de progression
enum ProgressStatus {
  notStarted('Non commencé'),
  inProgress('En cours'),
  halfWay('À mi-parcours'),
  almostDone('Presque terminé'),
  completed('Terminé');

  const ProgressStatus(this.label);

  final String label;

  /// Retourne la couleur associée au statut
  String get colorCode {
    switch (this) {
      case ProgressStatus.notStarted:
        return '#9E9E9E'; // Gris
      case ProgressStatus.inProgress:
        return '#2196F3'; // Bleu
      case ProgressStatus.halfWay:
        return '#FF9800'; // Orange
      case ProgressStatus.almostDone:
        return '#4CAF50'; // Vert clair
      case ProgressStatus.completed:
        return '#4CAF50'; // Vert
    }
  }

  /// Retourne l'icône associée au statut
  String get iconName {
    switch (this) {
      case ProgressStatus.notStarted:
        return 'radio_button_unchecked';
      case ProgressStatus.inProgress:
        return 'play_circle_outline';
      case ProgressStatus.halfWay:
        return 'adjust';
      case ProgressStatus.almostDone:
        return 'check_circle_outline';
      case ProgressStatus.completed:
        return 'check_circle';
    }
  }
}