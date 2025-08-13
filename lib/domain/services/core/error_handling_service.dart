import 'interfaces/error_handler_interface.dart';
import 'error_classification_service.dart';
import 'error_logger_service.dart';

/// Service centralisé de gestion des erreurs
/// 
/// Refactorisé pour respecter les principes SOLID :
/// - Single Responsibility : délègue la classification et le logging
/// - Dependency Inversion : dépend d'interfaces, pas d'implémentations
/// - Open/Closed : extensible via l'injection de dépendances
class ErrorHandlingService implements ErrorHandlerInterface {
  final ErrorClassifierInterface _classifier;
  final ErrorLoggerInterface _logger;

  ErrorHandlingService(this._classifier, this._logger);

  /// Factory constructor pour créer une instance avec les services par défaut
  factory ErrorHandlingService.defaultInstance() {
    return ErrorHandlingService(
      ErrorClassificationService(),
      ErrorLoggerService(),
    );
  }

  /// Catégories d'erreurs (pour compatibilité)
  static const String categoryValidation = 'VALIDATION';
  static const String categoryStorage = 'STORAGE';
  static const String categoryBusiness = 'BUSINESS';
  static const String categoryNetwork = 'NETWORK';
  static const String categoryUnknown = 'UNKNOWN';

  @override
  AppError handleError(dynamic error, {String? context, StackTrace? stackTrace}) {
    // Log l'erreur
    _logger.logError(error, context, stackTrace);

    // Classifier et retourner l'erreur appropriée
    return _classifier.classifyError(error, context);
  }


  @override
  AppError validationError(String message, {String? field}) {
    return AppError(
      message: message,
      category: categoryValidation,
      context: field != null ? 'Field: $field' : null,
    );
  }

  @override
  AppError businessError(String message, {String? operation}) {
    return AppError(
      message: message,
      category: categoryBusiness,
      context: operation,
    );
  }

  @override
  AppError storageError(String message, {String? operation}) {
    return AppError(
      message: message,
      category: categoryStorage,
      context: operation,
    );
  }
}

/// Service d'erreurs legacy (DEPRECATED)
/// 
/// Utilisez ErrorHandlingService à la place pour respecter les principes SOLID.
@Deprecated('Utilisez ErrorHandlingService à la place pour respecter les principes SOLID.')
class LegacyErrorHandlingService {
  static final LegacyErrorHandlingService _instance = LegacyErrorHandlingService._internal();
  factory LegacyErrorHandlingService() => _instance;
  LegacyErrorHandlingService._internal();

  AppError handleError(dynamic error, {String? context, StackTrace? stackTrace}) {
    return ErrorHandlingService.defaultInstance().handleError(error, context: context, stackTrace: stackTrace);
  }
}