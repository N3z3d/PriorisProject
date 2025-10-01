import 'package:flutter/material.dart';

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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIcon(),
          const SizedBox(height: 16),
          _buildTitle(),
          const SizedBox(height: 8),
          _buildErrorMessage(),
          const SizedBox(height: 24),
          _buildRetryButton(),
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

  Widget _buildTitle() {
    return Text(
      'Erreur de chargement',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.red[600],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Text(
      'Impossible de charger les habitudes: $error',
      style: TextStyle(
        fontSize: 16,
        color: Colors.red[500],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildRetryButton() {
    return ElevatedButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh),
      label: const Text('Réessayer'),
    );
  }
}
