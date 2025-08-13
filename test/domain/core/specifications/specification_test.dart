import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/core/specifications/specification.dart';

void main() {
  group('Specification Pattern', () {
    late Specification<String> startsWithA;
    late Specification<String> endsWithZ;
    late Specification<String> containsB;

    setUp(() {
      startsWithA = Specifications.fromPredicate<String>(
        (value) => value.startsWith('A'),
        'Starts with A',
      );
      
      endsWithZ = Specifications.fromPredicate<String>(
        (value) => value.endsWith('Z'),
        'Ends with Z',
      );
      
      containsB = Specifications.fromPredicate<String>(
        (value) => value.contains('B'),
        'Contains B',
      );
    });

    group('Basic Specifications', () {
      test('should evaluate simple predicate', () {
        // Arrange & Act & Assert
        expect(startsWithA.isSatisfiedBy('Apple'), isTrue);
        expect(startsWithA.isSatisfiedBy('Banana'), isFalse);
        expect(startsWithA.description, 'Starts with A');
      });

      test('should handle empty or null values gracefully', () {
        // Arrange & Act & Assert  
        expect(startsWithA.isSatisfiedBy(''), isFalse);
        expect(endsWithZ.isSatisfiedBy(''), isFalse);
      });
    });

    group('Logical Operations', () {
      test('should combine with AND operator', () {
        // Arrange
        final spec = startsWithA.and(endsWithZ);

        // Act & Assert
        expect(spec.isSatisfiedBy('AZ'), isTrue);
        expect(spec.isSatisfiedBy('ABCZ'), isTrue);
        expect(spec.isSatisfiedBy('ABC'), isFalse); // No Z
        expect(spec.isSatisfiedBy('XYZ'), isFalse); // No A start
      });

      test('should combine with OR operator', () {
        // Arrange
        final spec = startsWithA.or(endsWithZ);

        // Act & Assert
        expect(spec.isSatisfiedBy('Apple'), isTrue); // Starts with A
        expect(spec.isSatisfiedBy('XYZ'), isTrue); // Ends with Z
        expect(spec.isSatisfiedBy('AZ'), isTrue); // Both
        expect(spec.isSatisfiedBy('Banana'), isFalse); // Neither
      });

      test('should negate with NOT operator', () {
        // Arrange
        final spec = startsWithA.not();

        // Act & Assert
        expect(spec.isSatisfiedBy('Banana'), isTrue);
        expect(spec.isSatisfiedBy('Apple'), isFalse);
      });

      test('should chain multiple operations', () {
        // Arrange
        final spec = startsWithA
            .and(containsB)
            .or(endsWithZ);

        // Act & Assert
        expect(spec.isSatisfiedBy('ABC'), isTrue); // Starts A and contains B
        expect(spec.isSatisfiedBy('XYZ'), isTrue); // Ends with Z
        expect(spec.isSatisfiedBy('ACD'), isFalse); // Starts A but no B, no Z
        expect(spec.isSatisfiedBy('BCD'), isFalse); // Contains B but no A start, no Z
      });

      test('should handle complex nested operations', () {
        // Arrange
        final spec = startsWithA
            .and(containsB.or(endsWithZ))
            .not();

        // Act & Assert
        expect(spec.isSatisfiedBy('ABC'), isFalse); // Matches: starts A and contains B
        expect(spec.isSatisfiedBy('AZ'), isFalse); // Matches: starts A and ends Z
        expect(spec.isSatisfiedBy('ACD'), isTrue); // Doesn't match: starts A but no B/Z
        expect(spec.isSatisfiedBy('XBC'), isTrue); // Doesn't match: contains B but no A
      });
    });

    group('Custom Specifications', () {
      test('should create specifications with custom predicates', () {
        // Arrange
        final lengthGreaterThan3 = Specifications.fromPredicate<String>(
          (value) => value.length > 3,
          'Length greater than 3',
        );

        final isUpperCase = Specifications.fromPredicate<String>(
          (value) => value == value.toUpperCase(),
          'Is uppercase',
        );

        // Act & Assert
        expect(lengthGreaterThan3.isSatisfiedBy('Hello'), isTrue);
        expect(lengthGreaterThan3.isSatisfiedBy('Hi'), isFalse);
        
        expect(isUpperCase.isSatisfiedBy('HELLO'), isTrue);
        expect(isUpperCase.isSatisfiedBy('Hello'), isFalse);
      });

      test('should work with numerical specifications', () {
        // Arrange
        final greaterThan10 = Specifications.fromPredicate<int>(
          (value) => value > 10,
          'Greater than 10',
        );

        final isEven = Specifications.fromPredicate<int>(
          (value) => value % 2 == 0,
          'Is even number',
        );

        final complexSpec = greaterThan10.and(isEven);

        // Act & Assert
        expect(complexSpec.isSatisfiedBy(12), isTrue); // > 10 and even
        expect(complexSpec.isSatisfiedBy(11), isFalse); // > 10 but odd
        expect(complexSpec.isSatisfiedBy(8), isFalse); // even but <= 10
        expect(complexSpec.isSatisfiedBy(5), isFalse); // neither
      });

      test('should work with object specifications', () {
        // Arrange
        final person1 = Person('Alice', 25);
        final person2 = Person('Bob', 17);
        final person3 = Person('Charlie', 30);

        final isAdult = Specifications.fromPredicate<Person>(
          (person) => person.age >= 18,
          'Is adult',
        );

        final nameStartsWithA = Specifications.fromPredicate<Person>(
          (person) => person.name.startsWith('A'),
          'Name starts with A',
        );

        final adultWithAName = isAdult.and(nameStartsWithA);

        // Act & Assert
        expect(isAdult.isSatisfiedBy(person1), isTrue);
        expect(isAdult.isSatisfiedBy(person2), isFalse);
        
        expect(adultWithAName.isSatisfiedBy(person1), isTrue); // Adult Alice
        expect(adultWithAName.isSatisfiedBy(person2), isFalse); // Minor Bob
        expect(adultWithAName.isSatisfiedBy(person3), isFalse); // Adult Charlie (no A)
      });
    });

    group('Specification Composition', () {
      test('should maintain description through operations', () {
        // Arrange
        final spec = startsWithA.and(endsWithZ);

        // Act & Assert
        expect(spec.description, isNotNull);
        expect(spec.description.length, greaterThan(0));
      });

      test('should be reusable', () {
        // Arrange
        final baseSpec = startsWithA.and(containsB);

        // Act
        final spec1 = baseSpec.or(endsWithZ);
        final spec2 = baseSpec.not();

        // Assert
        expect(spec1.isSatisfiedBy('ABZ'), isTrue);
        expect(spec2.isSatisfiedBy('AXY'), isTrue); // Starts A but no B - should pass negated baseSpec
        expect(spec2.isSatisfiedBy('XBY'), isTrue); // Has B but doesn't start A
      });

      test('should handle identity operations correctly', () {
        // Arrange
        final spec = startsWithA.and(startsWithA); // Same spec twice

        // Act & Assert
        expect(spec.isSatisfiedBy('Apple'), isTrue);
        expect(spec.isSatisfiedBy('Banana'), isFalse);
      });

      test('should handle contradictory specifications', () {
        // Arrange
        final contradictorySpec = startsWithA.and(startsWithA.not());

        // Act & Assert
        expect(contradictorySpec.isSatisfiedBy('Apple'), isFalse);
        expect(contradictorySpec.isSatisfiedBy('Banana'), isFalse);
        expect(contradictorySpec.isSatisfiedBy(''), isFalse);
      });
    });

    group('Edge Cases', () {
      test('should handle repeated negations', () {
        // Arrange
        final doubleNegation = startsWithA.not().not();

        // Act & Assert
        expect(doubleNegation.isSatisfiedBy('Apple'), isTrue);
        expect(doubleNegation.isSatisfiedBy('Banana'), isFalse);
      });

      test('should handle complex precedence', () {
        // Arrange
        final spec1 = startsWithA.or(containsB).and(endsWithZ);
        final spec2 = startsWithA.or(containsB.and(endsWithZ));

        // Act & Assert
        // spec1: (A OR B) AND Z - requires Z
        expect(spec1.isSatisfiedBy('AZ'), isTrue);
        expect(spec1.isSatisfiedBy('BZ'), isTrue);
        expect(spec1.isSatisfiedBy('AB'), isFalse); // No Z

        // spec2: A OR (B AND Z) - Z only required if starting with B
        expect(spec2.isSatisfiedBy('AZ'), isTrue);
        expect(spec2.isSatisfiedBy('BZ'), isTrue);
        expect(spec2.isSatisfiedBy('AB'), isTrue); // Starts with A
        expect(spec2.isSatisfiedBy('B'), isFalse); // B but no Z
      });
    });
  });
}

// Helper class for testing
class Person {
  final String name;
  final int age;
  
  Person(this.name, this.age);
  
  @override
  String toString() => 'Person($name, $age)';
}