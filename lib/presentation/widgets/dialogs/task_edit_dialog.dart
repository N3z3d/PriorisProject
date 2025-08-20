import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/theme/glassmorphism.dart';
import 'package:uuid/uuid.dart';

/// Dialogue d'ajout/édition de tâche avec design glassmorphisme
class TaskEditDialog extends StatefulWidget {
  final Task? initialTask;
  final void Function(Task) onSubmit;

  const TaskEditDialog({
    super.key,
    this.initialTask,
    required this.onSubmit,
  });

  @override
  State<TaskEditDialog> createState() => _TaskEditDialogState();
}

class _TaskEditDialogState extends State<TaskEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late String _category;

  @override
  void initState() {
    super.initState();
    _title = widget.initialTask?.title ?? '';
    _description = widget.initialTask?.description ?? '';
    _category = widget.initialTask?.category ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Glassmorphism.glassCard(
        borderRadius: BorderRadiusTokens.modal,
        blur: 20.0,
        opacity: 0.15,
        width: MediaQuery.of(context).size.width * 0.9,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildTitleField(),
                  const SizedBox(height: 20),
                  _buildDescriptionField(),
                  const SizedBox(height: 20),
                  _buildCategoryField(),
                  const SizedBox(height: 32),
                  _buildActions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          widget.initialTask == null ? Icons.add_task : Icons.edit,
          color: AppTheme.primaryColor,
          size: 28,
        ),
        const SizedBox(width: 12),
        Text(
          widget.initialTask == null ? 'Ajouter une tâche' : 'Modifier la tâche',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Titre',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Glassmorphism.glassCard(
          blur: 6.0,
          opacity: 0.05,
          borderRadius: BorderRadiusTokens.input,
          padding: EdgeInsets.zero,
          child: TextFormField(
            initialValue: _title,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: 'Ex: Terminer le rapport, Appeler le client...',
              hintStyle: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.7)),
              border: OutlineInputBorder(
                borderRadius: BorderRadiusTokens.input,
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadiusTokens.input,
                borderSide: BorderSide(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le titre est obligatoire pour identifier cette tâche';
              }
              if (value.trim().length < 2) {
                return 'Le titre doit contenir au moins 2 caractères';
              }
              if (value.length > 200) {
                return 'Le titre ne peut pas dépasser 200 caractères (actuellement ${value.length})';
              }
              return null;
            },
            onSaved: (value) => _title = value!.trim(),
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description (optionnel)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Glassmorphism.glassCard(
          blur: 6.0,
          opacity: 0.05,
          borderRadius: BorderRadiusTokens.input,
          padding: EdgeInsets.zero,
          child: TextFormField(
            initialValue: _description,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: 'Détails additionnels sur la tâche...',
              hintStyle: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.7)),
              border: OutlineInputBorder(
                borderRadius: BorderRadiusTokens.input,
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadiusTokens.input,
                borderSide: BorderSide(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.all(16),
            ),
            maxLines: 3,
            maxLength: 1000,
            onSaved: (value) => _description = value?.trim() ?? '',
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Catégorie (optionnel)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Glassmorphism.glassCard(
          blur: 6.0,
          opacity: 0.05,
          borderRadius: BorderRadiusTokens.input,
          padding: EdgeInsets.zero,
          child: TextFormField(
            initialValue: _category,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: 'Ex: Travail, Personnel, Urgent...',
              hintStyle: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.7)),
              border: OutlineInputBorder(
                borderRadius: BorderRadiusTokens.input,
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadiusTokens.input,
                borderSide: BorderSide(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.all(16),
            ),
            onSaved: (value) => _category = value?.trim() ?? '',
            textCapitalization: TextCapitalization.words,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildCancelButton(),
        const SizedBox(width: 12),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildCancelButton() {
    return Glassmorphism.glassButton(
      onPressed: () => Navigator.of(context).pop(),
      color: AppTheme.textSecondary,
      blur: 8.0,
      opacity: 0.1,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      borderRadius: BorderRadiusTokens.button,
      child: const Text(
        'Annuler',
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Glassmorphism.glassButton(
      onPressed: _submit,
      color: AppTheme.primaryColor,
      blur: 12.0,
      opacity: 0.9,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      borderRadius: BorderRadiusTokens.button,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.initialTask == null ? Icons.add : Icons.save,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            widget.initialTask == null ? 'Ajouter' : 'Enregistrer',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      
      final task = Task(
        id: widget.initialTask?.id ?? const Uuid().v4(),
        title: _title,
        description: _description.isEmpty ? null : _description,
        category: _category.isEmpty ? null : _category,
        eloScore: widget.initialTask?.eloScore ?? 1200.0,
        isCompleted: widget.initialTask?.isCompleted ?? false,
        createdAt: widget.initialTask?.createdAt ?? DateTime.now(),
        completedAt: widget.initialTask?.completedAt,
        dueDate: widget.initialTask?.dueDate,
        tags: widget.initialTask?.tags ?? [],
        priority: widget.initialTask?.priority ?? 0,
        updatedAt: DateTime.now(),
        lastChosenAt: widget.initialTask?.lastChosenAt,
      );
      
      widget.onSubmit(task);
      Navigator.of(context).pop();
    }
  }
}