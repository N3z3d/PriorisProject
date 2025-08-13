# Architecture Domain-Driven Design (DDD) - Prioris

## Vue d'ensemble

L'application Prioris a été transformée pour implémenter une architecture Domain-Driven Design complète et robuste. Cette architecture sépare clairement les préoccupations métier des détails techniques et garantit une maintenabilité et évolutivité optimales.

## Structure de l'Architecture

```
lib/
├── domain/                     # Couche Domaine (Logique métier pure)
│   ├── core/                   # Concepts partagés
│   │   ├── value_objects/      # Value Objects du domaine
│   │   ├── aggregates/         # Interface AggregateRoot
│   │   ├── events/             # Événements du domaine
│   │   ├── specifications/     # Pattern Specification
│   │   ├── services/           # Services du domaine
│   │   ├── interfaces/         # Interfaces des repositories
│   │   └── exceptions/         # Exceptions du domaine
│   ├── task/                   # Bounded Context Task Management
│   ├── habit/                  # Bounded Context Habit Tracking  
│   ├── list/                   # Bounded Context List Management
│   └── bounded_context.dart    # Définition des contextes métier
├── application/                # Couche Application (Cas d'usage)
│   ├── services/               # Services d'application
│   └── use_cases/              # Cas d'usage métier
└── infrastructure/             # Couche Infrastructure (Détails techniques)
    ├── persistence/            # Implémentations des repositories
    └── external_services/      # Services externes
```

## Concepts DDD Implémentés

### 1. Value Objects

**Fichiers principaux :**
- `C:\Users\Thibaut\Desktop\PriorisProject\lib\domain\core\value_objects\elo_score.dart`
- `C:\Users\Thibaut\Desktop\PriorisProject\lib\domain\core\value_objects\priority.dart`
- `C:\Users\Thibaut\Desktop\PriorisProject\lib\domain\core\value_objects\progress.dart`
- `C:\Users\Thibaut\Desktop\PriorisProject\lib\domain\core\value_objects\date_range.dart`

**Caractéristiques :**
- **EloScore** : Système de notation pour prioriser les tâches
- **Priority** : Calcul intelligent des priorités basé sur l'ELO et l'urgence
- **Progress** : Suivi uniforme de la progression
- **DateRange** : Gestion des plages temporelles

### 2. Aggregates & Aggregate Roots

**Fichiers principaux :**
- `C:\Users\Thibaut\Desktop\PriorisProject\lib\domain\task\aggregates\task_aggregate.dart`
- `C:\Users\Thibaut\Desktop\PriorisProject\lib\domain\habit\aggregates\habit_aggregate.dart`
- `C:\Users\Thibaut\Desktop\PriorisProject\lib\domain\list\aggregates\custom_list_aggregate.dart`

**Invariants garantis :**
- **TaskAggregate** : Cohérence du système ELO et des états de complétion
- **HabitAggregate** : Validité des séries et des objectifs quantitatifs
- **CustomListAggregate** : Unicité des éléments et cohérence des progressions

### 3. Domain Events

**Événements implémentés :**

**Tasks :**
- TaskCreatedEvent, TaskCompletedEvent, TaskEloUpdatedEvent
- TaskDuelCompletedEvent, TaskOverdueEvent, TaskDeletedEvent

**Habits :**
- HabitCreatedEvent, HabitCompletedEvent, HabitStreakMilestoneEvent
- HabitStreakBrokenEvent, HabitTargetReachedEvent, HabitReminderEvent

**Lists :**
- ListCreatedEvent, ListItemAddedEvent, ListCompletedEvent
- ListProgressMilestoneEvent, ListReorganizedEvent

### 4. Specifications

**Fichiers principaux :**
- `C:\Users\Thibaut\Desktop\PriorisProject\lib\domain\task\specifications\task_specifications.dart`
- `C:\Users\Thibaut\Desktop\PriorisProject\lib\domain\habit\specifications\habit_specifications.dart`
- `C:\Users\Thibaut\Desktop\PriorisProject\lib\domain\list\specifications\list_specifications.dart`

**Capacités :**
- Filtrage avancé avec combinaisons logiques (AND, OR, NOT)
- Requêtes complexes réutilisables
- Validation métier encapsulée

### 5. Domain Services

**Services implémentés :**

**TaskEloService** : Gestion avancée du système ELO
- Duels automatiques entre tâches
- Calculs de probabilité de victoire
- Ajustements basés sur la performance
- Suggestions d'ELO initial intelligentes

**HabitAnalyticsService** : Analyses prédictives des habitudes
- Analyse de consistance et patterns temporels
- Prédictions de succès avec niveaux de confiance
- Recommandations personnalisées d'amélioration

**ListOptimizationService** : Optimisation des listes
- Réorganisation selon différents critères
- Équilibrage de difficulté optimale
- Suggestions d'éléments contextuelles

### 6. Repositories (Interfaces)

**Interfaces définies dans le domaine :**
- `TaskRepository` : Opérations spécialisées pour les tâches
- `HabitRepository` : Gestion des habitudes et analytics
- `CustomListRepository` : Manipulation avancée des listes

**Fonctionnalités :**
- Pagination, recherche et cache
- Requêtes métier spécialisées
- Extensions utilitaires pour cas d'usage complexes

### 7. Bounded Contexts

**Contextes définis :**

1. **TaskManagement** : Gestion des tâches, ELO, duels
2. **HabitTracking** : Suivi des habitudes, séries, analytics
3. **ListManagement** : Listes personnalisées, optimisation
4. **Analytics** : Statistiques, rapports, insights
5. **Notifications** : Rappels et alertes
6. **UserPreferences** : Paramètres utilisateur

**Collaborations :**
- Relations upstream/downstream définies
- Communication via événements du domaine
- Anti-corruption layers pour l'intégrité

### 8. Application Services

**Services d'orchestration :**
- `TaskApplicationService` : Cas d'usage des tâches
- `HabitApplicationService` : Cas d'usage des habitudes

**Patterns implémentés :**
- Command/Query Separation
- Validation centralisée
- Gestion d'erreurs uniforme
- Publication automatique d'événements

### 9. Event Bus

**Fonctionnalités :**
- Communication asynchrone entre bounded contexts
- Handlers d'événements typés
- Streams d'événements filtrables
- Gestion d'erreurs robuste

## Avantages de l'Architecture

### 1. Séparation des Préoccupations
- **Domaine** : Logique métier pure, sans dépendances techniques
- **Application** : Orchestration des cas d'usage
- **Infrastructure** : Détails techniques (base de données, API, etc.)

### 2. Testabilité
- Logique métier isolée et facilement testable
- Mocks simples pour les interfaces
- Tests unitaires du domaine sans infrastructure

### 3. Évolutivité
- Bounded contexts indépendants
- Ajout de nouvelles fonctionnalités sans impact sur l'existant
- Refactoring sécurisé grâce aux invariants

### 4. Expressivité
- Code qui reflète le langage métier
- Concepts du domaine explicites
- Règles métier centralisées

### 5. Performance
- Event sourcing pour l'audit
- Specifications optimisées
- Cache intelligent dans les repositories

## Utilisation

### Exemple : Créer une tâche

```dart
// Dans la couche présentation
final taskService = TaskApplicationService(taskRepo, eloService);

final command = CreateTaskCommand(
  title: 'Implémenter authentification',
  category: 'development',
  dueDate: DateTime.now().add(Duration(days: 7)),
);

final result = await taskService.createTask(command);
if (result.success) {
  print('Tâche créée: ${result.data.title}');
  print('ELO initial: ${result.data.eloScore.value}');
}
```

### Exemple : Recherche avec spécifications

```dart
// Trouver les tâches prioritaires
final spec = TaskSpecifications.incomplete()
  .and(TaskSpecifications.hasHighPriority())
  .and(TaskSpecifications.dueToday());

final tasks = await taskRepository.findBySpecification(spec);
```

### Exemple : Analytics d'habitude

```dart
final analytics = await habitAnalyticsService.predictSuccess(habit);
print('Probabilité de succès: ${(analytics.overallProbability * 100).toInt()}%');
print('Facteurs clés: ${analytics.keyFactors.join(', ')}');
```

## Migration et Compatibilité

L'architecture DDD a été conçue pour être compatible avec le code existant :

1. **Interfaces Legacy** : Conservées pour la transition graduelle
2. **Adaptateurs** : Conversion entre anciens et nouveaux modèles
3. **Migration Incrémentale** : Adoption progressive par fonctionnalité

## Prochaines Étapes

1. **Infrastructure** : Implémenter les repositories concrets
2. **Events Handlers** : Créer les gestionnaires d'événements
3. **Integration Tests** : Tests d'intégration de bout en bout
4. **Performance** : Optimisation des requêtes complexes
5. **Monitoring** : Métriques et observabilité

## Conclusion

Cette architecture DDD transforme Prioris en une application robuste, maintenable et évolutive. Elle respecte les meilleures pratiques du Domain-Driven Design tout en conservant la flexibilité nécessaire pour les futures évolutions métier.

Les concepts métier sont maintenant explicites, protégés par des invariants solides, et organisés en bounded contexts cohérents. Cette base solide permettra à l'équipe de développer rapidement de nouvelles fonctionnalités tout en maintenant la qualité du code.