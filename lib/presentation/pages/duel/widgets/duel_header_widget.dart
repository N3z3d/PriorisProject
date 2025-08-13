import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Widget affichant l'en-tête psychologique explicatif du système de duel
/// 
/// Ce widget explique à l'utilisateur le principe du duel de priorités
/// et l'encourage à faire un choix réfléchi entre deux tâches.
class DuelHeaderWidget extends StatelessWidget {
  const DuelHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _buildHeaderDecoration(),
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeaderIcon(),
              const SizedBox(height: 8),
              _buildHeaderTitle(context),
              const SizedBox(height: 4),
              _buildHeaderSubtitle(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit la décoration du header avec style professionnel
  BoxDecoration _buildHeaderDecoration() {
    return BoxDecoration(
      // Fond professionnel avec bordure subtile
      color: AppTheme.surfaceColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppTheme.dividerColor,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: AppTheme.grey300.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Construit l'icône du header
  Widget _buildHeaderIcon() {
    return Icon(
      Icons.psychology,
      size: 48,
      color: AppTheme.accentColor,
    );
  }

  /// Construit le titre du header
  Widget _buildHeaderTitle(BuildContext context) {
    return Text(
      'Quelle tâche est plus prioritaire ?',
      style: Theme.of(context).textTheme.headlineSmall,
      textAlign: TextAlign.center,
    );
  }

  /// Construit le sous-titre explicatif
  Widget _buildHeaderSubtitle(BuildContext context) {
    return Text(
      'Choisissez celle que vous devriez faire en premier',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      textAlign: TextAlign.center,
    );
  }
} 