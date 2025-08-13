/// Interface pour les opérations d'import de données
/// 
/// Respecte le principe Single Responsibility en se concentrant
/// uniquement sur l'import de données d'exemple.
abstract class DataImportInterface {
  /// Importe les données d'exemple
  Future<bool> importSampleData();
  
  /// Importe toutes les données d'exemple
  Future<void> importAllSampleData();
}

/// Interface pour la gestion des données existantes
/// 
/// Séparée de l'import selon le principe Interface Segregation.
abstract class DataManagementInterface {
  /// Efface toutes les données existantes
  Future<void> clearAllData();
  
  /// Réinitialise avec les données d'exemple
  Future<void> resetWithSampleData();
}

/// Interface pour les informations sur les données
/// 
/// Permet d'obtenir des informations sur l'état des données
/// sans coupler à l'implémentation du service.
abstract class DataInfoInterface {
  /// Vérifie si des données d'exemple sont déjà présentes
  Future<bool> hasSampleData();
  
  /// Obtient les statistiques des données d'exemple
  Map<String, int> getSampleDataStats();
}