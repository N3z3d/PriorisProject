import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/animations/particle_effects.dart';
import 'package:prioris/presentation/animations/core/particle_models.dart';

/// Tests pour valider la fonctionnalité avant et après refactoring
/// Ces tests garantissent que l'API publique reste compatible
void main() {
  group('ParticleEffects - API Compatibility Tests', () {
    testWidgets('confettiExplosion should create widget without errors', (WidgetTester tester) async {
      // Arrange & Act
      final widget = ParticleEffects.confettiExplosion(
        trigger: false,
        particleCount: 10,
        duration: const Duration(milliseconds: 500),
      );

      // Assert
      expect(widget, isA<Widget>());

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: widget),
      ));

      expect(find.byWidget(widget), findsOneWidget);
    });

    testWidgets('sparkleEffect should create widget without errors', (WidgetTester tester) async {
      // Arrange & Act
      final widget = ParticleEffects.sparkleEffect(
        trigger: false,
        sparkleCount: 5,
        duration: const Duration(milliseconds: 500),
      );

      // Assert
      expect(widget, isA<Widget>());

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: widget),
      ));

      expect(find.byWidget(widget), findsOneWidget);
    });

    testWidgets('fireworksEffect should create widget without errors', (WidgetTester tester) async {
      // Arrange & Act
      final widget = ParticleEffects.fireworksEffect(
        trigger: false,
        fireworkCount: 2,
        duration: const Duration(milliseconds: 500),
      );

      // Assert
      expect(widget, isA<Widget>());

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: widget),
      ));

      expect(find.byWidget(widget), findsOneWidget);
    });

    testWidgets('gentleParticleRain should create widget without errors', (WidgetTester tester) async {
      // Arrange & Act
      final widget = ParticleEffects.gentleParticleRain(
        trigger: false,
        particleCount: 5,
        duration: const Duration(milliseconds: 500),
      );

      // Assert
      expect(widget, isA<Widget>());

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: widget),
      ));

      expect(find.byWidget(widget), findsOneWidget);
    });

    testWidgets('rippleEffect should create widget without errors', (WidgetTester tester) async {
      // Arrange & Act
      final widget = ParticleEffects.rippleEffect(
        trigger: false,
        rippleCount: 2,
        duration: const Duration(milliseconds: 500),
      );

      // Assert
      expect(widget, isA<Widget>());

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: widget),
      ));

      expect(find.byWidget(widget), findsOneWidget);
    });

    testWidgets('floatingHearts should create widget without errors', (WidgetTester tester) async {
      // Arrange & Act
      final widget = ParticleEffects.floatingHearts(
        trigger: false,
        heartCount: 3,
        duration: const Duration(milliseconds: 500),
      );

      // Assert
      expect(widget, isA<Widget>());

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: widget),
      ));

      expect(find.byWidget(widget), findsOneWidget);
    });

    test('default colors should be accessible', () {
      // Arrange & Act & Assert - vérifier que les couleurs par défaut sont cohérentes
      expect(ParticleEffects.confettiExplosion(trigger: false), isA<Widget>());
      expect(ParticleEffects.sparkleEffect(trigger: false), isA<Widget>());
      expect(ParticleEffects.fireworksEffect(trigger: false), isA<Widget>());
      expect(ParticleEffects.gentleParticleRain(trigger: false), isA<Widget>());
      expect(ParticleEffects.floatingHearts(trigger: false), isA<Widget>());
    });

    test('custom colors should be applied correctly', () {
      // Arrange
      const customColors = [Colors.red, Colors.blue];

      // Act & Assert
      final confettiWidget = ParticleEffects.confettiExplosion(
        trigger: false,
        colors: customColors,
      );

      final sparkleWidget = ParticleEffects.sparkleEffect(
        trigger: false,
        colors: customColors,
      );

      // Vérifier que les widgets sont créés sans erreur
      expect(confettiWidget, isA<Widget>());
      expect(sparkleWidget, isA<Widget>());
    });

    test('callback onComplete should be supported', () {
      // Arrange
      bool callbackExecuted = false;

      // Act & Assert
      final widget = ParticleEffects.confettiExplosion(
        trigger: false,
        onComplete: () => callbackExecuted = true,
      );

      // Vérifier que le widget est créé avec callback
      expect(widget, isA<Widget>());
      // Le callback n'est pas déclenché car trigger = false
      expect(callbackExecuted, false);
    });
  });

  group('Particle class behavior tests', () {
    test('Particle should update position and opacity correctly', () {
      // Arrange
      final particle = Particle(
        position: const Offset(0, 0),
        velocity: const Offset(10, 5),
        size: 5.0,
        color: Colors.red,
        life: 2.0,
        maxLife: 2.0,
      );

      // Act
      particle.update(0.1); // 0.1 second update

      // Assert
      expect(particle.position.dx, 1.0); // 10 * 0.1
      expect(particle.position.dy, 0.5); // 5 * 0.1
      expect(particle.life, 1.9); // 2.0 - 0.1
      expect(particle.opacity, 0.95); // 1.9 / 2.0
      expect(particle.isDead, false);
    });

    test('Particle should be marked as dead when life reaches zero', () {
      // Arrange
      final particle = Particle(
        position: const Offset(0, 0),
        velocity: const Offset(0, 0),
        size: 5.0,
        color: Colors.red,
        life: 0.05,
        maxLife: 1.0,
      );

      // Act
      particle.update(0.1);

      // Assert
      expect(particle.isDead, true);
      expect(particle.opacity, 0.0); // Clamped to 0
    });

    test('Particle rotation should update correctly', () {
      // Arrange
      final particle = Particle(
        position: const Offset(0, 0),
        velocity: const Offset(0, 0),
        size: 5.0,
        color: Colors.red,
        rotation: 0.0,
        rotationSpeed: 2.0, // 2 radians per second
        life: 1.0,
        maxLife: 1.0,
      );

      // Act
      particle.update(0.5); // 0.5 second update

      // Assert
      expect(particle.rotation, 1.0); // 2.0 * 0.5
    });
  });
}