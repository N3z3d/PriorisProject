import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Service de haptic feedback premium avec vibrations contextuelles avancées
class PremiumHapticService {
  static PremiumHapticService? _instance;
  static PremiumHapticService get instance => _instance ??= PremiumHapticService._();
  
  PremiumHapticService._();

  bool _isEnabled = true;
  bool _hasVibrator = false;

  /// Initialise le service et vérifie les capacités de l'appareil
  Future<void> initialize() async {
    try {
      _hasVibrator = await Vibration.hasVibrator() ?? false;
    } catch (e) {
      _hasVibrator = false;
    }
  }

  /// Active ou désactive les retours haptiques
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Vérifie si les haptics sont activés
  bool get isEnabled => _isEnabled;

  /// Vérifie si l'appareil a un vibreur
  bool get hasVibrator => _hasVibrator;

  // ============ INTERACTIONS DE BASE ============

  /// Feedback léger pour les interactions subtiles (hover, focus)
  Future<void> lightImpact() async {
    if (!_isEnabled) return;
    
    if (Platform.isIOS) {
      HapticFeedback.lightImpact();
    } else if (_hasVibrator) {
      await Vibration.vibrate(duration: 10);
    }
  }

  /// Feedback moyen pour les interactions standards (tap, select)
  Future<void> mediumImpact() async {
    if (!_isEnabled) return;
    
    if (Platform.isIOS) {
      HapticFeedback.mediumImpact();
    } else if (_hasVibrator) {
      await Vibration.vibrate(duration: 25);
    }
  }

  /// Feedback fort pour les interactions importantes (confirmation, success)
  Future<void> heavyImpact() async {
    if (!_isEnabled) return;
    
    if (Platform.isIOS) {
      HapticFeedback.heavyImpact();
    } else if (_hasVibrator) {
      await Vibration.vibrate(duration: 50);
    }
  }

  // ============ FEEDBACKS CONTEXTUELS ============

  /// Feedback de succès (tâche complétée, objectif atteint)
  Future<void> success() async {
    if (!_isEnabled) return;
    
    if (Platform.isIOS) {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      HapticFeedback.lightImpact();
    } else if (_hasVibrator) {
      await Vibration.vibrate(
        pattern: [0, 50, 50, 30],
        amplitude: 255,
      );
    }
  }

  /// Feedback d'erreur (validation échouée, action impossible)
  Future<void> error() async {
    if (!_isEnabled) return;
    
    if (Platform.isIOS) {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      HapticFeedback.heavyImpact();
    } else if (_hasVibrator) {
      await Vibration.vibrate(
        pattern: [0, 100, 100, 100],
        amplitude: 255,
      );
    }
  }

  /// Feedback d'avertissement (attention requise)
  Future<void> warning() async {
    if (!_isEnabled) return;
    
    if (Platform.isIOS) {
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      HapticFeedback.lightImpact();
    } else if (_hasVibrator) {
      await Vibration.vibrate(
        pattern: [0, 75, 75, 25],
        amplitude: 200,
      );
    }
  }

  /// Feedback de notification (message reçu, rappel)
  Future<void> notification() async {
    if (!_isEnabled) return;
    
    if (Platform.isIOS) {
      HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 50));
      HapticFeedback.lightImpact();
    } else if (_hasVibrator) {
      await Vibration.vibrate(
        pattern: [0, 20, 50, 20],
        amplitude: 150,
      );
    }
  }

  // ============ FEEDBACKS SPÉCIALISÉS POUR PRIORIS ============

  /// Feedback pour l'ajout d'une tâche
  Future<void> taskAdded() async {
    if (!_isEnabled) return;
    
    if (Platform.isIOS) {
      HapticFeedback.lightImpact();
    } else if (_hasVibrator) {
      await Vibration.vibrate(duration: 15);
    }
  }

  /// Feedback pour la completion d'une tâche
  Future<void> taskCompleted() async {
    if (!_isEnabled) return;
    
    if (Platform.isIOS) {
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      HapticFeedback.lightImpact();
    } else if (_hasVibrator) {
      await Vibration.vibrate(
        pattern: [0, 30, 50, 20, 50, 15],
        amplitude: 200,
      );
    }
  }

  /// Feedback pour l'accomplissement d'une habitude
  Future<void> habitCompleted() async {
    if (!_isEnabled) return;
    
    if (Platform.isIOS) {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      HapticFeedback.mediumImpact();
    } else if (_hasVibrator) {
      await Vibration.vibrate(
        pattern: [0, 60, 100, 40],
        amplitude: 255,
      );
    }
  }

  /// Feedback pour un streak d'habitude (multiple de 7, 30, etc.)
  Future<void> streakMilestone(int streakCount) async {
    if (!_isEnabled) return;
    
    // Plus le streak est important, plus le feedback est prononcé
    final intensity = (streakCount / 7).clamp(1, 5).round();
    
    if (Platform.isIOS) {
      for (int i = 0; i < intensity; i++) {
        HapticFeedback.heavyImpact();
        if (i < intensity - 1) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
    } else if (_hasVibrator) {
      final pattern = <int>[0];
      
      for (int i = 0; i < intensity; i++) {
        pattern.addAll([80, 80]);
      }
      
      await Vibration.vibrate(pattern: pattern, amplitude: 255);
    }
  }

  /// Feedback pour le changement de priorité d'une tâche
  Future<void> priorityChanged(int oldPriority, int newPriority) async {
    if (!_isEnabled) return;
    
    if (newPriority > oldPriority) {
      // Priorité augmentée - feedback ascendant
      if (Platform.isIOS) {
        HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 50));
        HapticFeedback.mediumImpact();
      } else if (_hasVibrator) {
        await Vibration.vibrate(
          pattern: [0, 20, 30, 40],
          amplitude: 150,
        );
      }
    } else {
      // Priorité diminuée - feedback descendant
      if (Platform.isIOS) {
        HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 50));
        HapticFeedback.lightImpact();
      } else if (_hasVibrator) {
        await Vibration.vibrate(
          pattern: [0, 40, 30, 20],
          amplitude: 200,
        );
      }
    }
  }

  /// Feedback pour le drag & drop
  Future<void> dragStart() async {
    if (!_isEnabled) return;
    
    if (Platform.isIOS) {
      HapticFeedback.lightImpact();
    } else if (_hasVibrator) {
      await Vibration.vibrate(duration: 10);
    }
  }

  /// Feedback pour le drop réussi
  Future<void> dropSuccess() async {
    if (!_isEnabled) return;
    
    if (Platform.isIOS) {
      HapticFeedback.mediumImpact();
    } else if (_hasVibrator) {
      await Vibration.vibrate(duration: 30);
    }
  }

  /// Feedback pour le swipe action
  Future<void> swipeAction(SwipeActionType actionType) async {
    if (!_isEnabled) return;
    
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
    if (!_isEnabled) return;
    
    if (Platform.isIOS) {
      HapticFeedback.lightImpact();
    } else if (_hasVibrator) {
      await Vibration.vibrate(duration: 8);
    }
  }

  /// Feedback pour l'ouverture de modal/dialog
  Future<void> modalOpened() async {
    if (!_isEnabled) return;
    
    if (Platform.isIOS) {
      HapticFeedback.lightImpact();
    } else if (_hasVibrator) {
      await Vibration.vibrate(duration: 15);
    }
  }

  /// Feedback pour la fermeture de modal/dialog
  Future<void> modalClosed() async {
    if (!_isEnabled) return;
    
    if (Platform.isIOS) {
      HapticFeedback.lightImpact();
    } else if (_hasVibrator) {
      await Vibration.vibrate(duration: 10);
    }
  }

  // ============ FEEDBACKS AVANCÉS ============

  /// Feedback de progression (loading, upload)
  Future<void> progress(double progress) async {
    if (!_isEnabled) return;
    
    // Feedback seulement à certains seuils (25%, 50%, 75%, 100%)
    final threshold = (progress * 4).round() / 4;
    if (threshold == progress && threshold > 0) {
      final intensity = (threshold * 50).round();
      
      if (Platform.isIOS) {
        if (threshold == 1.0) {
          await success();
        } else {
          HapticFeedback.lightImpact();
        }
      } else if (_hasVibrator) {
        await Vibration.vibrate(duration: intensity);
      }
    }
  }

  /// Feedback pour le timer/pomodoro
  Future<void> timerTick() async {
    if (!_isEnabled) return;
    
    if (Platform.isIOS) {
      HapticFeedback.lightImpact();
    } else if (_hasVibrator) {
      await Vibration.vibrate(duration: 5);
    }
  }

  /// Feedback pour la fin du timer
  Future<void> timerFinished() async {
    if (!_isEnabled) return;
    
    if (Platform.isIOS) {
      for (int i = 0; i < 3; i++) {
        HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 200));
      }
    } else if (_hasVibrator) {
      await Vibration.vibrate(
        pattern: [0, 100, 200, 100, 200, 100],
        amplitude: 255,
      );
    }
  }

  /// Feedback pour l'atteinte d'un objectif
  Future<void> goalAchieved() async {
    if (!_isEnabled) return;
    
    if (Platform.isIOS) {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      HapticFeedback.lightImpact();
    } else if (_hasVibrator) {
      await Vibration.vibrate(
        pattern: [0, 80, 100, 60, 100, 40, 100, 20],
        amplitude: 255,
      );
    }
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
        break;
        
      case HapticContext.listScroll:
        if (parameters?['scrollEnd'] == true) {
          await lightImpact();
        }
        break;
        
      case HapticContext.tabSwitch:
        await pageTransition();
        break;
        
      case HapticContext.formValidation:
        if (parameters?['isValid'] == true) {
          await success();
        } else {
          await error();
        }
        break;
        
      case HapticContext.gameAction:
        final score = parameters?['score'] as int? ?? 0;
        if (score > 100) {
          await goalAchieved();
        } else {
          await taskCompleted();
        }
        break;
    }
  }

  // ============ PATTERNS PERSONNALISÉS ============

  /// Crée un pattern de vibration personnalisé
  Future<void> customPattern({
    required List<int> pattern,
    int amplitude = 255,
  }) async {
    if (!_isEnabled || !_hasVibrator) return;
    
    await Vibration.vibrate(
      pattern: pattern,
      amplitude: amplitude,
    );
  }

  /// Génère un pattern basé sur une mélodie
  Future<void> melodicPattern(List<int> notes) async {
    if (!_isEnabled) return;
    
    final pattern = <int>[0];
    
    for (final note in notes) {
      final duration = (note / 127 * 100).round(); // 0-127 -> 0-100ms
      pattern.addAll([duration, 50]); // vibration + pause
    }
    
    if (Platform.isAndroid && _hasVibrator) {
      // Use average amplitude based on notes
      final avgAmplitude = notes.isNotEmpty 
          ? (notes.reduce((a, b) => a + b) / notes.length / 127 * 255).round()
          : 128;
      await Vibration.vibrate(pattern: pattern, amplitude: avgAmplitude);
    } else if (Platform.isIOS) {
      // Simulation pour iOS avec des impacts variables
      for (final note in notes) {
        if (note < 50) {
          HapticFeedback.lightImpact();
        } else if (note < 100) {
          HapticFeedback.mediumImpact();
        } else {
          HapticFeedback.heavyImpact();
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }
}

/// Types d'actions de swipe
enum SwipeActionType {
  delete,
  complete,
  edit,
  archive,
}

/// Contextes haptiques
enum HapticContext {
  buttonPress,
  listScroll,
  tabSwitch,
  formValidation,
  gameAction,
}

/// Intensité du feedback haptique
enum HapticIntensity {
  light,
  medium,
  heavy,
}

/// Widget wrapper qui ajoute automatiquement des feedbacks haptiques
class HapticWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final HapticIntensity tapIntensity;
  final HapticIntensity longPressIntensity;
  final bool enableHaptics;

  const HapticWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.tapIntensity = HapticIntensity.medium,
    this.longPressIntensity = HapticIntensity.heavy,
    this.enableHaptics = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap != null ? () async {
        if (enableHaptics) {
          switch (tapIntensity) {
            case HapticIntensity.light:
              await PremiumHapticService.instance.lightImpact();
              break;
            case HapticIntensity.medium:
              await PremiumHapticService.instance.mediumImpact();
              break;
            case HapticIntensity.heavy:
              await PremiumHapticService.instance.heavyImpact();
              break;
          }
        }
        onTap!();
      } : null,
      onLongPress: onLongPress != null ? () async {
        if (enableHaptics) {
          switch (longPressIntensity) {
            case HapticIntensity.light:
              await PremiumHapticService.instance.lightImpact();
              break;
            case HapticIntensity.medium:
              await PremiumHapticService.instance.mediumImpact();
              break;
            case HapticIntensity.heavy:
              await PremiumHapticService.instance.heavyImpact();
              break;
          }
        }
        onLongPress!();
      } : null,
      child: child,
    );
  }
}