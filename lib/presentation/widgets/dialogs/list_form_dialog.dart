import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
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
              _buildDialogTitle(context, l10n),
              const SizedBox(height: 16),
              _buildNameField(l10n),
              const SizedBox(height: 16),
              _buildDescriptionField(l10n),
              const SizedBox(height: 16),
              _buildTypeDropdown(l10n),
              const SizedBox(height: 24),
              _buildActionButtons(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogTitle(BuildContext context, AppLocalizations l10n) {
    return Text(
      widget.initialList == null ? l10n.listFormCreateTitle : l10n.listFormEditTitle,
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }

  Widget _buildNameField(AppLocalizations l10n) {
    return TextFormField(
      initialValue: _name,
      decoration: InputDecoration(
        labelText: l10n.listEditNameLabel,
        border: const OutlineInputBorder(),
        hintText: l10n.listNameHint,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return l10n.listNameRequired;
        }
        if (value.trim().length < 2) {
          return l10n.listNameMinLength;
        }
        if (value.length > 100) {
          return l10n.listNameMaxLength(value.length);
        }
        return null;
      },
      onSaved: (value) => _name = value!.trim(),
    );
  }

  Widget _buildDescriptionField(AppLocalizations l10n) {
    return TextFormField(
      initialValue: _description,
      decoration: InputDecoration(
        labelText: l10n.taskDescriptionFieldLabel,
        border: const OutlineInputBorder(),
      ),
      maxLines: 2,
      maxLength: 500,
      onSaved: (value) => _description = value?.trim() ?? '',
    );
  }

  Widget _buildTypeDropdown(AppLocalizations l10n) {
    return DropdownButtonFormField<ListType>(
      value: _type,
      decoration: InputDecoration(
        labelText: l10n.listTypeLabel,
        border: const OutlineInputBorder(),
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
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
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
          child: Text(widget.initialList == null ? l10n.create : l10n.save),
        ),
      ],
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

