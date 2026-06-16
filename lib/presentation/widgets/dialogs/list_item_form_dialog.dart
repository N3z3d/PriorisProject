import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
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
                  _buildDialogHeader(context, l10n),
                  const SizedBox(height: 16),
                  _buildTitleField(l10n),
                  const SizedBox(height: 16),
                  _buildDescriptionField(l10n),
                  const SizedBox(height: 16),
                  _buildCategoryField(l10n),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildActionButtons(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogHeader(BuildContext context, AppLocalizations l10n) {
    return Text(
      widget.initialItem == null ? l10n.listItemAddTitle : l10n.listItemEditTitle,
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }

  Widget _buildTitleField(AppLocalizations l10n) {
    return TextFormField(
      initialValue: _title,
      decoration: InputDecoration(
        labelText: l10n.taskTitleFieldLabel,
        border: const OutlineInputBorder(),
        hintText: l10n.listItemTitleHint,
      ),
      validator: (value) => _validateTitle(value, l10n),
      onSaved: (value) => _title = value!.trim(),
    );
  }

  String? _validateTitle(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.listItemTitleRequired;
    }
    if (value.trim().length < 2) {
      return l10n.listItemTitleMinLength;
    }
    if (value.length > 200) {
      return l10n.listItemTitleMaxLength(value.length);
    }
    return null;
  }

  Widget _buildDescriptionField(AppLocalizations l10n) {
    return TextFormField(
      initialValue: _description,
      decoration: InputDecoration(
        labelText: l10n.taskDescriptionFieldLabel,
        border: const OutlineInputBorder(),
      ),
      maxLines: 3,
      maxLength: 1000,
      onSaved: (value) => _description = value?.trim() ?? '',
    );
  }

  Widget _buildCategoryField(AppLocalizations l10n) {
    return TextFormField(
      initialValue: _category,
      decoration: InputDecoration(
        labelText: l10n.categoryOptionalLabel,
        border: const OutlineInputBorder(),
        hintText: l10n.listItemCategoryHint,
      ),
      onSaved: (value) => _category = value?.trim() ?? '',
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
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _handleSubmit,
          child: Text(widget.initialItem == null ? l10n.add : l10n.edit),
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final item = ListItem(
      id: widget.initialItem?.id ?? const Uuid().v4(),
      title: _title,
      description: _description.isEmpty ? null : _description,
      category: _category.isEmpty ? null : _category,
      listId: widget.listId,
      createdAt: widget.initialItem?.createdAt ?? DateTime.now(),
      isCompleted: widget.initialItem?.isCompleted ?? false,
      completedAt: widget.initialItem?.completedAt,
      eloScore: widget.initialItem?.eloScore ?? 1200.0,
    );

    widget.onSubmit(item);
    Navigator.of(context).pop();
  }
}