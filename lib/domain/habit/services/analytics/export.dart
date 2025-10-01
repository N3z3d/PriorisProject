/// Export centralisé pour tous les services d'analytics d'habitudes
///
/// Ce fichier exporte tous les services spécialisés et modèles de données
/// pour faciliter l'importation dans les autres parties de l'application.
///
/// SOLID COMPLIANCE:
/// - ISP: Interface segregation avec exports modulaires
/// - DIP: Abstraction des services d'analytics

// Services spécialisés SOLID-compliant
export 'consistency_analyzer.dart';
export 'pattern_analyzer.dart';
export 'success_predictor.dart';
export 'recommendation_engine.dart';

// Modèles de données partagés
export 'models/export.dart';