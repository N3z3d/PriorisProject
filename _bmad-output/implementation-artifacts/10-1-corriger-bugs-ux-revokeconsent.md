# Story 10.1 : Corriger les bugs UX de revokeConsent (feedback visuel + redirection immédiate)

Status: ready-for-dev

## Story

En tant qu'utilisateur,
je veux que "Retirer mon consentement" me montre immédiatement un feedback visuel et me déconnecte sans avoir besoin de rafraîchir,
afin que je sache que mon action a été prise en compte et que l'application reflète mon choix en temps réel.

## Acceptance Criteria

1. Après tap "Retirer mon consentement" → snackbar de confirmation affichée immédiatement ("Consentement retiré. Déconnexion en cours…")
2. `AuthWrapper` se re-évalue immédiatement après `revokeConsent()` — sans refresh, sans navigation manuelle
3. L'utilisateur est redirigé vers `ConsentGatePage` dans la même frame (ou au prochain frame) après confirmation
4. `puro flutter analyze --no-pub` → 0 nouvelle erreur
5. `puro flutter test --exclude-tags integration` → 0 régression

## Tasks / Subtasks

- [ ] **T1 — Ajouter la clé i18n `settingsRevokeConsentSuccess` dans les 4 ARB** (AC: 1)
  - [ ] T1.1 — `lib/l10n/app_fr.arb` : ajouter clé après `settingsRevokeConsentError`
  - [ ] T1.2 — `lib/l10n/app_en.arb` : ajouter clé après `settingsRevokeConsentError`
  - [ ] T1.3 — `lib/l10n/app_de.arb` : ajouter clé après `settingsRevokeConsentError`
  - [ ] T1.4 — `lib/l10n/app_es.arb` : ajouter clé après `settingsRevokeConsentError`
  - [ ] T1.5 — `puro flutter gen-l10n` → régénère `lib/l10n/app_localizations*.dart`

- [ ] **T2 — Corriger `_showRevokeConsentDialog` dans `settings_page.dart`** (AC: 1, 2, 3)
  - [ ] T2.1 — Ajouter snackbar succès après `await revoke()` réussi
  - [ ] T2.2 — Ajouter `Navigator.of(context).popUntil((route) => route.isFirst)` après le snackbar
  - [ ] T2.3 — Vérifier `context.mounted` avant le bloc succès (déjà présent pour le bloc erreur)

- [ ] **T3 — Mettre à jour `settings_page_revoke_test.dart`** (AC: 5)
  - [ ] T3.1 — Ajouter test : tapper Retirer → snackbar succès visible
  - [ ] T3.2 — Vérifier que le test existant "tapper Retirer appelle revoke et ferme le dialog" reste vert

- [ ] **T4 — Validation finale** (AC: 4, 5)
  - [ ] T4.1 — `puro flutter analyze --no-pub` → 0 erreur
  - [ ] T4.2 — `puro flutter test --exclude-tags integration` → 0 régression
  - [ ] T4.3 — Test manuel : Settings → Retirer mon consentement → Retirer → snackbar visible → ConsentGatePage immédiate

## Dev Notes

### Analyse des bugs — Cause racine

#### Bug A : Pas de feedback visuel

**Fichier** : `lib/presentation/pages/settings_page.dart`, méthode `_showRevokeConsentDialog` (ligne 129)

Le bouton "Retirer" (ligne 145) :
- ferme le dialog
- appelle `await ref.read(consentProvider.notifier).revoke()`
- en cas d'**erreur** → snackbar d'erreur ✅
- en cas de **succès** → **rien du tout** ❌

La clé l10n `settingsRevokeConsentSuccess` **n'existe pas** dans les ARB files. Elle doit être créée.

#### Bug B : Redirection non immédiate

**Cause** : `SettingsPage` est poussé via `Navigator.push` au-dessus de `HomePage` dans le Navigator 1.0. Quand `revoke()` met `consentProvider` à `data(false)`, `AuthWrapper` (home du MaterialApp) **se re-évalue bien** — mais `SettingsPage` reste en haut du stack Navigator. L'utilisateur continue de voir `SettingsPage` jusqu'au prochain pop manuel.

**Fix** : après `revoke()` réussi, appeler `Navigator.of(context).popUntil((route) => route.isFirst)`. Cela pop toutes les routes empilées (SettingsPage et tout ce qui est au-dessus) et révèle le `home` du MaterialApp, qui est maintenant `ConsentGatePage` (car `AuthWrapper` a déjà rebuildt).

**IMPORTANT** : `AuthWrapper` a déjà rebuildt au moment où `popUntil` s'exécute — Riverpod schedule les rebuilds sur la frame suivante. Il faut appeler `ScaffoldMessenger.of(context).showSnackBar(...)` **avant** `popUntil`, pendant que `context` est encore mounted.

---

### Modification chirurgicale — `settings_page.dart`

**Seule la section `onPressed` du bouton "Retirer" dans `_showRevokeConsentDialog` est à modifier.**

État actuel (ligne 145-163) :
```dart
onPressed: () async {
  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
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
```

État cible :
```dart
onPressed: () async {
  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
  try {
    await ref.read(consentProvider.notifier).revoke();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsRevokeConsentSuccess)),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsRevokeConsentError)),
      );
    }
  }
},
```

**Ordre obligatoire** :
1. `showSnackBar(...)` → file le snackbar sur le `ScaffoldMessenger` root (persiste après pop)
2. `popUntil(...)` → pop `SettingsPage` → `ConsentGatePage` apparaît avec le snackbar dessus

Ne pas inverser l'ordre : après `popUntil`, `context.mounted` est false.

---

### Modification ARB — 4 fichiers

Ajouter la clé `settingsRevokeConsentSuccess` **après** le bloc `settingsRevokeConsentError` dans chaque ARB.

Format à respecter (même structure que les clés voisines) :

**`lib/l10n/app_fr.arb`** (après ligne 1332) :
```json
  "settingsRevokeConsentSuccess": "Consentement retiré. Déconnexion en cours…",
  "@settingsRevokeConsentSuccess": {
    "description": "Message de succès après le retrait du consentement"
  },
```

**`lib/l10n/app_en.arb`** (après `settingsRevokeConsentError`) :
```json
  "settingsRevokeConsentSuccess": "Consent withdrawn. Signing out…",
  "@settingsRevokeConsentSuccess": {
    "description": "Success message after consent is withdrawn"
  },
```

**`lib/l10n/app_de.arb`** (après `settingsRevokeConsentError`) :
```json
  "settingsRevokeConsentSuccess": "Einwilligung widerrufen. Abmeldung läuft…",
  "@settingsRevokeConsentSuccess": {
    "description": "Erfolgsmeldung nach dem Widerruf der Einwilligung"
  },
```

**`lib/l10n/app_es.arb`** (après `settingsRevokeConsentError`) :
```json
  "settingsRevokeConsentSuccess": "Consentimiento retirado. Cerrando sesión…",
  "@settingsRevokeConsentSuccess": {
    "description": "Mensaje de éxito tras retirar el consentimiento"
  },
```

Après les 4 ARB : `puro flutter gen-l10n` (régénère `lib/l10n/app_localizations.dart` + les 4 fichiers Dart).

---

### Modification des tests

#### Mise à jour `test/presentation/pages/settings/settings_page_revoke_test.dart`

Le test existant "tapper Retirer appelle revoke et ferme le dialog" (ligne 47) doit rester **inchangé** — il vérifie que le dialog se ferme et que `SharedPreferences` est vide.

**Ajouter** un test pour le snackbar de succès (dans le même groupe `SettingsPage — revoke consent tile`) :

```dart
testWidgets('tapper Retirer affiche le snackbar de succès', (tester) async {
  await tester.pumpWidget(buildSubject());
  await tester.pumpAndSettle();
  await tester.tap(find.textContaining('Retirer mon consentement'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Retirer'));
  await tester.pumpAndSettle();
  expect(find.textContaining('Consentement retiré'), findsOneWidget);
});
```

> **Note** : `localizedApp` wrapper crée `MaterialApp(home: Scaffold(body: SettingsPage()))`. Dans ce setup, `Navigator.of(context).popUntil((route) => route.isFirst)` est un no-op (déjà à la root). Le test ci-dessus vérifie uniquement le snackbar — le comportement `popUntil` est couvert par le test manuel (T4.3). Un test d'intégration complet (AuthWrapper + push SettingsPage + revoke → ConsentGatePage) nécessiterait de stubber `authUIStateProvider` et de pousser `SettingsPage` via un `NavigatorKey`, ce qui est hors scope pour cette story.

---

### Architecture — Contraintes à respecter

**Navigator 1.0** : L'app utilise `MaterialApp.onGenerateRoute` + `Navigator.push`. Il n'y a pas de GoRouter. `popUntil((r) => r.isFirst)` est la méthode correcte pour revenir à la route initiale.

**`consentProvider` autoDispose** : Le provider est `StateNotifierProvider.autoDispose`. `AuthWrapper` est le watcher permanent (via `ref.watch`). Quand `revoke()` met `state = data(false)`, `AuthWrapper` rebuildt sur le prochain frame → `ConsentGatePage` retourné. Le `autoDispose` ne crée pas de problème ici car `AuthWrapper` est toujours dans l'arbre (il ne dépend pas de SettingsPage).

**`lib/domain/CLAUDE.md`** : `ConsentService` dans `lib/domain/` importe `shared_preferences` — cette violation est hors scope de cette story (traitée en 10.2). Ne pas la corriger ici.

**`SettingsPage` est un `ConsumerWidget`** (pas `ConsumerStatefulWidget`). La méthode `_showRevokeConsentDialog` prend `WidgetRef ref` en paramètre — le `ref` capturé est celui du build et reste valide pendant toute la durée du dialog.

**Commandes Flutter** : Toujours préfixer avec `puro` (env `prioris-328`) :
- `puro flutter gen-l10n`
- `puro flutter analyze --no-pub`
- `puro flutter test --exclude-tags integration`

---

### Fichiers à modifier

| Fichier | Action | Lignes approx. |
|---------|--------|----------------|
| `lib/l10n/app_fr.arb` | Ajouter 4 lignes après ligne 1332 | +4 |
| `lib/l10n/app_en.arb` | Ajouter 4 lignes après `settingsRevokeConsentError` | +4 |
| `lib/l10n/app_de.arb` | Ajouter 4 lignes après `settingsRevokeConsentError` | +4 |
| `lib/l10n/app_es.arb` | Ajouter 4 lignes après `settingsRevokeConsentError` | +4 |
| `lib/l10n/app_localizations*.dart` | Auto-générés par `gen-l10n` | — |
| `lib/presentation/pages/settings_page.dart` | Modifier `onPressed` (6 lignes) dans `_showRevokeConsentDialog` | +5 |
| `test/presentation/pages/settings/settings_page_revoke_test.dart` | Ajouter 1 test (8 lignes) | +8 |

**Ne pas toucher** : `auth_wrapper.dart`, `consent_providers.dart`, `consent_service.dart`, `consent_gate_page.dart` — ces fichiers fonctionnent correctement pour cette story.

---

### Contexte des stories précédentes

- **Story 8.2** : Implémentait `revokeConsent()` — a créé l'infrastructure (ConsentService, ConsentNotifier, i18n, tile, dialog). La story 8.2 avait noté en T5.3 "Vérifier manuellement le flux" comme non coché → les bugs A et B n'ont pas été détectés jusqu'au test production de la rétro Épic 9.
- **Story 8.2 pattern i18n** : Les ARB files ont un bloc `"key": "value", "@key": { "description": "..." }` pour chaque clé. Respecter exactement ce format.
- **Story 8.2 tests** : Le pattern `SharedPreferences.setMockInitialValues({'privacy_consent_v1': true})` dans `setUp` est utilisé dans les tests existants — reproduire ce pattern.

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

- [ ] `puro flutter gen-l10n` exécuté après modification des ARB
- [ ] `puro flutter analyze --no-pub` → 0 erreur
- [ ] `puro flutter test --exclude-tags integration` → 0 régression
- [ ] Test non-créateur : vérifier le flux avec un compte utilisateur non-créateur du projet Supabase
- [ ] sprint-status mis à jour à `done` pour cette story

### File List

- `lib/l10n/app_fr.arb`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_de.arb`
- `lib/l10n/app_es.arb`
- `lib/l10n/app_localizations.dart` (généré)
- `lib/l10n/app_localizations_fr.dart` (généré)
- `lib/l10n/app_localizations_en.dart` (généré)
- `lib/l10n/app_localizations_de.dart` (généré)
- `lib/l10n/app_localizations_es.dart` (généré)
- `lib/presentation/pages/settings_page.dart`
- `test/presentation/pages/settings/settings_page_revoke_test.dart`
