import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/list_detail_page.dart';
import 'package:prioris/presentation/widgets/common/error/app_error_widget.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';

/// ARCHITECTURE FIX: Provider stable pour récupérer une liste 
/// Les repositories sont pré-initialisés donc les données sont disponibles immédiatement
final listDetailLoaderProvider = Provider.family<AsyncValue<CustomList?>, String>((ref, listId) {
  // Utilise le provider existant qui maintient un cache stable
  final listsState = ref.watch(listsControllerProvider);
  final currentList = listsState.findListById(listId);
  
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
        return _buildLoadingState(context);
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
      loading: () => _buildLoadingState(context),
      error: (error, stack) => _buildErrorState(context, error),
    );
  }
  
  Widget _buildLoadingState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.loadingListDetail),
          ],
        ),
      ),
    );
  }

  Widget _buildNoListsState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.noListsTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.list_alt, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l10n.noListsTitle),
            const SizedBox(height: 8),
            Text(l10n.noListsBody),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.error)),
      body: Center(
        child: AppErrorWidget.fromError(context: context, error: error),
      ),
    );
  }
} 