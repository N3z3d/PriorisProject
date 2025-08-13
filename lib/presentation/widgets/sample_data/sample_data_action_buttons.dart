import 'package:flutter/material.dart';

class SampleDataActionButtons extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onImport;

  const SampleDataActionButtons({
    super.key,
    required this.isLoading,
    required this.onCancel,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: isLoading ? null : onCancel,
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : onImport,
          child: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Importer'),
        ),
      ],
    );
  }
} 
