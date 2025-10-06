import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/validators/form_validators.dart';
import 'package:prioris/presentation/widgets/common/forms/common_button.dart';
import 'package:prioris/presentation/widgets/dialogs/components/list_type_helpers.dart';

/// Dialog pour créer ou éditer une liste personnalisée
class CustomListFormDialog extends StatefulWidget {
  /// Liste à éditer (null pour création)
  final CustomList? initialList;
  
  /// Callback appelé lors de la soumission
  final void Function(CustomList list) onSubmit;

  const CustomListFormDialog({
    super.key,
    this.initialList,
    required this.onSubmit,
  });

  @override
  State<CustomListFormDialog> createState() => _CustomListFormDialogState();
}

class _CustomListFormDialogState extends State<CustomListFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  ListType _selectedType = ListType.CUSTOM;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Pré-remplir les champs si on édite une liste existante
    if (widget.initialList != null) {
      _nameController.text = widget.initialList!.name;
      _descriptionController.text = widget.initialList!.description ?? '';
      _selectedType = widget.initialList!.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialList != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusTokens.modal,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogTitle(isEditing),
            const SizedBox(height: 24),
            _buildForm(),
            const SizedBox(height: 24),
            _buildActionButtons(context, isEditing),
          ],
        ),
      ),
    );
  }

  /// Construit le titre du dialogue
  Widget _buildDialogTitle(bool isEditing) {
    return Row(
      children: [
        Icon(
          isEditing ? Icons.edit : Icons.add,
          color: AppTheme.primaryColor,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          isEditing ? 'Modifier la liste' : 'Créer une nouvelle liste',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Construit le formulaire complet
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNameField(),
          const SizedBox(height: 16),
          _buildTypeSelector(),
          const SizedBox(height: 16),
          _buildDescriptionField(),
        ],
      ),
    );
  }

  /// Construit le champ nom de la liste
  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Nom de la liste *',
        hintText: 'Ex: Courses du week-end',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.list),
      ),
      textCapitalization: TextCapitalization.sentences,
      validator: (value) => FormValidators.requiredText(
        value,
        fieldName: 'nom de la liste',
        maxLength: 100,
      ),
    );
  }

  /// Construit le sélecteur de type de liste
  Widget _buildTypeSelector() {
    return DropdownButtonFormField<ListType>(
      value: _selectedType,
      decoration: const InputDecoration(
        labelText: 'Type de liste',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
      ),
      items: ListType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Row(
            children: [
              Icon(
                ListTypeHelpers.getIcon(type),
                size: 18,
                color: ListTypeHelpers.getColor(type),
              ),
              const SizedBox(width: 8),
              Text(type.displayName),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedType = value;
          });
        }
      },
    );
  }

  /// Construit le champ description
  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description (optionnelle)',
        hintText: 'Décrivez le contenu de cette liste...',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
      ),
      maxLines: 3,
      textCapitalization: TextCapitalization.sentences,
      validator: (value) => FormValidators.optionalText(
        value,
        maxLength: 500,
      ),
    );
  }

  /// Construit les boutons d'action
  Widget _buildActionButtons(BuildContext context, bool isEditing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        const SizedBox(width: 12),
        CommonButton(
          text: isEditing ? 'Modifier' : 'Créer',
          onPressed: _isLoading ? null : _handleSubmit,
          type: ButtonType.primary,
          isLoading: _isLoading,
          icon: isEditing ? Icons.save : Icons.add,
        ),
      ],
    );
  }

  /// Gère la soumission du formulaire
  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final list = _buildCustomList();
      widget.onSubmit(list);
    } catch (e) {
      _showErrorSnackBar(e);
    } finally {
      _setLoadingState(false);
    }
  }

  /// Construit l'objet CustomList à partir des données du formulaire
  CustomList _buildCustomList() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (widget.initialList != null) {
      return widget.initialList!.copyWith(
        name: name,
        description: description.isEmpty ? null : description,
        type: _selectedType,
        updatedAt: DateTime.now(),
      );
    } else {
      return CustomList(
        id: const Uuid().v4(),
        name: name,
        type: _selectedType,
        description: description.isEmpty ? null : description,
        items: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Affiche un message d'erreur
  void _showErrorSnackBar(Object error) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Met à jour l'état de chargement
  void _setLoadingState(bool isLoading) {
    if (mounted) {
      setState(() {
        _isLoading = isLoading;
      });
    }
  }

} 

