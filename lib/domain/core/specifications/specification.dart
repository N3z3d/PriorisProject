/// Interface de base pour les spécifications du domaine
/// 
/// Le pattern Specification permet d'encapsuler la logique métier
/// dans des objets réutilisables et combinables.
abstract class Specification<T> {
  /// Vérifie si l'entité satisfait la spécification
  bool isSatisfiedBy(T entity);

  /// Retourne une description de la spécification
  String get description;

  /// Combine cette spécification avec une autre en utilisant AND
  AndSpecification<T> and(Specification<T> other) {
    return AndSpecification(this, other);
  }

  /// Combine cette spécification avec une autre en utilisant OR
  OrSpecification<T> or(Specification<T> other) {
    return OrSpecification(this, other);
  }

  /// Retourne l'inverse de cette spécification
  NotSpecification<T> not() {
    return NotSpecification(this);
  }
}

/// Spécification composite utilisant l'opérateur AND
class AndSpecification<T> extends Specification<T> {
  final Specification<T> left;
  final Specification<T> right;

  AndSpecification(this.left, this.right);

  @override
  bool isSatisfiedBy(T entity) {
    return left.isSatisfiedBy(entity) && right.isSatisfiedBy(entity);
  }

  @override
  String get description => '(${left.description}) AND (${right.description})';
}

/// Spécification composite utilisant l'opérateur OR
class OrSpecification<T> extends Specification<T> {
  final Specification<T> left;
  final Specification<T> right;

  OrSpecification(this.left, this.right);

  @override
  bool isSatisfiedBy(T entity) {
    return left.isSatisfiedBy(entity) || right.isSatisfiedBy(entity);
  }

  @override
  String get description => '(${left.description}) OR (${right.description})';
}

/// Spécification utilisant l'opérateur NOT
class NotSpecification<T> extends Specification<T> {
  final Specification<T> specification;

  NotSpecification(this.specification);

  @override
  bool isSatisfiedBy(T entity) {
    return !specification.isSatisfiedBy(entity);
  }

  @override
  String get description => 'NOT (${specification.description})';
}

/// Classe utilitaire pour créer des spécifications
class Specifications {
  /// Crée une spécification qui est toujours vraie
  static Specification<T> alwaysTrue<T>() => _AlwaysTrueSpecification<T>();

  /// Crée une spécification qui est toujours fausse
  static Specification<T> alwaysFalse<T>() => _AlwaysFalseSpecification<T>();

  /// Crée une spécification à partir d'une fonction
  static Specification<T> fromPredicate<T>(
    bool Function(T entity) predicate,
    String description,
  ) {
    return _PredicateSpecification<T>(predicate, description);
  }
}

class _AlwaysTrueSpecification<T> extends Specification<T> {
  @override
  bool isSatisfiedBy(T entity) => true;

  @override
  String get description => 'Always True';
}

class _AlwaysFalseSpecification<T> extends Specification<T> {
  @override
  bool isSatisfiedBy(T entity) => false;

  @override
  String get description => 'Always False';
}

class _PredicateSpecification<T> extends Specification<T> {
  final bool Function(T entity) predicate;
  final String _description;

  _PredicateSpecification(this.predicate, this._description);

  @override
  bool isSatisfiedBy(T entity) => predicate(entity);

  @override
  String get description => _description;
}

/// Extension pour appliquer des spécifications à des listes
extension SpecificationList<T> on List<T> {
  /// Filtre la liste selon une spécification
  List<T> whereSpec(Specification<T> specification) {
    return where(specification.isSatisfiedBy).toList();
  }

  /// Vérifie si tous les éléments satisfont la spécification
  bool all(Specification<T> specification) {
    return every(specification.isSatisfiedBy);
  }

  /// Vérifie si au moins un élément satisfait la spécification
  bool anySpec(Specification<T> specification) {
    return any(specification.isSatisfiedBy);
  }

  /// Compte le nombre d'éléments qui satisfont la spécification
  int countWhereSpec(Specification<T> specification) {
    return where(specification.isSatisfiedBy).length;
  }

  /// Trouve le premier élément qui satisfait la spécification
  T? firstWhereOrNull(Specification<T> specification) {
    try {
      return firstWhere(specification.isSatisfiedBy);
    } catch (e) {
      return null;
    }
  }
}