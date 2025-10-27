import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

class HabitsEmptyState extends StatelessWidget {
  final VoidCallback onCreateHabit;

  const HabitsEmptyState({
    super.key,
    required this.onCreateHabit,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIllustration(),
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

  Widget _buildIllustration() {
    return Icon(
      Icons.psychology,
      size: 80,
      color: AppTheme.accentColor.withValues(alpha: 0.5),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Aucune habitude pour l\'instant',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Créez votre première habitude pour suivre vos progrès.',
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[500],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: 280,
      height: 48,
      child: ElevatedButton(
        onPressed: onCreateHabit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Créer une habitude',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
