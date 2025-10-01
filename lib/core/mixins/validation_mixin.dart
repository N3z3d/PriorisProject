/// DUPLICATION ELIMINATION - Validation Mixin
///
/// Consolidates validation logic scattered across the codebase.
/// Provides reusable validation patterns and error handling.

/// Common Validation Mixin
///
/// Eliminates duplicated validation code across forms, services, and entities.
mixin ValidationMixin {
  /// Validation results container
  final Map<String, String> _validationErrors = {};

  /// Adds a validation error
  void addValidationError(String field, String message) {
    _validationErrors[field] = message;
  }

  /// Removes a validation error
  void removeValidationError(String field) {
    _validationErrors.remove(field);
  }

  /// Clears all validation errors
  void clearValidationErrors() {
    _validationErrors.clear();
  }

  /// Checks if there are any validation errors
  bool get hasValidationErrors => _validationErrors.isNotEmpty;

  /// Gets all validation errors
  Map<String, String> get validationErrors => Map.unmodifiable(_validationErrors);

  /// Gets error for specific field
  String? getFieldError(String field) => _validationErrors[field];

  /// Validates multiple fields at once
  bool validateFields(Map<String, List<ValidationRule>> fieldRules) {
    clearValidationErrors();

    for (final entry in fieldRules.entries) {
      final field = entry.key;
      final rules = entry.value;

      for (final rule in rules) {
        final error = rule.validate();
        if (error != null) {
          addValidationError(field, error);
          break; // Stop at first error for this field
        }
      }
    }

    return !hasValidationErrors;
  }

  /// Common validation patterns
  static String? validateRequired(dynamic value, [String? fieldName]) {
    if (value == null || value.toString().trim().isEmpty) {
      return '${fieldName ?? 'Ce champ'} est requis';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value?.trim().isEmpty ?? true) return 'Email requis';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
      return 'Format email invalide';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value?.isEmpty ?? true) return 'Mot de passe requis';
    if (value!.length < 6) return 'Au moins 6 caractères requis';
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
      return 'Doit contenir au moins une lettre et un chiffre';
    }
    return null;
  }

  static String? validateLength(String? value, int min, int max, [String? fieldName]) {
    if (value == null) return null;
    if (value.length < min) {
      return '${fieldName ?? 'Ce champ'} doit contenir au moins $min caractères';
    }
    if (value.length > max) {
      return '${fieldName ?? 'Ce champ'} ne peut dépasser $max caractères';
    }
    return null;
  }

  static String? validateNumeric(String? value, [String? fieldName]) {
    if (value?.trim().isEmpty ?? true) return null;
    if (double.tryParse(value!) == null) {
      return '${fieldName ?? 'Ce champ'} doit être un nombre valide';
    }
    return null;
  }

  static String? validateRange(double? value, double min, double max, [String? fieldName]) {
    if (value == null) return null;
    if (value < min || value > max) {
      return '${fieldName ?? 'Cette valeur'} doit être entre $min et $max';
    }
    return null;
  }

  static String? validateDate(DateTime? value, [String? fieldName]) {
    if (value == null) return '${fieldName ?? 'Date'} invalide';
    return null;
  }

  static String? validateFutureDate(DateTime? value, [String? fieldName]) {
    if (value == null) return '${fieldName ?? 'Date'} invalide';
    if (value.isBefore(DateTime.now())) {
      return '${fieldName ?? 'La date'} doit être dans le futur';
    }
    return null;
  }

  static String? validateUrl(String? value, [String? fieldName]) {
    if (value?.trim().isEmpty ?? true) return null;
    if (!(Uri.tryParse(value!)?.hasAbsolutePath ?? false)) {
      return '${fieldName ?? 'URL'} invalide';
    }
    return null;
  }

  static String? validatePhone(String? value, [String? fieldName]) {
    if (value?.trim().isEmpty ?? true) return null;
    if (!RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(value!)) {
      return '${fieldName ?? 'Numéro de téléphone'} invalide';
    }
    return null;
  }

  /// Business logic validators
  static String? validateTaskTitle(String? value) {
    final error = validateRequired(value, 'Titre de la tâche');
    if (error != null) return error;
    return validateLength(value, 1, 200, 'Titre de la tâche');
  }

  static String? validateListName(String? value) {
    final error = validateRequired(value, 'Nom de la liste');
    if (error != null) return error;
    return validateLength(value, 1, 100, 'Nom de la liste');
  }

  static String? validateHabitName(String? value) {
    final error = validateRequired(value, 'Nom de l\'habitude');
    if (error != null) return error;
    return validateLength(value, 1, 150, 'Nom de l\'habitude');
  }

  static String? validateDescription(String? value) {
    if (value?.trim().isEmpty ?? true) return null;
    return validateLength(value, 0, 1000, 'Description');
  }

  static String? validateCategory(String? value) {
    if (value?.trim().isEmpty ?? true) return null;
    return validateLength(value, 1, 50, 'Catégorie');
  }
}

/// Validation Rule Interface
abstract class ValidationRule {
  String? validate();
}

/// Required Field Rule
class RequiredRule implements ValidationRule {
  final dynamic value;
  final String fieldName;

  RequiredRule(this.value, this.fieldName);

  @override
  String? validate() => ValidationMixin.validateRequired(value, fieldName);
}

/// Length Rule
class LengthRule implements ValidationRule {
  final String? value;
  final int min;
  final int max;
  final String fieldName;

  LengthRule(this.value, this.min, this.max, this.fieldName);

  @override
  String? validate() => ValidationMixin.validateLength(value, min, max, fieldName);
}

/// Email Rule
class EmailRule implements ValidationRule {
  final String? value;

  EmailRule(this.value);

  @override
  String? validate() => ValidationMixin.validateEmail(value);
}

/// Password Rule
class PasswordRule implements ValidationRule {
  final String? value;

  PasswordRule(this.value);

  @override
  String? validate() => ValidationMixin.validatePassword(value);
}

/// Custom Rule
class CustomRule implements ValidationRule {
  final String? Function() validator;

  CustomRule(this.validator);

  @override
  String? validate() => validator();
}

/// Validation Builder for fluent validation
class ValidationBuilder {
  final Map<String, List<ValidationRule>> _rules = {};

  ValidationBuilder field(String fieldName) {
    _currentField = fieldName;
    return this;
  }

  String? _currentField;

  ValidationBuilder required(dynamic value) {
    _addRule(RequiredRule(value, _currentField ?? 'Field'));
    return this;
  }

  ValidationBuilder length(String? value, int min, int max) {
    _addRule(LengthRule(value, min, max, _currentField ?? 'Field'));
    return this;
  }

  ValidationBuilder email(String? value) {
    _addRule(EmailRule(value));
    return this;
  }

  ValidationBuilder password(String? value) {
    _addRule(PasswordRule(value));
    return this;
  }

  ValidationBuilder custom(String? Function() validator) {
    _addRule(CustomRule(validator));
    return this;
  }

  void _addRule(ValidationRule rule) {
    final field = _currentField ?? 'unknown';
    _rules[field] ??= [];
    _rules[field]!.add(rule);
  }

  Map<String, List<ValidationRule>> build() => Map.unmodifiable(_rules);
}