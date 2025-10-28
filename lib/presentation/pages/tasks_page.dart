import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/repositories/task_repository.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/widgets/common/forms/common_text_field.dart';
import 'package:prioris/presentation/widgets/common/forms/common_button.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/domain/services/ui/accessibility_service.dart';
import 'package:prioris/presentation/widgets/common/headers/page_header.dart';

class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Travail';
  
  final List<String> _categories = [
    'Travail',
    'Personnel',
    'Santé',
    'Éducation',
    'Loisirs',
    'Famille',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(allTasksProvider);
    
    return Scaffold(
      appBar: const PageHeader(
        title: 'Mes Tâches',
        elevated: true,
      ),
      body: tasksAsync.when(
        data: (tasks) => tasks.isEmpty
            ? _buildEmptyState()
            : _buildTasksList(tasks),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erreur: $error'),
        ),
      ),
      floatingActionButton: Semantics(
        button: true,
        label: 'Ajouter une nouvelle tâche',
        hint: 'Ouvre un formulaire pour créer une nouvelle tâche',
        child: FloatingActionButton(
          heroTag: "tasks_fab",
          onPressed: _showAddTaskDialog,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          tooltip: 'Ajouter une tâche',
          child: const Icon(
            Icons.add,
            semanticLabel: 'Ajouter',
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Semantics(
      label: 'État vide: Aucune tâche',
      hint: 'Utilisez le bouton d\'ajout pour créer votre première tâche',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              image: true,
              label: 'Icône de tâche',
              child: Icon(
                Icons.task_alt_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Semantics(
              header: true,
              child: Text(
                'Aucune tâche',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez votre première tâche pour commencer',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList(List<Task> tasks) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task);
      },
    );
  }

  Widget _buildTaskCard(Task task) {
    return Semantics(
      button: true,
      label: 'Tâche: ${task.title}',
      value: task.isCompleted ? 'Terminée' : 'En cours',
      hint: task.isCompleted
          ? 'Tâche terminée. Appuyez pour plus d\'actions'
          : 'Tâche en cours. Appuyez pour plus d\'actions',
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusTokens.modal),
        child: Container(
          decoration: _buildTaskCardDecoration(task),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: _buildTaskLeadingIcon(task),
            title: _buildTaskTitle(task),
            subtitle: _buildTaskSubtitle(task),
            trailing: _buildTaskActionsMenu(task),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildTaskCardDecoration(Task task) {
    return BoxDecoration(
      color: task.isCompleted
          ? AppTheme.successColor.withValues(alpha: 0.05)
          : AppTheme.surfaceColor,
      borderRadius: BorderRadiusTokens.modal,
      border: Border.all(
        color: task.isCompleted
            ? AppTheme.successColor.withValues(alpha: 0.3)
            : AppTheme.dividerColor.withValues(alpha: 0.5),
        width: 0.5,
      ),
    );
  }

  Widget _buildTaskLeadingIcon(Task task) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: task.isCompleted ? AppTheme.successColor : AppTheme.primaryColor,
      ),
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        child: Icon(
          task.isCompleted ? Icons.check : Icons.task_alt,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTaskTitle(Task task) {
    return Text(
      task.title,
      style: TextStyle(
        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTaskSubtitle(Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (task.description != null && task.description!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              task.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildCategoryChip(task.category),
            const SizedBox(width: 8),
            _buildEloChip(task.eloScore),
          ],
        ),
      ],
    );
  }

  Widget _buildTaskActionsMenu(Task task) {
    return Semantics(
      button: true,
      label: 'Actions pour la tâche ${task.title}',
      hint: 'Menu des actions disponibles',
      child: PopupMenuButton<String>(
        onSelected: (value) => _handleTaskAction(value, task),
        tooltip: 'Actions de la tâche',
        itemBuilder: (context) => [
          PopupMenuItem(
            value: task.isCompleted ? 'uncomplete' : 'complete',
            child: Semantics(
              button: true,
              label: task.isCompleted ? 'Marquer comme non terminée' : 'Marquer comme terminée',
              child: Text(task.isCompleted ? 'Marquer non fait' : 'Marquer fait'),
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Semantics(
              button: true,
              label: 'Supprimer la tâche',
              child: const Text('Supprimer'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String? category) {
    if (category == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadiusTokens.card,
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEloChip(double elo) {
    Color color;
    if (elo >= 1400) {
      color = Colors.green;
    } else if (elo >= 1200) {
      color = Colors.orange;
    } else {
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadiusTokens.card,
      ),
      child: Text(
        'ELO ${elo.toInt()}',
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    final accessibilityService = AccessibilityService();
    accessibilityService.announceToScreenReader('Ouverture du formulaire de création de tâche');

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Semantics(
          header: true,
          child: const Text('Nouvelle tâche'),
        ),
        content: _buildDialogContent(),
        actions: _buildDialogActions(),
      ),
    );
  }

  Widget _buildDialogContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CommonTextField(
          controller: _titleController,
          label: 'Titre',
        ),
        const SizedBox(height: 16),
        CommonTextField(
          controller: _descriptionController,
          label: 'Description (optionnel)',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        _buildCategoryDropdown(),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Catégorie',
        border: OutlineInputBorder(),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
        });
      },
    );
  }

  List<Widget> _buildDialogActions() {
    return [
      Semantics(
        button: true,
        label: 'Annuler la création de tâche',
        child: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
      ),
      CommonButton(
        text: 'Ajouter',
        tooltip: 'Créer la nouvelle tâche',
        onPressed: _addTask,
      ),
    ];
  }

  void _addTask() async {
    if (_titleController.text.trim().isEmpty) return;

    final task = Task(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      category: _selectedCategory,
    );

    final repository = ref.read(taskRepositoryProvider);
    await repository.saveTask(task);
    
    // Rafraîchir la liste
    ref.invalidate(allTasksProvider);
    
    // Nettoyer les champs
    _titleController.clear();
    _descriptionController.clear();
    
    if (mounted) {
      Navigator.of(context).pop();
      
      final accessibilityService = AccessibilityService();
      accessibilityService.announceToScreenReader('Tâche ajoutée avec succès');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Semantics(
            liveRegion: true,
            child: const Text('Tâche ajoutée avec succès'),
          ),
        ),
      );
    }
  }

  void _handleTaskAction(String action, Task task) async {
    final repository = ref.read(taskRepositoryProvider);
    
    switch (action) {
      case 'complete':
      case 'uncomplete':
        final updatedTask = task.copyWith(
          isCompleted: !task.isCompleted,
          completedAt: !task.isCompleted ? DateTime.now() : null,
        );
        await repository.updateTask(updatedTask);
        break;
      case 'delete':
        await repository.deleteTask(task.id);
        break;
    }
    
    // Rafraîchir la liste
    ref.invalidate(allTasksProvider);
    
    if (mounted) {
      final accessibilityService = AccessibilityService();
      final message = 'Tâche ${action == 'delete' ? 'supprimée' : 'mise à jour'}';
      
      accessibilityService.announceToScreenReader(message);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Semantics(
            liveRegion: true,
            child: Text(message),
          ),
        ),
      );
    }
  }
}
