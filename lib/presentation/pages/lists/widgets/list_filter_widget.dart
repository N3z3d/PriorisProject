import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/widgets/common/displays/premium_card.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Widget pour filtrer les listes
/// 
/// Permet de filtrer les listes selon le type, le statut, la date
/// et d'autres critères avec une interface intuitive.
class ListFilterWidget extends StatefulWidget {
  final ListType? selectedType;
  final bool? selectedStatus;
  final String? selectedCategory;
  final DateTime? selectedDate;
  final ValueChanged<ListType?>? onTypeChanged;
  final ValueChanged<bool?>? onStatusChanged;
  final ValueChanged<String?>? onCategoryChanged;
  final ValueChanged<DateTime?>? onDateChanged;
  final VoidCallback? onClearFilters;

  const ListFilterWidget({
    super.key,
    this.selectedType,
    this.selectedStatus,
    this.selectedCategory,
    this.selectedDate,
    this.onTypeChanged,
    this.onStatusChanged,
    this.onCategoryChanged,
    this.onDateChanged,
    this.onClearFilters,
  });

  @override
  State<ListFilterWidget> createState() => _ListFilterWidgetState();
}

class _ListFilterWidgetState extends State<ListFilterWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = _hasActiveFilters();

    return PremiumCard(
      child: Column(
        children: [
          // En-tête avec bouton d'expansion
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: hasActiveFilters ? AppTheme.primaryColor : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                'Filtres',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: hasActiveFilters ? AppTheme.primaryColor : null,
                ),
              ),
              const Spacer(),
              if (hasActiveFilters)
                TextButton.icon(
                  onPressed: widget.onClearFilters,
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Effacer'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              IconButton(
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                icon: Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                ),
              ),
            ],
          ),
          
          // Contenu des filtres
          if (_isExpanded) ...[
            const Divider(),
            const SizedBox(height: 16),
            _buildFilterContent(context),
          ],
        ],
      ),
    );
  }

  /// Construit le contenu des filtres
  Widget _buildFilterContent(BuildContext context) {
    return Column(
      children: [
        // Filtre par type
        _buildTypeFilter(context),
        const SizedBox(height: 16),
        
        // Filtre par statut
        _buildStatusFilter(context),
        const SizedBox(height: 16),
        
        // Filtre par date
        _buildDateFilter(context),
      ],
    );
  }

  /// Construit le filtre par type
  Widget _buildTypeFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type de liste',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip(
              label: 'Tous',
              selected: widget.selectedType == null,
              onSelected: (_) => widget.onTypeChanged?.call(null),
            ),
            ...ListType.values.map((type) => _buildFilterChip(
              label: type.displayName,
              selected: widget.selectedType == type,
              onSelected: (_) => widget.onTypeChanged?.call(type),
            )),
          ],
        ),
      ],
    );
  }

  /// Construit le filtre par statut
  Widget _buildStatusFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statut',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip(
              label: 'Tous',
              selected: widget.selectedStatus == null,
              onSelected: (_) => widget.onStatusChanged?.call(null),
            ),
            _buildFilterChip(
              label: 'Actives',
              selected: widget.selectedStatus == false,
              onSelected: (_) => widget.onStatusChanged?.call(false),
            ),
            _buildFilterChip(
              label: 'Archivées',
              selected: widget.selectedStatus == true,
              onSelected: (_) => widget.onStatusChanged?.call(true),
            ),
          ],
        ),
      ],
    );
  }

  /// Construit le filtre par date
  Widget _buildDateFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip(
              label: 'Toutes',
              selected: widget.selectedDate == null,
              onSelected: (_) => widget.onDateChanged?.call(null),
            ),
            _buildFilterChip(
              label: 'Aujourd\'hui',
              selected: _isToday(widget.selectedDate),
              onSelected: (_) => widget.onDateChanged?.call(DateTime.now()),
            ),
            _buildFilterChip(
              label: 'Cette semaine',
              selected: _isThisWeek(widget.selectedDate),
              onSelected: (_) => widget.onDateChanged?.call(
                DateTime.now().subtract(const Duration(days: 7)),
              ),
            ),
            _buildFilterChip(
              label: 'Ce mois',
              selected: _isThisMonth(widget.selectedDate),
              onSelected: (_) => widget.onDateChanged?.call(
                DateTime.now().subtract(const Duration(days: 30)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Construit un chip de filtre
  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
    Color? color,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: color?.withValues(alpha: 0.2) ?? AppTheme.primaryColor.withValues(alpha: 0.2),
      checkmarkColor: color ?? AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: selected ? (color ?? AppTheme.primaryColor) : null,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  /// Vérifie s'il y a des filtres actifs
  bool _hasActiveFilters() {
    return widget.selectedType != null ||
           widget.selectedStatus != null ||
           widget.selectedCategory != null ||
           widget.selectedDate != null;
  }

  /// Vérifie si la date sélectionnée est aujourd'hui
  bool _isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  /// Vérifie si la date sélectionnée est cette semaine
  bool _isThisWeek(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return date.isAfter(weekAgo) && date.isBefore(now);
  }

  /// Vérifie si la date sélectionnée est ce mois
  bool _isThisMonth(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    return date.isAfter(monthAgo) && date.isBefore(now);
  }
} 
