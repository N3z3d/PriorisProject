import 'package:flutter/material.dart';

/// Loading state component for habits following SRP
class HabitsLoadingState extends StatelessWidget {
  const HabitsLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
