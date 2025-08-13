import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/common/displays/premium_card.dart';

/// Widget représentant une carte de tâche dans le système de duel ELO
/// 
/// Cette carte affiche une tâche avec son titre, description, score ELO
/// et permet à l'utilisateur de la sélectionner comme prioritaire.
class DuelTaskCard extends StatelessWidget {
  /// La tâche à afficher
  final Task task;
  
  /// Callback appelé lorsque l'utilisateur sélectionne cette tâche
  final VoidCallback onTap;
  
  /// Indique si les scores ELO doivent être masqués
  final bool hideElo;

  const DuelTaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.hideElo,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: PremiumCard(
        elevation: 4,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTaskHeader(context),
            _buildTaskDescription(context),
            const SizedBox(height: 12),
            _buildTaskChips(),
          ],
        ),
      ),
    );
  }

  /// Construit l'en-tête de la carte avec titre et score ELO
  Widget _buildTaskHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildTaskTitle(context),
        ),
        if (!hideElo) _buildEloScoreBadge(),
      ],
    );
  }

  /// Construit le titre de la tâche
  Widget _buildTaskTitle(BuildContext context) {
    return Text(
      task.title,
      style: Theme.of(context).textTheme.headlineSmall,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Construit la description de la tâche si elle existe
  Widget _buildTaskDescription(BuildContext context) {
    if (task.description == null || task.description!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        task.description!,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Construit les chips de catégorie et date d'échéance
  Widget _buildTaskChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: [
        if (task.category != null)
          _buildCategoryChip(task.category!),
        if (task.dueDate != null)
          _buildDueDateChip(task.dueDate!),
      ],
    );
  }

  /// Construit le badge du score ELO
  Widget _buildEloScoreBadge() {
    final scoreColor = _getScoreColor(task.eloScore);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scoreColor.withValues(alpha: 0.1),
        borderRadius: BorderRadiusTokens.card,
        border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        task.eloScore.toStringAsFixed(0),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: scoreColor,
          fontSize: 12,
        ),
      ),
    );
  }

  /// Détermine la couleur du score ELO
  Color _getScoreColor(double score) {
    if (score >= 1400) {
      return AppTheme.secondaryColor;
    } else if (score >= 1200) {
      return AppTheme.accentColor;
    } else {
      return AppTheme.grey400;
    }
  }

  /// Construit un chip de catégorie
  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadiusTokens.card,
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Construit un chip de date d'échéance
  Widget _buildDueDateChip(DateTime dueDate) {
    final isOverdue = dueDate.isBefore(DateTime.now());
    final color = isOverdue ? Colors.red : AppTheme.accentColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadiusTokens.card,
      ),
      child: Text(
        _formatDate(dueDate),
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Formate une date pour affichage
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return 'Aujourd\'hui';
    } else if (difference == 1) {
      return 'Demain';
    } else if (difference > 0) {
      return 'Dans $difference j';
    } else {
      return 'Il y a ${-difference} j';
    }
  }
} 