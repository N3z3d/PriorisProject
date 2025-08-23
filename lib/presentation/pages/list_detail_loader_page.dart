import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/presentation/pages/list_detail_page.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';

/// ARCHITECTURE FIX: Provider stable pour récupérer une liste 
/// Les repositories sont pré-initialisés donc les données sont disponibles immédiatement
final listDetailLoaderProvider = Provider.family<AsyncValue<CustomList?>, String>((ref, listId) {
  // Utilise le provider existant qui maintient un cache stable
  final currentList = ref.watch(listByIdProvider(listId));
  
  // ARCHITECTURE FIX: Retourne directement les données disponibles
  // Plus besoin de rechargement car repositories sont pré-initialisés
  return AsyncValue.data(currentList);
});

/// Page intermédiaire qui récupère la [CustomList] par son [listId] puis affiche
/// soit [ListDetailPage] soit un message d'erreur.
/// ARCHITECTURE FIX: Utilise le cache Riverpod au lieu de FutureBuilder
class ListDetailLoaderPage extends ConsumerWidget {
  final String? listId;
  const ListDetailLoaderPage({super.key, this.listId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('🔍 DEBUG ListDetailLoaderPage: listId = $listId');
    
    // CORRECTION UX: Si pas d'ID, utiliser la première liste disponible
    if (listId == null) {
      final listsState = ref.watch(listsControllerProvider);
      final availableLists = listsState.filteredLists.isNotEmpty 
          ? listsState.filteredLists 
          : listsState.lists;
      
      if (availableLists.isNotEmpty) {
        final firstList = availableLists.first;
        print('🎯 UX: Pas d\'ID fourni, utilisation de la première liste: ${firstList.name}');
        return ListDetailPage(list: firstList);
      } else if (listsState.isLoading) {
        return _buildLoadingState();
      } else {
        return _buildNoListsState(context);
      }
    }
    
    // ID fourni, utiliser le provider existant
    final asyncList = ref.watch(listDetailLoaderProvider(listId!));
    
    return asyncList.when(
      data: (list) {
        print('🔍 DEBUG ListDetailLoaderPage: data callback, list = ${list?.name ?? 'NULL'}');
        if (list == null) {
          print('🔧 DEBUG ListDetailLoaderPage: Liste non trouvée avec ID $listId, fallback vers première liste');
          // Fallback vers la première liste disponible au lieu d'afficher une erreur
          final listsState = ref.read(listsControllerProvider);
          final availableLists = listsState.filteredLists.isNotEmpty 
              ? listsState.filteredLists 
              : listsState.lists;
          
          if (availableLists.isNotEmpty) {
            final firstList = availableLists.first;
            print('🎯 Fallback: Utilisation de la première liste disponible: ${firstList.name}');
            return ListDetailPage(list: firstList);
          }
          
          return _buildNoListsState(context);
        }
        print('🔧 DEBUG ListDetailLoaderPage: Navigation vers ListDetailPage avec liste: ${list.name}');
        return ListDetailPage(list: list);
      },
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(context, error),
    );
  }
  
  Widget _buildLoadingState() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement de votre liste...'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNoListsState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aucune liste')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list_alt, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Aucune liste disponible'),
            SizedBox(height: 8),
            Text('Créez votre première liste pour commencer'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildErrorState(BuildContext context, Object error) {
    return Scaffold(
      appBar: AppBar(title: const Text('Erreur')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Erreur: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }
} 