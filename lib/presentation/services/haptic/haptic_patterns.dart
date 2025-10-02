/// Définitions des patterns de vibration
/// Centralise la configuration pour faciliter la maintenance (SRP)
class HapticPatterns {
  // ============ PATTERNS DE BASE ============

  static const List<int> success = [0, 50, 50, 30];
  static const int successAmplitude = 255;

  static const List<int> error = [0, 100, 100, 100];
  static const int errorAmplitude = 255;

  static const List<int> warning = [0, 75, 75, 25];
  static const int warningAmplitude = 200;

  static const List<int> notification = [0, 20, 50, 20];
  static const int notificationAmplitude = 150;

  // ============ PATTERNS POUR TÂCHES ============

  static const List<int> taskCompleted = [0, 30, 50, 20, 50, 15];
  static const int taskCompletedAmplitude = 200;

  // ============ PATTERNS POUR HABITUDES ============

  static const List<int> habitCompleted = [0, 60, 100, 40];
  static const int habitCompletedAmplitude = 255;

  /// Génère un pattern pour un streak milestone
  static List<int> streakMilestone(int streakCount) {
    final intensity = (streakCount / 7).clamp(1, 5).round();
    final pattern = <int>[0];

    for (int i = 0; i < intensity; i++) {
      pattern.addAll([80, 80]);
    }

    return pattern;
  }

  static const int streakAmplitude = 255;

  // ============ PATTERNS POUR PRIORITÉS ============

  static const List<int> priorityIncreased = [0, 20, 30, 40];
  static const int priorityIncreasedAmplitude = 150;

  static const List<int> priorityDecreased = [0, 40, 30, 20];
  static const int priorityDecreasedAmplitude = 200;

  // ============ PATTERNS AVANCÉS ============

  static const List<int> timerFinished = [0, 100, 200, 100, 200, 100];
  static const int timerFinishedAmplitude = 255;

  static const List<int> goalAchieved = [0, 80, 100, 60, 100, 40, 100, 20];
  static const int goalAchievedAmplitude = 255;

  // ============ HELPERS ============

  /// Génère un pattern mélodique basé sur des notes
  static List<int> melodic(List<int> notes) {
    final pattern = <int>[0];

    for (final note in notes) {
      final duration = (note / 127 * 100).round();
      pattern.addAll([duration, 50]);
    }

    return pattern;
  }

  /// Calcule l'amplitude moyenne pour un pattern mélodique
  static int melodicAmplitude(List<int> notes) {
    if (notes.isEmpty) return 128;
    return (notes.reduce((a, b) => a + b) / notes.length / 127 * 255).round();
  }
}
