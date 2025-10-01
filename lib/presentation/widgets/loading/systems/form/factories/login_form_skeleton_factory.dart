import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import '../base_form_skeleton_factory.dart';
import '../form_skeleton_config.dart';

/// Factory for creating login form skeletons
/// Single Responsibility: Creates login form layouts with authentication options
class LoginFormSkeletonFactory extends BaseFormSkeletonFactory {
  @override
  Widget create(FormSkeletonConfig config) {
    return SkeletonContainer(
      width: config.width,
      height: config.height,
      borderRadius: BorderRadiusTokens.modal,
      animationDuration: config.animationDuration ?? defaultAnimationDuration,
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 24,
        children: [
          // Logo and title section
          _createLogoSection(),

          // Login input fields
          _createLoginFields(),

          // Forgot password link
          if (config.showForgotPassword)
            SkeletonShapeFactory.text(width: 120, height: 14),

          // Main login button
          SkeletonShapeFactory.button(width: double.infinity),

          // Social login section
          if (config.showSocialLogin)
            _createSocialLoginSection(),

          // Sign up link
          if (config.showSignUp)
            SkeletonShapeFactory.text(width: 160, height: 16),
        ],
      ),
    );
  }

  /// Creates the logo and title section
  Widget _createLogoSection() {
    return SkeletonLayoutBuilder.vertical(
      children: [
        SkeletonShapeFactory.circular(size: 60),
        const SizedBox(height: 16),
        SkeletonShapeFactory.text(width: 150, height: 28),
      ],
    );
  }

  /// Creates the main login input fields (username/email and password)
  Widget _createLoginFields() {
    return SkeletonLayoutBuilder.vertical(
      spacing: 16,
      children: [
        SkeletonShapeFactory.input(width: double.infinity),
        SkeletonShapeFactory.input(width: double.infinity),
      ],
    );
  }

  /// Creates the social login section with separator and social buttons
  Widget _createSocialLoginSection() {
    return SkeletonLayoutBuilder.vertical(
      spacing: 16,
      children: [
        // Separator with "or" text
        _createSeparatorWithText(),

        // Social login buttons
        _createSocialButtons(),
      ],
    );
  }

  /// Creates a separator line with "or" text in the middle
  Widget _createSeparatorWithText() {
    return SkeletonLayoutBuilder.horizontal(
      children: [
        Expanded(child: SkeletonShapeFactory.rectangular(height: 1)),
        const SizedBox(width: 16),
        SkeletonShapeFactory.text(width: 20, height: 14),
        const SizedBox(width: 16),
        Expanded(child: SkeletonShapeFactory.rectangular(height: 1)),
      ],
    );
  }

  /// Creates social login buttons (typically Google, Facebook, etc.)
  Widget _createSocialButtons() {
    return SkeletonLayoutBuilder.horizontal(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SkeletonShapeFactory.button(width: 100, height: 40),
        SkeletonShapeFactory.button(width: 100, height: 40),
      ],
    );
  }
}