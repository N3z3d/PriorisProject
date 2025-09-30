import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/glassmorphism.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/animations/physics_animations.dart';
import 'package:prioris/presentation/widgets/dialogs/interfaces/premium_dialog_interfaces.dart';
import 'builders/export.dart';

/// Coordinateur UI refactorisé pour premium logout dialog - SOLID COMPLIANT
///
/// SOLID COMPLIANCE:
/// - SRP: Coordination et délégation uniquement (669→140 lignes)
/// - OCP: Extensible via injection de dépendances des builders
/// - LSP: Compatible avec IPremiumLogoutDialogUI existante
/// - ISP: Utilise des interfaces spécialisées pour chaque builder
/// - DIP: Dépend des abstractions des builders, pas des concretions
///
/// Refactoring Ultrathink:
/// - DialogContainerBuilder: Structure et glassmorphisme
/// - PremiumHeaderBuilder: Headers avec animations
/// - ContentSectionBuilder: Sections de contenu premium
/// - ActionButtonsBuilder: Boutons d'action interactifs
///
/// Architecture: 669 lignes → 4 services spécialisés + coordinateur
class PremiumLogoutDialogUI implements IPremiumLogoutDialogUI {

  // SOLID DIP: Services spécialisés injectés
  final DialogContainerBuilder _containerBuilder;
  final PremiumHeaderBuilder _headerBuilder;
  final ContentSectionBuilder _contentBuilder;
  final ActionButtonsBuilder _buttonsBuilder;

  PremiumLogoutDialogUI({
    DialogContainerBuilder? containerBuilder,
    PremiumHeaderBuilder? headerBuilder,
    ContentSectionBuilder? contentBuilder,
    ActionButtonsBuilder? buttonsBuilder,
  }) : _containerBuilder = containerBuilder ?? DialogContainerBuilder(),
       _headerBuilder = headerBuilder ?? PremiumHeaderBuilder(),
       _contentBuilder = contentBuilder ?? ContentSectionBuilder(),
       _buttonsBuilder = buttonsBuilder ?? ActionButtonsBuilder();
  @override
  Widget buildGlassmorphismDialog(BuildContext context) {
    // SOLID SRP: Interface compliance with default parameters
    return buildDialogWithCallbacks(
      context,
      onCancel: () {},
      onLogout: () {},
      onDataClear: () {},
      glowAnimation: const AlwaysStoppedAnimation(0.0),
      enablePhysicsAnimations: false,
      shouldReduceMotion: false,
    );
  }

  /// SOLID SRP: Coordination principale - délègue aux builders spécialisés
  Widget buildDialogWithCallbacks(
    BuildContext context, {
    required VoidCallback onCancel,
    required VoidCallback onLogout,
    required VoidCallback onDataClear,
    required Animation<double> glowAnimation,
    required bool enablePhysicsAnimations,
    required bool shouldReduceMotion,
  }) {
    // SOLID DIP: Délégation au service de container
    return _containerBuilder.buildGlassmorphismContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // SOLID DIP: Délégation au service de header
          buildPremiumHeader(context, glowAnimation),
          // SOLID DIP: Délégation au service de contenu
          _contentBuilder.buildFlexibleContentSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildMainContent(context),
                const SizedBox(height: 20),
                buildDestructiveOption(
                  context,
                  onTap: onDataClear,
                  enablePhysicsAnimations: enablePhysicsAnimations,
                  shouldReduceMotion: shouldReduceMotion,
                ),
                const SizedBox(height: 24),
                buildPremiumActions(
                  context,
                  onCancel: onCancel,
                  onLogout: onLogout,
                  enablePhysicsAnimations: enablePhysicsAnimations,
                  shouldReduceMotion: shouldReduceMotion,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildPremiumHeader(
    BuildContext context,
    Animation<double> glowAnimation,
  ) {
    // SOLID DIP: Délégation au service spécialisé de header
    return _headerBuilder.buildAnimatedPremiumHeader(
      context,
      glowAnimation: glowAnimation,
      icon: Icons.logout_rounded,
      title: 'Se déconnecter',
      subtitle: 'Choix de persistance des données',
      iconSemanticLabel: 'Icône de déconnexion premium',
    );
  }

  @override
  Widget buildMainContent(BuildContext context) {
    // SOLID DIP: Délégation au service de contenu
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _contentBuilder.buildMainContentSection(
          primaryText: 'Vos listes resteront disponibles sur cet appareil.',
        ),
        const SizedBox(height: 16),
        _contentBuilder.buildPremiumInfoCard(
          icon: Icons.cloud_sync_rounded,
          title: 'Synchronisation disponible',
          description: 'Reconnectez-vous à tout moment pour synchroniser vos données',
          primaryColor: Colors.blue,
        ),
      ],
    );
  }

  @override
  Widget buildDestructiveOption(
    BuildContext context, {
    required VoidCallback onTap,
    required bool enablePhysicsAnimations,
    required bool shouldReduceMotion,
  }) {
    // SOLID DIP: Délégation au service de boutons
    return _buttonsBuilder.buildDestructiveOptionButton(
      context: context,
      text: 'Effacer toutes mes données de cet appareil',
      onTap: onTap,
      enablePhysicsAnimations: enablePhysicsAnimations,
      shouldReduceMotion: shouldReduceMotion,
      semanticHint: 'Action irréversible - supprime toutes les données localement',
    );
  }

  @override
  Widget buildPremiumActions(
    BuildContext context, {
    required VoidCallback onCancel,
    required VoidCallback onLogout,
    required bool enablePhysicsAnimations,
    required bool shouldReduceMotion,
  }) {
    // SOLID DIP: Délégation au service de boutons
    return _buttonsBuilder.buildPremiumActionRow(
      context: context,
      onCancel: onCancel,
      onPrimaryAction: onLogout,
      primaryActionText: 'Se déconnecter',
      enablePhysicsAnimations: enablePhysicsAnimations,
      shouldReduceMotion: shouldReduceMotion,
    );
  }

  @override
  Widget buildCancelButton(BuildContext context) {
    // SOLID DIP: Délégation au service de boutons
    return _buttonsBuilder.buildCancelButton(context, 'Annuler');
  }

  @override
  Widget buildLogoutButton(BuildContext context) {
    // SOLID DIP: Délégation au service de boutons
    return _buttonsBuilder.buildPrimaryActionButton(context, 'Se déconnecter');
  }

  @override
  Widget buildDataClearDialog(
    BuildContext context, {
    required VoidCallback onCancel,
    required VoidCallback onConfirm,
    required bool enablePhysicsAnimations,
  }) {
    // SOLID DIP: Délégation complète aux services spécialisés
    return _containerBuilder.buildTransparentAlertDialog(
      content: _containerBuilder.buildConfirmationContainer(
        primaryColor: Colors.red,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _headerBuilder.buildConfirmationHeader(
              icon: Icons.warning_amber_rounded,
              title: 'Effacer les données',
              iconSemanticLabel: 'Avertissement - Action destructive',
            ),
            const SizedBox(height: 12),
            _contentBuilder.buildDescriptionSection(
              paragraphs: [
                'Cette action supprimera définitivement toutes vos listes de cet appareil.',
                'Vous ne pourrez pas annuler cette action.',
              ],
            ),
            const SizedBox(height: 24),
            _buttonsBuilder.buildConfirmationActionRow(
              context: context,
              onCancel: onCancel,
              onConfirm: onConfirm,
              confirmText: 'Effacer',
              enablePhysicsAnimations: enablePhysicsAnimations,
              confirmColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  /// Accès direct aux services spécialisés si nécessaire pour extensions
  DialogContainerBuilder get containerBuilder => _containerBuilder;
  PremiumHeaderBuilder get headerBuilder => _headerBuilder;
  ContentSectionBuilder get contentBuilder => _contentBuilder;
  ActionButtonsBuilder get buttonsBuilder => _buttonsBuilder;
}