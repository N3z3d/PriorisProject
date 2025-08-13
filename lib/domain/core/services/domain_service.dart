/// Interface de base pour tous les services du domaine
/// 
/// Les services du domaine encapsulent la logique métier qui ne rentre pas
/// naturellement dans les agrégats ou les value objects.
abstract class DomainService {
  /// Nom du service pour l'identification et le logging
  String get serviceName;

  /// Version du service pour la compatibilité
  String get version => '1.0.0';

  /// Valide les préconditions du service
  void validatePreconditions() {
    // Implémentation par défaut vide
    // Les services peuvent override cette méthode si nécessaire
  }

  /// Méthode template pour les opérations du service
  /// 1. Valide les préconditions
  /// 2. Exécute l'opération
  /// 3. Valide les postconditions si nécessaire
  T executeOperation<T>(T Function() operation) {
    validatePreconditions();
    return operation();
  }
}

/// Service de base avec logging intégré
abstract class LoggableDomainService extends DomainService {
  final List<String> _logs = [];

  /// Logs des opérations du service
  List<String> get logs => List.unmodifiable(_logs);

  /// Ajoute un log
  void log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    _logs.add('[$timestamp] [$serviceName] $message');
  }

  /// Nettoie les logs
  void clearLogs() {
    _logs.clear();
  }

  @override
  T executeOperation<T>(T Function() operation) {
    log('Début de l\'opération');
    validatePreconditions();
    
    try {
      final result = operation();
      log('Opération réussie');
      return result;
    } catch (e) {
      log('Erreur lors de l\'opération: $e');
      rethrow;
    }
  }
}