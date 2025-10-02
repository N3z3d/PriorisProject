import 'haptic/haptic_strategy.dart';
import 'haptic/haptic_patterns.dart';
import 'haptic/domain_haptic_service.dart';
import 'haptic/haptic_types.dart';

// Export public types
export 'haptic/haptic_types.dart';
export 'haptic/haptic_wrapper_widget.dart';

/// Service de haptic feedback premium avec vibrations contextuelles avancées
/// Refactorisé pour respecter SOLID:
/// - SRP: Délègue les responsabilités à des services spécialisés
/// - OCP: Extensible via stratégies et patterns
/// - DIP: Dépend d'abstractions (HapticStrategy)
class PremiumHapticService {
  PremiumHapticService._();

  static PremiumHapticService? _instance;
  static PremiumHapticService get instance => _instance ??= PremiumHapticService._();

  bool _isEnabled = true;
  HapticStrategy? _strategy;
  DomainHapticService? _domainService;

  /// Initialise le service et configure la stratégie appropriée
  Future<void> initialize() async {
    _strategy = await HapticStrategyFactory.create();
    _domainService = DomainHapticService(
      strategy: _strategy!,
      isEnabled: () => _isEnabled,
    );
  }

  /// Active ou désactive les retours haptiques
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Vérifie si les haptics sont activés
  bool get isEnabled => _isEnabled;

  /// Vérifie si l'appareil a un vibreur (Android only)
  bool get hasVibrator => _strategy is AndroidHapticStrategy
      ? (_strategy as AndroidHapticStrategy).hasVibrator
      : true;

  // ============ INTERACTIONS DE BASE ============

  /// Feedback léger pour les interactions subtiles (hover, focus)
  Future<void> lightImpact() async {
    if (!_isEnabled || _strategy == null) return;
    await _strategy!.lightImpact();
  }

  /// Feedback moyen pour les interactions standards (tap, select)
  Future<void> mediumImpact() async {
    if (!_isEnabled || _strategy == null) return;
    await _strategy!.mediumImpact();
  }

  /// Feedback fort pour les interactions importantes (confirmation, success)
  Future<void> heavyImpact() async {
    if (!_isEnabled || _strategy == null) return;
    await _strategy!.heavyImpact();
  }

  // ============ FEEDBACKS CONTEXTUELS ============

  /// Feedback de succès (tâche complétée, objectif atteint)
  Future<void> success() async {
    if (!_isEnabled || _strategy == null) return;
    await _strategy!.vibrate(
      pattern: HapticPatterns.success,
      amplitude: HapticPatterns.successAmplitude,
    );
  }

  /// Feedback d'erreur (validation échouée, action impossible)
  Future<void> error() async {
    if (!_isEnabled || _strategy == null) return;
    await _strategy!.vibrate(
      pattern: HapticPatterns.error,
      amplitude: HapticPatterns.errorAmplitude,
    );
  }

  /// Feedback d'avertissement (attention requise)
  Future<void> warning() async {
    if (!_isEnabled || _strategy == null) return;
    await _strategy!.vibrate(
      pattern: HapticPatterns.warning,
      amplitude: HapticPatterns.warningAmplitude,
    );
  }

  /// Feedback de notification (message reçu, rappel)
  Future<void> notification() async {
    if (!_isEnabled || _strategy == null) return;
    await _strategy!.vibrate(
      pattern: HapticPatterns.notification,
      amplitude: HapticPatterns.notificationAmplitude,
    );
  }

  // ============ FEEDBACKS SPÉCIALISÉS POUR PRIORIS ============
  // Délégation au service métier

  /// Feedback pour l'ajout d'une tâche
  Future<void> taskAdded() async {
    if (_domainService == null) return;
    await _domainService!.taskAdded();
  }

  /// Feedback pour la completion d'une tâche
  Future<void> taskCompleted() async {
    if (_domainService == null) return;
    await _domainService!.taskCompleted();
  }

  /// Feedback pour l'accomplissement d'une habitude
  Future<void> habitCompleted() async {
    if (_domainService == null) return;
    await _domainService!.habitCompleted();
  }

  /// Feedback pour un streak d'habitude
  Future<void> streakMilestone(int streakCount) async {
    if (_domainService == null) return;
    await _domainService!.streakMilestone(streakCount);
  }

  /// Feedback pour le changement de priorité
  Future<void> priorityChanged(int oldPriority, int newPriority) async {
    if (_domainService == null) return;
    await _domainService!.priorityChanged(oldPriority, newPriority);
  }

  /// Feedback pour le drag start
  Future<void> dragStart() async {
    if (_domainService == null) return;
    await _domainService!.dragStart();
  }

  /// Feedback pour le drop réussi
  Future<void> dropSuccess() async {
    if (_domainService == null) return;
    await _domainService!.dropSuccess();
  }

  /// Feedback pour le swipe action
  Future<void> swipeAction(SwipeActionType actionType) async {
    switch (actionType) {
      case SwipeActionType.delete:
        await error();
        break;
      case SwipeActionType.complete:
        await success();
        break;
      case SwipeActionType.edit:
        await mediumImpact();
        break;
      case SwipeActionType.archive:
        await lightImpact();
        break;
    }
  }

  /// Feedback pour la navigation entre pages
  Future<void> pageTransition() async {
    if (_domainService == null) return;
    await _domainService!.pageTransition();
  }

  /// Feedback pour l'ouverture de modal/dialog
  Future<void> modalOpened() async {
    if (_domainService == null) return;
    await _domainService!.modalOpened();
  }

  /// Feedback pour la fermeture de modal/dialog
  Future<void> modalClosed() async {
    if (_domainService == null) return;
    await _domainService!.modalClosed();
  }

  // ============ FEEDBACKS AVANCÉS ============

  /// Feedback de progression (loading, upload)
  Future<void> progress(double progress) async {
    if (_domainService == null) return;
    await _domainService!.progress(progress);
  }

  /// Feedback pour le timer/pomodoro
  Future<void> timerTick() async {
    if (_domainService == null) return;
    await _domainService!.timerTick();
  }

  /// Feedback pour la fin du timer
  Future<void> timerFinished() async {
    if (_domainService == null) return;
    await _domainService!.timerFinished();
  }

  /// Feedback pour l'atteinte d'un objectif
  Future<void> goalAchieved() async {
    if (_domainService == null) return;
    await _domainService!.goalAchieved();
  }

  // ============ FEEDBACKS ADAPTATIFS ============

  /// Feedback adaptatif basé sur le contexte
  Future<void> contextualFeedback({
    required HapticContext context,
    HapticIntensity intensity = HapticIntensity.medium,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isEnabled) return;

    switch (context) {
      case HapticContext.buttonPress:
        await _handleButtonPress(intensity);
        break;
      case HapticContext.listScroll:
        await _handleListScroll(parameters);
        break;
      case HapticContext.tabSwitch:
        await pageTransition();
        break;
      case HapticContext.formValidation:
        await _handleFormValidation(parameters);
        break;
      case HapticContext.gameAction:
        await _handleGameAction(parameters);
        break;
    }
  }

  Future<void> _handleButtonPress(HapticIntensity intensity) async {
    switch (intensity) {
      case HapticIntensity.light:
        await lightImpact();
        break;
      case HapticIntensity.medium:
        await mediumImpact();
        break;
      case HapticIntensity.heavy:
        await heavyImpact();
        break;
    }
  }

  Future<void> _handleListScroll(Map<String, dynamic>? parameters) async {
    if (parameters?['scrollEnd'] == true) {
      await lightImpact();
    }
  }

  Future<void> _handleFormValidation(Map<String, dynamic>? parameters) async {
    if (parameters?['isValid'] == true) {
      await success();
    } else {
      await error();
    }
  }

  Future<void> _handleGameAction(Map<String, dynamic>? parameters) async {
    final score = parameters?['score'] as int? ?? 0;
    if (score > 100) {
      await goalAchieved();
    } else {
      await taskCompleted();
    }
  }

  // ============ PATTERNS PERSONNALISÉS ============

  /// Crée un pattern de vibration personnalisé
  Future<void> customPattern({
    required List<int> pattern,
    int amplitude = 255,
  }) async {
    if (!_isEnabled || _strategy == null) return;
    await _strategy!.vibrate(pattern: pattern, amplitude: amplitude);
  }

  /// Génère un pattern basé sur une mélodie
  Future<void> melodicPattern(List<int> notes) async {
    if (!_isEnabled || _strategy == null) return;

    final pattern = HapticPatterns.melodic(notes);
    final amplitude = HapticPatterns.melodicAmplitude(notes);

    await _strategy!.vibrate(pattern: pattern, amplitude: amplitude);
  }
}
