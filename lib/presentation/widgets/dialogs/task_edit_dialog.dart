import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/theme/glassmorphism.dart';

/// Dialog d'édition/création de tâche avec design glassmorphisme
class TaskEditDialog extends StatefulWidget {
  /// Tâche existante à éditer (null pour création)
  final Task? initialTask;
  
  /// Callback appelé lors de la soumission
  final Function(Task) onSubmit;

  const TaskEditDialog({
    super.key,
    this.initialTask,
    required this.onSubmit,
  });

  @override
  State<TaskEditDialog> createState() => _TaskEditDialogState();
}

class _TaskEditDialogState extends State<TaskEditDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  
  final _formKey = GlobalKey<FormState>();
  final _titleFocusNode = FocusNode();
  
  bool get _isEditing => widget.initialTask != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    
    // Focus automatique sur le champ titre
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocusNode.requestFocus();
    });
  }

  void _initializeControllers() {
    _titleController = TextEditingController(
      text: widget.initialTask?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialTask?.description ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.initialTask?.category ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: _buildGlassmorphismContainer(),
    );
  }

  /// Construit le container principal avec effet glassmorphisme
  Widget _buildGlassmorphismContainer() {
    return Glassmorphism.glassCard(
      blur: 20.0,
      opacity: 0.1,
      borderRadius: BorderRadiusTokens.modal,
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.2),
        width: 1,
      ),
      padding: const EdgeInsets.all(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildFormFields(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit l'en-tête du dialog
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            _isEditing ? Icons.edit : Icons.add_task,
            color: AppTheme.primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            _isEditing ? 'Modifier la tâche' : 'Ajouter une tâche',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  /// Construit les champs de formulaire
  Widget _buildFormFields() {
    return Column(
      children: [
        _buildTitleField(),
        const SizedBox(height: 16),
        _buildDescriptionField(),
        const SizedBox(height: 16),
        _buildCategoryField(),
      ],
    );
  }

  /// Construit le champ titre
  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      focusNode: _titleFocusNode,
      decoration: InputDecoration(
        labelText: 'Titre',
        hintText: 'Entrez le titre de la tâche',
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadiusTokens.input,
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadiusTokens.input,
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadiusTokens.input,
          borderSide: BorderSide(
            color: AppTheme.primaryColor,
            width: 2,
          ),
        ),
        prefixIcon: Icon(
          Icons.title,
          color: AppTheme.textSecondary,
        ),
      ),
      textCapitalization: TextCapitalization.sentences,
      validator: _validateTitle,
    );
  }

  /// Construit le champ description
  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Description (optionnel)',
        hintText: 'Ajoutez une description détaillée',
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadiusTokens.input,
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadiusTokens.input,
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadiusTokens.input,
          borderSide: BorderSide(
            color: AppTheme.primaryColor,
            width: 2,
          ),
        ),
        prefixIcon: Icon(
          Icons.description,
          color: AppTheme.textSecondary,
        ),
      ),
      maxLines: 3,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  /// Construit le champ catégorie
  Widget _buildCategoryField() {
    return TextFormField(
      controller: _categoryController,
      decoration: InputDecoration(
        labelText: 'Catégorie (optionnel)',
        hintText: 'Travail, Personnel, etc.',
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadiusTokens.input,
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadiusTokens.input,
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadiusTokens.input,
          borderSide: BorderSide(
            color: AppTheme.primaryColor,
            width: 2,
          ),
        ),
        prefixIcon: Icon(
          Icons.category,
          color: AppTheme.textSecondary,
        ),
      ),
      textCapitalization: TextCapitalization.words,
    );
  }

  /// Construit les boutons d'action
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildCancelButton(),
        const SizedBox(width: 12),
        _buildSubmitButton(),
      ],
    );
  }

  /// Construit le bouton d'annulation
  Widget _buildCancelButton() {
    return Glassmorphism.glassButton(
      onPressed: () => Navigator.of(context).pop(),
      color: AppTheme.textSecondary,
      blur: 10.0,
      opacity: 0.1,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      borderRadius: BorderRadiusTokens.input,
      child: Text(
        'Annuler',
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Construit le bouton de soumission
  Widget _buildSubmitButton() {
    return Glassmorphism.glassButton(
      onPressed: _handleSubmit,
      color: AppTheme.primaryColor,
      blur: 10.0,
      opacity: 0.2,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      borderRadius: BorderRadiusTokens.input,
      child: Text(
        _isEditing ? 'Enregistrer' : 'Ajouter',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Valide le champ titre
  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le titre est obligatoire pour identifier cette tâche';
    }
    
    if (value.trim().length < 2) {
      return 'Le titre doit contenir au moins 2 caractères';
    }
    
    if (value.length > 200) {
      return 'Le titre ne peut pas dépasser 200 caractères';
    }
    
    return null;
  }

  /// Gère la soumission du formulaire
  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final category = _categoryController.text.trim();

    final task = _isEditing
        ? widget.initialTask!.copyWith(
            title: title,
            description: description.isEmpty ? null : description,
            category: category.isEmpty ? null : category,
            updatedAt: DateTime.now(),
          )
        : Task(
            title: title,
            description: description.isEmpty ? null : description,
            category: category.isEmpty ? null : category,
            eloScore: 1200.0,
          );

    widget.onSubmit(task);
    Navigator.of(context).pop();
  }
}