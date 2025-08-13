import 'interfaces/error_handler_interface.dart';

/// Service responsable de la classification des erreurs
/// 
/// Respecte le principe Single Responsibility en se concentrant
/// uniquement sur la classification des types d'erreurs.
class ErrorClassificationService implements ErrorClassifierInterface {
  /// Catégories d'erreurs
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

    if (error is ArgumentError) {
      return AppError(
        message: error.message?.toString() ?? 'Argument invalide',
        category: categoryValidation,
        context: context,
        originalError: error,
      );
    }

    if (error is StateError) {
      return AppError(
        message: 'État invalide: ${error.message}',
        category: categoryBusiness,
        context: context,
        originalError: error,
      );
    }

    if (error is FormatException) {
      return AppError(
        message: 'Format de données invalide',
        category: categoryValidation,
        context: context,
        originalError: error,
      );
    }

    if (_isStorageError(error)) {
      return AppError(
        message: 'Erreur de stockage local',
        category: categoryStorage,
        context: context,
        originalError: error,
      );
    }

    // Erreur inconnue
    return AppError(
      message: error.toString(),
      category: categoryUnknown,
      context: context,
      originalError: error,
    );
  }

  /// Vérifie si l'erreur est liée au stockage
  bool _isStorageError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('hive') || 
           errorString.contains('box') ||
           errorString.contains('storage') ||
           errorString.contains('database');
  }
}