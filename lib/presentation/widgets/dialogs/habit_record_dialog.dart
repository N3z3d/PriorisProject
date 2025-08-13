import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Widget dialog pour enregistrer une valeur d'habitude quantitative
class HabitRecordDialog extends StatefulWidget {
  /// Habitude à enregistrer
  final Habit habit;
  
  /// Valeur actuelle
  final dynamic currentValue;
  
  /// Callback appelé lors de l'enregistrement
  final Function(dynamic value) onSave;

  const HabitRecordDialog({
    super.key,
    required this.habit,
    required this.currentValue,
    required this.onSave,
  });

  @override
  State<HabitRecordDialog> createState() => _HabitRecordDialogState();
}

class _HabitRecordDialogState extends State<HabitRecordDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: (widget.currentValue as double?)?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveValue() {
    final value = double.tryParse(_controller.text);
    if (value != null) {
      widget.onSave(value);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSM),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            ),
            child: Icon(
              Icons.edit,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMD),
          Expanded(
            child: Text(
              'Enregistrer ${widget.habit.name}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Valeur actuelle pour aujourd\'hui',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppTheme.spacingMD),
          TextFormField(
            controller: _controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Valeur',
              suffixText: widget.habit.unit,
              prefixIcon: const Icon(Icons.numbers),
            ),
            onFieldSubmitted: (_) => _saveValue(),
          ),
          if (widget.habit.targetValue != null) ...[
            const SizedBox(height: AppTheme.spacingMD),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMD),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                border: Border.all(
                  color: AppTheme.infoColor.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    color: AppTheme.infoColor,
                    size: 16,
                  ),
                  const SizedBox(width: AppTheme.spacingSM),
                  Text(
                    'Objectif : ${widget.habit.targetValue} ${widget.habit.unit ?? ''}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.infoColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _saveValue,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
} 

