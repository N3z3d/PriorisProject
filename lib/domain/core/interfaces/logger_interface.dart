/// Interface pour le service de logging dans le domaine
///
/// Respecte le principe DIP (Dependency Inversion Principle) en définissant
/// l'abstraction dans le domaine plutôt que de dépendre directement de
/// l'implémentation infrastructure.
abstract class ILogger {
  /// Enregistre un message de debug
  void debug(String message, {
    String? context,
    String? correlationId,
    dynamic data,
  });

  /// Enregistre un message d'information
  void info(String message, {
    String? context,
    String? correlationId,
    dynamic data,
  });

  /// Enregistre un avertissement
  void warning(String message, {
    String? context,
    String? correlationId,
    dynamic data,
  });

  /// Enregistre une erreur
  void error(String message, {
    String? context,
    String? correlationId,
    dynamic error,
    StackTrace? stackTrace,
  });

  /// Enregistre une erreur fatale
  void fatal(String message, {
    String? context,
    String? correlationId,
    dynamic error,
    StackTrace? stackTrace,
  });

  /// Enregistre des métriques de performance
  void performance(String operation, Duration duration, {
    String? context,
    String? correlationId,
    Map<String, dynamic>? metrics,
  });

  /// Enregistre une action utilisateur
  void userAction(String action, {
    String? context,
    String? correlationId,
    Map<String, dynamic>? properties,
  });
}