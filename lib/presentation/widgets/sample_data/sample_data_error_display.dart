import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

class SampleDataErrorDisplay extends StatelessWidget {
  final String errorMessage;

  const SampleDataErrorDisplay({
    super.key,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadiusTokens.button,
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(child: Text(errorMessage)),
        ],
      ),
    );
  }
} 
