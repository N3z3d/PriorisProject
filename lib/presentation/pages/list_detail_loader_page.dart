import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/repository_providers.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/presentation/pages/list_detail_page.dart';

/// Page intermédiaire qui récupère la [CustomList] par son [listId] puis affiche
/// soit [ListDetailPage] soit un message d'erreur.
class ListDetailLoaderPage extends ConsumerWidget {
  final String listId;
  const ListDetailLoaderPage({super.key, required this.listId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(customListRepositoryProvider);
    return FutureBuilder<CustomList?>(
      future: repo.getListById(listId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final list = snapshot.data;
        if (list == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Erreur')),
            body: const Center(child: Text('Liste introuvable')),
          );
        }
        return ListDetailPage(list: list);
      },
    );
  }
} 
