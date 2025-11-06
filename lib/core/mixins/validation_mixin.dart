import 'dart:collection';

typedef ValidationCallback = String? Function();

/// Base mixin providing stateful form validation utilities.
mixin ValidationMixin {
  final Map<String, String> _validationErrors = <String, String>{};

  /// Returns `true` when at least one validation error is registered.
  bool get hasValidationErrors => _validationErrors.isNotEmpty;

  /// Exposes the current validation errors as an immutable map.
  Map<String, String> get validationErrors =>
      UnmodifiableMapView<String, String>(_validationErrors);

  /// Adds or replaces a validation error for the provided field.
  void addValidationError(String field, String message) {
    _validationErrors[field] = message;
  }

  /// Removes a validation error associated with the provided field.
  void removeValidationError(String field) {
    _validationErrors.remove(field);
  }

  /// Clears the full list of validation errors.
  void clearValidationErrors() {
    _validationErrors.clear();
  }

  /// Returns the current error message for the provided field if any.
  String? getFieldError(String field) => _validationErrors[field];

  /// Validates all rules for every field and stores the first failure.
  ///
  /// Returns `true` when all fields pass their validation rules.
  bool validateFields(Map<String, List<ValidationRule>> rules) {
    clearValidationErrors();
    var isValid = true;

    rules.forEach((field, fieldRules) {
      for (final rule in fieldRules) {
        final error = rule.validate();
        if (error != null) {
          addValidationError(field, error);
          isValid = false;
          break;
        }
      }
    });

    return isValid;
  }

  /// Helper: validates that a value is non empty.
  static String? validateRequired(String? value, [String field = 'Ce champ']) {
    if (value == null || value.trim().isEmpty) {
      return '$field est requis';
    }
    return null;
  }

  /// Helper: validates that a value matches an email pattern.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Format email invalide';
    }

    final emailRegex = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email invalide';
    }
    return null;
  }

  /// Helper: validates common password constraints.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mot de passe requis';
    }
    if (value.length < 6) {
      return 'Au moins 6 caractères';
    }

    final hasLetter = value.contains(RegExp(r'[A-Za-z]'));
    final hasDigit = value.contains(RegExp(r'[0-9]'));
    if (!hasLetter || !hasDigit) {
      return 'Doit contenir lettres et chiffres';
    }
    return null;
  }

  /// Helper: validates a string length (inclusive) when not null.
  static String? validateLength(
    String? value,
    int min,
    int max, [
    String field = 'Ce champ',
  ]) {
    if (value == null) {
      return null;
    }

    if (value.length < min) {
      return '$field doit contenir au moins $min caractères';
    }
    if (value.length > max) {
      return '$field doit contenir au plus $max caractères';
    }
    return null;
  }
  static String? validateNumeric(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final numericRegex = RegExp(r'^[-+]?[0-9]*\.?[0-9]+$');
    if (!numericRegex.hasMatch(value.trim())) {
      return 'Valeur numérique invalide';
    }
    return null;
  }

  static String? validateRange(num? value, num min, num max) {
    if (value == null) {
      return null;
    }
    if (value < min || value > max) {
      return 'La valeur doit être comprise entre $min et $max';
    }
    return null;
  }

  static String? validateDate(DateTime? value) {
    if (value == null) {
      return 'Date requise';
    }
    return null;
  }

  static String? validateFutureDate(DateTime? value) {
    if (value == null) {
      return 'Date requise';
    }
    if (value.isBefore(DateTime.now())) {
      return 'La date doit être dans le futur';
    }
    return null;
  }

  static String? validatePastDate(DateTime? value) {
    if (value == null) {
      return 'Date requise';
    }
    if (value.isAfter(DateTime.now())) {
      return 'La date doit être dans le passé';
    }
    return null;
  }

  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final urlRegex =
        RegExp(r'^(https?:\/\/)?([A-Za-z0-9-]+\.)+[A-Za-z]{2,}(:\d+)?(\/.*)?$');
    if (!urlRegex.hasMatch(value.trim())) {
      return 'URL invalide';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final phoneRegex = RegExp(r'^[+0-9().\-\s]{6,}$');
    final digitRegex = RegExp(r'\d');
    if (!phoneRegex.hasMatch(value) || !digitRegex.hasMatch(value)) {
      return 'Numéro de téléphone invalide';
    }
    return null;
  }

  static String? validateTaskTitle(String? value) {
    final required = validateRequired(value, 'Le titre de la tâche');
    if (required != null) {
      return required;
    }
    return validateLength(value, 1, 200, 'Le titre de la tâche');
  }

  static String? validateListName(String? value) {
    final required = validateRequired(value, 'Le nom de la liste');
    if (required != null) {
      return required;
    }
    return validateLength(value, 1, 100, 'Le nom de la liste');
  }

  static String? validateHabitName(String? value) {
    final required = validateRequired(value, 'Le nom de l’habitude');
    if (required != null) {
      return required;
    }
    return validateLength(value, 1, 150, 'Le nom de l’habitude');
  }

  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return validateLength(value, 0, 1000, 'La description');
  }

  static String? validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return validateLength(value, 0, 50, 'La catégorie');
  }
}

/// Base class for field validation rules.
abstract class ValidationRule {
  const ValidationRule();

  /// Implementations return `null` when valid, otherwise an error message.
  String? validate();
}

class RequiredRule extends ValidationRule {
  const RequiredRule(this.value, this.fieldName);

  final String? value;
  final String fieldName;

  @override
  String? validate() => ValidationMixin.validateRequired(value, fieldName);
}

class EmailRule extends ValidationRule {
  const EmailRule(this.value);

  final String? value;

  @override
  String? validate() => ValidationMixin.validateEmail(value);
}

class PasswordRule extends ValidationRule {
  const PasswordRule(this.value);

  final String? value;

  @override
  String? validate() => ValidationMixin.validatePassword(value);
}

class LengthRule extends ValidationRule {
  const LengthRule(
    this.value,
    this.min,
    this.max,
    this.fieldName,
  );

  final String? value;
  final int min;
  final int max;
  final String fieldName;

  @override
  String? validate() =>
      ValidationMixin.validateLength(value, min, max, fieldName);
}

class CustomRule extends ValidationRule {
  const CustomRule(this.validator);

  final ValidationCallback validator;

  @override
  String? validate() => validator();
}

class ValidationBuilder {
  final Map<String, List<ValidationRule>> _rules =
      <String, List<ValidationRule>>{};
  String? _currentField;

  ValidationBuilder field(String fieldName) {
    _currentField = fieldName;
    _rules.putIfAbsent(fieldName, () => <ValidationRule>[]);
    return this;
  }

  ValidationBuilder required(String? value, [String? label]) {
    _ensureFieldSelected();
    _rules[_currentField]!.add(
      RequiredRule(value, label ?? _defaultLabel(_currentField!)),
    );
    return this;
  }

  ValidationBuilder email(String? value) {
    _ensureFieldSelected();
    _rules[_currentField]!.add(EmailRule(value));
    return this;
  }

  ValidationBuilder password(String? value) {
    _ensureFieldSelected();
    _rules[_currentField]!.add(PasswordRule(value));
    return this;
  }

  ValidationBuilder length(
    String? value,
    int min,
    int max, [
    String? label,
  ]) {
    _ensureFieldSelected();
    _rules[_currentField]!.add(
      LengthRule(value, min, max, label ?? _defaultLabel(_currentField!)),
    );
    return this;
  }

  ValidationBuilder custom(ValidationCallback validator) {
    _ensureFieldSelected();
    _rules[_currentField]!.add(CustomRule(validator));
    return this;
  }

  Map<String, List<ValidationRule>> build() {
    return Map.unmodifiable(
      _rules.map(
        (key, value) => MapEntry(key, List<ValidationRule>.unmodifiable(value)),
      ),
    );
  }

  void _ensureFieldSelected() {
    if (_currentField == null) {
      throw StateError('Aucun champ sélectionné. Appelez field() avant.');
    }
  }

  String _defaultLabel(String field) {
    if (field.isEmpty) return 'Ce champ';
    return '${field[0].toUpperCase()}${field.substring(1)}';
  }
}
