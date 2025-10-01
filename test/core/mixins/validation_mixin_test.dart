import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/core/mixins/validation_mixin.dart';

// Test class that uses the ValidationMixin
class TestValidator with ValidationMixin {}

void main() {
  group('ValidationMixin', () {
    late TestValidator validator;

    setUp(() {
      validator = TestValidator();
    });

    group('Basic Validation State', () {
      test('should start with no validation errors', () {
        expect(validator.hasValidationErrors, isFalse);
        expect(validator.validationErrors, isEmpty);
      });

      test('should add validation error', () {
        validator.addValidationError('email', 'Email is required');

        expect(validator.hasValidationErrors, isTrue);
        expect(validator.getFieldError('email'), equals('Email is required'));
      });

      test('should remove validation error', () {
        validator.addValidationError('email', 'Email is required');
        validator.removeValidationError('email');

        expect(validator.hasValidationErrors, isFalse);
        expect(validator.getFieldError('email'), isNull);
      });

      test('should clear all validation errors', () {
        validator.addValidationError('email', 'Email error');
        validator.addValidationError('password', 'Password error');

        validator.clearValidationErrors();

        expect(validator.hasValidationErrors, isFalse);
        expect(validator.validationErrors, isEmpty);
      });

      test('should return immutable validation errors map', () {
        validator.addValidationError('email', 'Email error');

        final errors = validator.validationErrors;
        expect(() => errors['test'] = 'should fail', throwsUnsupportedError);
      });
    });

    group('Field Validation Rules', () {
      test('should validate fields with rules', () {
        final rules = {
          'email': [
            RequiredRule('', 'Email'),
            EmailRule('invalid-email'),
          ],
          'password': [
            RequiredRule('123', 'Password'),
            PasswordRule('123'),
          ],
        };

        final isValid = validator.validateFields(rules);

        expect(isValid, isFalse);
        expect(validator.hasValidationErrors, isTrue);
        expect(validator.getFieldError('email'), isNotNull);
        expect(validator.getFieldError('password'), isNotNull);
      });

      test('should pass validation with valid data', () {
        final rules = {
          'email': [
            RequiredRule('test@example.com', 'Email'),
            EmailRule('test@example.com'),
          ],
          'password': [
            RequiredRule('password123', 'Password'),
            PasswordRule('password123'),
          ],
        };

        final isValid = validator.validateFields(rules);

        expect(isValid, isTrue);
        expect(validator.hasValidationErrors, isFalse);
      });

      test('should stop at first error for each field', () {
        final rules = {
          'email': [
            RequiredRule('', 'Email'), // This should fail
            EmailRule(''), // This should not be executed
          ],
        };

        validator.validateFields(rules);

        expect(validator.getFieldError('email'), contains('Email est requis'));
      });
    });

    group('Static Validation Methods', () {
      group('validateRequired', () {
        test('should validate required fields', () {
          expect(ValidationMixin.validateRequired('value'), isNull);
          expect(ValidationMixin.validateRequired(''), isNotNull);
          expect(ValidationMixin.validateRequired('  '), isNotNull);
          expect(ValidationMixin.validateRequired(null), isNotNull);
        });

        test('should use custom field name', () {
          final error = ValidationMixin.validateRequired('', 'Email');
          expect(error, contains('Email'));
        });
      });

      group('validateEmail', () {
        test('should validate email format', () {
          expect(ValidationMixin.validateEmail('test@example.com'), isNull);
          expect(ValidationMixin.validateEmail('user.name@domain.co.uk'), isNull);
          expect(ValidationMixin.validateEmail('invalid-email'), isNotNull);
          expect(ValidationMixin.validateEmail(''), isNotNull);
          expect(ValidationMixin.validateEmail(null), isNotNull);
        });
      });

      group('validatePassword', () {
        test('should validate password requirements', () {
          expect(ValidationMixin.validatePassword('password123'), isNull);
          expect(ValidationMixin.validatePassword('abc123'), isNull);
          expect(ValidationMixin.validatePassword(''), isNotNull);
          expect(ValidationMixin.validatePassword('12345'), isNotNull);
          expect(ValidationMixin.validatePassword('password'), isNotNull);
          expect(ValidationMixin.validatePassword('123456'), isNotNull);
          expect(ValidationMixin.validatePassword(null), isNotNull);
        });
      });

      group('validateLength', () {
        test('should validate string length', () {
          expect(ValidationMixin.validateLength('hello', 3, 10), isNull);
          expect(ValidationMixin.validateLength('hi', 3, 10), isNotNull);
          expect(ValidationMixin.validateLength('very long string', 3, 10), isNotNull);
          expect(ValidationMixin.validateLength(null, 3, 10), isNull);
        });

        test('should use custom field name', () {
          final error = ValidationMixin.validateLength('hi', 3, 10, 'Username');
          expect(error, contains('Username'));
        });
      });

      group('validateNumeric', () {
        test('should validate numeric values', () {
          expect(ValidationMixin.validateNumeric('123'), isNull);
          expect(ValidationMixin.validateNumeric('123.45'), isNull);
          expect(ValidationMixin.validateNumeric('-123'), isNull);
          expect(ValidationMixin.validateNumeric('abc'), isNotNull);
          expect(ValidationMixin.validateNumeric(''), isNull);
          expect(ValidationMixin.validateNumeric(null), isNull);
        });
      });

      group('validateRange', () {
        test('should validate numeric range', () {
          expect(ValidationMixin.validateRange(5.0, 1.0, 10.0), isNull);
          expect(ValidationMixin.validateRange(0.0, 1.0, 10.0), isNotNull);
          expect(ValidationMixin.validateRange(11.0, 1.0, 10.0), isNotNull);
          expect(ValidationMixin.validateRange(null, 1.0, 10.0), isNull);
        });
      });

      group('validateDate', () {
        test('should validate date values', () {
          expect(ValidationMixin.validateDate(DateTime.now()), isNull);
          expect(ValidationMixin.validateDate(null), isNotNull);
        });
      });

      group('validateFutureDate', () {
        test('should validate future dates', () {
          final future = DateTime.now().add(const Duration(days: 1));
          final past = DateTime.now().subtract(const Duration(days: 1));

          expect(ValidationMixin.validateFutureDate(future), isNull);
          expect(ValidationMixin.validateFutureDate(past), isNotNull);
          expect(ValidationMixin.validateFutureDate(null), isNotNull);
        });
      });

      group('validateUrl', () {
        test('should validate URL format', () {
          expect(ValidationMixin.validateUrl('https://example.com'), isNull);
          expect(ValidationMixin.validateUrl('http://test.org'), isNull);
          expect(ValidationMixin.validateUrl('invalid-url'), isNotNull);
          expect(ValidationMixin.validateUrl(''), isNull);
          expect(ValidationMixin.validateUrl(null), isNull);
        });
      });

      group('validatePhone', () {
        test('should validate phone number format', () {
          expect(ValidationMixin.validatePhone('+33123456789'), isNull);
          expect(ValidationMixin.validatePhone('0123456789'), isNull);
          expect(ValidationMixin.validatePhone('+1 (555) 123-4567'), isNull);
          expect(ValidationMixin.validatePhone('123'), isNotNull);
          expect(ValidationMixin.validatePhone(''), isNull);
          expect(ValidationMixin.validatePhone(null), isNull);
        });
      });
    });

    group('Business Logic Validators', () {
      group('validateTaskTitle', () {
        test('should validate task title', () {
          expect(ValidationMixin.validateTaskTitle('Valid task title'), isNull);
          expect(ValidationMixin.validateTaskTitle(''), isNotNull);
          expect(ValidationMixin.validateTaskTitle('x' * 201), isNotNull);
          expect(ValidationMixin.validateTaskTitle(null), isNotNull);
        });
      });

      group('validateListName', () {
        test('should validate list name', () {
          expect(ValidationMixin.validateListName('My List'), isNull);
          expect(ValidationMixin.validateListName(''), isNotNull);
          expect(ValidationMixin.validateListName('x' * 101), isNotNull);
          expect(ValidationMixin.validateListName(null), isNotNull);
        });
      });

      group('validateHabitName', () {
        test('should validate habit name', () {
          expect(ValidationMixin.validateHabitName('Daily Exercise'), isNull);
          expect(ValidationMixin.validateHabitName(''), isNotNull);
          expect(ValidationMixin.validateHabitName('x' * 151), isNotNull);
          expect(ValidationMixin.validateHabitName(null), isNotNull);
        });
      });

      group('validateDescription', () {
        test('should validate description', () {
          expect(ValidationMixin.validateDescription('Valid description'), isNull);
          expect(ValidationMixin.validateDescription(''), isNull);
          expect(ValidationMixin.validateDescription(null), isNull);
          expect(ValidationMixin.validateDescription('x' * 1001), isNotNull);
        });
      });

      group('validateCategory', () {
        test('should validate category', () {
          expect(ValidationMixin.validateCategory('Work'), isNull);
          expect(ValidationMixin.validateCategory(''), isNull);
          expect(ValidationMixin.validateCategory(null), isNull);
          expect(ValidationMixin.validateCategory('x' * 51), isNotNull);
        });
      });
    });

    group('Validation Rules Classes', () {
      group('RequiredRule', () {
        test('should validate required values', () {
          final rule = RequiredRule('value', 'Test Field');
          expect(rule.validate(), isNull);

          final emptyRule = RequiredRule('', 'Test Field');
          expect(emptyRule.validate(), isNotNull);
        });
      });

      group('LengthRule', () {
        test('should validate string length', () {
          final rule = LengthRule('hello', 3, 10, 'Test Field');
          expect(rule.validate(), isNull);

          final shortRule = LengthRule('hi', 3, 10, 'Test Field');
          expect(shortRule.validate(), isNotNull);
        });
      });

      group('EmailRule', () {
        test('should validate email format', () {
          final rule = EmailRule('test@example.com');
          expect(rule.validate(), isNull);

          final invalidRule = EmailRule('invalid');
          expect(invalidRule.validate(), isNotNull);
        });
      });

      group('PasswordRule', () {
        test('should validate password strength', () {
          final rule = PasswordRule('password123');
          expect(rule.validate(), isNull);

          final weakRule = PasswordRule('123');
          expect(weakRule.validate(), isNotNull);
        });
      });

      group('CustomRule', () {
        test('should execute custom validation logic', () {
          final rule = CustomRule(() => null);
          expect(rule.validate(), isNull);

          final failingRule = CustomRule(() => 'Custom error');
          expect(failingRule.validate(), equals('Custom error'));
        });
      });
    });

    group('ValidationBuilder Fluent API', () {
      test('should build validation rules fluently', () {
        final builder = ValidationBuilder()
          ..field('email')
          ..required('test@example.com')
          ..email('test@example.com')
          ..field('password')
          ..required('password123')
          ..password('password123')
          ..length('password123', 6, 20);

        final rules = builder.build();

        expect(rules.containsKey('email'), isTrue);
        expect(rules.containsKey('password'), isTrue);
        expect(rules['email']?.length, equals(2));
        expect(rules['password']?.length, equals(3));
      });

      test('should handle custom validation rules', () {
        final builder = ValidationBuilder()
          ..field('custom')
          ..custom(() => 'Custom validation error');

        final rules = builder.build();

        expect(rules.containsKey('custom'), isTrue);
        expect(rules['custom']?.first.validate(), equals('Custom validation error'));
      });

      test('should return immutable rules map', () {
        final builder = ValidationBuilder()
          ..field('test')
          ..required('value');

        final rules = builder.build();

        expect(() => rules['new'] = [], throwsUnsupportedError);
      });
    });

    group('Integration with Form Validation', () {
      test('should validate complete form', () {
        final formData = {
          'email': 'test@example.com',
          'password': 'password123',
          'confirmPassword': 'password123',
          'name': 'John Doe',
        };

        final rules = {
          'email': [
            RequiredRule(formData['email'], 'Email'),
            EmailRule(formData['email']),
          ],
          'password': [
            RequiredRule(formData['password'], 'Password'),
            PasswordRule(formData['password']),
          ],
          'confirmPassword': [
            RequiredRule(formData['confirmPassword'], 'Confirm Password'),
            CustomRule(() {
              return formData['password'] == formData['confirmPassword']
                  ? null
                  : 'Passwords do not match';
            }),
          ],
          'name': [
            RequiredRule(formData['name'], 'Name'),
            LengthRule(formData['name'], 2, 50, 'Name'),
          ],
        };

        final isValid = validator.validateFields(rules);

        expect(isValid, isTrue);
        expect(validator.hasValidationErrors, isFalse);
      });

      test('should handle form with validation errors', () {
        final formData = {
          'email': 'invalid-email',
          'password': '123',
          'confirmPassword': '456',
          'name': '',
        };

        final rules = {
          'email': [
            RequiredRule(formData['email'], 'Email'),
            EmailRule(formData['email']),
          ],
          'password': [
            RequiredRule(formData['password'], 'Password'),
            PasswordRule(formData['password']),
          ],
          'confirmPassword': [
            RequiredRule(formData['confirmPassword'], 'Confirm Password'),
            CustomRule(() {
              return formData['password'] == formData['confirmPassword']
                  ? null
                  : 'Passwords do not match';
            }),
          ],
          'name': [
            RequiredRule(formData['name'], 'Name'),
          ],
        };

        final isValid = validator.validateFields(rules);

        expect(isValid, isFalse);
        expect(validator.hasValidationErrors, isTrue);
        expect(validator.getFieldError('email'), isNotNull);
        expect(validator.getFieldError('password'), isNotNull);
        expect(validator.getFieldError('confirmPassword'), isNotNull);
        expect(validator.getFieldError('name'), isNotNull);
      });
    });

    group('Error Message Localization', () {
      test('should provide French error messages', () {
        expect(ValidationMixin.validateRequired('', 'Email'),
               contains('requis'));
        expect(ValidationMixin.validateEmail('invalid'),
               contains('Format email invalide'));
        expect(ValidationMixin.validatePassword('123'),
               contains('Au moins 6 caractères'));
        expect(ValidationMixin.validateLength('x', 5, 10, 'Nom'),
               contains('au moins 5 caractères'));
      });
    });

    group('Performance and Edge Cases', () {
      test('should handle large number of validation rules efficiently', () {
        final rules = <String, List<ValidationRule>>{};

        // Create many validation rules
        for (int i = 0; i < 100; i++) {
          rules['field_$i'] = [
            RequiredRule('value_$i', 'Field $i'),
            LengthRule('value_$i', 1, 20, 'Field $i'),
          ];
        }

        final stopwatch = Stopwatch()..start();
        final isValid = validator.validateFields(rules);
        stopwatch.stop();

        expect(isValid, isTrue);
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('should handle null values gracefully', () {
        final rules = {
          'nullable': [
            LengthRule(null, 1, 10, 'Nullable'),
            CustomRule(() => null),
          ],
        };

        final isValid = validator.validateFields(rules);

        expect(isValid, isTrue);
        expect(validator.hasValidationErrors, isFalse);
      });

      test('should handle empty validation rules', () {
        final isValid = validator.validateFields({});

        expect(isValid, isTrue);
        expect(validator.hasValidationErrors, isFalse);
      });
    });
  });
}