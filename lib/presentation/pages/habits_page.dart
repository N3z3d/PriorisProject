import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/repositories/habit_repository.dart';
import 'package:prioris/data/providers/habits_state_provider.dart';
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
    // 🚀 NOUVELLE ARCHITECTURE RÉACTIVE: Utilise le StateNotifier
    final habits = ref.watch(reactiveHabitsProvider);
    final isLoading = ref.watch(habitsLoadingProvider);
    final error = ref.watch(habitsErrorProvider);

    // Auto-charge les habitudes si nécessaire
    if (habits.isEmpty && !isLoading && error == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(habitsStateProvider.notifier).loadHabits();
      });
    }

    return Scaffold(
      body: Column(
        children: [
          _buildContextualHeader(),
          Expanded(child: _buildBodyReactive(habits, isLoading, error)),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Construit le header premium pour la section Habitudes
  Widget _buildContextualHeader() {
    return Container(
      decoration: _buildPremiumHeaderDecoration(),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header avec titre et icône premium
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  // Icône élégante avec dégradé
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.2),
                          Colors.white.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.psychology_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Titre avec style premium
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Habitudes & Routines',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          'Construisez votre meilleure version',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.8),
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Tabs avec design premium
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorPadding: const EdgeInsets.all(2),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'En cours'),
                  Tab(text: 'Terminées'),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Crée la décoration premium pour le header
  BoxDecoration _buildPremiumHeaderDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppTheme.primaryColor, // Bleu professionnel
          AppTheme.accentColor,  // Violet élégant
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0.0, 1.0],
      ),
      boxShadow: [
        BoxShadow(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
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
          border: const Border(
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

  /// Construit le corps de la page avec architecture réactive
  Widget _buildBodyReactive(List<Habit> habits, bool isLoading, String? error) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildHabitsTabReactive(habits, isLoading, error),
        _buildAddTab(),
      ],
    );
  }

  /// Construit l'onglet des habitudes avec architecture réactive
  Widget _buildHabitsTabReactive(List<Habit> habits, bool isLoading, String? error) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (error != null) {
      return _buildErrorState(error);
    }
    
    return _buildHabitsList(habits);
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadiusTokens.modal),
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
      tooltip: 'Afficher le menu',
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
    // Utilisation des vraies données de l'habitude
    final progress = habit.getSuccessRate(days: 7); // Taux de réussite sur 7 jours
    final streak = habit.getCurrentStreak();
    final completedToday = habit.isCompletedToday();

    // Calculer les jours réussis cette semaine
    final successfulDays = (progress * 7).round();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(progress * 100).round()}% cette semaine',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '$successfulDays/7 jours',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: successfulDays > 0 ? AppTheme.accentColor : Colors.grey[500],
              ),
            ),
          ],
        ),
        if (streak > 0) ...[
          const SizedBox(height: 2),
          Text(
            'Série: $streak jour${streak > 1 ? 's' : ''} 🔥',
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.successColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(progress > 0 ? AppTheme.accentColor : Colors.grey[400]!),
        ),
      ],
    );
  }

  /// Construit le bouton d'action flottant
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      heroTag: 'habits_fab',
      onPressed: () => _tabController.animateTo(1),
      backgroundColor: AppTheme.accentColor,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  /// Ajoute une nouvelle habitude avec architecture réactive
  Future<void> _addHabit(Habit habit) async {
    try {
      // 🚀 UTILISE LA NOUVELLE ARCHITECTURE RÉACTIVE
      await ref.addHabitReactive(habit);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Habitude "${habit.name}" créée avec succès !'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
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
                // 🚀 UTILISE LA NOUVELLE ARCHITECTURE RÉACTIVE
                await ref.deleteHabitReactive(habit.id);
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

