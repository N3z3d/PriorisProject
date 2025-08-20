/// Paramètres configurables pour la variation dynamique d'ELO
/// 
/// Cette classe encapsule la logique de calcul des multiplicateurs ELO
/// basés sur l'ancienneté des tâches (lastChosenAt).
/// Utilisée pour favoriser les tâches anciennes ou nouvelles.
class EloVariationSettings {
  /// Multiplicateur pour les nouvelles tâches (jamais choisies)
  final double newTaskMultiplier;
  
  /// Multiplicateur pour les tâches pas choisies depuis 7+ jours
  final double oldTaskMultiplier7Days;
  
  /// Multiplicateur pour les tâches pas choisies depuis 30+ jours
  final double oldTaskMultiplier30Days;
  
  /// Seuil en jours pour appliquer oldTaskMultiplier7Days
  final int threshold7Days;
  
  /// Seuil en jours pour appliquer oldTaskMultiplier30Days
  final int threshold30Days;

  EloVariationSettings({
    required this.newTaskMultiplier,
    required this.oldTaskMultiplier7Days,
    required this.oldTaskMultiplier30Days,
    required this.threshold7Days,
    required this.threshold30Days,
  }) {
    // Validation des paramètres
    if (newTaskMultiplier <= 0 ||
        oldTaskMultiplier7Days <= 0 ||
        oldTaskMultiplier30Days <= 0) {
      throw ArgumentError('Tous les multiplicateurs doivent être positifs');
    }
    
    if (threshold30Days <= threshold7Days) {
      throw ArgumentError('threshold30Days doit être supérieur à threshold7Days');
    }
    
    if (threshold7Days <= 0 || threshold30Days <= 0) {
      throw ArgumentError('Les seuils doivent être positifs');
    }
  }

  /// Constructeur const pour les paramètres par défaut (sans validation runtime)
  const EloVariationSettings._internal({
    required this.newTaskMultiplier,
    required this.oldTaskMultiplier7Days,
    required this.oldTaskMultiplier30Days,
    required this.threshold7Days,
    required this.threshold30Days,
  });

  /// Paramètres par défaut recommandés
  factory EloVariationSettings.defaultSettings() {
    return const EloVariationSettings._internal(
      newTaskMultiplier: 1.2,        // +20% pour nouvelles tâches
      oldTaskMultiplier7Days: 1.5,   // +50% après 7 jours
      oldTaskMultiplier30Days: 2.0,  // +100% après 30 jours
      threshold7Days: 7,
      threshold30Days: 30,
    );
  }

  /// Calcule le multiplicateur ELO selon la date de dernier choix
  /// 
  /// [lastChosenAt] : null pour nouvelles tâches, sinon date du dernier choix
  /// 
  /// Retourne :
  /// - [newTaskMultiplier] si lastChosenAt == null (nouvelle tâche)
  /// - [oldTaskMultiplier30Days] si >= 30 jours
  /// - [oldTaskMultiplier7Days] si >= 7 jours  
  /// - 1.0 si < 7 jours (pas de bonus)
  double calculateMultiplier({DateTime? lastChosenAt}) {
    // Nouvelle tâche (jamais choisie)
    if (lastChosenAt == null) {
      return newTaskMultiplier;
    }
    
    // Calculer le nombre de jours depuis le dernier choix
    final daysSinceChosen = DateTime.now().difference(lastChosenAt).inDays;
    
    // Appliquer les multiplicateurs selon l'ancienneté
    if (daysSinceChosen >= threshold30Days) {
      return oldTaskMultiplier30Days;
    } else if (daysSinceChosen >= threshold7Days) {
      return oldTaskMultiplier7Days;
    } else {
      return 1.0; // Pas de bonus pour les tâches récentes
    }
  }

  /// Copie avec modification de certains paramètres
  EloVariationSettings copyWith({
    double? newTaskMultiplier,
    double? oldTaskMultiplier7Days,
    double? oldTaskMultiplier30Days,
    int? threshold7Days,
    int? threshold30Days,
  }) {
    return EloVariationSettings(
      newTaskMultiplier: newTaskMultiplier ?? this.newTaskMultiplier,
      oldTaskMultiplier7Days: oldTaskMultiplier7Days ?? this.oldTaskMultiplier7Days,
      oldTaskMultiplier30Days: oldTaskMultiplier30Days ?? this.oldTaskMultiplier30Days,
      threshold7Days: threshold7Days ?? this.threshold7Days,
      threshold30Days: threshold30Days ?? this.threshold30Days,
    );
  }

  @override
  String toString() {
    return 'EloVariationSettings('
        'new: ${newTaskMultiplier}x, '
        '${threshold7Days}d+: ${oldTaskMultiplier7Days}x, '
        '${threshold30Days}d+: ${oldTaskMultiplier30Days}x'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EloVariationSettings &&
        other.newTaskMultiplier == newTaskMultiplier &&
        other.oldTaskMultiplier7Days == oldTaskMultiplier7Days &&
        other.oldTaskMultiplier30Days == oldTaskMultiplier30Days &&
        other.threshold7Days == threshold7Days &&
        other.threshold30Days == threshold30Days;
  }

  @override
  int get hashCode {
    return Object.hash(
      newTaskMultiplier,
      oldTaskMultiplier7Days,
      oldTaskMultiplier30Days,
      threshold7Days,
      threshold30Days,
    );
  }
}