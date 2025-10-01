/// **LOGIN FORM SKELETON** - SRP Specialized Component
///
/// **LOT 7** : Composant spécialisé pour formulaires de connexion
/// **SRP** : Gestion uniquement des formulaires de login/authentification
/// **Taille** : <200 lignes (extraction depuis 700 lignes God Class)

import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import '../interfaces/form_skeleton_interface.dart';
import '../shared/form_skeleton_helpers.dart';

/// Composant spécialisé pour créer des skelettes de formulaires de connexion
///
/// **SRP** : Formulaires d'authentification uniquement
/// **OCP** : Extensible via options (social login, forgot password, etc.)
class LoginFormSkeleton implements IFormSkeletonComponent {
  @override
  String get componentId => 'login_form_skeleton';

  @override
  List<String> get supportedTypes => [
    'login_form',
    'auth_form',
    'signin_form',
    'authentication',
  ];

  @override
  List<String> get availableVariants => [
    'login',
    'minimal',
  ];

  @override
  bool canHandle(String skeletonType) {
    return supportedTypes.contains(skeletonType) ||
           skeletonType.contains('login') ||
           skeletonType.contains('auth') ||
           skeletonType.contains('signin');
  }

  @override
  Widget createSkeleton({
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    return createVariant(
      'login',
      width: width,
      height: height,
      options: options,
    );
  }

  @override
  Widget createVariant(
    String variant, {
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    final config = SkeletonConfig(
      width: width,
      height: height,
      options: options ?? {},
    );

    switch (variant) {
      case 'minimal':
        return _createMinimalLogin(config);
      case 'login':
      default:
        return _createStandardLogin(config);
    }
  }

  /// Crée un formulaire de connexion standard complet
  Widget _createStandardLogin(SkeletonConfig config) {
    final showSocialLogin = config.options['showSocialLogin'] ?? true;
    final showForgotPassword = config.options['showForgotPassword'] ?? true;
    final showSignUp = config.options['showSignUp'] ?? true;

    return SkeletonContainer(
      width: config.width,
      height: config.height,
      borderRadius: BorderRadiusTokens.modal,
      animationDuration: config.animationDuration ?? const Duration(milliseconds: 1500),
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 24,
        children: [
          // Logo/Title section
          _createHeader(),

          // Login credentials fields
          SharedFormHelpers.createFormField('text', required: true), // Email
          SharedFormHelpers.createFormField('text', required: true), // Password

          // Forgot password link
          if (showForgotPassword)
            SkeletonShapeFactory.text(width: 120, height: 14),

          // Login button
          SkeletonShapeFactory.button(width: double.infinity),

          // Social login section
          if (showSocialLogin)
            _createSocialSection(),

          // Sign up link
          if (showSignUp)
            SkeletonShapeFactory.text(width: 160, height: 16),
        ],
      ),
    );
  }

  /// Crée un formulaire de connexion minimal
  Widget _createMinimalLogin(SkeletonConfig config) {
    return SkeletonContainer(
      width: config.width,
      height: config.height,
      borderRadius: BorderRadiusTokens.card,
      animationDuration: config.animationDuration ?? const Duration(milliseconds: 1500),
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          SkeletonShapeFactory.text(width: 120, height: 20),
          SharedFormHelpers.createFormField('text', required: true),
          SharedFormHelpers.createFormField('text', required: true),
          SkeletonShapeFactory.button(width: double.infinity),
        ],
      ),
    );
  }

  // === MÉTHODES HELPER MINIMALES ===

  Widget _createHeader() {
    return SkeletonLayoutBuilder.vertical(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 12,
      children: [
        SkeletonShapeFactory.circular(size: 60), // Logo
        SkeletonShapeFactory.text(width: 150, height: 28), // Title
      ],
    );
  }

  Widget _createSocialSection() {
    return SkeletonLayoutBuilder.horizontal(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SkeletonShapeFactory.button(width: 100, height: 40),
        SkeletonShapeFactory.button(width: 100, height: 40),
      ],
    );
  }
}