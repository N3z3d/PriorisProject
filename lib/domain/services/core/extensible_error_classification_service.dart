import 'abstract_error_classifier.dart';
import 'interfaces/error_handler_interface.dart';

/// Implémentation extensible du service de classification d'erreurs
/// 
/// Respecte le principe Open/Closed en étendant la classe abstraite
/// sans modifier le code existant.
class ExtensibleErrorClassificationService extends AbstractErrorClassifier {
  
  @override
  AppError? classifyCustomError(dynamic error, String? context) {
    // Classification des erreurs réseau
    if (isNetworkError(error)) {
      return AppError(
        message: 'Erreur de connexion réseau',
        category: 'NETWORK',
        context: context,
        originalError: error,
      );
    }

    // Classification des erreurs de timeout
    if (isTimeoutError(error)) {
      return AppError(
        message: 'Délai d\'attente dépassé',
        category: 'TIMEOUT',
        context: context,
        originalError: error,
      );
    }

    // Classification des erreurs d'autorisation
    if (isAuthorizationError(error)) {
      return AppError(
        message: 'Accès non autorisé',
        category: 'AUTHORIZATION',
        context: context,
        originalError: error,
      );
    }

    return null; // Aucune classification personnalisée trouvée
  }

  /// Vérifie si l'erreur est liée au réseau
  bool isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') || 
           errorString.contains('connection') ||
           errorString.contains('socket') ||
           errorString.contains('http');
  }

  /// Vérifie si l'erreur est liée à un timeout
  bool isTimeoutError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('timeout') || 
           errorString.contains('deadline') ||
           errorString.contains('expired');
  }

  /// Vérifie si l'erreur est liée aux autorisations
  bool isAuthorizationError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('unauthorized') || 
           errorString.contains('forbidden') ||
           errorString.contains('access denied') ||
           errorString.contains('permission');
  }

  @override
  bool isStorageError(dynamic error) {
    // Extension de la logique de base
    final baseResult = super.isStorageError(error);
    if (baseResult) return true;

    // Logique supplémentaire pour d'autres types de stockage
    final errorString = error.toString().toLowerCase();
    return errorString.contains('sqlite') || 
           errorString.contains('preferences') ||
           errorString.contains('file not found');
  }
}