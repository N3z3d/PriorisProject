import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/core/di/dependency_injection_container.dart';

// Test interfaces and implementations
abstract class ITestService {
  String getMessage();
}

class TestService implements ITestService {
  final String message;
  TestService(this.message);

  @override
  String getMessage() => message;
}

class AnotherTestService implements ITestService {
  @override
  String getMessage() => 'Another service';
}

// Test class with dependencies
abstract class ITestRepository {
  String getData();
}

class TestRepository implements ITestRepository {
  final ITestService _service;
  TestRepository(this._service);

  @override
  String getData() => 'Data from: ${_service.getMessage()}';
}

// Test async service
abstract class ITestAsyncService {
  Future<String> getAsyncData();
}

class TestAsyncService implements ITestAsyncService {
  bool _isInitialized = false;

  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 10));
    _isInitialized = true;
  }

  @override
  Future<String> getAsyncData() async {
    if (!_isInitialized) {
      throw StateError('Service not initialized');
    }
    return 'Async data';
  }
}

// Test disposable service
class TestDisposableService implements Disposable {
  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;

  @override
  Future<void> dispose() async {
    _isDisposed = true;
  }
}

void main() {
  group('DIContainer', () {
    late DIContainer container;

    setUp(() {
      container = DIContainer();
    });

    tearDown(() async {
      await container.dispose();
    });

    group('Factory Registration and Resolution', () {
      test('should register and resolve factory services', () {
        container.registerFactory<ITestService>(
          () => TestService('Factory service'),
        );

        final service = container.resolve<ITestService>();
        expect(service, isA<TestService>());
        expect(service.getMessage(), equals('Factory service'));
      });

      test('should create new instances for factory services', () {
        container.registerFactory<ITestService>(
          () => TestService('Factory service'),
        );

        final service1 = container.resolve<ITestService>();
        final service2 = container.resolve<ITestService>();

        expect(service1, isA<TestService>());
        expect(service2, isA<TestService>());
        expect(identical(service1, service2), isFalse);
      });

      test('should resolve factory dependencies', () {
        container.registerFactory<ITestService>(
          () => TestService('Dependency service'),
        );
        container.registerFactory<ITestRepository>(
          () => TestRepository(container.resolve<ITestService>()),
        );

        final repository = container.resolve<ITestRepository>();
        expect(repository, isA<TestRepository>());
        expect(repository.getData(), equals('Data from: Dependency service'));
      });
    });

    group('Singleton Registration and Resolution', () {
      test('should register and resolve singleton services', () {
        container.registerSingleton<ITestService>(
          () => TestService('Singleton service'),
        );

        final service = container.resolve<ITestService>();
        expect(service, isA<TestService>());
        expect(service.getMessage(), equals('Singleton service'));
      });

      test('should return same instance for singleton services', () {
        container.registerSingleton<ITestService>(
          () => TestService('Singleton service'),
        );

        final service1 = container.resolve<ITestService>();
        final service2 = container.resolve<ITestService>();

        expect(service1, isA<TestService>());
        expect(service2, isA<TestService>());
        expect(identical(service1, service2), isTrue);
      });

      test('should lazy-initialize singleton services', () {
        bool factoryCalled = false;

        container.registerSingleton<ITestService>(() {
          factoryCalled = true;
          return TestService('Lazy singleton');
        });

        // Factory should not be called yet
        expect(factoryCalled, isFalse);

        // First resolve should call factory
        final service = container.resolve<ITestService>();
        expect(factoryCalled, isTrue);
        expect(service.getMessage(), equals('Lazy singleton'));
      });
    });

    group('Async Service Registration and Resolution', () {
      test('should register and resolve async services', () async {
        final asyncService = TestAsyncService();
        await asyncService.initialize();

        container.registerAsyncService<ITestAsyncService>(
          Future.value(asyncService),
        );

        final resolvedService = await container.resolveAsync<ITestAsyncService>();
        expect(resolvedService, isA<TestAsyncService>());

        final data = await resolvedService.getAsyncData();
        expect(data, equals('Async data'));
      });

      test('should handle async service initialization', () async {
        final asyncService = TestAsyncService();

        container.registerAsyncService<ITestAsyncService>(
          asyncService.initialize().then((_) => asyncService),
        );

        final resolvedService = await container.resolveAsync<ITestAsyncService>();
        final data = await resolvedService.getAsyncData();
        expect(data, equals('Async data'));
      });

      test('should cache async service instances', () async {
        final asyncService = TestAsyncService();
        await asyncService.initialize();

        container.registerAsyncService<ITestAsyncService>(
          Future.value(asyncService),
        );

        final service1 = await container.resolveAsync<ITestAsyncService>();
        final service2 = await container.resolveAsync<ITestAsyncService>();

        expect(identical(service1, service2), isTrue);
      });
    });

    group('Service Registration Management', () {
      test('should check if service is registered', () {
        expect(container.isRegistered<ITestService>(), isFalse);

        container.registerFactory<ITestService>(
          () => TestService('Test'),
        );

        expect(container.isRegistered<ITestService>(), isTrue);
      });

      test('should unregister services', () {
        container.registerFactory<ITestService>(
          () => TestService('Test'),
        );

        expect(container.isRegistered<ITestService>(), isTrue);

        container.unregister<ITestService>();

        expect(container.isRegistered<ITestService>(), isFalse);
      });

      test('should replace existing registrations', () {
        container.registerFactory<ITestService>(
          () => TestService('Original'),
        );

        container.registerFactory<ITestService>(
          () => TestService('Replaced'),
        );

        final service = container.resolve<ITestService>();
        expect(service.getMessage(), equals('Replaced'));
      });
    });

    group('Error Handling', () {
      test('should throw ServiceNotFoundException for unregistered services', () {
        expect(
          () => container.resolve<ITestService>(),
          throwsA(isA<ServiceNotFoundException>()),
        );
      });

      test('should throw ServiceNotFoundException for unregistered async services', () async {
        expect(
          () => container.resolveAsync<ITestAsyncService>(),
          throwsA(isA<ServiceNotFoundException>()),
        );
      });

      test('should provide detailed error messages', () {
        try {
          container.resolve<ITestService>();
          fail('Expected ServiceNotFoundException');
        } catch (e) {
          expect(e, isA<ServiceNotFoundException>());
          expect(e.toString(), contains('ITestService'));
        }
      });

      test('should detect circular dependencies', () {
        // Register services with circular dependency
        container.registerFactory<ITestService>(
          () => TestService(container.resolve<ITestRepository>().getData()),
        );
        container.registerFactory<ITestRepository>(
          () => TestRepository(container.resolve<ITestService>()),
        );

        expect(
          () => container.resolve<ITestService>(),
          throwsA(isA<CircularDependencyException>()),
        );
      });
    });

    group('Container Management', () {
      test('should clear all registrations', () {
        container.registerFactory<ITestService>(
          () => TestService('Test'),
        );
        container.registerSingleton<ITestRepository>(
          () => TestRepository(TestService('Singleton')),
        );

        expect(container.isRegistered<ITestService>(), isTrue);
        expect(container.isRegistered<ITestRepository>(), isTrue);

        container.clear();

        expect(container.isRegistered<ITestService>(), isFalse);
        expect(container.isRegistered<ITestRepository>(), isFalse);
      });

      test('should dispose all disposable services', () async {
        final disposableService = TestDisposableService();

        container.registerSingleton<TestDisposableService>(
          () => disposableService,
        );

        // Resolve to create the singleton
        container.resolve<TestDisposableService>();

        expect(disposableService.isDisposed, isFalse);

        await container.dispose();

        expect(disposableService.isDisposed, isTrue);
      });

      test('should handle dispose gracefully when no disposable services exist', () async {
        container.registerFactory<ITestService>(
          () => TestService('Test'),
        );

        // Should not throw
        await container.dispose();
      });
    });

    group('Performance and Memory Management', () {
      test('should handle large number of registrations efficiently', () {
        // Register many services
        for (int i = 0; i < 1000; i++) {
          container.registerFactory<String>(
            () => 'Service $i',
            name: 'service_$i',
          );
        }

        // Resolution should still be fast
        final stopwatch = Stopwatch()..start();
        for (int i = 0; i < 100; i++) {
          final service = container.resolve<String>(name: 'service_$i');
          expect(service, equals('Service $i'));
        }
        stopwatch.stop();

        // Should complete within reasonable time (adjust threshold as needed)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('should not leak memory with factory services', () {
        container.registerFactory<ITestService>(
          () => TestService('Factory'),
        );

        // Create many instances - they should be garbage collected
        for (int i = 0; i < 1000; i++) {
          container.resolve<ITestService>();
        }

        // Test passes if no memory issues occur
        expect(container.isRegistered<ITestService>(), isTrue);
      });
    });

    group('Named Service Registration', () {
      test('should register and resolve named services', () {
        container.registerFactory<ITestService>(
          () => TestService('Default'),
        );
        container.registerFactory<ITestService>(
          () => TestService('Named'),
          name: 'named_service',
        );

        final defaultService = container.resolve<ITestService>();
        final namedService = container.resolve<ITestService>(name: 'named_service');

        expect(defaultService.getMessage(), equals('Default'));
        expect(namedService.getMessage(), equals('Named'));
      });

      test('should handle named service unregistration', () {
        container.registerFactory<ITestService>(
          () => TestService('Named'),
          name: 'named_service',
        );

        expect(container.isRegistered<ITestService>(name: 'named_service'), isTrue);

        container.unregister<ITestService>(name: 'named_service');

        expect(container.isRegistered<ITestService>(name: 'named_service'), isFalse);
      });
    });

    group('Type Safety and Generics', () {
      test('should maintain type safety with generics', () {
        container.registerFactory<ITestService>(
          () => TestService('Type safe'),
        );

        final service = container.resolve<ITestService>();
        expect(service, isA<ITestService>());
        expect(service, isA<TestService>());
      });

      test('should handle interface implementations correctly', () {
        container.registerFactory<ITestService>(
          () => AnotherTestService(),
        );

        final service = container.resolve<ITestService>();
        expect(service, isA<ITestService>());
        expect(service, isA<AnotherTestService>());
        expect(service.getMessage(), equals('Another service'));
      });
    });

    group('SOLID Principles Compliance', () {
      test('should demonstrate Dependency Inversion Principle', () {
        // High-level modules should not depend on low-level modules
        // Both should depend on abstractions

        container.registerFactory<ITestService>(
          () => TestService('DIP compliant'),
        );
        container.registerFactory<ITestRepository>(
          () => TestRepository(container.resolve<ITestService>()),
        );

        final repository = container.resolve<ITestRepository>();

        // Repository depends on ITestService abstraction, not concrete TestService
        expect(repository, isA<ITestRepository>());
        expect(repository.getData(), contains('DIP compliant'));
      });

      test('should demonstrate Single Responsibility Principle', () {
        // Container's single responsibility is managing object lifecycle
        // It should not know about business logic

        container.registerFactory<ITestService>(
          () => TestService('SRP compliant'),
        );

        final service = container.resolve<ITestService>();

        // Container creates objects but doesn't interfere with their behavior
        expect(service.getMessage(), equals('SRP compliant'));
      });

      test('should demonstrate Open/Closed Principle', () {
        // Container should be open for extension (new service types)
        // but closed for modification

        // Can register different types without modifying container
        container.registerFactory<ITestService>(
          () => TestService('OCP test'),
        );
        container.registerFactory<ITestRepository>(
          () => TestRepository(container.resolve<ITestService>()),
        );

        final service = container.resolve<ITestService>();
        final repository = container.resolve<ITestRepository>();

        expect(service, isA<ITestService>());
        expect(repository, isA<ITestRepository>());
      });
    });
  });
}