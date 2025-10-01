/// Export centralisé pour tous les modèles de données d'analytics
///
/// Ce fichier exporte tous les modèles de données utilisés par les services
/// d'analytics d'habitudes pour éviter la duplication de code.

// Export des modèles depuis les services spécialisés
// Note: Les modèles sont définis dans leurs services respectifs
// pour maintenir la cohésion et éviter les dépendances circulaires

// ConsistencyAnalyzer models
export '../consistency_analyzer.dart' show
  ConsistencyAnalysis,
  ConsistencyLevel,
  MomentumAnalysis,
  MomentumDirection;

// PatternAnalyzer models
export '../pattern_analyzer.dart' show
  PatternAnalysis,
  TrendDirection,
  DayOfWeekAnalysis;

// SuccessPredictor models
export '../success_predictor.dart' show
  SuccessPrediction,
  DayPrediction,
  PredictionFactors;

// RecommendationEngine models
export '../recommendation_engine.dart' show
  HabitRecommendation,
  RecommendationType,
  RecommendationPriority,
  RecommendationContext;