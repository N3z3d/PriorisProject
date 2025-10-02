import '../../../core/services/domain_service.dart';
import '../../aggregates/custom_list_aggregate.dart';
import '../../../models/core/enums/list_enums.dart';

/// Moteur de suggestions d'éléments
///
/// Génère des suggestions intelligentes d'éléments à ajouter à une liste
/// en fonction du type de liste, du contexte utilisateur et des éléments existants.
///
/// SOLID:
/// - SRP: Responsabilité unique de génération de suggestions
/// - OCP: Extensible via ajout de nouveaux types de suggestions
/// - DIP: Dépend de l'abstraction LoggableDomainService
class ItemSuggestionEngine extends LoggableDomainService {
  @override
  String get serviceName => 'ItemSuggestionEngine';

  /// Suggère des éléments à ajouter pour compléter une liste
  List<ItemSuggestion> suggestItems(
    CustomListAggregate list,
    ListContext context,
  ) {
    return executeOperation(() {
      log('Génération de suggestions pour ${list.name}');

      final suggestions = <ItemSuggestion>[];
      final existingCategories = list.getCategories();

      // Suggestions basées sur le type de liste
      switch (list.type) {
        case ListType.SHOPPING:
          suggestions.addAll(_generateShoppingSuggestions(list, existingCategories));
          break;
        case ListType.TODO:
          suggestions.addAll(_generateTodoSuggestions(list, context));
          break;
        case ListType.MOVIES:
          suggestions.addAll(_generateMovieSuggestions(list));
          break;
        case ListType.BOOKS:
          suggestions.addAll(_generateBookSuggestions(list));
          break;
        case ListType.GOALS:
          suggestions.addAll(_generateGoalSuggestions(list, context));
          break;
        default:
          suggestions.addAll(_generateGenericSuggestions(list, context));
      }

      // Filtrer et scorer les suggestions
      final scoredSuggestions = suggestions
          .map((suggestion) => _scoreSuggestion(suggestion, list, context))
          .where((suggestion) => suggestion.relevanceScore > 0.3)
          .toList()
        ..sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

      log('${scoredSuggestions.length} suggestions générées');

      return scoredSuggestions.take(10).toList(); // Limiter à 10 suggestions
    });
  }

  List<ItemSuggestion> _generateShoppingSuggestions(
      CustomListAggregate list, Set<String> categories) {
    return [
      ItemSuggestion('Fruits et légumes', 'Alimentation', 1100, 0.8,
          'Catégorie essentielle manquante'),
      ItemSuggestion('Produits laitiers', 'Alimentation', 1050, 0.7,
          'Compléter les produits de base'),
    ];
  }

  List<ItemSuggestion> _generateTodoSuggestions(
      CustomListAggregate list, ListContext context) {
    return [
      ItemSuggestion('Réviser les objectifs', 'Organisation', 1300, 0.6,
          'Améliorer la planification'),
    ];
  }

  List<ItemSuggestion> _generateMovieSuggestions(CustomListAggregate list) {
    return [
      ItemSuggestion('Film recommandé', 'Divertissement', 1200, 0.5,
          'Suggestion algorithmique'),
    ];
  }

  List<ItemSuggestion> _generateBookSuggestions(CustomListAggregate list) {
    return [
      ItemSuggestion('Livre de développement personnel', 'Lecture', 1250, 0.6,
          'Équilibre des genres'),
    ];
  }

  List<ItemSuggestion> _generateGoalSuggestions(
      CustomListAggregate list, ListContext context) {
    return [
      ItemSuggestion(
          'Objectif de santé', 'Santé', 1400, 0.7, 'Domaine de vie important'),
    ];
  }

  List<ItemSuggestion> _generateGenericSuggestions(
      CustomListAggregate list, ListContext context) {
    return [
      ItemSuggestion(
          'Élément suggéré', 'Général', 1200, 0.4, 'Suggestion générique'),
    ];
  }

  ItemSuggestion _scoreSuggestion(
      ItemSuggestion suggestion, CustomListAggregate list, ListContext context) {
    // Pour le moment, retourner la suggestion telle quelle
    // Une implémentation plus sophistiquée analyserait le contexte
    return suggestion;
  }
}

/// Suggestion d'élément à ajouter à une liste
class ItemSuggestion {
  final String name;
  final String category;
  final double suggestedElo;
  final double relevanceScore;
  final String reason;

  const ItemSuggestion(
    this.name,
    this.category,
    this.suggestedElo,
    this.relevanceScore,
    this.reason,
  );
}

/// Contexte pour la génération de suggestions
class ListContext {
  final String userPreferences;
  final DateTime timeOfDay;
  final Map<String, dynamic> environmentalFactors;

  const ListContext({
    required this.userPreferences,
    required this.timeOfDay,
    required this.environmentalFactors,
  });
}
