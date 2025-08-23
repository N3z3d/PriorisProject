import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/common/forms/common_button.dart';

/// Onboarding ultra-simplifié pour expliquer la persistance des données
/// 
/// PRINCIPE UX: 
/// - Message rassurant principal: "Tout est automatique"
/// - Éliminer la complexité technique 
/// - Focus sur les bénéfices utilisateur
/// - Call-to-action clair pour commencer
class SimplifiedDataOnboarding extends ConsumerWidget {
  final VoidCallback? onGetStarted;
  
  const SimplifiedDataOnboarding({
    super.key,
    this.onGetStarted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      // WCAG 1.3.1 : Structure d'onboarding avec région landmark
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadiusTokens.card,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icône principale rassurante
          Semantics(
            image: true,
            label: 'Icône de protection - Bouclier de sécurité',
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shield_outlined,
                size: 48,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Titre principal
          Semantics(
            // WCAG 2.4.6 : En-tête principal de l'onboarding
            header: true,
            child: const Text(
              'Vos listes sont automatiquement protégées',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                height: 1.2,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Sous-titre rassurant
          Text(
            'Prioris s\'occupe de tout. Créez vos listes, nous nous chargeons du reste.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Bénéfices visuels simples
          Semantics(
            // WCAG 1.3.2 : Groupe de bénéfices avec ordre logique
            container: true,
            child: Column(
              children: [
                // WCAG 1.3.2 : Ordre logique pour navigation clavier
                _buildBenefit(
                  icon: Icons.offline_bolt,
                  title: 'Fonctionne hors ligne',
                  description: 'Accès à vos listes même sans connexion internet',
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildBenefit(
                  icon: Icons.sync,
                  title: 'Sync automatique',
                  description: 'Vos données se synchronisent entre appareils',
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildBenefit(
                  icon: Icons.security,
                  title: 'Toujours sécurisé',
                  description: 'Protection et chiffrement de vos données personnelles',
                  color: Colors.green,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Call-to-action principal
          SizedBox(
            width: double.infinity,
            child: Focus(
              // WCAG 2.4.3 : Focus automatique sur action principale
              autofocus: true,
              child: CommonButton(
                onPressed: () {
                  _markOnboardingCompleted();
                  onGetStarted?.call();
                },
                text: 'Créer ma première liste',
                isPrimary: true,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Lien discret pour les détails techniques
          GestureDetector(
            onTap: () => _showTechnicalDetails(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Comment ça marche ?',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.primaryColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Semantics(
      // WCAG 1.3.1 : Chaque bénéfice est un élément focusable
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadiusTokens.card,
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: color,
                semanticLabel: _getIconSemanticLabel(icon),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// WCAG 1.1.1 : Fournit des labels sémantiques pour les icônes
  String _getIconSemanticLabel(IconData icon) {
    switch (icon) {
      case Icons.offline_bolt:
        return 'Icône mode hors ligne';
      case Icons.sync:
        return 'Icône synchronisation';
      case Icons.security:
        return 'Icône sécurité';
      default:
        return 'Icône';
    }
  }

  void _showTechnicalDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusTokens.dialog,
        ),
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text('Comment ça marche'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TechnicalPoint(
              icon: Icons.phone_android,
              title: 'Stockage local',
              description: 'Vos données sont toujours disponibles sur votre appareil, même sans connexion.',
            ),
            SizedBox(height: 16),
            _TechnicalPoint(
              icon: Icons.cloud_sync,
              title: 'Synchronisation intelligente',
              description: 'Quand vous vous connectez, vos données se synchronisent automatiquement entre tous vos appareils.',
            ),
            SizedBox(height: 16),
            _TechnicalPoint(
              icon: Icons.merge_type,
              title: 'Fusion automatique',
              description: 'Si des conflits surviennent, nous fusionnons vos données intelligemment sans rien perdre.',
            ),
          ],
        ),
        actions: [
          CommonButton(
            onPressed: () => Navigator.of(context).pop(),
            text: 'Compris',
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  void _markOnboardingCompleted() {
    // TODO: Store in shared preferences that onboarding is completed
  }
}

/// Widget pour afficher un point technique
class _TechnicalPoint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _TechnicalPoint({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadiusTokens.button,
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Version compacte pour l'affichage inline dans l'app
class CompactDataOnboardingBanner extends ConsumerWidget {
  final VoidCallback? onDismiss;
  
  const CompactDataOnboardingBanner({
    super.key,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadiusTokens.card,
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.shield_outlined,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vos données sont protégées',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Sync automatique et sauvegarde locale',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(
              Icons.close,
              size: 18,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}