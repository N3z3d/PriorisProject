import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/common/forms/common_button.dart';

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
            // Titre
            Row(
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
            ),
            const SizedBox(height: 24),
            
            // Formulaire
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom de la liste
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom de la liste *',
                      hintText: 'Ex: Courses du week-end',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.list),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le nom de la liste est obligatoire';
                      }
                      if (value.trim().length < 2) {
                        return 'Le nom doit contenir au moins 2 caractères';
                      }
                      if (value.trim().length > 100) {
                        return 'Le nom ne peut pas dépasser 100 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Type de liste
                  DropdownButtonFormField<ListType>(
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
                              _getTypeIcon(type),
                              size: 18,
                              color: _getTypeColor(type),
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
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optionnelle)',
                      hintText: 'Décrivez le contenu de cette liste...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value != null && value.trim().length > 500) {
                        return 'La description ne peut pas dépasser 500 caractères';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Boutons d'action
            Row(
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
            ),
          ],
        ),
      ),
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
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      
      final CustomList list;
      
      if (widget.initialList != null) {
        // Modification d'une liste existante
        list = widget.initialList!.copyWith(
          name: name,
          description: description.isEmpty ? null : description,
          type: _selectedType,
          updatedAt: DateTime.now(),
        );
      } else {
        // Création d'une nouvelle liste
        list = CustomList(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          type: _selectedType,
          description: description.isEmpty ? null : description,
          items: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }

      widget.onSubmit(list);
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Retourne l'icône pour un type de liste
  IconData _getTypeIcon(ListType type) {
    switch (type) {
      case ListType.SHOPPING:
        return Icons.shopping_cart;
      case ListType.TRAVEL:
        return Icons.flight;
      case ListType.MOVIES:
        return Icons.movie;
      case ListType.BOOKS:
        return Icons.book;
      case ListType.RESTAURANTS:
        return Icons.restaurant;
      case ListType.PROJECTS:
        return Icons.work;
      case ListType.CUSTOM:
        return Icons.list;
    }
  }

  /// Retourne la couleur pour un type de liste
  Color _getTypeColor(ListType type) {
    switch (type) {
      case ListType.SHOPPING:
        return Colors.blue;
      case ListType.TRAVEL:
        return Colors.green;
      case ListType.MOVIES:
        return Colors.purple;
      case ListType.BOOKS:
        return Colors.amber;
      case ListType.RESTAURANTS:
        return Colors.pink;
      case ListType.PROJECTS:
        return Colors.orange;
      case ListType.CUSTOM:
        return AppTheme.primaryColor;
    }
  }
} 

