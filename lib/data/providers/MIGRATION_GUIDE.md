# Migration Guide - Providers Consolidés

## Vue d'ensemble

L'architecture des providers Riverpod pour les listes personnalisées a été **consolidée de 17 providers à 4 providers essentiels**, offrant de meilleures performances, une maintenance simplifiée et une API plus cohérente.

## Changements majeurs

### Avant (17 providers)
- `allCustomListsProvider` - Toutes les listes
- `customListsByTypeProvider` - Listes par type  
- `completedCustomListsProvider` - Listes complétées
- `incompleteCustomListsProvider` - Listes incomplètes
- `customListsSortedByProgressProvider` - Tri par progression
- `customListsSortedByDateProvider` - Tri par date
- `customListsSortedByUpdateProvider` - Tri par mise à jour
- `customListsSortedByItemCountProvider` - Tri par nombre d'items
- `customListsStatsProvider` - Statistiques globales
- `customListsStatsByTypeProvider` - Statistiques par type
- `customListsSearchProvider` - Recherche
- `customListsFilteredProvider` - Filtres avancés
- `customListsSortedProvider` - Tri personnalisé
- Et 4 autres providers utilitaires...

### Maintenant (4 providers)
- `consolidatedListsProvider` - Provider principal avec StateNotifier
- `processedListsProvider` - Listes filtrées/triées (le plus utilisé)
- `listsStatisticsProvider` - Toutes les statistiques (global + par type)
- `listsConfigProvider` - Configuration actuelle des filtres/tri

## Guide de migration

### 1. Remplacer les anciens providers

#### Ancien code :
```dart
// ❌ Ancien - multiple providers
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allLists = ref.watch(allCustomListsProvider);
    final travelLists = ref.watch(customListsByTypeProvider(ListType.TRAVEL));
    final stats = ref.watch(customListsStatsProvider);
    final searchResults = ref.watch(customListsSearchProvider("query"));
    
    return allLists.when(
      data: (lists) => ListView(...),
      loading: () => CircularProgressIndicator(),
      error: (e, s) => Text('Erreur: $e'),
    );
  }
}
```

#### Nouveau code :
```dart
// ✅ Nouveau - provider consolidé
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Charger les listes automatiquement
    ref.loadListsIfNeeded();
    
    final lists = ref.watch(processedListsProvider);
    final stats = ref.watch(listsStatisticsProvider);
    final state = ref.watch(consolidatedListsProvider);
    
    if (state.isLoading) return CircularProgressIndicator();
    if (state.error != null) return Text('Erreur: ${state.error}');
    
    return ListView.builder(
      itemCount: lists.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(lists[index].name),
        subtitle: Text('${lists[index].itemCount} éléments'),
      ),
    );
  }
}
```

### 2. Utiliser la nouvelle API pour filtrer/trier

#### Configuration de filtres et tri :
```dart
// ✅ Filtrer par type
ref.updateTypeFilter(ListType.TRAVEL);

// ✅ Rechercher dans les listes
ref.updateSearch("courses");

// ✅ Changer le tri
ref.updateSort("progress"); // progress, date, name, items...

// ✅ Appliquer des filtres avancés
ref.updateAdvancedFilters({
  'minProgress': 0.5,
  'maxItems': 10,
  'isCompleted': false,
});
```

### 3. Accéder aux statistiques

#### Ancien code :
```dart
// ❌ Ancien - multiple providers pour stats
final globalStats = await ref.read(customListsStatsProvider.future);
final travelStats = await ref.read(customListsStatsByTypeProvider.future);
final travelSpecificStats = travelStats[ListType.TRAVEL];
```

#### Nouveau code :
```dart
// ✅ Nouveau - statistiques consolidées
final stats = ref.watch(listsStatisticsProvider);
final globalStats = stats['global'];
final travelStats = ref.getStatsForType(ListType.TRAVEL);

// Exemple d'utilisation
final totalLists = globalStats['totalLists'];
final avgProgress = globalStats['averageProgress'];
```

## Compatibilité rétroactive

Les anciens providers restent disponibles avec des annotations `@Deprecated` pour faciliter la migration :

```dart
// ⚠️ Deprecated mais toujours fonctionnel
final lists = ref.watch(allCustomListsProvider);
final movieLists = ref.watch(customListsByTypeProvider(ListType.MOVIES));
final stats = ref.watch(customListsStatsProvider);
```

**Note :** Ces alias seront supprimés dans une future version.

## Avantages de la nouvelle architecture

### 1. **Performances optimisées**
- Cache intelligent avec mémorisation
- Recalculs uniquement si nécessaire
- Moins de providers = moins de reconstructions

### 2. **API simplifiée**
- Extension methods pour les opérations courantes
- Configuration centralisée via `ListsConfig`
- État consolidé dans un seul StateNotifier

### 3. **Maintenabilité améliorée**
- 4 providers au lieu de 17 (réduction de 76%)
- Logique centralisée et cohérente
- Tests plus faciles à écrire et maintenir

### 4. **Fonctionnalités avancées**
- Filtrage combiné (type + recherche + statut + filtres avancés)
- Tri dynamique avec tous les critères supportés
- Statistiques temps réel (global + par type)
- Cache intelligent avec invalidation automatique

## Exemples d'utilisation avancés

### Filtrage combiné
```dart
// Listes de voyage non complétées avec plus de 5 éléments
final notifier = ref.read(consolidatedListsProvider.notifier);
notifier.updateConfig(ListsConfig(
  typeFilter: ListType.TRAVEL,
  showCompleted: false,
  showInProgress: true,
  advancedFilters: {'minItems': 5},
  sortBy: 'progress',
));

final filteredLists = ref.watch(processedListsProvider);
```

### Dashboard avec statistiques
```dart
class Dashboard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(listsStatisticsProvider);
    final globalStats = stats['global'];
    final byType = stats['byType'] as Map<String, dynamic>;
    
    return Column(
      children: [
        Text('Total: ${globalStats['totalLists']} listes'),
        Text('Progression: ${(globalStats['averageProgress'] * 100).toInt()}%'),
        ...ListType.values.map((type) {
          final typeStats = byType[type.name];
          if (typeStats == null) return SizedBox.shrink();
          return ListTile(
            title: Text(type.displayName),
            subtitle: Text('${typeStats['totalLists']} listes'),
            trailing: CircularProgressIndicator(
              value: typeStats['averageProgress'],
            ),
          );
        }).toList(),
      ],
    );
  }
}
```

### Recherche en temps réel
```dart
class SearchListsWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<SearchListsWidget> createState() => _SearchListsWidgetState();
}

class _SearchListsWidgetState extends ConsumerState<SearchListsWidget> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref.updateSearch(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lists = ref.watch(processedListsProvider);
    final isLoading = ref.watch(consolidatedListsProvider).isLoading;
    
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Rechercher dans les listes...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        if (isLoading)
          LinearProgressIndicator()
        else
          Expanded(
            child: ListView.builder(
              itemCount: lists.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(lists[index].name),
                subtitle: Text(lists[index].description ?? ''),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
```

## Prochaines étapes

1. **Migration progressive** : Remplacez les anciens providers par les nouveaux au fur et à mesure
2. **Tests** : Vérifiez que votre code fonctionne avec la nouvelle API
3. **Optimisation** : Profitez des nouvelles fonctionnalités pour optimiser votre UI
4. **Suppression** : Les providers deprecated seront supprimés dans la v2.0

## Support

Si vous rencontrez des problèmes lors de la migration, consultez les exemples ci-dessus ou créez une issue sur le dépôt du projet.