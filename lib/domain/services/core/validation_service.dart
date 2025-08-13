import 'package:flutter/material.dart';

/// Service pour gérer la validation et le feedback utilisateur
/// 
/// Fournit des méthodes pour standardiser les messages d'erreur,
/// valider les données en temps réel et améliorer le feedback visuel.
class ValidationService {
  static final ValidationService _instance = ValidationService._internal();
  factory ValidationService() => _instance;
  ValidationService._internal();

  /// Messages d'erreur standardisés par type
  static const Map<String, String> _errorMessages = {
    'required': 'Ce champ est obligatoire',
    'email': 'Veuillez entrer une adresse email valide',
    'minLength': 'Ce champ doit contenir au moins {min} caractères',
    'maxLength': 'Ce champ ne peut pas dépasser {max} caractères',
    'numeric': 'Ce champ doit contenir uniquement des chiffres',
    'positive': 'Ce champ doit être un nombre positif',
    'date': 'Veuillez entrer une date valide',
    'futureDate': 'La date doit être dans le futur',
    'pastDate': 'La date doit être dans le passé',
    'url': 'Veuillez entrer une URL valide',
    'phone': 'Veuillez entrer un numéro de téléphone valide',
    'password': 'Le mot de passe doit contenir au moins 8 caractères',
    'passwordMatch': 'Les mots de passe ne correspondent pas',
    'unique': 'Cette valeur existe déjà',
    'invalidFormat': 'Format invalide',
    'networkError': 'Erreur de connexion. Veuillez réessayer.',
    'serverError': 'Erreur serveur. Veuillez réessayer plus tard.',
    'timeout': 'Délai d\'attente dépassé. Veuillez réessayer.',
    'unknown': 'Une erreur inattendue s\'est produite',
  };

  /// Suggestions de correction par type d'erreur
  static const Map<String, List<String>> _correctionSuggestions = {
    'email': [
      'Vérifiez que l\'email contient @ et un domaine valide',
      'Exemple : utilisateur@exemple.com',
    ],
    'password': [
      'Utilisez au moins 8 caractères',
      'Incluez des lettres majuscules et minuscules',
      'Ajoutez des chiffres et symboles',
    ],
    'minLength': [
      'Ajoutez plus de caractères',
      'Utilisez des mots plus longs',
    ],
    'maxLength': [
      'Raccourcissez le texte',
      'Supprimez les caractères inutiles',
    ],
    'numeric': [
      'N\'utilisez que des chiffres (0-9)',
      'Supprimez les lettres et symboles',
    ],
    'date': [
      'Utilisez le format JJ/MM/AAAA',
      'Vérifiez que la date existe',
    ],
  };

  /// Obtient un message d'erreur standardisé
  String getErrorMessage(String errorType, {Map<String, dynamic>? parameters}) {
    final baseMessage = _errorMessages[errorType] ?? _errorMessages['unknown']!;
    
    if (parameters != null) {
      return _replaceParameters(baseMessage, parameters);
    }
    
    return baseMessage;
  }

  /// Obtient des suggestions de correction
  List<String> getCorrectionSuggestions(String errorType) {
    return _correctionSuggestions[errorType] ?? [];
  }

  /// Remplace les paramètres dans un message
  String _replaceParameters(String message, Map<String, dynamic> parameters) {
    String result = message;
    parameters.forEach((key, value) {
      result = result.replaceAll('{$key}', value.toString());
    });
    return result;
  }

  /// Valide une adresse email
  ValidationResult validateEmail(String email) {
    if (email.isEmpty) {
      return ValidationResult(
        isValid: false,
        errorType: 'required',
        suggestions: getCorrectionSuggestions('email'),
      );
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      return ValidationResult(
        isValid: false,
        errorType: 'email',
        suggestions: getCorrectionSuggestions('email'),
      );
    }

    return ValidationResult(isValid: true);
  }

  /// Valide un mot de passe
  ValidationResult validatePassword(String password) {
    if (password.isEmpty) {
      return ValidationResult(
        isValid: false,
        errorType: 'required',
        suggestions: getCorrectionSuggestions('password'),
      );
    }

    if (password.length < 8) {
      return ValidationResult(
        isValid: false,
        errorType: 'minLength',
        suggestions: getCorrectionSuggestions('password'),
        parameters: {'min': '8'},
      );
    }

    return ValidationResult(isValid: true);
  }

  /// Valide la longueur d'un texte
  ValidationResult validateLength(String text, {int? minLength, int? maxLength}) {
    if (text.isEmpty && minLength != null && minLength > 0) {
      return ValidationResult(
        isValid: false,
        errorType: 'required',
      );
    }

    if (minLength != null && text.length < minLength) {
      return ValidationResult(
        isValid: false,
        errorType: 'minLength',
        suggestions: getCorrectionSuggestions('minLength'),
        parameters: {'min': minLength.toString()},
      );
    }

    if (maxLength != null && text.length > maxLength) {
      return ValidationResult(
        isValid: false,
        errorType: 'maxLength',
        suggestions: getCorrectionSuggestions('maxLength'),
        parameters: {'max': maxLength.toString()},
      );
    }

    return ValidationResult(isValid: true);
  }

  /// Valide un nombre
  ValidationResult validateNumber(String text, {bool allowNegative = false}) {
    if (text.isEmpty) {
      return ValidationResult(
        isValid: false,
        errorType: 'required',
      );
    }

    final numberRegex = allowNegative 
        ? RegExp(r'^-?\d+(\.\d+)?$')
        : RegExp(r'^\d+(\.\d+)?$');

    if (!numberRegex.hasMatch(text)) {
      return ValidationResult(
        isValid: false,
        errorType: 'numeric',
        suggestions: getCorrectionSuggestions('numeric'),
      );
    }

    final number = double.tryParse(text);
    if (number != null && !allowNegative && number < 0) {
      return ValidationResult(
        isValid: false,
        errorType: 'positive',
      );
    }

    return ValidationResult(isValid: true);
  }

  /// Valide une date
  ValidationResult validateDate(DateTime? date, {bool mustBeFuture = false, bool mustBePast = false}) {
    if (date == null) {
      return ValidationResult(
        isValid: false,
        errorType: 'required',
      );
    }

    final now = DateTime.now();
    
    if (mustBeFuture && date.isBefore(now)) {
      return ValidationResult(
        isValid: false,
        errorType: 'futureDate',
        suggestions: getCorrectionSuggestions('date'),
      );
    }

    if (mustBePast && date.isAfter(now)) {
      return ValidationResult(
        isValid: false,
        errorType: 'pastDate',
        suggestions: getCorrectionSuggestions('date'),
      );
    }

    return ValidationResult(isValid: true);
  }

  /// Obtient un message contextuel selon l'action
  String getContextualMessage(String action, {bool isSuccess = true}) {
    final messages = {
      'create': isSuccess ? 'Créé avec succès' : 'Erreur lors de la création',
      'update': isSuccess ? 'Mis à jour avec succès' : 'Erreur lors de la mise à jour',
      'delete': isSuccess ? 'Supprimé avec succès' : 'Erreur lors de la suppression',
      'save': isSuccess ? 'Enregistré avec succès' : 'Erreur lors de l\'enregistrement',
      'load': isSuccess ? 'Chargé avec succès' : 'Erreur lors du chargement',
      'import': isSuccess ? 'Importé avec succès' : 'Erreur lors de l\'import',
      'export': isSuccess ? 'Exporté avec succès' : 'Erreur lors de l\'export',
      'connect': isSuccess ? 'Connecté avec succès' : 'Erreur de connexion',
      'disconnect': isSuccess ? 'Déconnecté avec succès' : 'Erreur de déconnexion',
    };

    return messages[action] ?? (isSuccess ? 'Action réussie' : 'Erreur');
  }

  /// Obtient une couleur selon le type de message
  Color getMessageColor(String messageType) {
    switch (messageType) {
      case 'success':
        return Colors.green;
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'info':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// Obtient une icône selon le type de message
  IconData getMessageIcon(String messageType) {
    switch (messageType) {
      case 'success':
        return Icons.check_circle;
      case 'error':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      case 'info':
        return Icons.info;
      default:
        return Icons.message;
    }
  }
}

/// Résultat d'une validation
class ValidationResult {
  final bool isValid;
  final String? errorType;
  final List<String> suggestions;
  final Map<String, dynamic>? parameters;

  const ValidationResult({
    required this.isValid,
    this.errorType,
    this.suggestions = const [],
    this.parameters,
  });

  /// Obtient le message d'erreur formaté
  String getErrorMessage() {
    if (isValid) return '';
    
    final service = ValidationService();
    return service.getErrorMessage(errorType ?? 'unknown', parameters: parameters);
  }

  /// Obtient les suggestions de correction
  List<String> getCorrectionSuggestions() {
    if (isValid) return [];
    
    final service = ValidationService();
    return service.getCorrectionSuggestions(errorType ?? '');
  }
} 
