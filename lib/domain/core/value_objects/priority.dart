/// Value Object représentant la priorité d'une tâche ou habitude
/// 
/// La priorité est déterminée par plusieurs facteurs :
/// - Score ELO (importance relative)
/// - Date d'échéance
/// - Catégorie d'urgence
/// - Contexte métier
class Priority {
  final PriorityLevel level;
  final double score;
  final String? reason;

  const Priority._({
    required this.level,
    required this.score,
    this.reason,
  });

  /// Crée une priorité basée sur un score ELO et une date d'échéance
  factory Priority.fromEloAndDueDate({
    required double eloScore,
    DateTime? dueDate,
    DateTime? now,
  }) {
    now ??= DateTime.now();
    
    // Score de base basé sur l'ELO (normalisé entre 0 et 1)
    double baseScore = (eloScore - 800) / 1600; // ELO 800-2400 -> 0-1
    baseScore = baseScore.clamp(0.0, 1.0);
    
    double urgencyMultiplier = 1.0;
    String? reason;
    
    if (dueDate != null) {
      final daysUntilDue = dueDate.difference(now).inDays;
      
      if (daysUntilDue < 0) {
        // En retard
        urgencyMultiplier = 2.0;
        reason = 'Tâche en retard de ${(-daysUntilDue)} jour(s)';
      } else if (daysUntilDue == 0) {
        // Aujourd'hui
        urgencyMultiplier = 1.8;
        reason = 'Échéance aujourd\'hui';
      } else if (daysUntilDue == 1) {
        // Demain
        urgencyMultiplier = 1.5;
        reason = 'Échéance demain';
      } else if (daysUntilDue <= 3) {
        // Dans les 3 jours
        urgencyMultiplier = 1.3;
        reason = 'Échéance dans $daysUntilDue jour(s)';
      } else if (daysUntilDue <= 7) {
        // Dans la semaine
        urgencyMultiplier = 1.1;
        reason = 'Échéance dans $daysUntilDue jour(s)';
      }
    }
    
    final finalScore = (baseScore * urgencyMultiplier).clamp(0.0, 2.0);
    final level = PriorityLevel.fromScore(finalScore);
    
    return Priority._(
      level: level,
      score: finalScore,
      reason: reason,
    );
  }

  /// Crée une priorité avec un niveau spécifique
  factory Priority.fromLevel(PriorityLevel level, {String? reason}) {
    return Priority._(
      level: level,
      score: level.scoreRange.end,
      reason: reason,
    );
  }

  /// Crée une priorité critique
  factory Priority.critical({String? reason}) {
    return Priority.fromLevel(PriorityLevel.critical, reason: reason);
  }

  /// Crée une priorité élevée
  factory Priority.high({String? reason}) {
    return Priority.fromLevel(PriorityLevel.high, reason: reason);
  }

  /// Crée une priorité moyenne
  factory Priority.medium({String? reason}) {
    return Priority.fromLevel(PriorityLevel.medium, reason: reason);
  }

  /// Crée une priorité basse
  factory Priority.low({String? reason}) {
    return Priority.fromLevel(PriorityLevel.low, reason: reason);
  }

  /// Compare cette priorité avec une autre
  int compareTo(Priority other) {
    // Score plus élevé = priorité plus élevée
    return other.score.compareTo(score);
  }

  /// Détermine si cette priorité est plus importante que l'autre
  bool isHigherThan(Priority other) => score > other.score;

  /// Détermine si cette priorité nécessite une action immédiate
  bool get requiresImmediateAction => level.index >= PriorityLevel.high.index;

  /// Détermine si cette priorité peut être reportée
  bool get canBeDeferred => level.index <= PriorityLevel.medium.index;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Priority &&
        other.level == level &&
        other.score == score &&
        other.reason == reason;
  }

  @override
  int get hashCode => Object.hash(level, score, reason);

  @override
  String toString() {
    final reasonText = reason != null ? ' ($reason)' : '';
    return 'Priority(${level.name}, score: ${score.toStringAsFixed(2)}$reasonText)';
  }

  /// Sérialisation JSON
  Map<String, dynamic> toJson() => {
    'level': level.name,
    'score': score,
    'reason': reason,
  };

  /// Désérialisation JSON
  factory Priority.fromJson(Map<String, dynamic> json) {
    return Priority._(
      level: PriorityLevel.values.firstWhere(
        (l) => l.name == json['level'],
        orElse: () => PriorityLevel.medium,
      ),
      score: json['score'] as double,
      reason: json['reason'] as String?,
    );
  }
}

/// Énumération des niveaux de priorité
enum PriorityLevel {
  low('Basse', PriorityRange(0.0, 0.5)),
  medium('Moyenne', PriorityRange(0.5, 1.0)),
  high('Élevée', PriorityRange(1.0, 1.5)),
  critical('Critique', PriorityRange(1.5, 2.0));

  const PriorityLevel(this.label, this.scoreRange);

  final String label;
  final PriorityRange scoreRange;

  /// Détermine le niveau de priorité basé sur un score
  static PriorityLevel fromScore(double score) {
    if (score >= 1.5) return PriorityLevel.critical;
    if (score >= 1.0) return PriorityLevel.high;
    if (score >= 0.5) return PriorityLevel.medium;
    return PriorityLevel.low;
  }

  /// Retourne la couleur associée au niveau de priorité
  String get colorCode {
    switch (this) {
      case PriorityLevel.low:
        return '#4CAF50'; // Vert
      case PriorityLevel.medium:
        return '#FF9800'; // Orange
      case PriorityLevel.high:
        return '#F44336'; // Rouge
      case PriorityLevel.critical:
        return '#9C27B0'; // Violet
    }
  }

  /// Retourne l'icône associée au niveau de priorité
  String get iconName {
    switch (this) {
      case PriorityLevel.low:
        return 'low_priority';
      case PriorityLevel.medium:
        return 'priority_high';
      case PriorityLevel.high:
        return 'priority_high';
      case PriorityLevel.critical:
        return 'error';
    }
  }
}

/// Classe représentant une plage de scores de priorité
class PriorityRange {
  final double start;
  final double end;

  const PriorityRange(this.start, this.end);

  /// Vérifie si un score est dans cette plage
  bool contains(double score) => score >= start && score < end;

  @override
  String toString() => 'PriorityRange($start - $end)';
}