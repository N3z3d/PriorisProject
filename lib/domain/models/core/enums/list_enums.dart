import 'package:hive/hive.dart';

part 'list_enums.g.dart';

/// Énumération des types de listes prédéfinis
@HiveType(typeId: 2)
enum ListType {
  /// Liste de voyages à faire
  @HiveField(0)
  TRAVEL,
  
  /// Liste de courses/achats
  @HiveField(1)
  SHOPPING,
  
  /// Liste de films/séries à regarder
  @HiveField(2)
  MOVIES,
  
  /// Liste de livres à lire
  @HiveField(3)
  BOOKS,
  
  /// Liste de restaurants à tester
  @HiveField(4)
  RESTAURANTS,
  
  /// Liste de projets personnels
  @HiveField(5)
  PROJECTS,

  /// Liste de taches quotidiennes
  @HiveField(6)
  TODO,

  /// Liste d'idees/inspirations
  @HiveField(7)
  IDEAS,
  
  /// Liste personnalisée
  @HiveField(8)
  CUSTOM,
}

/// Extension pour ajouter des méthodes utilitaires à ListType
extension ListTypeExtension on ListType {
  /// Retourne le nom affichable du type
  String get displayName {
    switch (this) {
      case ListType.TRAVEL:
        return 'Voyages';
      case ListType.SHOPPING:
        return 'Courses';
      case ListType.MOVIES:
        return 'Films & Séries';
      case ListType.BOOKS:
        return 'Livres';
      case ListType.RESTAURANTS:
        return 'Restaurants';
      case ListType.PROJECTS:
        return 'Projets';
      case ListType.TODO:
        return 'Tâches';
      case ListType.IDEAS:
        return 'Idées';
      case ListType.CUSTOM:
        return 'Personnalisée';
    }
  }

  /// Retourne l'icône associée au type
  String get iconName {
    switch (this) {
      case ListType.TRAVEL:
        return 'flight';
      case ListType.SHOPPING:
        return 'shopping_cart';
      case ListType.MOVIES:
        return 'movie';
      case ListType.BOOKS:
        return 'book';
      case ListType.RESTAURANTS:
        return 'restaurant';
      case ListType.PROJECTS:
        return 'work';
      case ListType.TODO:
        return 'check';
      case ListType.IDEAS:
        return 'lightbulb';
      case ListType.CUSTOM:
        return 'list';
    }
  }

  /// Retourne la couleur associée au type
  int get colorValue {
    switch (this) {
      case ListType.TRAVEL:
        return 0xFF2196F3; // Bleu
      case ListType.SHOPPING:
        return 0xFF4CAF50; // Vert
      case ListType.MOVIES:
        return 0xFF9C27B0; // Violet
      case ListType.BOOKS:
        return 0xFFFF9800; // Orange
      case ListType.RESTAURANTS:
        return 0xFFE91E63; // Rose
      case ListType.PROJECTS:
        return 0xFF607D8B; // Gris-bleu
      case ListType.TODO:
        return 0xFF3F51B5; // Indigo
      case ListType.IDEAS:
        return 0xFFFFC107; // Ambre
      case ListType.CUSTOM:
        return 0xFF795548; // Marron
    }
  }

  /// Retourne la description du type
  String get description {
    switch (this) {
      case ListType.TRAVEL:
        return 'Destinations à visiter et voyages à planifier';
      case ListType.SHOPPING:
        return 'Articles à acheter et courses à faire';
      case ListType.MOVIES:
        return 'Films et séries à regarder';
      case ListType.BOOKS:
        return 'Livres à lire et à découvrir';
      case ListType.RESTAURANTS:
        return 'Restaurants à tester et à recommander';
      case ListType.PROJECTS:
        return 'Projets personnels et professionnels';
      case ListType.TODO:
        return 'Tâches quotidiennes et priorités à suivre';
      case ListType.IDEAS:
        return 'Idées, inspirations et notes rapides';
      case ListType.CUSTOM:
        return 'Liste personnalisée selon vos besoins';
    }
  }
}

/// Constantes pour les listes personnalisées
class ListConstants {
  /// Nombre maximum d'éléments par liste
  static const int maxItemsPerList = 100;
  
  /// Nombre maximum de tags par élément
  static const int maxTagsPerItem = 10;
  
  /// Longueur maximale du titre d'une liste
  static const int maxListTitleLength = 100;
  
  /// Longueur maximale de la description d'une liste
  static const int maxListDescriptionLength = 500;
  
  /// Longueur maximale du titre d'un élément
  static const int maxItemTitleLength = 200;
  
  /// Longueur maximale de la description d'un élément
  static const int maxItemDescriptionLength = 1000;
  
  /// Longueur maximale du nom d'une catégorie
  static const int maxCategoryLength = 50;
  
  /// Longueur maximale d'un tag
  static const int maxTagLength = 30;
  
  /// Tags prédéfinis populaires
  static const List<String> predefinedTags = [
    'important',
    'urgent',
    'fun',
    'work',
    'personal',
    'health',
    'finance',
    'education',
    'entertainment',
    'family',
  ];
  
  /// Catégories prédéfinies populaires
  static const List<String> predefinedCategories = [
    'Travail',
    'Personnel',
    'Santé',
    'Finance',
    'Éducation',
    'Loisirs',
    'Famille',
    'Voyage',
    'Maison',
    'Technologie',
  ];
} 
