import 'package:flutter/material.dart';

class SampleDataStatsDisplay extends StatelessWidget {
  final Map<String, int> stats;

  const SampleDataStatsDisplay({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cette action importera :',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        
        Row(
          children: [
            const Icon(Icons.task_alt, size: 20),
            const SizedBox(width: 8),
            Text('${stats['tasks']} tâches d\'exemple'),
          ],
        ),
        const SizedBox(height: 4),
        
        Row(
          children: [
            const Icon(Icons.track_changes, size: 20),
            const SizedBox(width: 8),
            Text('${stats['habits']} habitudes d\'exemple'),
          ],
        ),
        const SizedBox(height: 4),
        
        Row(
          children: [
            const Icon(Icons.analytics, size: 20),
            const SizedBox(width: 8),
            Text('Total: ${stats['total']} éléments'),
          ],
        ),
      ],
    );
  }
} 
