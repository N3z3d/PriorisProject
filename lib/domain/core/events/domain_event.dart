/// Interface de base pour tous les événements du domaine
/// 
/// Les événements de domaine permettent de découpler les différentes parties
/// du système et de maintenir la cohérence entre les agrégats.
abstract class DomainEvent {
  /// Identifiant unique de l'événement
  final String eventId;
  
  /// Timestamp de création de l'événement
  final DateTime occurredAt;
  
  /// Version de l'événement pour la compatibilité
  final int version;

  const DomainEvent({
    required this.eventId,
    required this.occurredAt,
    this.version = 1,
  });

  /// Nom de l'événement pour l'identification
  String get eventName;

  /// Données utiles de l'événement
  Map<String, dynamic> get payload;

  /// Métadonnées additionnelles
  Map<String, dynamic> get metadata => {
    'eventId': eventId,
    'eventName': eventName,
    'occurredAt': occurredAt.toIso8601String(),
    'version': version,
  };

  /// Sérialisation complète de l'événement
  Map<String, dynamic> toJson() => {
    ...metadata,
    'payload': payload,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DomainEvent && 
           other.eventId == eventId &&
           other.eventName == eventName;
  }

  @override
  int get hashCode => Object.hash(eventId, eventName);

  @override
  String toString() => '$eventName($eventId, $occurredAt)';
}

/// Mixin pour les agrégats qui peuvent publier des événements
mixin EventPublisher {
  final List<DomainEvent> _domainEvents = [];

  /// Liste des événements non publiés
  List<DomainEvent> get uncommittedEvents => List.unmodifiable(_domainEvents);
  List<DomainEvent> get domainEvents => List.unmodifiable(_domainEvents);

  /// Ajoute un événement à la liste des événements non publiés
  void addEvent(DomainEvent event) {
    _domainEvents.add(event);
  }

  /// Marque tous les événements comme publiés
  void markEventsAsCommitted() {
    _domainEvents.clear();
  }

  /// Vérifie s'il y a des événements non publiés
  bool get hasUncommittedEvents => _domainEvents.isNotEmpty;
}
