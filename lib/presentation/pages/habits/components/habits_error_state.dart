import 'package:flutter/material.dart';
import 'package:prioris/l10n/app_localizations.dart';

/// Error state component for habits following SRP
class HabitsErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const HabitsErrorState({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIcon(),
          const SizedBox(height: 16),
          _buildTitle(l10n),
          const SizedBox(height: 8),
          _buildErrorMessage(l10n),
          const SizedBox(height: 24),
          _buildRetryButton(l10n),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Icon(
      Icons.error_outline,
      size: 80,
      color: Colors.red[300],
    );
  }

  Widget _buildTitle(AppLocalizations l10n) {
    return Text(
      l10n.habitsErrorTitle,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.red[600],
      ),
    );
  }

  Widget _buildErrorMessage(AppLocalizations l10n) {
    return Text(
      l10n.habitsErrorLoadFailure(error),
      style: TextStyle(
        fontSize: 16,
        color: Colors.red[500],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildRetryButton(AppLocalizations l10n) {
    return ElevatedButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh),
      label: Text(l10n.retry),
    );
  }
}
