import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/common/headers/unified_page_header.dart';

/// Bandeau d'aperçu des listes utilisant le header unifie.
class ListsOverviewBanner extends StatelessWidget {
  final int totalLists;
  final int totalItems;

  const ListsOverviewBanner({
    super.key,
    required this.totalLists,
    required this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    return UnifiedPageHeader(
      icon: Icons.view_list,
      title: 'Organisez vos listes en un coup d\'oeil',
      subtitle: '$totalLists listes | $totalItems elements actifs',
    );
  }
}
