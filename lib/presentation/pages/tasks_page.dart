import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/repositories/task_repository.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/widgets/common/error/app_error_widget.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final tasksAsync = ref.watch(allTasksProvider);

    return Scaffold(
      appBar: PageHeader(
        title: l10n.tasksPageTitle,
        elevated: true,
      ),
      body: tasksAsync.when(
        data: (tasks) => tasks.isEmpty
            ? _buildEmptyState()
            : _buildTasksList(tasks),
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l10n.loading),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: AppErrorWidget.fromError(
            context: context,
            error: error,
            onRetry: () => ref.invalidate(allTasksProvider),
          ),
        ),
      ),
      floatingActionButton: Semantics(
        button: true,
        label: l10n.tasksFabAddLabel,
        hint: l10n.tasksFabAddHint,
        child: FloatingActionButton(
          heroTag: "tasks_fab",
          onPressed: _showAddTaskDialog,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          tooltip: l10n.tasksFabAddTooltip,
          child: Icon(
            Icons.add,
            semanticLabel: l10n.add,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      label: l10n.tasksEmptyStateLabel,
      hint: l10n.tasksEmptyStateHint,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              image: true,
              label: l10n.tasksIconLabel,
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
                l10n.tasksEmptyTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tasksEmptyBody,
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
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      label: l10n.tasksItemLabel(task.title),
      value: task.isCompleted ? l10n.tasksStatusCompleted : l10n.tasksStatusInProgress,
      hint: task.isCompleted
          ? l10n.tasksItemHintCompleted
          : l10n.tasksItemHintInProgress,
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
    final l10n = AppLocalizations.of(context)!;
    final label = task.isCompleted ? l10n.tasksMarkUndone : l10n.tasksMarkDone;
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        hint: l10n.tasksToggleHint,
        child: InkWell(
          onTap: () => _handleTaskAction(
            task.isCompleted ? 'uncomplete' : 'complete',
            task,
          ),
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: task.isCompleted
                  ? AppTheme.successColor
                  : AppTheme.primaryColor,
            ),
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Icon(
                task.isCompleted ? Icons.check : Icons.task_alt,
                color: Colors.white,
              ),
            ),
          ),
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
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      label: l10n.tasksActionsLabel(task.title),
      hint: l10n.tasksActionsHint,
      child: PopupMenuButton<String>(
        onSelected: (value) => _handleTaskAction(value, task),
        tooltip: l10n.tasksActionsTooltip,
        itemBuilder: (context) => [
          PopupMenuItem(
            value: task.isCompleted ? 'uncomplete' : 'complete',
            child: Semantics(
              button: true,
              label: task.isCompleted ? l10n.tasksMarkUndoneLong : l10n.tasksMarkDoneLong,
              child: Text(task.isCompleted ? l10n.tasksMarkUndone : l10n.tasksMarkDone),
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Semantics(
              button: true,
              label: l10n.tasksDeleteLabel,
              child: Text(l10n.delete),
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
    final l10n = AppLocalizations.of(context)!;
    final accessibilityService = AccessibilityService();
    accessibilityService.announceToScreenReader(l10n.tasksDialogOpenAnnounce);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Semantics(
          header: true,
          child: Text(l10n.taskNewDialogTitle),
        ),
        content: _buildDialogContent(l10n),
        actions: _buildDialogActions(l10n),
      ),
    );
  }

  Widget _buildDialogContent(AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CommonTextField(
          controller: _titleController,
          label: l10n.taskTitleFieldLabel,
        ),
        const SizedBox(height: 16),
        CommonTextField(
          controller: _descriptionController,
          label: l10n.taskDescriptionFieldLabel,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        _buildCategoryDropdown(l10n),
      ],
    );
  }

  Widget _buildCategoryDropdown(AppLocalizations l10n) {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: l10n.category,
        border: const OutlineInputBorder(),
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

  List<Widget> _buildDialogActions(AppLocalizations l10n) {
    return [
      Semantics(
        button: true,
        label: l10n.cancel,
        child: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
      ),
      CommonButton(
        text: l10n.add,
        tooltip: l10n.tasksCreateTooltip,
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
      final l10n = AppLocalizations.of(context)!;
      Navigator.of(context).pop();

      final accessibilityService = AccessibilityService();
      accessibilityService.announceToScreenReader(l10n.taskAddedSuccess);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Semantics(
            liveRegion: true,
            child: Text(l10n.taskAddedSuccess),
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
      final l10n = AppLocalizations.of(context)!;
      final accessibilityService = AccessibilityService();
      final message = action == 'delete' ? l10n.taskDeletedAnnounce : l10n.taskUpdatedAnnounce;

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
