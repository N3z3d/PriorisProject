import 'package:flutter/material.dart';
import 'package:prioris/core/config/app_config.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/pilot/pilot_instance_notice.dart';

/// Widget d'en-tete de la page de connexion.
///
/// SRP: affiche uniquement le logo et le titre.
class LoginHeader extends StatelessWidget {
  const LoginHeader({
    super.key,
    required this.isSignUp,
  });

  final bool isSignUp;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final config = AppConfig.instance;

    return Column(
      children: [
        Icon(
          Icons.checklist_rtl,
          size: 64,
          color: AppTheme.lightTheme.primaryColor,
        ),
        const SizedBox(height: 16),
        Text(
          'Prioris',
          style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.lightTheme.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          isSignUp
              ? l10n?.authSignUpTitle ?? 'Creer un compte'
              : l10n?.authLoginTitle ?? 'Connectez-vous',
          style: AppTheme.lightTheme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        if (config.hasExplicitPilotInstance) ...[
          const SizedBox(height: 20),
          const PilotInstanceNotice(),
        ],
      ],
    );
  }
}
