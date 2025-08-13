import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Dialogue de création/édition de liste personnalisée
class ListFormDialog extends StatefulWidget {
  final CustomList? initialList;
  final void Function(CustomList) onSubmit;

  const ListFormDialog({
    super.key,
    this.initialList,
    required this.onSubmit,
  });

  @override
  State<ListFormDialog> createState() => _ListFormDialogState();
}

class _ListFormDialogState extends State<ListFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late ListType _type;

  @override
  void initState() {
    super.initState();
    _name = widget.initialList?.name ?? '';
    _description = widget.initialList?.description ?? '';
    _type = widget.initialList?.type ?? ListType.CUSTOM;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusTokens.modal),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.initialList == null ? 'Créer une nouvelle liste' : 'Modifier la liste',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(
                  labelText: 'Nom de la liste',
                  border: OutlineInputBorder(),
                  hintText: 'Ex: Liste de courses, Voyage Paris...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le nom de la liste est obligatoire pour l\'identifier';
                  }
                  if (value.trim().length < 2) {
                    return 'Le nom doit contenir au moins 2 caractères';
                  }
                  if (value.length > 100) {
                    return 'Le nom ne peut pas dépasser 100 caractères (actuellement ${value.length})';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnel)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                maxLength: 500,
                onSaved: (value) => _description = value?.trim() ?? '',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ListType>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: 'Type de liste',
                  border: OutlineInputBorder(),
                ),
                items: ListType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _type = value);
                },
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
                    child: Text(widget.initialList == null ? 'Créer' : 'Enregistrer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      final list = CustomList(
        id: widget.initialList?.id ?? UniqueKey().toString(),
        name: _name,
        type: _type,
        description: _description,
        items: widget.initialList?.items ?? [],
        createdAt: widget.initialList?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      widget.onSubmit(list);
      Navigator.of(context).pop();
    }
  }
} 

