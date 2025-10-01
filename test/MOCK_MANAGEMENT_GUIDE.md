# Mock Management Best Practices

## Overview
This guide establishes best practices for mock management to ensure consistent, fast, and reliable tests throughout the Prioris project.

## Quick Start

### 1. Using MockFactory
```dart
import '../test_utils/mock_factory.dart';

testWidgets('fast test with mocks', (tester) async {
  // Create complete test environment
  final env = MockFactory.createTestEnvironment(
    testLists: [TestData.createTestList(id: 'test-1')],
  );

  // Use mocks in your test
  await tester.pumpWidget(MyWidget(service: env.adaptiveService));
});
```

### 2. Performance-Optimized Testing
```dart
import '../test_utils/performance_test_utils.dart';

testWidgets('performance-optimized test', (tester) async {
  await PerformanceTestUtils.pumpWidgetFast(
    tester,
    MyWidget(),
    settleTimeout: Duration(seconds: 1), // Prevent infinite loops
  );
});
```

## Mock Generation Process

### Automatic Mock Generation
Mock files are generated automatically using `build_runner`:

```bash
# Generate all mocks
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes
flutter pub run build_runner watch
```

### Manual Mock Creation
For simple mocks that don't require code generation:

```dart
class MockSimpleService extends Mock implements SimpleService {
  @override
  String get simpleProperty => 'mock-value';
}
```

### Required Mock Annotations
Add `@GenerateMocks([...])` annotations to test files that need mocks:

```dart
import 'package:mockito/annotations.dart';

@GenerateMocks([
  CustomListRepository,
  ListItemRepository,
  AdaptivePersistenceService,
])
void main() {
  // Tests using generated mocks
}
```

## Performance Best Practices

### ✅ DO: Fast Mock Responses
```dart
// ✅ Good - immediate response
when(mockRepo.getAllLists()).thenAnswer((_) async => testData);

// ❌ Bad - introduces artificial delay
when(mockRepo.getAllLists()).thenAnswer((_) async {
  await Future.delayed(Duration(seconds: 1));
  return testData;
});
```

### ✅ DO: Use MockFactory for Consistency
```dart
// ✅ Good - consistent mock setup
final mockRepo = MockFactory.createMockCustomListRepository(
  mockLists: testLists,
);

// ❌ Bad - manual setup prone to errors
final mockRepo = MockCustomListRepository();
when(mockRepo.getAllLists()).thenAnswer((_) async => testLists);
when(mockRepo.getListById(any)).thenAnswer(/* complex logic */);
```

### ✅ DO: Proper Resource Management
```dart
// ✅ Good - proper cleanup
tearDown(() {
  container.dispose();
  verifyNoMoreInteractions(mockService);
});

// ❌ Bad - no cleanup, potential memory leaks
tearDown(() {
  // Nothing - resources leak
});
```

### ✅ DO: Use Shared Mock Setup
```dart
// ✅ Good - shared setup
class TestEnvironmentSetup {
  static TestEnvironment createStandardEnvironment() {
    return MockFactory.createTestEnvironment(
      testLists: StandardTestData.lists,
      testItems: StandardTestData.items,
    );
  }
}

// Use in tests
final env = TestEnvironmentSetup.createStandardEnvironment();
```

## Mock Verification Patterns

### Verify Interactions
```dart
test('should call repository method', () async {
  // Act
  await service.performOperation();

  // Verify
  verify(mockRepo.saveList(any)).called(1);
  verifyNoMoreInteractions(mockRepo);
});
```

### Verify Arguments
```dart
test('should pass correct arguments', () async {
  // Act
  await service.saveList(testList);

  // Verify with argument matching
  verify(mockRepo.saveList(argThat(
    predicate<CustomList>((list) =>
      list.id == testList.id &&
      list.name == testList.name
    ),
  ))).called(1);
});
```

### Verify Call Order
```dart
test('should call methods in correct order', () async {
  // Act
  await service.complexOperation();

  // Verify order
  verifyInOrder([
    mockRepo.getAllLists(),
    mockRepo.saveList(any),
    mockNotificationService.showSuccess(any),
  ]);
});
```

## Common Mock Patterns

### Repository Mocks
```dart
// Standard repository mock with CRUD operations
final mockRepo = MockFactory.createMockCustomListRepository();

// Override specific behavior
when(mockRepo.getListById('special-id'))
    .thenThrow(StateError('Special handling'));
```

### Service Mocks with State
```dart
class MockStatefulService extends Mock implements StatefulService {
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
  }

  @override
  bool get isInitialized => _isInitialized;
}
```

### Provider Mocks
```dart
// Mock providers for Riverpod tests
final container = ProviderContainer(
  overrides: [
    customListRepositoryProvider.overrideWith(
      (ref) => MockFactory.createMockCustomListRepository(),
    ),
    adaptivePersistenceServiceProvider.overrideWith(
      (ref) => MockFactory.createMockAdaptivePersistenceService(),
    ),
  ],
);
```

## Troubleshooting

### Mock Files Not Generated
1. Check `@GenerateMocks` annotation syntax
2. Run `flutter pub run build_runner clean`
3. Run `flutter pub run build_runner build --delete-conflicting-outputs`
4. Verify no syntax errors in annotated files

### Tests Timing Out
1. Replace `pumpAndSettle()` with `PerformanceTestUtils.pumpUntilSettled()`
2. Use immediate mock responses (no delays)
3. Check for infinite rebuild cycles
4. Add explicit timeouts to tests

### Memory Leaks in Tests
1. Always dispose ProviderContainers in `tearDown()`
2. Clear mock interactions with `clearInteractions()`
3. Use `PerformanceTestUtils.withProviderContainer()` for automatic cleanup

### Mock Verification Failures
1. Use `verify()` instead of `verifyNever()` when possible
2. Check argument matchers (`any`, `argThat`)
3. Use `verifyInOrder()` for sequence-dependent operations
4. Clear interactions between tests if needed

## Performance Monitoring

### Test Execution Times
```bash
# Monitor test performance
flutter test --reporter=json > test_results.json

# Analyze slow tests
grep -E '"testID|duration' test_results.json | head -20
```

### Memory Usage
```dart
test('memory-monitored test', () async {
  final result = await PerformanceTestUtils.measurePerformance(
    'test_operation',
    () async => await service.complexOperation(),
  );

  expect(result.isPerformant(maxDuration: Duration(milliseconds: 100)), isTrue);
  print('Test performance: $result');
});
```

## File Organization

```
test/
├── test_utils/
│   ├── mock_factory.dart          # Centralized mock creation
│   ├── performance_test_utils.dart # Performance utilities
│   ├── test_data.dart             # Test data generators
│   └── test_providers.dart        # Provider overrides
├── unit/                          # Fast unit tests (<100ms)
├── widget/                        # Widget tests (<500ms)
├── integration/                   # Integration tests (<2s)
├── e2e/                          # End-to-end tests (<10s)
└── performance/                   # Performance benchmarks
```

## Success Metrics

- **Test Speed**: Unit tests <100ms, Widget tests <500ms
- **Mock Coverage**: 100% of external dependencies mocked
- **Memory Safety**: No memory leaks in test runs
- **Reliability**: Tests pass consistently (>95% success rate)
- **Maintainability**: Shared mock setup reduces duplication

## Quick Commands

```bash
# Fast unit tests only
flutter test test/unit/ --timeout=5s --tags=fast

# Full test suite with coverage
./scripts/test_performance.ps1 -Coverage

# Performance tests only
flutter test test/performance/ --timeout=60s

# Generate fresh mocks
flutter pub run build_runner build --delete-conflicting-outputs
```