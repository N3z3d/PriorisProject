import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';

/// Widget pour les champs quantitatifs d'une habitude (objectif et unité)
class HabitQuantitativeForm extends StatelessWidget {
  /// Contrôleur pour la valeur cible
  final TextEditingController targetValueController;
  
  /// Contrôleur pour l'unité
  final TextEditingController unitController;
  
  /// Type d'habitude sélectionné
  final HabitType selectedType;

  const HabitQuantitativeForm({
    super.key,
    required this.targetValueController,
    required this.unitController,
    required this.selectedType,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedType != HabitType.quantitative) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: targetValueController,
                decoration: const InputDecoration(
                  labelText: 'Objectif *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (selectedType == HabitType.quantitative) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Objectif requis';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Nombre invalide';
                    }
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: unitController,
                decoration: const InputDecoration(
                  labelText: 'Unité',
                  border: OutlineInputBorder(),
                  hintText: 'ex: verres',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
} 
