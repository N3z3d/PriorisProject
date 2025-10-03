import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/onboarding/components/onboarding_benefit_card.dart';

/// List of benefits displayed in the onboarding screen
///
/// Presents three main benefits: offline functionality, automatic sync,
/// and security. Each benefit is rendered using OnboardingBenefitCard.
class OnboardingBenefitsList extends StatelessWidget {
  const OnboardingBenefitsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      // WCAG 1.3.2 : Group of benefits with logical order
      container: true,
      child: Column(
        children: [
          // WCAG 1.3.2 : Logical order for keyboard navigation
          const OnboardingBenefitCard(
            icon: Icons.offline_bolt,
            title: 'Fonctionne hors ligne',
            description: 'Accès à vos listes même sans connexion internet',
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          const OnboardingBenefitCard(
            icon: Icons.sync,
            title: 'Sync automatique',
            description: 'Vos données se synchronisent entre appareils',
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          const OnboardingBenefitCard(
            icon: Icons.security,
            title: 'Toujours sécurisé',
            description: 'Protection et chiffrement de vos données personnelles',
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}
