// Définition des Bounded Contexts de l'application Prioris
// 
// Un Bounded Context est une frontière explicite dans laquelle
// un modèle de domaine particulier est défini et applicable.

/// Interface de base pour tous les bounded contexts
abstract class BoundedContext {
  /// Nom unique du context
  String get contextName;
  
  /// Description du contexte métier
  String get description;
  
  /// Version du contexte pour la compatibilité
  String get version;
  
  /// Liste des agrégats gérés par ce contexte
  List<String> get aggregateRoots;
  
  /// Liste des événements de domaine produits
  List<String> get domainEvents;
  
  /// Liste des services du domaine
  List<String> get domainServices;
  
  /// Contextes avec lesquels ce contexte collabore
  Map<String, CollaborationType> get collaborations;
}

/// Types de collaboration entre contextes
enum CollaborationType {
  /// Le contexte amont fournit des données au contexte aval
  upstreamDownstream,
  
  /// Les contextes partagent des concepts communs
  sharedKernel,
  
  /// Les contextes sont partenaires égaux
  partnership,
  
  /// Le contexte suit un autre contexte
  conformist,
  
  /// Le contexte traduit les concepts d'un autre contexte
  anticorruptionLayer,
}

/// Bounded Context pour la gestion des tâches
class TaskManagementContext extends BoundedContext {
  @override
  String get contextName => 'TaskManagement';

  @override
  String get description => 'Gestion des tâches, priorisation, système ELO et duels';

  @override
  String get version => '1.0.0';

  @override
  List<String> get aggregateRoots => ['TaskAggregate'];

  @override
  List<String> get domainEvents => [
    'TaskCreatedEvent',
    'TaskCompletedEvent',
    'TaskEloUpdatedEvent',
    'TaskDuelCompletedEvent',
    'TaskModifiedEvent',
    'TaskDeletedEvent',
    'TaskOverdueEvent',
  ];

  @override
  List<String> get domainServices => [
    'TaskEloService',
  ];

  @override
  Map<String, CollaborationType> get collaborations => {
    'HabitTracking': CollaborationType.partnership,
    'ListManagement': CollaborationType.partnership,
    'Analytics': CollaborationType.upstreamDownstream,
  };
}

/// Bounded Context pour le suivi des habitudes
class HabitTrackingContext extends BoundedContext {
  @override
  String get contextName => 'HabitTracking';

  @override
  String get description => 'Suivi des habitudes, séries, analyse de performance et prédictions';

  @override
  String get version => '1.0.0';

  @override
  List<String> get aggregateRoots => ['HabitAggregate'];

  @override
  List<String> get domainEvents => [
    'HabitCreatedEvent',
    'HabitCompletedEvent',
    'HabitStreakMilestoneEvent',
    'HabitStreakBrokenEvent',
    'HabitModifiedEvent',
    'HabitDeletedEvent',
    'HabitTargetReachedEvent',
    'HabitReminderEvent',
  ];

  @override
  List<String> get domainServices => [
    'HabitAnalyticsService',
  ];

  @override
  Map<String, CollaborationType> get collaborations => {
    'TaskManagement': CollaborationType.partnership,
    'ListManagement': CollaborationType.partnership,
    'Analytics': CollaborationType.upstreamDownstream,
    'Notifications': CollaborationType.upstreamDownstream,
  };
}

/// Bounded Context pour la gestion des listes
class ListManagementContext extends BoundedContext {
  @override
  String get contextName => 'ListManagement';

  @override
  String get description => 'Gestion des listes personnalisées, organisation et optimisation';

  @override
  String get version => '1.0.0';

  @override
  List<String> get aggregateRoots => ['CustomListAggregate'];

  @override
  List<String> get domainEvents => [
    'ListCreatedEvent',
    'ListItemAddedEvent',
    'ListItemCompletedEvent',
    'ListCompletedEvent',
    'ListModifiedEvent',
    'ListItemRemovedEvent',
    'ListDeletedEvent',
    'ListProgressMilestoneEvent',
    'ListItemDuelEvent',
    'ListReorganizedEvent',
  ];

  @override
  List<String> get domainServices => [
    'ListOptimizationService',
  ];

  @override
  Map<String, CollaborationType> get collaborations => {
    'TaskManagement': CollaborationType.partnership,
    'HabitTracking': CollaborationType.partnership,
    'Analytics': CollaborationType.upstreamDownstream,
  };
}

/// Bounded Context pour les analyses et statistiques
class AnalyticsContext extends BoundedContext {
  @override
  String get contextName => 'Analytics';

  @override
  String get description => 'Analyses, statistiques, rapports et insights de performance';

  @override
  String get version => '1.0.0';

  @override
  List<String> get aggregateRoots => ['AnalyticsReportAggregate'];

  @override
  List<String> get domainEvents => [
    'ReportGeneratedEvent',
    'InsightDiscoveredEvent',
    'TrendDetectedEvent',
    'PerformanceAlertEvent',
  ];

  @override
  List<String> get domainServices => [
    'StatisticsCalculationService',
    'InsightGenerationService',
    'TrendAnalysisService',
  ];

  @override
  Map<String, CollaborationType> get collaborations => {
    'TaskManagement': CollaborationType.conformist,
    'HabitTracking': CollaborationType.conformist,
    'ListManagement': CollaborationType.conformist,
    'Notifications': CollaborationType.upstreamDownstream,
  };
}

/// Bounded Context pour les notifications et rappels
class NotificationContext extends BoundedContext {
  @override
  String get contextName => 'Notifications';

  @override
  String get description => 'Système de notifications, rappels et alertes';

  @override
  String get version => '1.0.0';

  @override
  List<String> get aggregateRoots => ['NotificationAggregate'];

  @override
  List<String> get domainEvents => [
    'NotificationCreatedEvent',
    'NotificationSentEvent',
    'NotificationReadEvent',
    'ReminderScheduledEvent',
  ];

  @override
  List<String> get domainServices => [
    'NotificationSchedulingService',
    'ReminderService',
  ];

  @override
  Map<String, CollaborationType> get collaborations => {
    'HabitTracking': CollaborationType.conformist,
    'Analytics': CollaborationType.conformist,
    'UserPreferences': CollaborationType.partnership,
  };
}

/// Bounded Context pour les préférences utilisateur
class UserPreferencesContext extends BoundedContext {
  @override
  String get contextName => 'UserPreferences';

  @override
  String get description => 'Gestion des préférences, paramètres et personnalisation';

  @override
  String get version => '1.0.0';

  @override
  List<String> get aggregateRoots => ['UserPreferencesAggregate'];

  @override
  List<String> get domainEvents => [
    'PreferencesUpdatedEvent',
    'ThemeChangedEvent',
    'LanguageChangedEvent',
    'NotificationSettingsChangedEvent',
  ];

  @override
  List<String> get domainServices => [
    'PersonalizationService',
  ];

  @override
  Map<String, CollaborationType> get collaborations => {
    'Notifications': CollaborationType.partnership,
  };
}

/// Registre des bounded contexts
class BoundedContextRegistry {
  static final Map<String, BoundedContext> _contexts = {
    'TaskManagement': TaskManagementContext(),
    'HabitTracking': HabitTrackingContext(),
    'ListManagement': ListManagementContext(),
    'Analytics': AnalyticsContext(),
    'Notifications': NotificationContext(),
    'UserPreferences': UserPreferencesContext(),
  };

  /// Récupère un contexte par son nom
  static BoundedContext? getContext(String contextName) {
    return _contexts[contextName];
  }

  /// Liste tous les contextes
  static List<BoundedContext> getAllContexts() {
    return _contexts.values.toList();
  }

  /// Vérifie si deux contextes collaborent
  static bool areCollaborating(String context1, String context2) {
    final ctx1 = _contexts[context1];
    if (ctx1 == null) return false;
    
    return ctx1.collaborations.containsKey(context2);
  }

  /// Obtient le type de collaboration entre deux contextes
  static CollaborationType? getCollaborationType(String context1, String context2) {
    final ctx1 = _contexts[context1];
    if (ctx1 == null) return null;
    
    return ctx1.collaborations[context2];
  }

  /// Génère un rapport de la carte des contextes
  static ContextMap generateContextMap() {
    final relationships = <ContextRelationship>[];
    
    for (final context in _contexts.values) {
      for (final collaboration in context.collaborations.entries) {
        relationships.add(ContextRelationship(
          upstream: context.contextName,
          downstream: collaboration.key,
          type: collaboration.value,
        ));
      }
    }
    
    return ContextMap(
      contexts: _contexts.values.toList(),
      relationships: relationships,
    );
  }
}

/// Relation entre deux bounded contexts
class ContextRelationship {
  final String upstream;
  final String downstream;
  final CollaborationType type;

  const ContextRelationship({
    required this.upstream,
    required this.downstream,
    required this.type,
  });

  @override
  String toString() {
    return '$upstream --> $downstream ($type)';
  }
}

/// Carte complète des bounded contexts
class ContextMap {
  final List<BoundedContext> contexts;
  final List<ContextRelationship> relationships;

  const ContextMap({
    required this.contexts,
    required this.relationships,
  });

  /// Génère une représentation textuelle de la carte
  String generateDescription() {
    final buffer = StringBuffer();
    
    buffer.writeln('=== CARTE DES BOUNDED CONTEXTS ===\n');
    
    buffer.writeln('CONTEXTES (${contexts.length}):');
    for (final context in contexts) {
      buffer.writeln('• ${context.contextName}: ${context.description}');
      buffer.writeln('  Agrégats: ${context.aggregateRoots.join(", ")}');
      buffer.writeln('  Événements: ${context.domainEvents.length}');
      buffer.writeln('  Services: ${context.domainServices.length}');
      buffer.writeln();
    }
    
    buffer.writeln('RELATIONS (${relationships.length}):');
    for (final relationship in relationships) {
      buffer.writeln('• ${relationship.toString()}');
    }
    
    return buffer.toString();
  }

  /// Identifie les contextes centraux (avec le plus de collaborations)
  List<String> getCentralContexts() {
    final collaborationCounts = <String, int>{};
    
    for (final relationship in relationships) {
      collaborationCounts[relationship.upstream] = 
        (collaborationCounts[relationship.upstream] ?? 0) + 1;
      collaborationCounts[relationship.downstream] = 
        (collaborationCounts[relationship.downstream] ?? 0) + 1;
    }
    
    final sortedContexts = collaborationCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedContexts.take(3).map((entry) => entry.key).toList();
  }

  /// Identifie les contextes isolés (sans collaborations)
  List<String> getIsolatedContexts() {
    final collaboratingContexts = <String>{};
    
    for (final relationship in relationships) {
      collaboratingContexts.add(relationship.upstream);
      collaboratingContexts.add(relationship.downstream);
    }
    
    return contexts
        .where((context) => !collaboratingContexts.contains(context.contextName))
        .map((context) => context.contextName)
        .toList();
  }
}