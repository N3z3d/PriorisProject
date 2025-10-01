import 'dart:math';
import 'package:flutter/material.dart';

/// Modèle de particule (Single Responsibility Principle)
/// Représente une seule particule avec ses propriétés physiques
class Particle {
  Offset position;
  Offset velocity;
  double size;
  Color color;
  double opacity;
  double rotation;
  double rotationSpeed;
  double life;
  double maxLife;

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    this.opacity = 1.0,
    this.rotation = 0.0,
    this.rotationSpeed = 0.0,
    required this.life,
    required this.maxLife,
  });

  /// Met à jour l'état de la particule
  void update(double dt) {
    position += velocity * dt;
    rotation += rotationSpeed * dt;
    life -= dt;
    opacity = (life / maxLife).clamp(0.0, 1.0);
  }

  /// Vérifie si la particule est morte
  bool get isDead => life <= 0;

  /// Factory pour créer une particule avec des valeurs aléatoires
  factory Particle.random({
    required Offset center,
    required Color color,
    required double maxLife,
    double minSize = 2.0,
    double maxSize = 8.0,
    double minSpeed = 50.0,
    double maxSpeed = 150.0,
  }) {
    final random = Random();
    final angle = random.nextDouble() * 2 * pi;
    final speed = random.nextDouble() * (maxSpeed - minSpeed) + minSpeed;

    return Particle(
      position: center,
      velocity: Offset(cos(angle) * speed, sin(angle) * speed),
      size: random.nextDouble() * (maxSize - minSize) + minSize,
      color: color,
      rotationSpeed: (random.nextDouble() - 0.5) * 10,
      life: maxLife,
      maxLife: maxLife,
    );
  }
}

/// Configuration spécialisée pour les effets de confettis
class ConfettiConfig {
  final int particleCount;
  final Duration duration;
  final List<Color> colors;
  final double gravityStrength;
  final double friction;

  const ConfettiConfig({
    this.particleCount = 50,
    this.duration = const Duration(seconds: 3),
    this.colors = const [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
    ],
    this.gravityStrength = 200.0,
    this.friction = 0.98,
  });
}

/// Configuration spécialisée pour les effets d'étoiles scintillantes
class SparkleConfig {
  final int sparkleCount;
  final Duration duration;
  final double maxSize;
  final List<Color> colors;
  final double twinkleIntensity;

  const SparkleConfig({
    this.sparkleCount = 20,
    this.duration = const Duration(seconds: 2),
    this.maxSize = 8.0,
    this.colors = const [
      Colors.white,
      Colors.yellow,
      Colors.amber,
      Colors.lightBlue,
    ],
    this.twinkleIntensity = 10.0,
  });
}

/// Configuration spécialisée pour les feux d'artifice
class FireworksConfig {
  final int fireworkCount;
  final Duration duration;
  final List<Color> colors;
  final int particlesPerFirework;
  final double friction;

  const FireworksConfig({
    this.fireworkCount = 5,
    this.duration = const Duration(seconds: 4),
    this.colors = const [
      Colors.red,
      Colors.blue,
      Colors.white,
      Colors.yellow,
      Colors.purple,
    ],
    this.particlesPerFirework = 20,
    this.friction = 0.99,
  });
}

/// Configuration pour les effets de célébration (coeurs, ondulations, pluie)
class CelebrationConfig {
  final int itemCount;
  final Duration duration;
  final List<Color> colors;
  final double fallSpeed;
  final double maxRadius; // Pour les ripples

  const CelebrationConfig({
    this.itemCount = 15,
    this.duration = const Duration(seconds: 3),
    this.colors = const [
      Colors.pink,
      Colors.red,
      Colors.purple,
      Colors.pinkAccent,
    ],
    this.fallSpeed = 1.0,
    this.maxRadius = 100.0,
  });
}

/// Utilitaires pour les calculs physiques des particules
class ParticlePhysics {
  /// Applique la gravité à une particule
  static void applyGravity(Particle particle, double gravity, double dt) {
    particle.velocity = Offset(
      particle.velocity.dx,
      particle.velocity.dy + gravity * dt,
    );
  }

  /// Applique la friction à une particule
  static void applyFriction(Particle particle, double friction) {
    particle.velocity = particle.velocity * friction;
  }

  /// Applique un mouvement sinusoïdal horizontal
  static void applySinusoidalMovement(Particle particle, double intensity) {
    particle.velocity = Offset(
      sin(particle.life * 5) * intensity,
      particle.velocity.dy,
    );
  }

  /// Vérifie les limites de l'écran et supprime les particules hors limites
  static bool isOutOfBounds(Particle particle, Size screenSize) {
    return particle.position.dx < -50 ||
           particle.position.dx > screenSize.width + 50 ||
           particle.position.dy > screenSize.height + 50;
  }
}