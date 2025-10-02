import 'dart:io';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Interface pour les stratégies de feedback haptique
/// Applique le Dependency Inversion Principle (DIP)
abstract class HapticStrategy {
  Future<void> lightImpact();
  Future<void> mediumImpact();
  Future<void> heavyImpact();
  Future<void> vibrate({required List<int> pattern, int amplitude = 255});
}

/// Stratégie iOS utilisant HapticFeedback natif
class IOSHapticStrategy implements HapticStrategy {
  @override
  Future<void> lightImpact() async {
    HapticFeedback.lightImpact();
  }

  @override
  Future<void> mediumImpact() async {
    HapticFeedback.mediumImpact();
  }

  @override
  Future<void> heavyImpact() async {
    HapticFeedback.heavyImpact();
  }

  @override
  Future<void> vibrate({required List<int> pattern, int amplitude = 255}) async {
    // Simule le pattern avec des impacts variables
    for (int i = 1; i < pattern.length; i += 2) {
      final duration = pattern[i];
      if (duration > 50) {
        await heavyImpact();
      } else if (duration > 25) {
        await mediumImpact();
      } else {
        await lightImpact();
      }
      if (i + 1 < pattern.length) {
        await Future.delayed(Duration(milliseconds: pattern[i + 1]));
      }
    }
  }
}

/// Stratégie Android utilisant le plugin Vibration
class AndroidHapticStrategy implements HapticStrategy {
  const AndroidHapticStrategy({required this.hasVibrator});

  final bool hasVibrator;

  @override
  Future<void> lightImpact() async {
    if (!hasVibrator) return;
    await Vibration.vibrate(duration: 10);
  }

  @override
  Future<void> mediumImpact() async {
    if (!hasVibrator) return;
    await Vibration.vibrate(duration: 25);
  }

  @override
  Future<void> heavyImpact() async {
    if (!hasVibrator) return;
    await Vibration.vibrate(duration: 50);
  }

  @override
  Future<void> vibrate({required List<int> pattern, int amplitude = 255}) async {
    if (!hasVibrator) return;
    await Vibration.vibrate(pattern: pattern, amplitude: amplitude);
  }
}

/// Factory pour créer la stratégie appropriée selon la plateforme
/// Applique le Factory Pattern et Open/Closed Principle (OCP)
class HapticStrategyFactory {
  static Future<HapticStrategy> create() async {
    if (Platform.isIOS) {
      return IOSHapticStrategy();
    } else {
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      return AndroidHapticStrategy(hasVibrator: hasVibrator);
    }
  }
}
