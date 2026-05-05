import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/consent_providers.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/routes/app_routes.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

class ConsentGatePage extends ConsumerWidget {
  const ConsentGatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final consentAsync = ref.watch(consentProvider);
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
              TextButton(
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.privacyPolicy),
                child: Text(l10n.privacyConsentReadPolicyLink),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: consentAsync.isLoading
                    ? null
                    : () => ref.read(consentProvider.notifier).accept(),
                child: Text(l10n.privacyConsentAcceptButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
