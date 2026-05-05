import 'package:flutter/material.dart';
import 'package:prioris/domain/services/core/consent_service.dart';
import 'package:prioris/l10n/app_localizations.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyPolicyTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildPolicySections(),
        ),
      ),
    );
  }

  List<Widget> _buildPolicySections() => [
    _section('Dernière mise à jour : avril 2026'),
    const SizedBox(height: 16),
    _heading('1. RESPONSABLE DU TRAITEMENT'),
    _body(
      'Prioris est un service de productivité personnelle développé par Thibaut Lambert.\n'
      'Contact : ${ConsentService.consentContactEmail}',
    ),
    _heading('2. DONNÉES COLLECTÉES'),
    _body(
      'Nous collectons les données suivantes :\n'
      '• Votre adresse email et les informations de votre profil\n'
      '• Vos tâches, listes et habitudes que vous créez dans l\'application\n'
      '• Des données d\'utilisation anonymes pour améliorer le service',
    ),
    _heading('3. FINALITÉ DU TRAITEMENT'),
    _body(
      'Vos données sont utilisées exclusivement pour :\n'
      '• Vous fournir le service de priorisation personnelle\n'
      '• Synchroniser vos données entre vos appareils\n'
      '• Vous permettre de vous reconnecter à votre compte',
    ),
    _heading('4. HÉBERGEMENT ET SÉCURITÉ'),
    _body(
      'Vos données sont stockées de façon sécurisée via une infrastructure sécurisée.\n'
      'Aucune donnée n\'est partagée avec des tiers à des fins publicitaires ou commerciales.',
    ),
    _heading('5. VOS DROITS'),
    _body(
      'Conformément au RGPD, vous disposez d\'un droit d\'accès, de rectification et de suppression de vos données.\n'
      'Pour exercer ces droits, envoyez un email à : ${ConsentService.consentContactEmail}',
    ),
    _heading('6. SERVICES TIERS'),
    _body(
      '• Supabase : hébergement et base de données (données nécessaires au fonctionnement)\n'
      '• Google Sign-In : authentification optionnelle (si vous choisissez de vous connecter avec Google)',
    ),
  ];

  Widget _heading(String text) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 4),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      );

  Widget _body(String text) =>
      Text(text, style: const TextStyle(fontSize: 14, height: 1.5));

  Widget _section(String text) => Text(
        text,
        style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
      );
}
