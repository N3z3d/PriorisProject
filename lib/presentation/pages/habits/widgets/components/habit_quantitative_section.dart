import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/common/forms/common_text_field.dart';
import 'package:prioris/l10n/app_localizations.dart';

class HabitQuantitativeSection extends StatelessWidget {
  const HabitQuantitativeSection({
    super.key,
    required this.targetController,
    required this.unitController,
    required this.onTargetChanged,
    required this.onUnitChanged,
    this.targetFieldKey,
    this.unitFieldKey,
  });

  final TextEditingController targetController;
  final TextEditingController unitController;
  final ValueChanged<double> onTargetChanged;
  final ValueChanged<String> onUnitChanged;
  final Key? targetFieldKey;
  final Key? unitFieldKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CommonTextField(
            fieldKey: targetFieldKey,
            controller: targetController,
            label: l10n.habitFormQuantTargetLabel,
            hint: l10n.habitFormQuantTargetHint,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) => onTargetChanged(_parseTarget(value)),
            prefix: const Icon(Icons.flag),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CommonTextField(
            fieldKey: unitFieldKey,
            controller: unitController,
            label: l10n.habitFormQuantUnitLabel,
            hint: l10n.habitFormQuantUnitHint,
            onChanged: (value) => onUnitChanged(value?.trim() ?? ''),
            prefix: const Icon(Icons.straighten),
          ),
        ),
      ],
    );
  }

  double _parseTarget(String? rawValue) {
    if (rawValue == null) {
      return 1.0;
    }

    final normalized = rawValue.replaceAll(',', '.').trim();
    final parsed = double.tryParse(normalized);
    if (parsed == null || parsed <= 0) {
      return 1.0;
    }
    return parsed;
  }
}
