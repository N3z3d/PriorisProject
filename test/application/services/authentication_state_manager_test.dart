/// TDD Tests for AuthenticationStateManager
/// Follows Red → Green → Refactor methodology
/// Tests written to validate P0 critical service

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/application/services/authentication_state_manager.dart';
import 'package:prioris/application/ports/persistence_interfaces.dart';

void main() {
  group('AuthenticationStateManager Tests - P0 Critical Service', () {
    late AuthenticationStateManager manager;

    setUp(() {
      manager = AuthenticationStateManager();
    });

    tearDown(() {
      manager.dispose();
    });

    group('Initialization Tests', () {
      test('should initialize with isAuthenticated=false and mode=localFirst', () async {
        // WHEN
        await manager.initialize(isAuthenticated: false);

        // THEN
        expect(manager.isAuthenticated, isFalse);
        expect(manager.currentMode, equals(PersistenceMode.localFirst));
      });

      test('should initialize with isAuthenticated=true and mode=cloudFirst', () async {
        // WHEN
        await manager.initialize(isAuthenticated: true);

        // THEN
        expect(manager.isAuthenticated, isTrue);
        expect(manager.currentMode, equals(PersistenceMode.cloudFirst));
      });
    });

    group('State Transition Tests', () {
      test('should transition false → true and change mode to cloudFirst', () async {
        // GIVEN
        await manager.initialize(isAuthenticated: false);
        expect(manager.currentMode, equals(PersistenceMode.localFirst));

        // WHEN
        await manager.updateAuthenticationState(isAuthenticated: true);

        // THEN
        expect(manager.isAuthenticated, isTrue);
        expect(manager.currentMode, equals(PersistenceMode.cloudFirst));
      });

      test('should transition true → false and change mode to localFirst', () async {
        // GIVEN
        await manager.initialize(isAuthenticated: true);
        expect(manager.currentMode, equals(PersistenceMode.cloudFirst));

        // WHEN
        await manager.updateAuthenticationState(isAuthenticated: false);

        // THEN
        expect(manager.isAuthenticated, isFalse);
        expect(manager.currentMode, equals(PersistenceMode.localFirst));
      });
    });

    group('Stream Notification Tests', () {
      test('should notify listeners when authentication state changes', () async {
        // GIVEN
        await manager.initialize(isAuthenticated: false);

        final receivedStates = <bool>[];
        final subscription = manager.authenticationStateStream.listen(receivedStates.add);

        // WHEN
        await manager.updateAuthenticationState(isAuthenticated: true);
        await Future.delayed(Duration(milliseconds: 10)); // Let stream emit

        // THEN
        expect(receivedStates, contains(true));

        await subscription.cancel();
      });

      test('should support multiple listeners simultaneously', () async {
        // GIVEN
        await manager.initialize(isAuthenticated: false);

        final listener1States = <bool>[];
        final listener2States = <bool>[];
        final listener3States = <bool>[];

        final sub1 = manager.authenticationStateStream.listen(listener1States.add);
        final sub2 = manager.authenticationStateStream.listen(listener2States.add);
        final sub3 = manager.authenticationStateStream.listen(listener3States.add);

        // WHEN
        await manager.updateAuthenticationState(isAuthenticated: true);
        await Future.delayed(Duration(milliseconds: 10));

        await manager.updateAuthenticationState(isAuthenticated: false);
        await Future.delayed(Duration(milliseconds: 10));

        // THEN
        expect(listener1States, equals([true, false]));
        expect(listener2States, equals([true, false]));
        expect(listener3States, equals([true, false]));

        await sub1.cancel();
        await sub2.cancel();
        await sub3.cancel();
      });
    });

    group('Context Tracking Tests', () {
      test('should return true when hasAuthenticationChanged detects state change', () async {
        // GIVEN
        await manager.initialize(isAuthenticated: false);

        // WHEN
        final hasChanged = manager.hasAuthenticationChanged(true);

        // THEN
        expect(hasChanged, isTrue);
      });

      test('should return false when hasAuthenticationChanged detects no change', () async {
        // GIVEN
        await manager.initialize(isAuthenticated: true);

        // WHEN
        final hasChanged = manager.hasAuthenticationChanged(true);

        // THEN
        expect(hasChanged, isFalse);
      });

      test('should return correct authentication context metadata', () async {
        // GIVEN
        await manager.initialize(isAuthenticated: true);

        // WHEN
        final context = manager.getAuthContext();

        // THEN
        expect(context['isAuthenticated'], isTrue);
        expect(context['currentMode'], equals('cloudFirst'));
        expect(context['timestamp'], isNotNull);
        expect(context['timestamp'], isA<String>());
      });
    });

    group('Disposal Tests', () {
      test('should close stream correctly on disposal', () async {
        // GIVEN
        await manager.initialize(isAuthenticated: false);

        var streamClosed = false;
        final subscription = manager.authenticationStateStream.listen(
          (_) {},
          onDone: () => streamClosed = true,
        );

        // WHEN
        manager.dispose();

        // THEN
        await Future.delayed(Duration(milliseconds: 10));
        expect(streamClosed, isTrue);

        await subscription.cancel();
      });

      test('should not throw exception on multiple dispose calls', () {
        // WHEN & THEN
        expect(() => manager.dispose(), returnsNormally);
        expect(() => manager.dispose(), returnsNormally); // Second dispose should not crash
      });
    });

    group('Edge Cases', () {
      test('should handle rapid state transitions correctly', () async {
        // GIVEN
        await manager.initialize(isAuthenticated: false);

        final receivedStates = <bool>[];
        final subscription = manager.authenticationStateStream.listen(receivedStates.add);

        // WHEN - Rapid transitions
        await manager.updateAuthenticationState(isAuthenticated: true);
        await manager.updateAuthenticationState(isAuthenticated: false);
        await manager.updateAuthenticationState(isAuthenticated: true);
        await Future.delayed(Duration(milliseconds: 20));

        // THEN
        expect(receivedStates, equals([true, false, true]));
        expect(manager.isAuthenticated, isTrue);
        expect(manager.currentMode, equals(PersistenceMode.cloudFirst));

        await subscription.cancel();
      });

      test('should maintain state consistency after initialization', () async {
        // GIVEN & WHEN
        await manager.initialize(isAuthenticated: true);

        // THEN - State should remain consistent
        expect(manager.isAuthenticated, isTrue);
        expect(manager.currentMode, equals(PersistenceMode.cloudFirst));

        final context = manager.getAuthContext();
        expect(context['isAuthenticated'], equals(manager.isAuthenticated));
        expect(context['currentMode'], equals(manager.currentMode.name));
      });
    });
  });
}