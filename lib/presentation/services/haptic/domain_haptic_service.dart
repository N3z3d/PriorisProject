import 'haptic_strategy.dart';
import 'haptic_patterns.dart';

/// Service spécialisé pour les feedbacks haptiques métier (Prioris)
/// Sépare la logique métier de la logique technique (SRP, ISP)
class DomainHapticService {
  const DomainHapticService({
    required HapticStrategy strategy,
    required bool Function() isEnabled,
  })  : _strategy = strategy,
        _isEnabled = isEnabled;

  final HapticStrategy _strategy;
  final bool Function() _isEnabled;

  // ============ FEEDBACKS POUR TÂCHES ============

  /// Feedback pour l'ajout d'une tâche
  Future<void> taskAdded() async {
    if (!_isEnabled()) return;
    await _strategy.lightImpact();
  }

  /// Feedback pour la completion d'une tâche
  Future<void> taskCompleted() async {
    if (!_isEnabled()) return;
    await _strategy.vibrate(
      pattern: HapticPatterns.taskCompleted,
      amplitude: HapticPatterns.taskCompletedAmplitude,
    );
  }

  // ============ FEEDBACKS POUR HABITUDES ============

  /// Feedback pour l'accomplissement d'une habitude
  Future<void> habitCompleted() async {
    if (!_isEnabled()) return;
    await _strategy.vibrate(
      pattern: HapticPatterns.habitCompleted,
      amplitude: HapticPatterns.habitCompletedAmplitude,
    );
  }

  /// Feedback pour un streak d'habitude
  Future<void> streakMilestone(int streakCount) async {
    if (!_isEnabled()) return;

    final pattern = HapticPatterns.streakMilestone(streakCount);
    await _strategy.vibrate(
      pattern: pattern,
      amplitude: HapticPatterns.streakAmplitude,
    );
  }

  // ============ FEEDBACKS POUR PRIORITÉS ============

  /// Feedback pour le changement de priorité
  Future<void> priorityChanged(int oldPriority, int newPriority) async {
    if (!_isEnabled()) return;

    if (newPriority > oldPriority) {
      await _strategy.vibrate(
        pattern: HapticPatterns.priorityIncreased,
        amplitude: HapticPatterns.priorityIncreasedAmplitude,
      );
    } else {
      await _strategy.vibrate(
        pattern: HapticPatterns.priorityDecreased,
        amplitude: HapticPatterns.priorityDecreasedAmplitude,
      );
    }
  }

  // ============ FEEDBACKS POUR INTERACTIONS ============

  /// Feedback pour le drag start
  Future<void> dragStart() async {
    if (!_isEnabled()) return;
    await _strategy.lightImpact();
  }

  /// Feedback pour le drop réussi
  Future<void> dropSuccess() async {
    if (!_isEnabled()) return;
    await _strategy.mediumImpact();
  }

  /// Feedback pour la navigation
  Future<void> pageTransition() async {
    if (!_isEnabled()) return;
    await _strategy.lightImpact();
  }

  /// Feedback pour l'ouverture de modal
  Future<void> modalOpened() async {
    if (!_isEnabled()) return;
    await _strategy.lightImpact();
  }

  /// Feedback pour la fermeture de modal
  Future<void> modalClosed() async {
    if (!_isEnabled()) return;
    await _strategy.lightImpact();
  }

  // ============ FEEDBACKS AVANCÉS ============

  /// Feedback pour le timer/pomodoro tick
  Future<void> timerTick() async {
    if (!_isEnabled()) return;
    await _strategy.lightImpact();
  }

  /// Feedback pour la fin du timer
  Future<void> timerFinished() async {
    if (!_isEnabled()) return;
    await _strategy.vibrate(
      pattern: HapticPatterns.timerFinished,
      amplitude: HapticPatterns.timerFinishedAmplitude,
    );
  }

  /// Feedback pour l'atteinte d'un objectif
  Future<void> goalAchieved() async {
    if (!_isEnabled()) return;
    await _strategy.vibrate(
      pattern: HapticPatterns.goalAchieved,
      amplitude: HapticPatterns.goalAchievedAmplitude,
    );
  }

  /// Feedback de progression (loading, upload)
  Future<void> progress(double progress) async {
    if (!_isEnabled()) return;

    // Feedback seulement à certains seuils (25%, 50%, 75%, 100%)
    final threshold = (progress * 4).round() / 4;
    if (threshold == progress && threshold > 0) {
      if (threshold == 1.0) {
        await _strategy.vibrate(
          pattern: HapticPatterns.success,
          amplitude: HapticPatterns.successAmplitude,
        );
      } else {
        await _strategy.lightImpact();
      }
    }
  }
}
