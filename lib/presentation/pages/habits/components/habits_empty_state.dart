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
      'Créez une habitude ou démarrez avec un modèle.',
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[500],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButton() {
    return Column(
      children: [
        SizedBox(
          width: 280,
          height: 48,
          child: ElevatedButton(
            onPressed: onNavigateToAdd,
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
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            // TODO: Show template selection modal
          },
          child: Text(
            'Explorer les modèles',
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildTemplatesSuggestions(),
      ],
    );
  }

  Widget _buildTemplatesSuggestions() {
    final templates = [
      _TemplateModel(
        icon: Icons.fitness_center,
        title: 'Sport quotidien',
        description: '30 min d\'exercice',
        color: const Color(0xFF10b981),
      ),
      _TemplateModel(
        icon: Icons.menu_book,
        title: 'Lecture',
        description: '20 pages par jour',
        color: const Color(0xFF3b82f6),
      ),
      _TemplateModel(
        icon: Icons.self_improvement,
        title: 'Méditation',
        description: '10 min le matin',
        color: const Color(0xFF8b5cf6),
      ),
    ];

    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: templates.map((template) => _buildTemplateCard(template)).toList(),
      ),
    );
  }

  Widget _buildTemplateCard(_TemplateModel template) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: template.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              template.icon,
              color: template.color,
              size: 22,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            template.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            template.description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateModel {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  _TemplateModel({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
