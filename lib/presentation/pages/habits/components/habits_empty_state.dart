import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Empty state component for habits following SRP
class HabitsEmptyState extends StatelessWidget {
  final VoidCallback onNavigateToAdd;

  const HabitsEmptyState({
    super.key,
    required this.onNavigateToAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIcon(),
          const SizedBox(height: 16),
          _buildTitle(),
          const SizedBox(height: 8),
          _buildSubtitle(),
          const SizedBox(height: 24),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Icon(
      Icons.psychology,
      size: 80,
      color: AppTheme.accentColor.withValues(alpha: 0.5),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Aucune habitude',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Commencez à construire de meilleures habitudes dès aujourd\'hui !',
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[500],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton.icon(
      onPressed: onNavigateToAdd,
      icon: const Icon(Icons.add),
      label: const Text('Ajouter ma première habitude'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accentColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}
