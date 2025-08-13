import '../events/domain_event.dart';

/// Interface de base pour tous les Aggregate Roots
/// 
/// Un Aggregate Root est l'entité racine d'un agrégat qui garantit
/// la cohérence des invariants métier et publie les événements du domaine.
abstract class AggregateRoot with EventPublisher {
  /// Identifiant unique de l'agrégat
  String get id;

  /// Version de l'agrégat pour la gestion de la concurrence optimiste
  int _version = 0;
  
  int get version => _version;

  /// Incrémente la version de l'agrégat
  void incrementVersion() {
    _version++;
  }

  /// Valide les invariants de l'agrégat
  /// Cette méthode doit être implémentée par chaque agrégat pour
  /// vérifier que l'état de l'agrégat est cohérent
  void validateInvariants();

  /// Méthode template pour les opérations sur l'agrégat
  /// 1. Valide les invariants avant l'opération
  /// 2. Exécute l'opération
  /// 3. Valide les invariants après l'opération
  /// 4. Publie les événements si nécessaire
  T executeOperation<T>(T Function() operation) {
    validateInvariants();
    final result = operation();
    validateInvariants();
    incrementVersion();
    return result;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AggregateRoot && 
           other.runtimeType == runtimeType && 
           other.id == id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);
}

/// Mixin pour les entités qui font partie d'un agrégat mais ne sont pas la racine
mixin Entity {
  /// Identifiant unique de l'entité
  String get id;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Entity && 
           other.runtimeType == runtimeType && 
           other.id == id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);
}