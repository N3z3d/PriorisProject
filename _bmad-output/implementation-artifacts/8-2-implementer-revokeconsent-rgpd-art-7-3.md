# Story 8.2 : Implémenter revokeConsent() — RGPD Art. 7.3

Status: review

## Story

En tant qu'utilisateur,
je veux pouvoir retirer mon consentement à tout moment aussi facilement que je l'ai donné,
afin que mes droits RGPD sur le retrait du consentement (Art. 7.3) soient respectés.

## Acceptance Criteria

1. `ConsentService` expose une méthode `revokeConsent()` qui efface les flags de consentement en local (clés `privacy_consent_v1` et `privacy_consent_date_v1` dans SharedPreferences)
2. Un bouton "Retirer mon consentement" est accessible depuis `SettingsPage` dans la section CONFIDENTIALITÉ ET DONNÉES
3. Après retrait, l'utilisateur est redirigé vers `ConsentGatePage` (redirection immédiate via réactivité Riverpod — `AuthWrapper` détecte `consentProvider` → `data(false)` → affiche `ConsentGatePage`)
4. Le bouton est libellé et fonctionnel en FR et EN (et DE/ES pour cohérence) — 6 clés i18n ajoutées dans les 4 ARB files + fichiers générés
5. Tests unitaires `ConsentService.revokeConsent()` + tests unitaires `ConsentNotifier.revoke()` + tests widget `SettingsPage` (tile visible, dialog s'ouvre, confirm déclenche revoke)
6. `flutter analyze --no-pub` propre, aucune régression (suite `flutter test --exclude-tags integration` reste à 0 échec)

---

## Tasks / Subtasks

- [x] **T1 — Ajouter `revokeConsent()` à `ConsentService`** (AC: 1)
  - [x] T1.1 — Dans `lib/domain/services/core/consent_service.dart`, ajouter la méthode `revokeConsent()` qui efface `_consentKey` et `_consentDateKey` via `prefs.remove()`
  - [x] T1.2 — Vérifier que `revokeConsent()` est idempotent (double appel sur prefs vides ne lève pas)
  - [x] T1.3 — Ajouter les tests dans `test/domain/services/core/consent_service_test.dart` (groupe `revokeConsent`) : 4 tests (voir Dev Notes)

- [x] **T2 — Ajouter `revoke()` à `ConsentNotifier`** (AC: 1, 3)
  - [x] T2.1 — Dans `lib/data/providers/consent_providers.dart`, ajouter `Future<void> revoke()` à `ConsentNotifier`, miroir de `accept()` : appelle `_service.revokeConsent()`, définit `state = const AsyncValue.data(false)` si monté
  - [x] T2.2 — Créer `test/data/providers/consent_notifier_revoke_test.dart` avec tests unitaires `ConsentNotifier.revoke()` (voir Dev Notes)

- [x] **T3 — Ajouter les clés i18n dans les 4 ARB files** (AC: 4)
  - [x] T3.1 — Ajouter les 6 clés dans `lib/l10n/app_fr.arb` (valeurs FR)
  - [x] T3.2 — Ajouter les 6 clés dans `lib/l10n/app_en.arb` (valeurs EN)
  - [x] T3.3 — Ajouter les 6 clés dans `lib/l10n/app_de.arb` (valeurs DE)
  - [x] T3.4 — Ajouter les 6 clés dans `lib/l10n/app_es.arb` (valeurs ES)
  - [x] T3.5 — Régénérer les fichiers Dart : `puro flutter gen-l10n` (génère `app_localizations.dart` + `app_localizations_fr.dart` etc.)

- [x] **T4 — Ajouter le tile + dialog dans `SettingsPage`** (AC: 2, 3, 4)
  - [x] T4.1 — Ajouter l'import `consent_providers.dart` dans `settings_page.dart`
  - [x] T4.2 — Insérer le tile revoke après le tile "Politique de confidentialité" et avant le tile "Supprimer mon compte" dans la section Privacy
  - [x] T4.3 — Ajouter `_showRevokeConsentDialog(BuildContext context, AppLocalizations l10n, WidgetRef ref)` (voir Dev Notes — patron exact à respecter)
  - [x] T4.4 — Créer `test/presentation/pages/settings/settings_page_revoke_test.dart` (voir Dev Notes)

- [x] **T5 — Validation finale** (AC: 6)
  - [x] T5.1 — `puro flutter analyze --no-pub` → 0 erreur dans `lib/` (erreurs pré-existantes Epic 9 hors scope)
  - [x] T5.2 — `puro flutter test --exclude-tags integration --no-pub` → 0 échec (1947 passaient, +11 nouveaux)
  - [ ] T5.3 — Vérifier manuellement le flux : Settings → tile revoke → dialog → Retirer → `ConsentGatePage` s'affiche

---

## Dev Notes

### Analyse exhaustive des fichiers à modifier

#### `lib/domain/services/core/consent_service.dart` (23 lignes — MODIFIER)

État actuel :
```dart
class ConsentService {
  static const String _consentKey = 'privacy_consent_v1';
  static const String _consentDateKey = 'privacy_consent_date_v1';
  static const String consentContactEmail = 'support@prioris.app';

  Future<bool> hasAcceptedConsent() async { ... }
  Future<void> acceptConsent() async { ... }
  // revokeConsent() ABSENT — à ajouter
}
```

**Méthode à ajouter (verbatim — ne pas dévier) :**
```dart
Future<void> revokeConsent() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_consentKey);
  await prefs.remove(_consentDateKey);
}
```

Pourquoi `remove()` et pas `setBool(false)` : effacer complètement les clés garantit que `hasAcceptedConsent()` retourne `false` (via `?? false`) ET que la date n'est plus présente — cohérence d'état totale. Pas de gestion d'erreur nécessaire : `remove()` est no-op si la clé est absente (idempotent natif).

La classe restera sous 25 lignes — pas de contrainte 500/50 à vérifier.

---

#### `lib/data/providers/consent_providers.dart` (35 lignes — MODIFIER)

État actuel : `ConsentNotifier` a `_load()` et `accept()`. Il faut ajouter `revoke()`.

**Méthode à ajouter dans `ConsentNotifier` après `accept()` :**
```dart
Future<void> revoke() async {
  try {
    await _service.revokeConsent();
    if (mounted) state = const AsyncValue.data(false);
  } catch (e, st) {
    if (mounted) state = AsyncValue.error(e, st);
  }
}
```

Aucune autre modification. Le fichier passera de 35 à ~42 lignes.

**Important** : `consentProvider` est `autoDispose`, MAIS `AuthWrapper` le `watch()` en permanence (il est dans le widget `home:` de `MaterialApp`). Donc le provider reste vivant tant que l'app est ouverte. Quand `revoke()` passe l'état à `data(false)`, `AuthWrapper` rebuild immédiatement et affiche `ConsentGatePage` — l'utilisateur est redirigé sans navigation explicite.

---

#### `lib/presentation/pages/settings_page.dart` (203 lignes — MODIFIER)

**Import à ajouter :**
```dart
import 'package:prioris/data/providers/consent_providers.dart';
```

**Tile à insérer** dans la méthode `build()`, à l'intérieur du `_buildSection` de la section Privacy, après le tile `settingsPrivacyPolicyTile` et AVANT le tile `settingsDeleteAccountTile` :
```dart
_buildSettingTile(
  icon: Icons.lock_open_outlined,
  title: l10n.settingsRevokeConsentTile,
  subtitle: l10n.settingsRevokeConsentSubtitle,
  onTap: () => _showRevokeConsentDialog(context, l10n, ref),
  showChevron: false,
),
```

**Méthode à ajouter** dans la classe `SettingsPage`, après `_showDeleteAccountDialog` :
```dart
void _showRevokeConsentDialog(
  BuildContext context,
  AppLocalizations l10n,
  WidgetRef ref,
) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.settingsRevokeConsentDialogTitle),
      content: Text(l10n.settingsRevokeConsentDialogBody),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.of(dialogContext).pop();
            try {
              await ref.read(consentProvider.notifier).revoke();
            } catch (_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.settingsRevokeConsentError)),
                );
              }
            }
          },
          child: Text(
            l10n.settingsRevokeConsentDialogConfirm,
            style: const TextStyle(color: Colors.red),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(l10n.settingsRevokeConsentDialogCancel),
        ),
      ],
    ),
  );
}
```

**Pourquoi `ref` est passé en paramètre** : `SettingsPage` est un `ConsumerWidget`, donc `ref` est disponible dans `build(context, ref)` et peut être capturé par le lambda `onTap`. La méthode `_showRevokeConsentDialog` reçoit `ref` comme paramètre (pattern déjà utilisé pour `context` et `l10n` dans `_showDeleteAccountDialog`). C'est la façon idiomatique avec Riverpod + ConsumerWidget sans StatefulWidget.

**Pourquoi `ref.read` (pas `ref.watch`) dans le callback async** : dans un callback `onPressed`, on lit une valeur ponctuelle — `ref.read` est correct. `ref.watch` est réservé à `build()`.

**Contrainte 50 lignes/méthode** : `_showRevokeConsentDialog` aura ~30 lignes. OK.
**Contrainte 500 lignes/classe** : `SettingsPage` passera de 203 à ~230 lignes. OK.

---

### Clés i18n à ajouter (6 clés × 4 langues)

**Valeurs FR (`app_fr.arb`)** — insérer avant la clé `settingsDeleteAccountTile` :
```json
"settingsRevokeConsentTile": "Retirer mon consentement",
"settingsRevokeConsentSubtitle": "Révoquer l'accès à vos données personnelles",
"settingsRevokeConsentDialogTitle": "Retirer votre consentement",
"settingsRevokeConsentDialogBody": "Vous serez immédiatement redirigé vers la page de consentement. Vous pouvez accepter à nouveau à tout moment.",
"settingsRevokeConsentDialogConfirm": "Retirer",
"settingsRevokeConsentDialogCancel": "Annuler",
"settingsRevokeConsentError": "Erreur lors du retrait du consentement. Veuillez réessayer."
```

**Valeurs EN (`app_en.arb`)** :
```json
"settingsRevokeConsentTile": "Withdraw my consent",
"settingsRevokeConsentSubtitle": "Revoke access to your personal data",
"settingsRevokeConsentDialogTitle": "Withdraw your consent",
"settingsRevokeConsentDialogBody": "You will be immediately redirected to the consent page. You can accept again at any time.",
"settingsRevokeConsentDialogConfirm": "Withdraw",
"settingsRevokeConsentDialogCancel": "Cancel",
"settingsRevokeConsentError": "Error withdrawing consent. Please try again."
```

**Valeurs DE (`app_de.arb`)** :
```json
"settingsRevokeConsentTile": "Einwilligung widerrufen",
"settingsRevokeConsentSubtitle": "Zugriff auf Ihre persönlichen Daten widerrufen",
"settingsRevokeConsentDialogTitle": "Einwilligung widerrufen",
"settingsRevokeConsentDialogBody": "Sie werden sofort zur Einwilligungsseite weitergeleitet. Sie können jederzeit erneut zustimmen.",
"settingsRevokeConsentDialogConfirm": "Widerrufen",
"settingsRevokeConsentDialogCancel": "Abbrechen",
"settingsRevokeConsentError": "Fehler beim Widerrufen der Einwilligung. Bitte versuchen Sie es erneut."
```

**Valeurs ES (`app_es.arb`)** :
```json
"settingsRevokeConsentTile": "Retirar mi consentimiento",
"settingsRevokeConsentSubtitle": "Revocar el acceso a sus datos personales",
"settingsRevokeConsentDialogTitle": "Retirar su consentimiento",
"settingsRevokeConsentDialogBody": "Será redirigido inmediatamente a la página de consentimiento. Puede aceptar de nuevo en cualquier momento.",
"settingsRevokeConsentDialogConfirm": "Retirar",
"settingsRevokeConsentDialogCancel": "Cancelar",
"settingsRevokeConsentError": "Error al retirar el consentimiento. Por favor, inténtelo de nuevo."
```

**Commande de génération :** `puro flutter gen-l10n` — génère `lib/l10n/app_localizations.dart` + les 4 fichiers `app_localizations_*.dart`. Ne pas éditer ces fichiers générés manuellement.

> **Note** : 7 clés (pas 6 — `settingsRevokeConsentError` est la 7ème). Insérer dans les ARBs en respectant l'ordre existant des clés voisines (`settingsPrivacyPolicyTile` → nouvelles clés → `settingsDeleteAccountTile`).

---

### Tests à écrire

#### T1.3 — `test/domain/services/core/consent_service_test.dart` (ajouter un groupe)

Ajouter dans le `main()` existant, après le groupe `'ConsentService'` actuel :

```dart
group('ConsentService.revokeConsent', () {
  test('revokeConsent → hasAcceptedConsent retourne false', () async {
    final service = ConsentService();
    await service.acceptConsent();
    await service.revokeConsent();
    expect(await service.hasAcceptedConsent(), isFalse);
  });

  test('revokeConsent supprime aussi la date de consentement', () async {
    final service = ConsentService();
    await service.acceptConsent();
    await service.revokeConsent();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('privacy_consent_date_v1'), isNull);
  });

  test('revokeConsent est idempotent (double appel ne lève pas)', () async {
    final service = ConsentService();
    await service.acceptConsent();
    await service.revokeConsent();
    await expectLater(service.revokeConsent(), completes);
  });

  test('revokeConsent sur prefs vides ne lève pas', () async {
    final service = ConsentService();
    await expectLater(service.revokeConsent(), completes);
    expect(await service.hasAcceptedConsent(), isFalse);
  });
});
```

Le `setUp(() { SharedPreferences.setMockInitialValues({}); })` existant au niveau `main()` s'applique déjà à ce groupe.

---

#### T2.2 — `test/data/providers/consent_notifier_revoke_test.dart` (nouveau fichier)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/providers/consent_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('ConsentNotifier.revoke', () {
    test('revoke après accept → state devient data(false)', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initialiser avec consentement accepté
      SharedPreferences.setMockInitialValues({'privacy_consent_v1': true});
      final notifier = container.read(consentProvider.notifier);
      await Future<void>.delayed(Duration.zero); // laisse _load() se terminer

      expect(container.read(consentProvider).value, isTrue);

      await notifier.revoke();
      expect(container.read(consentProvider).value, isFalse);
    });

    test('revoke appelle revokeConsent sur le service (SharedPreferences)', () async {
      SharedPreferences.setMockInitialValues({'privacy_consent_v1': true});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await Future<void>.delayed(Duration.zero);
      await container.read(consentProvider.notifier).revoke();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('privacy_consent_v1'), isNull);
      expect(prefs.getString('privacy_consent_date_v1'), isNull);
    });

    test('revoke sur notifier non-accepté passe state à data(false) sans erreur', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await Future<void>.delayed(Duration.zero);

      await expectLater(
        container.read(consentProvider.notifier).revoke(),
        completes,
      );
      expect(container.read(consentProvider).value, isFalse);
    });
  });
}
```

---

#### T4.4 — `test/presentation/pages/settings/settings_page_revoke_test.dart` (nouveau fichier)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/providers/consent_providers.dart';
import 'package:prioris/presentation/pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/localized_widget.dart'; // helper existant du projet

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'privacy_consent_v1': true});
  });

  Widget buildSubject() {
    return ProviderScope(
      child: localizedApp(const SettingsPage()),
    );
  }

  group('SettingsPage — revoke consent tile', () {
    testWidgets('le tile "Retirer mon consentement" est visible', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.textContaining('Retirer mon consentement'), findsOneWidget);
    });

    testWidgets('tapper le tile ouvre le dialog de confirmation', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Retirer mon consentement'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Retirer votre consentement'), findsOneWidget);
    });

    testWidgets('tapper Annuler ferme le dialog sans modifier le consentement', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Retirer mon consentement'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Retirer votre consentement'), findsNothing);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('privacy_consent_v1'), isTrue);
    });

    testWidgets('tapper Retirer appelle revoke et ferme le dialog', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Retirer mon consentement'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retirer'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Retirer votre consentement'), findsNothing);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('privacy_consent_v1'), isNull);
    });
  });
}
```

> **Note helper** : `localizedApp()` est dans `test/helpers/localized_widget.dart` (existant depuis story 7.6+). Vérifier le chemin exact avant import.

---

### Flux RGPD — comportement attendu

```
Utilisateur sur SettingsPage
  → Tape "Retirer mon consentement"
  → Dialog de confirmation s'ouvre
  → Tape "Retirer"
    → Navigator.pop(dialogContext)         ← dialog fermé
    → ref.read(consentProvider.notifier).revoke()
      → ConsentService.revokeConsent()     ← SharedPreferences.remove() × 2
      → state = AsyncValue.data(false)
        → AuthWrapper rebuild              ← IMMÉDIAT (reactive)
          → consentProvider = data(false)
          → authUIState = signedIn
          → Widget affiché : ConsentGatePage ← redirect automatique
```

L'AC3 dit "à la prochaine ouverture" — l'implémentation fait mieux (redirect immédiate) car `AuthWrapper` est réactif. Le comportement est conforme et supérieur à l'AC.

---

### Précautions critiques

1. **`ref.read` vs `ref.watch`** : dans `_showRevokeConsentDialog`, utiliser `ref.read(consentProvider.notifier)` dans le callback `onPressed`. Ne jamais utiliser `ref.watch` hors de `build()`.

2. **Mounted checks** : après `await`, vérifier `context.mounted` avant tout appel sur `context` (SnackBar erreur). `ref.read()` est safe sans mounted check — Riverpod gère l'invalidation.

3. **Ordre des tiles** : le tile revoke doit s'insérer **entre** `settingsPrivacyPolicyTile` et `settingsDeleteAccountTile`. Ne pas modifier l'ordre des tiles existants.

4. **Génération l10n** : toujours exécuter `puro flutter gen-l10n` APRÈS avoir modifié les ARBs. Ne pas éditer manuellement `app_localizations.dart` ou `app_localizations_fr.dart`.

5. **Commandes Flutter via PowerShell + puro uniquement** (comme établi en story 8.1) :
   ```powershell
   puro flutter gen-l10n
   puro flutter analyze --no-pub
   puro flutter test --exclude-tags integration --no-pub
   ```

6. **Ne pas toucher** `ConsentGatePage`, `AuthWrapper`, `consent_gate_page_test.dart` — le flux de redirection est entièrement géré par la réactivité Riverpod existante, sans code supplémentaire dans ces fichiers.

7. **Deferred-work.md** : les items différés de la story 7.7 liés à `ConsentService` (notamment "double getInstance() par méthode" et "consentServiceProvider expose classe concrète sans interface DIP") restent hors scope — ne pas les adresser dans cette story.

---

### Arbre de décision pour les tests widget

Les tests widget de `SettingsPage` nécessitent que `consentProvider` soit initialisé. Le `ProviderScope` sans override utilise `SharedPreferences.setMockInitialValues({'privacy_consent_v1': true})` en `setUp()` — le `ConsentNotifier` se charge via `_load()` au démarrage et trouve `true`. C'est suffisant pour que `SettingsPage` s'affiche correctement (l'utilisateur est "connecté avec consentement").

Si les tests widget échouent avec "provider not found" ou "StateError", vérifier que `ProviderScope` enveloppe correctement le widget.

---

### Project Structure Notes

- `ConsentService` : `lib/domain/services/core/consent_service.dart` — couche domain, dépendance `shared_preferences` autorisée (pure Dart)
- `ConsentNotifier` : `lib/data/providers/consent_providers.dart` — couche data (providers Riverpod)
- `SettingsPage` : `lib/presentation/pages/settings_page.dart` — couche presentation
- Tests unitaires service : `test/domain/services/core/consent_service_test.dart` (existant — compléter)
- Tests unitaires notifier : `test/data/providers/consent_notifier_revoke_test.dart` (nouveau — à créer)
- Tests widget settings : `test/presentation/pages/settings/settings_page_revoke_test.dart` (nouveau — créer le dossier si absent)
- ARBs : `lib/l10n/app_fr.arb`, `app_en.arb`, `app_de.arb`, `app_es.arb`
- Fichiers générés (ne pas éditer) : `lib/l10n/app_localizations.dart` + `app_localizations_fr.dart` + `app_localizations_en.dart` + `app_localizations_de.dart` + `app_localizations_es.dart`

### References

- Architecture layered : `_bmad-output/planning-artifacts/architecture.md` — section "Architecture globale" et tableau "Flux AuthWrapper"
- Deferred revokeConsent : `_bmad-output/implementation-artifacts/deferred-work.md` — section "Deferred from: code review of 7-7-bases-rgpd-minimales"
- ConsentService existant : `lib/domain/services/core/consent_service.dart`
- ConsentNotifier existant : `lib/data/providers/consent_providers.dart`
- SettingsPage existante : `lib/presentation/pages/settings_page.dart`
- Tests ConsentService existants : `test/domain/services/core/consent_service_test.dart`
- Commandes PowerShell + puro : story 8.1 Dev Notes section "Précautions critiques"
- RGPD Art. 7.3 : le retrait du consentement doit être "aussi aisé" que son octroi — bouton de même niveau de profondeur que l'acceptation initiale (ConsentGatePage → 1 clic ; SettingsPage → 2 clics : acceptable)

---

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

- [x] T1 : `revokeConsent()` ajouté à `ConsentService` — `prefs.remove()` × 2, idempotent natif. 4 tests unitaires verts.
- [x] T2 : `revoke()` ajouté à `ConsentNotifier` — miroir de `accept()`, gestion mounted/error. Test T1 adapté (accept() via notifier plutôt que setMockInitialValues — plus fiable avec autoDispose). 3 tests unitaires verts.
- [x] T3 : 7 clés i18n ajoutées dans les 4 ARBs (FR/EN/DE/ES). `gen-l10n` régénéré sans erreur.
- [x] T4 : Tile + dialog insérés dans SettingsPage (entre Privacy Policy et Delete Account). Import consent_providers ajouté. `_showRevokeConsentDialog` ~30 lignes. 4 tests widget verts.
- [x] T5 : `flutter analyze` propre pour les fichiers de la story. Suite complète : 1947 tests passés (baseline 1936 + 11 nouveaux), 0 échec, 0 régression.
- [ ] T5.3 — Test manuel : vérifier flux Settings → tile → dialog → Retirer → ConsentGatePage (à faire par Thibaut)

### Change Log

- 2026-04-30 : Implémentation story 8.2 — revokeConsent RGPD Art. 7.3 (claude-sonnet-4-6)

### File List
- lib/domain/services/core/consent_service.dart (modifier — ajouter revokeConsent)
- lib/data/providers/consent_providers.dart (modifier — ajouter revoke() à ConsentNotifier)
- lib/presentation/pages/settings_page.dart (modifier — tile + dialog)
- lib/l10n/app_fr.arb (modifier — 7 clés)
- lib/l10n/app_en.arb (modifier — 7 clés)
- lib/l10n/app_de.arb (modifier — 7 clés)
- lib/l10n/app_es.arb (modifier — 7 clés)
- lib/l10n/app_localizations.dart (généré par gen-l10n)
- lib/l10n/app_localizations_fr.dart (généré par gen-l10n)
- lib/l10n/app_localizations_en.dart (généré par gen-l10n)
- lib/l10n/app_localizations_de.dart (généré par gen-l10n)
- lib/l10n/app_localizations_es.dart (généré par gen-l10n)
- test/domain/services/core/consent_service_test.dart (modifier — groupe revokeConsent)
- test/data/providers/consent_notifier_revoke_test.dart (créer)
- test/presentation/pages/settings/settings_page_revoke_test.dart (créer)
