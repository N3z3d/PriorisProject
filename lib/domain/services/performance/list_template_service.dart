import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

/// Données pour créer un élément de liste
class TemplateItem {
  final String title;
  final String description;
  final String category;
  final double eloScore;

  const TemplateItem({
    required this.title,
    required this.description,
    required this.category,
    required this.eloScore,
  });
}

/// Définition d'un template de liste
class ListTemplate {
  final String id;
  final String name;
  final ListType type;
  final String description;
  final List<TemplateItem> items;

  const ListTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.items,
  });
}

class ListTemplateService {
  /// Templates prédéfinis pour tous les types de listes
  static const Map<String, ListTemplate> _templates = {
    'shopping': ListTemplate(
      id: 'shopping_template',
      name: 'Courses - Modèle',
      type: ListType.SHOPPING,
      description: 'Liste de courses avec articles essentiels',
      items: _shoppingItems,
    ),
    'housework': ListTemplate(
      id: 'housework_template',
      name: 'Tâches ménagères - Modèle',
      type: ListType.CUSTOM,
      description: 'Tâches ménagères hebdomadaires',
      items: _houseworkItems,
    ),
    'travel': ListTemplate(
      id: 'travel_template',
      name: 'Voyage - Modèle',
      type: ListType.TRAVEL,
      description: 'Préparatifs de voyage',
      items: _travelItems,
    ),
    'event': ListTemplate(
      id: 'event_template',
      name: 'Événement - Modèle',
      type: ListType.CUSTOM,
      description: 'Organisation d\'événement',
      items: _eventItems,
    ),
    'movies': ListTemplate(
      id: 'movies_template',
      name: 'Films & Séries - Modèle',
      type: ListType.MOVIES,
      description: 'Films et séries à regarder',
      items: _moviesItems,
    ),
    'books': ListTemplate(
      id: 'books_template',
      name: 'Livres - Modèle',
      type: ListType.BOOKS,
      description: 'Livres à lire',
      items: _booksItems,
    ),
    'restaurants': ListTemplate(
      id: 'restaurants_template',
      name: 'Restaurants - Modèle',
      type: ListType.RESTAURANTS,
      description: 'Restaurants à essayer',
      items: _restaurantsItems,
    ),
    'projects': ListTemplate(
      id: 'project_template',
      name: 'Projet - Modèle',
      type: ListType.PROJECTS,
      description: 'Gestion de projet',
      items: _projectsItems,
    ),
  };

  // === Méthodes publiques ===

  /// Crée une liste à partir d'un template
  CustomList createFromTemplate(String templateKey) {
    final template = _templates[templateKey];
    if (template == null) {
      throw ArgumentError('Template non trouvé: $templateKey');
    }
    return _buildCustomList(template);
  }

  /// Retourne tous les templates disponibles
  List<CustomList> getAllTemplates() {
    return _templates.values.map(_buildCustomList).toList();
  }

  /// Obtient des templates selon la catégorie (pour compatibilité avec les tests)
  Future<List<TemplateItem>> getTemplatesForCategory(String category) async {
    switch (category.toLowerCase()) {
      case 'courses':
      case 'shopping':
        return _shoppingItems;
      case 'travail':
      case 'work':
        return _workItems;
      case 'personnel':
      case 'personal':
        return _personalItems;
      default:
        return _shoppingItems;
    }
  }

  /// Méthodes spécifiques pour compatibilité (délèguent vers createFromTemplate)
  CustomList createShoppingListTemplate() => createFromTemplate('shopping');
  CustomList createHouseworkListTemplate() => createFromTemplate('housework');
  CustomList createTravelListTemplate() => createFromTemplate('travel');
  CustomList createEventListTemplate() => createFromTemplate('event');
  CustomList createMoviesListTemplate() => createFromTemplate('movies');
  CustomList createBooksListTemplate() => createFromTemplate('books');
  CustomList createRestaurantsListTemplate() => createFromTemplate('restaurants');
  CustomList createProjectListTemplate() => createFromTemplate('projects');

  // === Méthodes privées ===

  /// Construit une CustomList à partir d'un template
  CustomList _buildCustomList(ListTemplate template) {
    return CustomList(
      id: template.id,
      name: template.name,
      type: template.type,
      description: template.description,
      items: _buildListItems(template.items, template.id),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Convertit les TemplateItems en ListItems
  List<ListItem> _buildListItems(List<TemplateItem> templateItems, String templateId) {
    return templateItems.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final item = entry.value;
      return ListItem(
        id: '${templateId}_$index',
        title: item.title,
        description: item.description,
        category: item.category,
        eloScore: item.eloScore,
        isCompleted: false,
        createdAt: DateTime.now(),
        listId: templateId,
      );
    }).toList();
  }

  // === Données des templates (MISES À JOUR avec exemples universels) ===

  /// Templates de travail professionnel
  static const List<TemplateItem> _workItems = [
    TemplateItem(title: 'Terminer rapport projet', description: 'Finaliser le rapport mensuel', category: 'Travail', eloScore: 1600.0),
    TemplateItem(title: 'Préparer présentation client', description: 'Slides pour la réunion de demain', category: 'Travail', eloScore: 1550.0),
    TemplateItem(title: 'Réviser documentation technique', description: 'Mise à jour des spécifications', category: 'Travail', eloScore: 1500.0),
    TemplateItem(title: 'Planifier réunion équipe', description: 'Organiser la réunion hebdomadaire', category: 'Travail', eloScore: 1450.0),
    TemplateItem(title: 'Répondre aux emails urgents', description: 'Traiter les messages prioritaires', category: 'Travail', eloScore: 1400.0),
  ];

  /// Templates personnels
  static const List<TemplateItem> _personalItems = [
    TemplateItem(title: 'Organiser rendez-vous médical', description: 'Prendre RDV chez le médecin', category: 'Personnel', eloScore: 1500.0),
    TemplateItem(title: 'Planifier vacances été', description: 'Rechercher destinations et réserver', category: 'Personnel', eloScore: 1450.0),
    TemplateItem(title: 'Réviser budget mensuel', description: 'Analyser les dépenses du mois', category: 'Personnel', eloScore: 1400.0),
    TemplateItem(title: 'Organiser soirée entre amis', description: 'Planifier la soirée du weekend', category: 'Personnel', eloScore: 1350.0),
    TemplateItem(title: 'Nettoyer et ranger maison', description: 'Grand ménage hebdomadaire', category: 'Personnel', eloScore: 1300.0),
  ];

  static const List<TemplateItem> _shoppingItems = [
    TemplateItem(title: 'Produits d\'épicerie', description: 'Articles de première nécessité', category: 'Courses', eloScore: 1500.0),
    TemplateItem(title: 'Fournitures bureau', description: 'Matériel de travail et papeterie', category: 'Courses', eloScore: 1450.0),
    TemplateItem(title: 'Articles ménagers', description: 'Produits d\'entretien et nettoyage', category: 'Courses', eloScore: 1400.0),
    TemplateItem(title: 'Équipement informatique', description: 'Accessoires et composants tech', category: 'Courses', eloScore: 1350.0),
    TemplateItem(title: 'Vêtements saison', description: 'Habits adaptés à la météo', category: 'Courses', eloScore: 1300.0),
    TemplateItem(title: 'Articles de sport', description: 'Équipement pour activités physiques', category: 'Courses', eloScore: 1250.0),
    TemplateItem(title: 'Cadeaux et occasions', description: 'Présents pour anniversaires et fêtes', category: 'Courses', eloScore: 1200.0),
  ];

  static const List<TemplateItem> _houseworkItems = [
    TemplateItem(title: 'Passer l\'aspirateur', description: 'Aspirer toutes les pièces principales', category: 'Nettoyage sols', eloScore: 1500.0),
    TemplateItem(title: 'Nettoyer la salle de bain', description: 'Douche, lavabo, WC, sol', category: 'Salle de bain', eloScore: 1500.0),
    TemplateItem(title: 'Faire les courses', description: 'Acheter les produits de première nécessité', category: 'Approvisionnement', eloScore: 1400.0),
    TemplateItem(title: 'Laver les vitres', description: 'Nettoyer les fenêtres intérieures', category: 'Nettoyage', eloScore: 1100.0),
    TemplateItem(title: 'Ranger les placards', description: 'Organiser et trier les affaires', category: 'Organisation', eloScore: 1100.0),
  ];

  static const List<TemplateItem> _travelItems = [
    TemplateItem(title: 'Réserver l\'hébergement', description: 'Hôtel, AirBnB ou autre logement', category: 'Réservations', eloScore: 1500.0),
    TemplateItem(title: 'Réserver les transports', description: 'Avion, train, voiture de location', category: 'Transports', eloScore: 1500.0),
    TemplateItem(title: 'Préparer les documents', description: 'Passeport, visa, assurance voyage', category: 'Documents', eloScore: 1500.0),
    TemplateItem(title: 'Faire la valise', description: 'Vêtements et affaires personnelles', category: 'Préparation', eloScore: 1300.0),
    TemplateItem(title: 'Rechercher les activités', description: 'Visites, restaurants, attractions', category: 'Planification', eloScore: 1200.0),
  ];

  static const List<TemplateItem> _eventItems = [
    TemplateItem(title: 'Définir le budget', description: 'Établir l\'enveloppe financière', category: 'Budget', eloScore: 1500.0),
    TemplateItem(title: 'Choisir le lieu', description: 'Réserver la salle ou l\'espace', category: 'Lieu', eloScore: 1500.0),
    TemplateItem(title: 'Établir la liste d\'invités', description: 'Définir le nombre de participants', category: 'Invités', eloScore: 1400.0),
    TemplateItem(title: 'Planifier le menu', description: 'Nourriture et boissons', category: 'Restauration', eloScore: 1300.0),
    TemplateItem(title: 'Préparer les animations', description: 'Musique, jeux, activités', category: 'Animation', eloScore: 1200.0),
  ];

  static const List<TemplateItem> _moviesItems = [
    TemplateItem(title: 'Films récents populaires', description: 'Dernières sorties au cinéma', category: 'Cinéma', eloScore: 1300.0),
    TemplateItem(title: 'Classiques à voir', description: 'Films cultes et incontournables', category: 'Classiques', eloScore: 1300.0),
    TemplateItem(title: 'Séries TV', description: 'Séries à binge-watcher', category: 'Séries', eloScore: 1300.0),
    TemplateItem(title: 'Documentaires', description: 'Documentaires intéressants', category: 'Documentaires', eloScore: 1100.0),
    TemplateItem(title: 'Films d\'auteur', description: 'Cinéma d\'art et d\'essai', category: 'Art et Essai', eloScore: 1100.0),
  ];

  static const List<TemplateItem> _booksItems = [
    TemplateItem(title: 'Romans contemporains', description: 'Derniers romans populaires', category: 'Romans', eloScore: 1300.0),
    TemplateItem(title: 'Livres de développement personnel', description: 'Amélioration de soi et motivation', category: 'Développement Personnel', eloScore: 1300.0),
    TemplateItem(title: 'Livres techniques', description: 'Programmation, science, technologie', category: 'Technique', eloScore: 1300.0),
    TemplateItem(title: 'Classiques de la littérature', description: 'Oeuvres littéraires majeures', category: 'Classiques', eloScore: 1100.0),
    TemplateItem(title: 'Livres de cuisine', description: 'Recettes et techniques culinaires', category: 'Cuisine', eloScore: 1100.0),
  ];

  static const List<TemplateItem> _restaurantsItems = [
    TemplateItem(title: 'Restaurants gastronomiques', description: 'Haute cuisine et expériences culinaires', category: 'Gastronomique', eloScore: 1300.0),
    TemplateItem(title: 'Cuisines du monde', description: 'Restaurants internationaux', category: 'International', eloScore: 1300.0),
    TemplateItem(title: 'Restaurants végétariens', description: 'Cuisine végétarienne et végane', category: 'Végétarien', eloScore: 1300.0),
    TemplateItem(title: 'Brasseries et bistrots', description: 'Cuisine traditionnelle française', category: 'Traditionnel', eloScore: 1300.0),
    TemplateItem(title: 'Concept culinaires originaux', description: 'Cuisine créative et concepts innovants', category: 'Créatif', eloScore: 1100.0),
  ];

  static const List<TemplateItem> _projectsItems = [
    TemplateItem(title: 'Définir les objectifs', description: 'Clarifier les buts et résultats attendus', category: 'Planification', eloScore: 1500.0),
    TemplateItem(title: 'Créer le planning', description: 'Établir le calendrier et les échéances', category: 'Planification', eloScore: 1500.0),
    TemplateItem(title: 'Identifier les ressources', description: 'Matériel, budget, compétences nécessaires', category: 'Ressources', eloScore: 1500.0),
    TemplateItem(title: 'Décomposer les tâches', description: 'Diviser le projet en sous-tâches', category: 'Organisation', eloScore: 1400.0),
    TemplateItem(title: 'Suivre l\'avancement', description: 'Monitoring et contrôle qualité', category: 'Suivi', eloScore: 1300.0),
  ];
}