import 'interfaces/error_handler_interface.dart';

/// Classe abstraite pour la classification d'erreurs
/// 
/// Respecte le principe Open/Closed en permettant l'extension
/// via l'héritage sans modification du code existant.
abstract class AbstractErrorClassifier implements ErrorClassifierInterface {
  
  /// Catégories d'erreurs communes
  static const String categoryValidation = 'VALIDATION';
  static const String categoryStorage = 'STORAGE';
  static const String categoryBusiness = 'BUSINESS';
  static const String categoryNetwork = 'NETWORK';
  static const String categoryUnknown = 'UNKNOWN';

  @override
  AppError classifyError(dynamic error, String? context) {
    if (error is AppError) {
      return error;
    }

    // Chaîne de responsabilité pour la classification
    final classifiedError = classifyArgumentError(error, context) ??
                           classifyStateError(error, context) ??
                           classifyFormatError(error, context) ??
                           classifyStorageError(error, context) ??
                           classifyCustomError(error, context) ??
                           createUnknownError(error, context);

    return classifiedError;
  }

  /// Classifie les erreurs d'argument
  /// 
  /// Peut être redéfinie dans les classes filles pour une logique spécifique.
  AppError? classifyArgumentError(dynamic error, String? context) {
    if (error is ArgumentError) {
      return AppError(
        message: error.message?.toString() ?? 'Argument invalide',
        category: categoryValidation,
        context: context,
        originalError: error,
      );
    }
    return null;
  }

  /// Classifie les erreurs d'état
  /// 
  /// Peut être redéfinie dans les classes filles pour une logique spécifique.
  AppError? classifyStateError(dynamic error, String? context) {
    if (error is StateError) {
      return AppError(
        message: 'État invalide: ${error.message}',
        category: categoryBusiness,
        context: context,
        originalError: error,
      );
    }
    return null;
  }

  /// Classifie les erreurs de format
  /// 
  /// Peut être redéfinie dans les classes filles pour une logique spécifique.
  AppError? classifyFormatError(dynamic error, String? context) {
    if (error is FormatException) {
      return AppError(
        message: 'Format de données invalide',
        category: categoryValidation,
        context: context,
        originalError: error,
      );
    }
    return null;
  }

  /// Classifie les erreurs de stockage
  /// 
  /// Peut être redéfinie dans les classes filles pour une logique spécifique.
  AppError? classifyStorageError(dynamic error, String? context) {
    if (isStorageError(error)) {
      return AppError(
        message: 'Erreur de stockage local',
        category: categoryStorage,
        context: context,
        originalError: error,
      );
    }
    return null;
  }

  /// Classifie les erreurs personnalisées
  /// 
  /// Méthode abstraite que les classes filles doivent implémenter
  /// pour ajouter leur propre logique de classification.
  AppError? classifyCustomError(dynamic error, String? context);

  /// Crée une erreur inconnue par défaut
  AppError createUnknownError(dynamic error, String? context) {
    return AppError(
      message: error.toString(),
      category: categoryUnknown,
      context: context,
      originalError: error,
    );
  }

  /// Vérifie si l'erreur est liée au stockage
  /// 
  /// Peut être redéfinie dans les classes filles pour une logique spécifique.
  bool isStorageError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('hive') || 
           errorString.contains('box') ||
           errorString.contains('storage') ||
           errorString.contains('database');
  }
}