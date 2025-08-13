import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/data/providers/list_providers.dart';

/// Exemple d'utilisation des providers consolidés
/// 
/// Cette classe montre comment migrer du système à 17 providers 
/// vers le système consolidé à 4 providers.
class ConsolidatedProvidersExample extends ConsumerStatefulWidget {
  const ConsolidatedProvidersExample({super.key});

  @override
  ConsumerState<ConsolidatedProvidersExample> createState() => 
      _ConsolidatedProvidersExampleState();
}

class _ConsolidatedProvidersExampleState 
    extends ConsumerState<ConsolidatedProvidersExample> {
  
  final _searchController = TextEditingController();
  ListType? _selectedType;
  String _sortBy = 'date';
  
  @override
  void initState() {
    super.initState();
    
    // Charger les listes au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.loadListsIfNeeded();
    });
    
    // Écouter les changements de recherche
    _searchController.addListener(() {
      ref.updateSearch(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Nouveau : 1 seul provider pour l'état complet
    final state = ref.watch(consolidatedListsProvider);
    final lists = ref.watch(processedListsProvider);
    final stats = ref.watch(listsStatisticsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listes Consolidées'),
        actions: [
          // Bouton pour recharger
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(consolidatedListsProvider.notifier).loadLists(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Section de recherche et filtres
          _buildFiltersSection(),
          
          // Section des statistiques
          _buildStatsSection(stats),
          
          // Section des listes
          Expanded(
            child: _buildListsSection(state, lists),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filtres & Tri', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            // Recherche
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Rechercher dans les listes...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            
            // Filtre par type
            Row(
              children: [
                const Text('Type: '),
                Expanded(
                  child: DropdownButton<ListType?>(
                    value: _selectedType,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Tous')),
                      ...ListType.values.map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.displayName),
                      )),
                    ],
                    onChanged: (type) {
                      setState(() => _selectedType = type);
                      ref.updateTypeFilter(type);
                    },
                  ),
                ),
              ],
            ),
            
            // Tri
            Row(
              children: [
                const Text('Tri: '),
                Expanded(
                  child: DropdownButton<String>(
                    value: _sortBy,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'date', child: Text('Date de création')),
                      DropdownMenuItem(value: 'updated', child: Text('Dernière modif.')),
                      DropdownMenuItem(value: 'name', child: Text('Nom (A-Z)')),
                      DropdownMenuItem(value: 'progress', child: Text('Progression')),
                      DropdownMenuItem(value: 'items', child: Text('Nb éléments')),
                    ],
                    onChanged: (sortBy) {
                      if (sortBy != null) {
                        setState(() => _sortBy = sortBy);
                        ref.updateSort(sortBy);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(Map<String, dynamic> stats) {
    final globalStats = stats['global'] as Map<String, dynamic>? ?? {};
    final byType = stats['byType'] as Map<String, dynamic>? ?? {};
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Statistiques', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            // Stats globales
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Listes totales',
                    value: '${globalStats['totalLists'] ?? 0}',
                    icon: Icons.list,
                  ),
                ),
                Expanded(
                  child: _StatCard(
                    title: 'Éléments totaux',
                    value: '${globalStats['totalItems'] ?? 0}',
                    icon: Icons.inventory,
                  ),
                ),
                Expanded(
                  child: _StatCard(
                    title: 'Progression moy.',
                    value: '${((globalStats['averageProgress'] ?? 0.0) * 100).toInt()}%',
                    icon: Icons.trending_up,
                  ),
                ),
              ],
            ),
            
            // Stats par type (si données disponibles)
            if (byType.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Par type:', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: byType.entries.map((entry) {
                  final typeStats = entry.value as Map<String, dynamic>;
                  final type = ListType.values.firstWhere(
                    (t) => t.name == entry.key,
                    orElse: () => ListType.CUSTOM,
                  );
                  
                  return Chip(
                    avatar: Icon(Icons.apps, size: 16),
                    label: Text(
                      '${type.displayName}: ${typeStats['totalLists']}',
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildListsSection(ConsolidatedListsState state, List<CustomList> lists) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement des listes...'),
          ],
        ),
      );
    }
    
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erreur: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(consolidatedListsProvider.notifier).loadLists(),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }
    
    if (lists.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 48),
            SizedBox(height: 16),
            Text('Aucune liste trouvée'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: lists.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final list = lists[index];
        final progress = list.getProgress();
        
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(list.type.colorValue),
              child: Icon(
                _getIconData(list.type.iconName),
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(list.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (list.description?.isNotEmpty ?? false)
                  Text(list.description!, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('${list.itemCount} éléments • ${(progress * 100).toInt()}% terminé'),
                const SizedBox(height: 4),
                LinearProgressIndicator(value: progress),
              ],
            ),
            isThreeLine: true,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  list.type.displayName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(list.updatedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'flight': return Icons.flight;
      case 'shopping_cart': return Icons.shopping_cart;
      case 'movie': return Icons.movie;
      case 'book': return Icons.book;
      case 'restaurant': return Icons.restaurant;
      case 'work': return Icons.work;
      default: return Icons.list;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) return 'Aujourd\'hui';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: Theme.of(context).primaryColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Exemple d'utilisation de filtres avancés
class AdvancedFiltersExample extends ConsumerWidget {
  const AdvancedFiltersExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            // ✅ Filtrage avancé : listes avec progression entre 25% et 75%
            ref.updateAdvancedFilters({
              'minProgress': 0.25,
              'maxProgress': 0.75,
            });
          },
          child: const Text('Listes en cours (25-75%)'),
        ),
        
        ElevatedButton(
          onPressed: () {
            // ✅ Filtrage avancé : listes avec moins de 5 éléments
            ref.updateAdvancedFilters({
              'maxItems': 5,
            });
          },
          child: const Text('Petites listes (< 5 éléments)'),
        ),
        
        ElevatedButton(
          onPressed: () {
            // ✅ Réinitialiser tous les filtres
            final notifier = ref.read(consolidatedListsProvider.notifier);
            notifier.updateConfig(const ListsConfig());
          },
          child: const Text('Réinitialiser filtres'),
        ),
      ],
    );
  }
}

/// Exemple d'utilisation des statistiques par type
class TypeStatsExample extends ConsumerWidget {
  const TypeStatsExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: ListType.values.map((type) {
        final typeStats = ref.getStatsForType(type);
        
        if (typeStats == null) {
          return ListTile(
            leading: Icon(_getIconData(type.iconName)),
            title: Text(type.displayName),
            subtitle: const Text('Aucune liste'),
          );
        }
        
        final totalLists = typeStats['totalLists'] ?? 0;
        final avgProgress = typeStats['averageProgress'] ?? 0.0;
        
        return ListTile(
          leading: Icon(
            _getIconData(type.iconName),
            color: Color(type.colorValue),
          ),
          title: Text(type.displayName),
          subtitle: Text('$totalLists listes • ${(avgProgress * 100).toInt()}% moy.'),
          trailing: CircularProgressIndicator(
            value: avgProgress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation(Color(type.colorValue)),
          ),
        );
      }).toList(),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'flight': return Icons.flight;
      case 'shopping_cart': return Icons.shopping_cart;
      case 'movie': return Icons.movie;
      case 'book': return Icons.book;
      case 'restaurant': return Icons.restaurant;
      case 'work': return Icons.work;
      default: return Icons.list;
    }
  }
}