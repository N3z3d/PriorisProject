import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/onboarding_providers.dart';
import 'package:prioris/presentation/pages/home_page.dart';
import 'package:prioris/presentation/pages/onboarding/onboarding_flow_page.dart';

/// Décide entre l'onboarding actif et HomePage pour un utilisateur consenti.
///
/// Fail-open : en cas d'erreur de lecture du flag, ne jamais bloquer l'accès.
class OnboardingGate extends ConsumerWidget {
  const OnboardingGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shouldShow = ref.watch(shouldShowOnboardingProvider);
    return shouldShow.when(
      data: (show) => show ? const OnboardingFlowPage() : const HomePage(),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const HomePage(),
    );
  }
}
