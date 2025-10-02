import '../../../value_objects/list_item.dart';

/// Interface définissant le contrat pour les stratégies d'optimisation de liste
///
/// SOLID COMPLIANCE:
/// - SRP: Interface unique avec une seule responsabilité (optimiser)
/// - OCP: Ouverte à l'extension (nouvelles stratégies), fermée à la modification
/// - DIP: Abstraction permettant l'injection de dépendances
abstract class OptimizationStrategy {
  /// Nom unique de la stratégie
  String get name;

  /// Description de la stratégie
  String get description;

  /// Optimise l'ordre des éléments selon la stratégie spécifique
  ///
  /// Retourne une nouvelle liste ordonnée (immuable)
  List<ListItem> optimize(List<ListItem> items);

  /// Calcule le score d'amélioration par rapport à l'ordre original
  ///
  /// Retourne une valeur entre 0.0 (aucune amélioration) et 1.0 (amélioration max)
  double calculateImprovement(List<ListItem> original, List<ListItem> optimized);

  /// Génère une explication textuelle du raisonnement de la stratégie
  String generateReasoning(List<ListItem> original, List<ListItem> optimized);
}
