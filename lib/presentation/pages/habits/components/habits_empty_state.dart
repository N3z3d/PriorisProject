import 'package:flutter/material.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

class HabitsEmptyState extends StatelessWidget {
  final VoidCallback onCreateHabit;

  const HabitsEmptyState({
    super.key,
    required this.onCreateHabit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIllustration(),
          const SizedBox(height: 16),
          _buildTitle(l10n),
          const SizedBox(height: 8),
          _buildSubtitle(l10n),
          const SizedBox(height: 24),
          _buildActionButton(l10n),
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

  Widget _buildTitle(AppLocalizations l10n) {
    return Text(
      l10n.habitsEmptyTitle,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildSubtitle(AppLocalizations l10n) {
    return Text(
      l10n.habitsEmptySubtitle,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[500],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButton(AppLocalizations l10n) {
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
        child: Text(
          l10n.habitsButtonCreate,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
