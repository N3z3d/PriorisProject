/// Validateurs de formulaires réutilisables
///
/// **Principe DRY** : Évite la duplication de logique de validation
/// **SRP** : Chaque validateur a une responsabilité unique

class FormValidators {
  FormValidators._();

  /// Valide qu'un champ texte n'est pas vide et respecte les contraintes de longueur
  ///
  /// **Paramètres** :
  /// - [fieldName] : Nom du champ pour les messages d'erreur
  /// - [minLength] : Longueur minimale (défaut: 2)
  /// - [maxLength] : Longueur maximale (défaut: 200)
  ///
  /// **Exemple** :
  /// ```dart
  /// validator: (value) => FormValidators.requiredText(
  ///   value,
  ///   fieldName: 'titre',
  ///   minLength: 3,
  ///   maxLength: 100,
  /// )
  /// ```
  static String? requiredText(
    String? value, {
    required String fieldName,
    int minLength = 2,
    int maxLength = 200,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Le $fieldName est obligatoire';
    }

    final trimmed = value.trim();

    if (trimmed.length < minLength) {
      return 'Le $fieldName doit contenir au moins $minLength caractères';
    }

    if (value.length > maxLength) {
      return 'Le $fieldName ne peut pas dépasser $maxLength caractères';
    }

    return null;
  }

  /// Valide un email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'L\'email est obligatoire';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Veuillez entrer un email valide';
    }

    return null;
  }

  /// Valide un mot de passe
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est obligatoire';
    }

    if (value.length < minLength) {
      return 'Le mot de passe doit contenir au moins $minLength caractères';
    }

    return null;
  }

  /// Valide un nombre (entier positif)
  static String? positiveInteger(String? value, {required String fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return 'Le $fieldName est obligatoire';
    }

    final number = int.tryParse(value.trim());

    if (number == null) {
      return 'Le $fieldName doit être un nombre entier';
    }

    if (number <= 0) {
      return 'Le $fieldName doit être positif';
    }

    return null;
  }

  /// Valide un texte optionnel avec limite de longueur
  static String? optionalText(String? value, {int maxLength = 500}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optionnel, donc valide
    }

    if (value.length > maxLength) {
      return 'Le texte ne peut pas dépasser $maxLength caractères';
    }

    return null;
  }
}
