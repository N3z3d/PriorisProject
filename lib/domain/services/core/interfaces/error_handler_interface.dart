/// Interface pour la gestion d'erreurs
/// 
/// Permet l'injection de dépendances et facilite les tests
/// en respectant le principe de Dependency Inversion.
abstract class ErrorHandlerInterface {
  /// Traite une erreur et retourne une erreur applicative
  AppError handleError(dynamic error, {String? context, StackTrace? stackTrace});
  
  /// Crée une erreur de validation
  AppError validationError(String message, {String? field});
  
  /// Crée une erreur métier
  AppError businessError(String message, {String? operation});
  
  /// Crée une erreur de stockage
  AppError storageError(String message, {String? operation});
}

/// Interface pour la classification d'erreurs
/// 
/// Séparée du gestionnaire principal selon le principe
/// Interface Segregation.
abstract class ErrorClassifierInterface {
  /// Classifie une erreur selon son type
  AppError classifyError(dynamic error, String? context);
}

/// Interface pour le logging d'erreurs
/// 
/// Permet de séparer la logique de logging de la gestion d'erreurs.
abstract class ErrorLoggerInterface {
  /// Log une erreur
  void logError(dynamic error, String? context, StackTrace? stackTrace);
}

/// Classe d'erreur unifiée pour l'application
class AppError implements Exception {
  final String message;
  final String category;
  final String? context;
  final dynamic originalError;
  final DateTime timestamp;

  AppError({
    required this.message,
    required this.category,
    this.context,
    this.originalError,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Message utilisateur-friendly
  String get userMessage {
    switch (category) {
      case 'VALIDATION':
        return 'Veuillez vérifier les informations saisies: $message';
      case 'STORAGE':
        return 'Erreur lors de l\'accès aux données. Veuillez réessayer.';
      case 'BUSINESS':
        return message;
      case 'NETWORK':
        return 'Problème de connexion. Veuillez vérifier votre réseau.';
      default:
        return 'Une erreur inattendue s\'est produite. Veuillez réessayer.';
    }
  }

  /// Sévérité de l'erreur
  ErrorSeverity get severity {
    switch (category) {
      case 'VALIDATION':
        return ErrorSeverity.warning;
      case 'STORAGE':
        return ErrorSeverity.error;
      case 'BUSINESS':
        return ErrorSeverity.info;
      case 'NETWORK':
        return ErrorSeverity.warning;
      default:
        return ErrorSeverity.error;
    }
  }

  @override
  String toString() => 'AppError[$category]: $message${context != null ? ' (Context: $context)' : ''}';
}

/// Niveaux de sévérité des erreurs
enum ErrorSeverity {
  info,
  warning,
  error,
  critical,
}