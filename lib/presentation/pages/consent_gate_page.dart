import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/auth_providers.dart';
import 'package:prioris/data/providers/consent_providers.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/routes/app_routes.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

class ConsentGatePage extends ConsumerStatefulWidget {
  const ConsentGatePage({super.key});

  @override
  ConsumerState<ConsentGatePage> createState() => _ConsentGatePageState();
}

class _ConsentGatePageState extends ConsumerState<ConsentGatePage> {
  bool _signingOut = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final consentAsync = ref.watch(consentProvider);
    // Désactive les actions pendant une opération en cours (accept via l'état
    // loading du consentement, signOut via le flag local) : évite le double-tap.
    final isBusy = consentAsync.isLoading || _signingOut;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.security, size: 64, color: Colors.blue),
              const SizedBox(height: 24),
              Text(
                l10n.privacyConsentTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.privacyConsentBody,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.consentGateActionPrompt,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ..._buildActions(context, l10n, isBusy),
            ],
          ),
        ),
      ),
    );
  }

  /// Les 3 choix de l'état terminal (story 10.18) : accepter, lire, se déconnecter.
  List<Widget> _buildActions(
    BuildContext context,
    AppLocalizations l10n,
    bool isBusy,
  ) {
    return [
      // Choix 1 (action principale) : accepter les conditions → re-consent.
      ElevatedButton(
        onPressed: isBusy ? null : () => ref.read(consentProvider.notifier).accept(),
        child: Text(l10n.privacyConsentAcceptButton),
      ),
      const SizedBox(height: 8),
      // Choix 2 : lire les conditions (politique de confidentialité).
      TextButton(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.privacyPolicy),
        child: Text(l10n.privacyConsentReadPolicyLink),
      ),
      // Choix 3 : se déconnecter. La redirection vers LoginPage est gérée par
      // AuthWrapper (guard réactif à l'état d'authentification).
      TextButton(
        onPressed: isBusy ? null : () => _handleSignOut(l10n),
        child: Text(l10n.logout),
      ),
    ];
  }

  /// Déconnexion robuste : attend le résultat, protège contre le double-tap et
  /// surface une erreur au lieu de l'avaler (fire-and-forget).
  Future<void> _handleSignOut(AppLocalizations l10n) async {
    setState(() => _signingOut = true);
    try {
      await ref.read(authControllerProvider).signOut();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.consentGateSignOutError)),
        );
      }
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }
}
