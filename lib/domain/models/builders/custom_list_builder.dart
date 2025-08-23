import 'package:uuid/uuid.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

/// Builder Pattern pour la classe CustomList
/// Simplifie la création d'instances avec paramètres optionnels
class CustomListBuilder {
  String? _id;
  String? _name;
  ListType? _type;
  String? _description;
  List<ListItem>? _items;
  DateTime? _createdAt;
  DateTime? _updatedAt;

  /// Définir l'ID de la liste
  CustomListBuilder withId(String id) {
    _id = id;
    return this;
  }

  /// Définir le nom de la liste (requis)
  CustomListBuilder withName(String name) {
    _name = name;
    return this;
  }

  /// Définir le type de la liste (requis)
  CustomListBuilder withType(ListType type) {
    _type = type;
    return this;
  }

  /// Définir la description de la liste
  CustomListBuilder withDescription(String description) {
    _description = description;
    return this;
  }

  /// Définir les éléments de la liste
  CustomListBuilder withItems(List<ListItem> items) {
    _items = items;
    return this;
  }

  /// Ajouter un élément à la liste
  CustomListBuilder addItem(ListItem item) {
    _items ??= [];
    _items!.add(item);
    return this;
  }

  /// Définir la date de création
  CustomListBuilder withCreatedAt(DateTime createdAt) {
    _createdAt = createdAt;
    return this;
  }

  /// Définir la date de dernière modification
  CustomListBuilder withUpdatedAt(DateTime updatedAt) {
    _updatedAt = updatedAt;
    return this;
  }

  /// Méthodes de configuration pour les types de listes courants

  /// Créer une liste de voyages
  CustomListBuilder asTravelList(String name) {
    return withName(name).withType(ListType.TRAVEL);
  }

  /// Créer une liste de courses
  CustomListBuilder asShoppingList(String name) {
    return withName(name).withType(ListType.SHOPPING);
  }

  /// Créer une liste de films/séries
  CustomListBuilder asMoviesList(String name) {
    return withName(name).withType(ListType.MOVIES);
  }

  /// Créer une liste de livres
  CustomListBuilder asBooksList(String name) {
    return withName(name).withType(ListType.BOOKS);
  }

  /// Créer une liste de restaurants
  CustomListBuilder asRestaurantsList(String name) {
    return withName(name).withType(ListType.RESTAURANTS);
  }

  /// Créer une liste de projets
  CustomListBuilder asProjectsList(String name) {
    return withName(name).withType(ListType.PROJECTS);
  }

  /// Créer une liste personnalisée
  CustomListBuilder asCustomList(String name) {
    return withName(name).withType(ListType.CUSTOM);
  }

  /// Configurer une liste avec des éléments initiaux
  CustomListBuilder withInitialItems(List<ListItem> initialItems) {
    return withItems(initialItems);
  }

  /// Configurer une liste vide
  CustomListBuilder asEmptyList() {
    return withItems([]);
  }

  /// Configurer les dates automatiquement (création = maintenant, modification = maintenant)
  CustomListBuilder withAutoDates() {
    final now = DateTime.now();
    return withCreatedAt(now).withUpdatedAt(now);
  }

  /// Configurer une liste avec un ID généré automatiquement (UUID)
  CustomListBuilder withAutoId() {
    return withId(const Uuid().v4());
  }

  /// Construire l'instance CustomList
  /// Lance une exception si les paramètres requis ne sont pas définis
  CustomList build() {
    if (_id != null && _id!.isEmpty) {
      throw ArgumentError('L\'ID ne peut pas être vide');
    }
    if (_name == null || _name!.isEmpty) {
      throw ArgumentError('Le nom de la liste est requis');
    }
    if (_type == null) {
      throw ArgumentError('Le type de liste est requis');
    }

    final now = DateTime.now();
    DateTime createdAt = _createdAt ?? now;
    DateTime updatedAt = _updatedAt ?? now;
    
    // Vérifier la cohérence des dates si elles sont explicitement définies
    if (_createdAt != null && _updatedAt != null && updatedAt.isBefore(createdAt)) {
      throw ArgumentError('La date de mise à jour ne peut pas être antérieure à la date de création');
    }
    
    // Si seulement updatedAt est défini, utiliser cette date pour createdAt aussi
    if (_updatedAt != null && _createdAt == null) {
      createdAt = _updatedAt!;
    }

    return CustomList(
      id: _id ?? const Uuid().v4(),
      name: _name!,
      type: _type!,
      description: _description,
      items: _items ?? [],
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Créer une liste avec des paramètres minimaux
  /// Utilise des valeurs par défaut pour les paramètres optionnels
  static CustomListBuilder create(String name, ListType type) {
    return CustomListBuilder()
        .withName(name)
        .withType(type)
        .withAutoId()
        .withAutoDates();
  }

  /// Créer une liste de voyages avec des paramètres par défaut
  static CustomListBuilder createTravelList(String name) {
    return create(name, ListType.TRAVEL);
  }

  /// Créer une liste de courses avec des paramètres par défaut
  static CustomListBuilder createShoppingList(String name) {
    return create(name, ListType.SHOPPING);
  }

  /// Créer une liste de films avec des paramètres par défaut
  static CustomListBuilder createMoviesList(String name) {
    return create(name, ListType.MOVIES);
  }

  /// Créer une liste de livres avec des paramètres par défaut
  static CustomListBuilder createBooksList(String name) {
    return create(name, ListType.BOOKS);
  }

  /// Créer une liste de restaurants avec des paramètres par défaut
  static CustomListBuilder createRestaurantsList(String name) {
    return create(name, ListType.RESTAURANTS);
  }

  /// Créer une liste de projets avec des paramètres par défaut
  static CustomListBuilder createProjectsList(String name) {
    return create(name, ListType.PROJECTS);
  }

  /// Créer une liste personnalisée avec des paramètres par défaut
  static CustomListBuilder createCustomList(String name) {
    return create(name, ListType.CUSTOM);
  }
}
