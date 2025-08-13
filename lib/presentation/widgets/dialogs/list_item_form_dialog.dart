import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Dialogue d'ajout/édition d'élément de liste
class ListItemFormDialog extends StatefulWidget {
  final ListItem? initialItem;
  final void Function(ListItem) onSubmit;
  final String listId;

  const ListItemFormDialog({
    super.key,
    this.initialItem,
    required this.onSubmit,
    required this.listId,
  });

  @override
  State<ListItemFormDialog> createState() => _ListItemFormDialogState();
}

class _ListItemFormDialogState extends State<ListItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late String _category;

  @override
  void initState() {
    super.initState();
    _title = widget.initialItem?.title ?? '';
    _description = widget.initialItem?.description ?? '';
    _category = widget.initialItem?.category ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusTokens.modal),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 400),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(24),
          children: [
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.initialItem == null ? 'Ajouter un élément' : 'Modifier l\'élément',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _title,
                    decoration: const InputDecoration(
                      labelText: 'Titre',
                      border: OutlineInputBorder(),
                      hintText: 'Ex: Acheter du pain, Réserver hôtel...',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le titre est obligatoire pour identifier cet élément';
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
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _description,
                    decoration: const InputDecoration(
                      labelText: 'Description (optionnel)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    maxLength: 1000,
                    onSaved: (value) => _description = value?.trim() ?? '',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _category,
                    decoration: const InputDecoration(
                      labelText: 'Catégorie (optionnel)',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) => _category = value?.trim() ?? '',
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Annuler'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusTokens.button,
                          ),
                        ),
                        child: Text(widget.initialItem == null ? 'Ajouter' : 'Enregistrer'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      final item = ListItem(
        id: widget.initialItem?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _title,
        description: _description.isEmpty ? null : _description,
        category: _category.isEmpty ? null : _category,
        eloScore: widget.initialItem?.eloScore ?? 1200.0, // Score ELO par défaut
        isCompleted: widget.initialItem?.isCompleted ?? false,
        createdAt: widget.initialItem?.createdAt ?? DateTime.now(),
        listId: widget.listId,
      );
      widget.onSubmit(item);
      Navigator.of(context).pop();
    }
  }
} 

