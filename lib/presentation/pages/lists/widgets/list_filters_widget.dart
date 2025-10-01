import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/services/core/lists_filter_service.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';
import 'package:prioris/presentation/widgets/common/displays/premium_card.dart';
import 'package:prioris/presentation/widgets/common/forms/common_button.dart';
import 'package:prioris/presentation/widgets/common/layouts/common_section_header.dart';
import 'package:prioris/presentation/widgets/common/forms/common_text_field.dart';
import 'package:prioris/presentation/widgets/common/displays/status_indicator.dart';

/// Widget autonome affichant la recherche et les filtres de la page Listes
class ListFiltersWidget extends ConsumerWidget {
  final ListsState state;
  const ListFiltersWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PremiumCard(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CommonSectionHeader(title: 'Recherche et filtres', icon: Icons.filter_list),
            const SizedBox(height: 16),
            // Recherche
            CommonTextField(
              hint: 'Rechercher dans mes listes...',
              prefix: const Icon(Icons.search),
              onChanged: (value) => ref.read(listsControllerProvider.notifier).updateSearchQuery(value ?? ''),
            ),
            const SizedBox(height: 16),
            // Filtres principaux (type + statut)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width >= 600 ? 280 : double.infinity,
                  child: _buildTypeFilter(ref),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width >= 600 ? 280 : double.infinity,
                  child: _buildStatusFilter(ref),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Date
            _buildDateFilter(ref),
            const SizedBox(height: 12),
            // Tri
            _buildSortFilter(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeFilter(WidgetRef ref) {
    return DropdownButtonFormField<ListType?>(
      isExpanded: true,
      value: state.selectedType,
      decoration: const InputDecoration(
        labelText: 'Type de liste',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('Tous les types')),
        ...ListType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.displayName))),
      ],
      onChanged: (v) => ref.read(listsControllerProvider.notifier).updateTypeFilter(v),
    );
  }

  Widget _buildStatusFilter(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Statut', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                width: 140,
                child: CommonButton(
                  text: 'Actives',
                  icon: Icons.play_circle_outline,
                  type: state.showInProgress ? ButtonType.primary : ButtonType.secondary,
                  onPressed: () => ref.read(listsControllerProvider.notifier).updateShowInProgress(!state.showInProgress),
                ),
              ),
              SizedBox(
                width: 140,
                child: CommonButton(
                  text: 'Complétées',
                  icon: Icons.check_circle_outline,
                  type: state.showCompleted ? ButtonType.primary : ButtonType.secondary,
                  onPressed: () => ref.read(listsControllerProvider.notifier).updateShowCompleted(!state.showCompleted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter(WidgetRef ref) {
    return DropdownButtonFormField<String?>(
      isExpanded: true,
      value: state.selectedDateFilter,
      decoration: const InputDecoration(
        labelText: 'Filtrer par date',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text('Toutes les dates')),
        DropdownMenuItem(value: 'today', child: Text('Aujourd\'hui')),
        DropdownMenuItem(value: 'week', child: Text('Cette semaine')),
        DropdownMenuItem(value: 'month', child: Text('Ce mois')),
        DropdownMenuItem(value: 'year', child: Text('Cette année')),
      ],
      onChanged: (v) => ref.read(listsControllerProvider.notifier).updateDateFilter(v),
    );
  }

  Widget _buildSortFilter(WidgetRef ref) {
    return DropdownButtonFormField<SortOption>(
      isExpanded: true,
      value: state.sortOption,
      decoration: const InputDecoration(
        labelText: 'Trier par',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: SortOption.values.map((o) => DropdownMenuItem(value: o, child: Text(o.displayName))).toList(),
      onChanged: (v) => ref.read(listsControllerProvider.notifier).updateSortOption(v!),
    );
  }
} 
