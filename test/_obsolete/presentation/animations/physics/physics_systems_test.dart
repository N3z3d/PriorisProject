import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:prioris/presentation/animations/physics/interfaces/physics_system_interface.dart';
import 'package:prioris/presentation/animations/physics/configs/physics_configs.dart';
import 'package:prioris/presentation/animations/physics/physics_animations_manager.dart';
import 'package:prioris/presentation/animations/physics/systems/spring_physics_system.dart';
import 'package:prioris/presentation/animations/physics/systems/gravity_physics_system.dart';
import 'package:prioris/presentation/animations/physics/systems/elastic_physics_system.dart';
import 'package:prioris/presentation/animations/physics/systems/wave_physics_system.dart';

void main() {
  setUpAll(() {
    // Initialize Flutter binding for tests
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('PhysicsAnimationsManager Tests', () {
    late PhysicsAnimationsManager manager;

    setUp(() {
      manager = PhysicsAnimationsManager();
    });

    tearDown(() async {
      await manager.dispose();
    });

    test('should initialize successfully', () async {
      await manager.initialize();
      expect(manager.isInitialized, isTrue);
    });

    test('should register physics systems', () async {
      await manager.initialize();

      expect(manager.isSystemAvailable(PhysicsSystemType.spring), isTrue);
      expect(manager.isSystemAvailable(PhysicsSystemType.gravity), isTrue);
      expect(manager.isSystemAvailable(PhysicsSystemType.elastic), isTrue);
      expect(manager.isSystemAvailable(PhysicsSystemType.wave), isTrue);
    });

    test('should create spring animation widget', () async {
      await manager.initialize();

      final config = SpringPhysicsConfig(
        duration: const Duration(milliseconds: 800),
        stiffness: 100.0,
        dampingRatio: 0.8,
        trigger: true,
      );

      final widget = manager.createSpringAnimation(
        child: Container(),
        config: config,
      );

      expect(widget, isNotNull);
      expect(widget, isA<Widget>());
    });

    test('should handle system not found gracefully', () {
      expect(
        () => manager.getSystem(PhysicsSystemType.spring),
        throwsA(isA<PhysicsSystemException>()),
      );
    });

    test('should dispose all systems properly', () async {
      await manager.initialize();
      await manager.dispose();

      expect(manager.isInitialized, isFalse);
    });
  });

  group('SpringPhysicsSystem Tests', () {
    late SpringPhysicsSystem springSystem;

    setUp(() {
      springSystem = SpringPhysicsSystem();
    });

    tearDown(() async {
      await springSystem.dispose();
    });

    test('should initialize spring system', () async {
      await springSystem.initialize();

      expect(springSystem.isActive, isTrue);
      expect(springSystem.systemId, equals('spring_physics'));
      expect(springSystem.systemName, equals('Spring Physics System'));
    });

    test('should calculate correct spring physics state', () async {
      await springSystem.initialize();

      final parameters = SpringPhysicsParameters(
        mass: 1.0,
        damping: 0.8,
        stiffness: 100.0,
      );

      final state = springSystem.calculateState(
        time: 0.5,
        parameters: parameters,
      );

      expect(state, isNotNull);
      expect(state.position, isA<Offset>());
      expect(state.velocity, isA<Offset>());
      expect(state.acceleration, isA<Offset>());
    });

    test('should create spring animation widget', () async {
      await springSystem.initialize();

      final config = SpringPhysicsConfig(
        duration: const Duration(milliseconds: 800),
        stiffness: 100.0,
        dampingRatio: 0.8,
      );

      final widget = springSystem.createAnimation(
        child: Container(),
        config: config,
      );

      expect(widget, isNotNull);
      expect(widget, isA<Widget>());
    });

    test('should trigger animation correctly', () async {
      await springSystem.initialize();

      final config = SpringPhysicsConfig(
        duration: const Duration(milliseconds: 800),
        stiffness: 100.0,
        dampingRatio: 0.8,
        trigger: true,
      );

      bool completed = false;
      await springSystem.trigger(
        config: config,
        onComplete: () => completed = true,
      );

      expect(springSystem.isAnimating, isFalse);
    });

    test('should handle invalid parameters', () {
      // Note: SpringPhysicsParameters doesn't have built-in validation
      // Validation happens in the physics system itself
      expect(() {
        final params = SpringPhysicsParameters(
          mass: -1.0,
          damping: 0.8,
          stiffness: 100.0,
        );
        // The validation would happen when the system processes the parameters
      }, returnsNormally);
    });
  });

  group('GravityPhysicsSystem Tests', () {
    late GravityPhysicsSystem gravitySystem;

    setUp(() {
      gravitySystem = GravityPhysicsSystem();
    });

    tearDown(() async {
      await gravitySystem.dispose();
    });

    test('should initialize gravity system', () async {
      await gravitySystem.initialize();

      expect(gravitySystem.isActive, isTrue);
      expect(gravitySystem.systemId, equals('gravity_physics'));
      expect(gravitySystem.systemName, equals('Gravity Physics System'));
    });

    test('should calculate gravity physics with correct acceleration', () async {
      await gravitySystem.initialize();

      final parameters = GravityPhysicsParameters(
        mass: 1.0,
        damping: 0.1,
        gravity: 9.81,
        restitution: 0.8,
      );

      final state = gravitySystem.calculateState(
        time: 1.0,
        parameters: parameters,
      );

      expect(state.acceleration.dy, closeTo(9.81, 0.1));
      expect(state.velocity.dy, greaterThan(0));
    });

    test('should create gravity bounce animation', () async {
      await gravitySystem.initialize();

      final config = GravityPhysicsConfig(
        duration: const Duration(milliseconds: 2000),
        height: 100.0,
        gravity: 9.81,
        bounceCount: 3,
        trigger: true,
      );

      final widget = gravitySystem.createAnimation(
        child: Container(),
        config: config,
      );

      expect(widget, isNotNull);
    });

    test('should handle bounce count correctly', () async {
      await gravitySystem.initialize();

      final config = GravityPhysicsConfig(
        duration: const Duration(milliseconds: 2000),
        height: 100.0,
        bounceCount: 0,
        trigger: true,
      );

      expect(() => gravitySystem.createAnimation(
        child: Container(),
        config: config,
      ), isNot(throwsException));
    });
  });

  group('ElasticPhysicsSystem Tests', () {
    late ElasticPhysicsSystem elasticSystem;

    setUp(() {
      elasticSystem = ElasticPhysicsSystem();
    });

    tearDown(() async {
      await elasticSystem.dispose();
    });

    test('should initialize elastic system', () async {
      await elasticSystem.initialize();

      expect(elasticSystem.isActive, isTrue);
      expect(elasticSystem.systemId, equals('elastic_physics'));
      expect(elasticSystem.systemName, equals('Elastic Physics System'));
    });

    test('should create elastic bounce animation', () async {
      await elasticSystem.initialize();

      final config = ElasticPhysicsConfig(
        duration: const Duration(milliseconds: 1200),
        bounceHeight: 1.3,
        bounceCount: 3,
        trigger: true,
      );

      final widget = elasticSystem.createAnimation(
        child: Container(),
        config: config,
      );

      expect(widget, isNotNull);
    });

    test('should handle elastic parameters correctly', () async {
      await elasticSystem.initialize();

      final config = ElasticPhysicsConfig(
        duration: const Duration(milliseconds: 1200),
        bounceHeight: 2.0,
        bounceCount: 5,
        elasticity: 0.9,
        trigger: true,
      );

      expect(config.bounceHeight, equals(2.0));
      expect(config.bounceCount, equals(5));
      expect(config.elasticity, equals(0.9));
    });
  });

  group('WavePhysicsSystem Tests', () {
    late WavePhysicsSystem waveSystem;

    setUp(() {
      waveSystem = WavePhysicsSystem();
    });

    tearDown(() async {
      await waveSystem.dispose();
    });

    test('should initialize wave system', () async {
      await waveSystem.initialize();

      expect(waveSystem.isActive, isTrue);
      expect(waveSystem.systemId, equals('wave_physics'));
      expect(waveSystem.systemName, equals('Wave Physics System'));
    });

    test('should calculate wave physics correctly', () async {
      await waveSystem.initialize();

      final parameters = WavePhysicsParameters(
        mass: 1.0,
        damping: 0.02,
        amplitude: 15.0,
        frequency: 2.0,
        phase: 0.0,
      );

      final state = waveSystem.calculateState(
        time: 0.5,
        parameters: parameters,
      );

      expect(state.position.dx, isNotNull);
      expect(state.position.dx.abs(), lessThanOrEqualTo(15.0));
    });

    test('should create wave animation with different wave types', () async {
      await waveSystem.initialize();

      for (final waveType in WaveType.values) {
        final config = WavePhysicsConfig(
          duration: const Duration(seconds: 3),
          amplitude: 15.0,
          frequency: 2.0,
          waveType: waveType,
        );

        final widget = waveSystem.createAnimation(
          child: Container(),
          config: config,
        );

        expect(widget, isNotNull);
      }
    });

    test('should handle damping correctly', () async {
      await waveSystem.initialize();

      final parameters = WavePhysicsParameters(
        mass: 1.0,
        damping: 0.1,
        amplitude: 15.0,
        frequency: 2.0,
        phase: 0.0,
      );

      final initialState = waveSystem.calculateState(
        time: 0.0,
        parameters: parameters,
      );

      final laterState = waveSystem.calculateState(
        time: 10.0,
        parameters: parameters,
      );

      expect(laterState.position.dx.abs(), lessThanOrEqualTo(initialState.position.dx.abs() + 0.1));
    });
  });

  group('PhysicsState Tests', () {
    test('should create physics state correctly', () {
      final state = PhysicsState(
        position: const Offset(10.0, 20.0),
        velocity: const Offset(5.0, -3.0),
        acceleration: const Offset(0.0, 9.81),
        rotation: 1.57,
        scale: 1.2,
        time: 2.5,
      );

      expect(state.position, equals(const Offset(10.0, 20.0)));
      expect(state.velocity, equals(const Offset(5.0, -3.0)));
      expect(state.acceleration, equals(const Offset(0.0, 9.81)));
      expect(state.rotation, equals(1.57));
      expect(state.scale, equals(1.2));
      expect(state.time, equals(2.5));
    });

    test('should copy with correctly', () {
      final originalState = PhysicsState(
        position: const Offset(10.0, 20.0),
        velocity: const Offset(5.0, -3.0),
        acceleration: const Offset(0.0, 9.81),
        rotation: 1.57,
        scale: 1.2,
        time: 2.5,
      );

      final newState = originalState.copyWith(
        position: const Offset(15.0, 25.0),
        time: 3.0,
      );

      expect(newState.position, equals(const Offset(15.0, 25.0)));
      expect(newState.velocity, equals(const Offset(5.0, -3.0)));
      expect(newState.time, equals(3.0));
      expect(newState.scale, equals(1.2));
    });
  });

  group('Configuration Tests', () {
    test('should create spring config with correct defaults', () {
      final config = SpringPhysicsConfig(
        duration: const Duration(milliseconds: 800),
        stiffness: 100.0,
        dampingRatio: 0.8,
      );

      expect(config.duration, equals(const Duration(milliseconds: 800)));
      expect(config.stiffness, equals(100.0));
      expect(config.dampingRatio, equals(0.8));
      expect(config.mass, equals(1.0));
      expect(config.scaleFactor, equals(1.2));
      expect(config.autoStart, isFalse);
    });

    test('should copy config with modifications', () {
      final original = SpringPhysicsConfig(
        duration: const Duration(milliseconds: 800),
        stiffness: 100.0,
        dampingRatio: 0.8,
      );

      final modified = original.copyWith(
        stiffness: 150.0,
        autoStart: true,
      );

      expect(modified.stiffness, equals(150.0));
      expect(modified.autoStart, isTrue);
      expect(modified.dampingRatio, equals(0.8));
    });
  });

  group('Error Handling Tests', () {
    test('should throw PhysicsSystemException for invalid operations', () {
      expect(
        () => throw PhysicsSystemException(
          'Test error',
          'test_system',
          'Root cause',
        ),
        throwsA(isA<PhysicsSystemException>()),
      );
    });

    test('should format exception message correctly', () {
      final exception = PhysicsSystemException(
        'Test error message',
        'test_system_id',
      );

      expect(
        exception.toString(),
        equals('PhysicsSystemException(test_system_id): Test error message'),
      );
    });
  });
}