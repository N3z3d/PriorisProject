import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/repositories/habit_repository.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/pages/habits/widgets/habit_form_widget.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/common/lists/virtualized_list.dart';

class HabitsPage extends ConsumerStatefulWidget {
  const HabitsPage({super.key});

  @override
  ConsumerState<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends ConsumerState<HabitsPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(allHabitsProvider);
    
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(habitsAsync),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Construit l'AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Mes Habitudes'),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          // Fond professionnel avec couleur unie professionnelle
          color: AppTheme.professionalSurfaceColor,
          border: Border(
            bottom: BorderSide(
              color: AppTheme.dividerColor,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.primaryColor,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: AppTheme.textSecondary,
        tabs: const [
          Tab(text: 'Mes Habitudes', icon: Icon(Icons.list)),
          Tab(text: 'Ajouter', icon: Icon(Icons.add)),
        ],
      ),
    );
  }

  /// Construit le corps de la page
  Widget _buildBody(AsyncValue<List<Habit>> habitsAsync) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildHabitsTab(habitsAsync),
        _buildAddTab(),
      ],
    );
  }

  /// Construit l'onglet des habitudes
  Widget _buildHabitsTab(AsyncValue<List<Habit>> habitsAsync) {
    return habitsAsync.when(
      data: (habits) => _buildHabitsList(habits),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  /// Construit l'onglet d'ajout
  Widget _buildAddTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: HabitFormWidget(
        onSubmit: _addHabit,
      ),
    );
  }

  /// Construit la liste des habitudes
  Widget _buildHabitsList(List<Habit> habits) {
    if (habits.isEmpty) {
      return _buildEmptyState();
    }

    return VirtualizedList<Habit>(
      items: habits,
      padding: const EdgeInsets.all(16),
      cacheExtent: 500, // Cache étendu pour une meilleure fluidité
      itemBuilder: (context, habit, index) => _buildHabitCard(habit),
      emptyWidget: _buildEmptyState(),
    );
  }

  /// Construit l'état vide
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.psychology,
            size: 80,
            color: AppTheme.accentColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune habitude',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez à construire de meilleures habitudes dès aujourd\'hui !',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _tabController.animateTo(1),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter ma première habitude'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Construit l'état d'erreur
  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Impossible de charger les habitudes: $error',
            style: TextStyle(
              fontSize: 16,
              color: Colors.red[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => ref.refresh(allHabitsProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  /// Construit une carte d'habitude
  Widget _buildHabitCard(Habit habit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusTokens.modal),
      child: Container(
        decoration: _buildCardDecoration(),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          leading: _buildHabitAvatar(habit),
          title: _buildHabitTitle(habit),
          subtitle: _buildHabitSubtitle(habit),
          trailing: _buildHabitMenu(habit),
        ),
      ),
    );
  }

  /// Construit la décoration professionnelle pour la carte
  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      // Fond professionnel uni avec très légère teinte
      color: AppTheme.surfaceColor,
      borderRadius: BorderRadiusTokens.modal,
      border: Border.all(
        color: AppTheme.dividerColor.withValues(alpha: 0.5),
        width: 0.5,
      ),
    );
  }

  /// Construit l'avatar de l'habitude
  Widget _buildHabitAvatar(Habit habit) {
    return CircleAvatar(
      backgroundColor: AppTheme.accentColor,
      child: Icon(
        _getHabitIcon(habit.category ?? 'Général'),
        color: Colors.white,
      ),
    );
  }

  /// Construit le titre de l'habitude
  Widget _buildHabitTitle(Habit habit) {
    return Text(
      habit.name,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Construit le sous-titre avec catégorie et progression
  Widget _buildHabitSubtitle(Habit habit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text(habit.category ?? 'Général'),
        const SizedBox(height: 4),
        _buildHabitProgress(habit),
      ],
    );
  }

  /// Construit le menu d'actions pour l'habitude
  Widget _buildHabitMenu(Habit habit) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleHabitAction(value, habit),
      itemBuilder: (context) => [
        _buildMenuAction('record', Icons.check_circle, 'Enregistrer'),
        _buildMenuAction('edit', Icons.edit, 'Modifier'),
        _buildMenuAction('delete', Icons.delete, 'Supprimer', isDestructive: true),
      ],
    );
  }

  /// Construit un élément du menu d'action
  PopupMenuItem<String> _buildMenuAction(String value, IconData icon, String text, {bool isDestructive = false}) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: isDestructive ? Colors.red : null),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: isDestructive ? Colors.red : null)),
        ],
      ),
    );
  }

  /// Construit l'indicateur de progression
  Widget _buildHabitProgress(Habit habit) {
    // Logique simplifiée pour l'exemple
    final progress = 0.7; // À implémenter selon vos besoins
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(progress * 100).toInt()}% cette semaine',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '7/10 jours',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
        ),
      ],
    );
  }

  /// Construit le bouton d'action flottant
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      heroTag: "habits_fab",
      onPressed: () => _tabController.animateTo(1),
      backgroundColor: AppTheme.accentColor,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  /// Ajoute une nouvelle habitude
  Future<void> _addHabit(Habit habit) async {
    await ref.read(habitRepositoryProvider).addHabit(habit);
    ref.invalidate(allHabitsProvider);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Habitude "${habit.name}" créée avec succès !'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  /// Gère les actions sur une habitude
  void _handleHabitAction(String action, Habit habit) {
    switch (action) {
      case 'record':
        _recordHabit(habit);
        break;
      case 'edit':
        _editHabit(habit);
        break;
      case 'delete':
        _deleteHabit(habit);
        break;
    }
  }

  /// Enregistre une exécution d'habitude
  void _recordHabit(Habit habit) {
    // Logique d'enregistrement à implémenter
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Habitude "${habit.name}" enregistrée !'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  /// Édite une habitude
  void _editHabit(Habit habit) {
    // Navigation vers l'édition à implémenter
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Édition à implémenter'),
      ),
    );
  }

  /// Supprime une habitude
  void _deleteHabit(Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'habitude'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${habit.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              
              try {
                await ref.read(habitRepositoryProvider).deleteHabit(habit.id);
                ref.invalidate(allHabitsProvider);
                navigator.pop();
                
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Habitude "${habit.name}" supprimée'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la suppression: $e'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Retourne l'icône pour une catégorie
  IconData _getHabitIcon(String category) {
    switch (category.toLowerCase()) {
      case 'santé':
        return Icons.favorite;
      case 'sport':
        return Icons.fitness_center;
      case 'productivité':
        return Icons.work;
      case 'développement personnel':
        return Icons.psychology;
      case 'créativité':
        return Icons.palette;
      case 'sociale':
        return Icons.people;
      default:
        return Icons.star;
    }
  }
} 
