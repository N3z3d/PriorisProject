# Story 10.16 : Compléter la couverture i18n — tous les textes fixes (EN/ES/DE)

Status: done

## Story

En tant qu'utilisateur non francophone,
je veux que tous les textes fixes de l'interface soient dans ma langue (EN, ES, DE),
afin que l'application soit réellement utilisable dans toutes les langues supportées.

## Acceptance Criteria

1. `grep -rn '"[A-Z]' lib/presentation/` → 0 chaîne hardcodée non localisée dans les **fichiers modifiés** par cette story
2. Privacy Policy et textes de consentement RGPD disponibles en DE (ils sont déjà en EN et ES)
3. Tous les textes fixes d'interface traduits en 4 langues (FR/EN/ES/DE) — boutons, labels, messages d'erreur, snackbars, dialogs
4. Les contenus créés par l'utilisateur (noms de listes, titres de tâches, catégories custom) ne sont pas touchés
5. `puro flutter test --exclude-tags integration` → 0 régression (baseline : 2120 pass, 26 skip — story 10-15)

## Tasks / Subtasks

- [x] **T1 — Corriger app_de.arb : 2 clés manquantes** (AC 3)
  - [x] T1.1 — Ajouter `habitFrequencyEveryHours` en allemand (documenté dans `untranslated.json`)
  - [x] T1.2 — Ajouter `habitFrequencyEveryDays` en allemand (documenté dans `untranslated.json`)
  - [x] T1.3 — Vider `untranslated.json` après correction

- [x] **T2 — Corriger app_de.arb : clés avec valeur anglaise** (AC 2, 3)
  - [x] T2.1 — Insights labels (insightsTabOverview, insightsCtaCreateHabit, insightsTrendsSuccessRate, insightsTrendsStreak, insightsTrendsToday)
  - [x] T2.2 — Habits actions snackbars (habitsActionCreateSuccess/Error, habitsActionUpdateSuccess/Error, habitsActionDeleteSuccess/Error, habitsActionRecordSuccess/Error, habitsLoadingRecord, habitsLoadingDelete, habitsActionUnsupported, habitsDialogDeleteTitle, habitsDialogDeleteMessage)
  - [x] T2.3 — Habits header/tabs (habitsHeaderTitle, habitsHeaderSubtitle, habitsHeroTitle, habitsHeroSubtitle, habitsTabHabits, habitsTabAdd)
  - [x] T2.4 — Duplicate warning dialog (duplicateWarningTitle, duplicateWarningSingle, duplicateWarningMultiple, duplicateWarningSkipAction, duplicateWarningAddAllSingle, duplicateWarningAddAllBulk, bulkAddImportSuccessWithSkipped)
  - [x] T2.5 — Error states (errorGenericTitle, errorNetworkTitle, errorNetworkMessage, errorGenericMessage)
  - [x] T2.6 — List operations (loadingListDetail, noListsTitle, noListsBody, listCreateDialogTitle, listCreateError, listEditError, listDeleteError, listCreatedSuccess, listUpdatedSuccess, listDeletedSuccess, settingsFeatureInDevelopment, archiveAction)
  - [x] T2.7 — Logout (logoutKeepDataAction, logoutClearDataAction, logoutDataQuestion, logoutLocalDataInfo)
  - [x] T2.8 — Privacy/RGPD/Consent (privacyConsentTitle, privacyConsentBody, privacyConsentAcceptButton, privacyConsentReadPolicyLink, privacyPolicyTitle, settingsPrivacySectionTitle, settingsPrivacyPolicyTile, settingsPrivacyPolicySubtitle)
  - [x] T2.9 — Delete account (settingsDeleteAccountTile, settingsDeleteAccountSubtitle, settingsDeleteAccountDialogTitle, settingsDeleteAccountDialogBody, settingsDeleteAccountDialogCopyEmail, settingsDeleteAccountEmailCopied)

- [x] **T3 — Corriger app_es.arb : encodage garble** (AC 3)
  - [x] T3.1 — Remplacer les 26 occurrences de `?` remplaçant des caractères accentués espagnols (`á`, `é`, `í`, `ó`, `ú`, `ñ`, `¿`, `¡`, `ü`) dans les premières clés du fichier

- [x] **T4 — Ajouter nouvelles clés ARB pour chaînes hardcodées** (AC 1, 3)
  - [x] T4.1 — Ajouter `taskNewDialogTitle` dans app_fr.arb + toutes langues ("Nouvelle tâche" / "New task" / "Nueva tarea" / "Neue Aufgabe")
  - [x] T4.2 — Ajouter `taskAddedSuccess` dans toutes langues ("Tâche ajoutée avec succès" / ...)
  - [x] T4.3 — Ajouter `taskTitleFieldLabel` dans toutes langues ("Titre" / "Title" / "Título" / "Titel")
  - [x] T4.4 — Ajouter `taskDescriptionFieldLabel` dans toutes langues ("Description (optionnel)" / ...)
  - [x] T4.5 — Ajouter `clearAllDataAction` dans toutes langues ("Tout supprimer" / "Delete all" / ...)
  - [x] T4.6 — Ajouter `clearDataAndSignOut` dans toutes langues ("Effacer et se déconnecter" / ...)

- [x] **T5 — Corriger chaînes hardcodées dans lib/presentation/pages/** (AC 1)
  - [x] T5.1 — `tasks_page.dart` : remplacer 'Supprimer' (l280), 'Nouvelle tâche' (l345), 'Annuler' (l401), 'Tâche ajoutée avec succès' (l443), 'Titre' (l358), 'Description (optionnel)' (l362), 'Catégorie' (l378), 'Ajouter' (l405), 'Annuler la création de tâche' (l398), 'Tâche ajoutée avec succès' (l437 accessibility)
  - [x] T5.2 — `habits/components/habit_card_builder.dart` : remplacer 'Modifier' (l126), 'Supprimer' (l136) par `l10n.habitsMenuEdit` / `l10n.habitsMenuDelete`
  - [x] T5.3 — `lists/widgets/simple_list_card.dart` : remplacer 'Modifier' (l112), 'Supprimer' (l116) par `l10n.edit` / `l10n.delete`

- [x] **T6 — Corriger chaînes hardcodées dans lib/presentation/widgets/dialogs/** (AC 1)
  - [x] T6.1 — `list_selection_dialog.dart` : ajouter import l10n + remplacer 'Annuler' (l200), 'Sauvegarder' (l209) par `l10n.cancel` / `l10n.save`
  - [x] T6.2 — `add_habit_dialog.dart` : ajouter import l10n + remplacer 'Annuler' (l131) par `l10n.cancel`
  - [x] T6.3 — `clear_data_dialog.dart` : ajouter import l10n + remplacer 'Annuler' (l349), 'Tout supprimer' (l367) par `l10n.cancel` / `l10n.clearAllDataAction`
  - [x] T6.4 — `components/data_clear_confirmation_dialog.dart` : ajouter import l10n + remplacer 'Annuler' (l97), 'Effacer et se déconnecter' (l115) par `l10n.cancel` / `l10n.clearDataAndSignOut`
  - [x] T6.5 — `custom_list_form_dialog.dart` : ajouter import l10n + remplacer 'Annuler' (l200), `Text('Erreur: $error')` (l264) par `l10n.cancel` / `Text('${l10n.error}: $error')`
  - [x] T6.6 — `forgot_password_dialog.dart` : ajouter import l10n + remplacer 'Annuler' (l194) par `l10n.cancel`
  - [x] T6.7 — `habit_record_dialog.dart` : ajouter import l10n + remplacer 'Annuler' (l60), 'Enregistrer' (l64) par `l10n.cancel` / `l10n.save`
  - [x] T6.8 — `list_form_dialog.dart` : ajouter import l10n + remplacer 'Annuler' (l133) par `l10n.cancel`
  - [x] T6.9 — `list_item_form_dialog.dart` : ajouter import l10n + remplacer 'Annuler' (l136) par `l10n.cancel`
  - [x] T6.10 — `simplified_logout_dialog.dart` : ajouter import l10n + remplacer 'Annuler' (l50) par `l10n.cancel`

- [x] **T7 — Tests** (AC 5)
  - [x] T7.1 — Vérifier `puro flutter test --exclude-tags integration` → 0 régression
  - [x] T7.2 — Si des widget tests utilisent `find.text('Annuler')` ou d'autres chaînes hardcodées dans les fichiers modifiés → mettre à jour les finders avec `find.text(l10n.cancel)` ou les valeurs localisées FR

## Dev Notes

### Contexte i18n existant

Le système i18n utilise **Flutter Intl / ARB** avec 4 langues : `fr`, `en`, `es`, `de`.

- Fichiers ARB : `lib/l10n/app_{locale}.arb`
- Fichiers Dart générés : `lib/l10n/app_localizations_{locale}.dart` (ne pas modifier manuellement)
- Accès dans les widgets : `AppLocalizations.of(context)!` ou `final l10n = AppLocalizations.of(context)!;`
- Import : `import 'package:prioris/l10n/app_localizations.dart';`
- Régénération après modif ARB : `puro flutter gen-l10n` (ou auto-détecté à la compilation)

Le fichier `lib/l10n/untranslated.json` documente les clés manquantes. Après T1, le vider (`{}`).

### État actuel des fichiers ARB

**FR :** 580 clés, référence canonique — aucune modification structurelle requise (seulement ajout T4)

**EN :** 580 clés, complet — aucune modification sauf ajout T4

**ES :** 580 clés mais ~26 chars garblés dans les premières clés — encodage `?` remplaçant caractères accentués. Patterns : `h?b` (`á`→`?`), `c?m` (`ó`→`?`), `d?s` (`í`→`?`), `r?a` (`ó`→`?`), `r?s` (`é`→`?`). Correction : ouvrir en UTF-8 et remplacer les patterns garblés.

**DE :** 578 clés (2 manquantes), ~56 clés en anglais au lieu d'allemand.

Clés DE **légitimement identiques à l'anglais** (ne pas modifier) :
- `name`, `version`, `feedback`, `credits`, `online`, `offline`, `normal`, `trivial`, `fitness`, `hobby`
- Mois : `habitMonthApril`, `habitMonthAugust`, `habitMonthSeptember`, `habitMonthNovember`
- `settingsPilotSectionTitle: "Pilot"` (germanisme acceptable)

### Chaînes hardcodées dans lib/presentation/

**Pattern d'accès l10n** (déjà en place dans `tasks_page.dart` ligne 45) :
```dart
import 'package:prioris/l10n/app_localizations.dart';
// dans build() :
final l10n = AppLocalizations.of(context)!;
```

**Fichiers sans import l10n** (à ajouter) :
- `list_selection_dialog.dart`, `add_habit_dialog.dart`, `clear_data_dialog.dart`
- `data_clear_confirmation_dialog.dart`, `custom_list_form_dialog.dart`
- `forgot_password_dialog.dart`, `habit_record_dialog.dart`, `list_form_dialog.dart`
- `list_item_form_dialog.dart`, `simplified_logout_dialog.dart`
- `habit_card_builder.dart`, `simple_list_card.dart`

**Clés ARB existantes utilisables directement** :
- `cancel` → "Annuler" / "Cancel" / "Cancelar" / "Abbrechen"
- `save` → "Enregistrer" / "Save" / "Guardar" / "Speichern"
- `delete` → "Supprimer" / "Delete" / "Eliminar" / "Löschen"
- `edit` → "Modifier" / "Edit" / "Editar" / "Bearbeiten"
- `add` → "Ajouter" / "Add" / "Añadir" / "Hinzufügen"
- `category` → "Catégorie" / ...
- `error` → "Erreur" / ... (pour `Text('${l10n.error}: $error')`)
- `habitsMenuEdit` → "Modifier" / ...
- `habitsMenuDelete` → "Supprimer" / ...

**Nouvelles clés à ajouter dans T4** (FR / EN / ES / DE) :
```
taskNewDialogTitle     : "Nouvelle tâche" / "New task" / "Nueva tarea" / "Neue Aufgabe"
taskAddedSuccess       : "Tâche ajoutée avec succès" / "Task added successfully" / "Tarea añadida con éxito" / "Aufgabe erfolgreich hinzugefügt"
taskTitleFieldLabel    : "Titre" / "Title" / "Título" / "Titel"
taskDescriptionFieldLabel : "Description (optionnel)" / "Description (optional)" / "Descripción (opcional)" / "Beschreibung (optional)"
clearAllDataAction     : "Tout supprimer" / "Delete all" / "Eliminar todo" / "Alles löschen"
clearDataAndSignOut    : "Effacer et se déconnecter" / "Clear data and sign out" / "Borrar datos y cerrar sesión" / "Daten löschen und abmelden"
```

### Traductions DE à utiliser pour T2 (référence)

```
insightsTabOverview          → "Übersicht"
insightsCtaCreateHabit       → "Eine Gewohnheit erstellen"
insightsTrendsSuccessRate    → "Erfolgsrate"
insightsTrendsStreak         → "Aktuelle Serie"
insightsTrendsToday          → "Heute abgeschlossen"
habitsActionCreateSuccess    → "Gewohnheit erstellt ✅"
habitsActionCreateError      → "Fehler beim Erstellen: {error}"
habitsActionUpdateSuccess    → "Gewohnheit \"{habitName}\" aktualisiert"
habitsActionUpdateError      → "Fehler beim Aktualisieren: {error}"
habitsActionDeleteSuccess    → "Gewohnheit \"{habitName}\" gelöscht"
habitsActionDeleteError      → "Gewohnheit konnte nicht gelöscht werden: {error}"
habitsActionRecordSuccess    → "Gewohnheit \"{habitName}\" eingetragen"
habitsActionRecordError      → "Fehler beim Eintragen: {error}"
habitsLoadingRecord          → "Wird eingetragen..."
habitsLoadingDelete          → "Wird gelöscht..."
habitsActionUnsupported      → "Nicht unterstützte Aktion: {action}"
habitsDialogDeleteTitle      → "Gewohnheit löschen"
habitsDialogDeleteMessage    → "Gewohnheit \"{habitName}\" löschen?\nDiese Aktion ist unwiderruflich und löscht auch den Verlauf."
habitsHeaderTitle            → "Meine Gewohnheiten"
habitsHeaderSubtitle         → "Verfolge deinen Fortschritt täglich"
habitsHeroTitle              → "Meine Gewohnheiten"
habitsHeroSubtitle           → "Erstelle und verfolge deine täglichen Gewohnheiten"
habitsTabHabits              → "Gewohnheiten"
habitsTabAdd                 → "Hinzufügen"
duplicateWarningTitle        → "Duplikat erkannt"
duplicateWarningSingle       → "Das Element \"{title}\" ist bereits in deiner Liste."
duplicateWarningMultiple     → "{duplicateCount, plural, one {{duplicateCount} Element ist bereits} other {{duplicateCount} Elemente sind bereits}} in deiner Liste (von {total})."
duplicateWarningSkipAction   → "Duplikate überspringen ({uniqueCount} hinzufügen)"
duplicateWarningAddAllSingle → "Trotzdem hinzufügen"
duplicateWarningAddAllBulk   → "Alle hinzufügen ({count})"
bulkAddImportSuccessWithSkipped → "{count, plural, one {{count} Element importiert} other {{count} Elemente importiert}}, {skipped, plural, one {{skipped} Duplikat übersprungen} other {{skipped} Duplikate übersprungen}}"
errorGenericTitle            → "Ein Fehler ist aufgetreten"
errorNetworkTitle            → "Verbindungsproblem"
errorNetworkMessage          → "Überprüfe deine Internetverbindung und versuche es erneut."
errorGenericMessage          → "Ein unerwarteter Fehler ist aufgetreten. Bitte versuche es erneut."
loadingListDetail            → "Deine Liste wird geladen..."
noListsTitle                 → "Keine Listen verfügbar"
noListsBody                  → "Erstelle deine erste Liste, um loszulegen."
settingsFeatureInDevelopment → "Funktion in Entwicklung"
archiveAction                → "Archivieren"
listCreateDialogTitle        → "Neue Liste"
listCreateError              → "Liste konnte nicht erstellt werden. Versuche es erneut."
listEditError                → "Fehler beim Bearbeiten: {error}"
listDeleteError              → "Fehler beim Löschen: {error}"
logoutKeepDataAction         → "Daten behalten"
logoutClearDataAction        → "Daten löschen"
listCreatedSuccess           → "Liste \"{title}\" erfolgreich erstellt"
listUpdatedSuccess           → "Liste \"{name}\" erfolgreich aktualisiert"
listDeletedSuccess           → "Liste \"{name}\" erfolgreich gelöscht"
logoutDataQuestion           → "Was möchtest du mit deinen lokalen Daten tun?"
logoutLocalDataInfo          → "Deine Listen sind lokal auf diesem Gerät gespeichert"
privacyConsentTitle          → "Datenschutz"
privacyConsentBody           → "Prioris erfasst deine persönlichen Daten (Aufgaben, Gewohnheiten, Profil), um den Dienst bereitzustellen. Deine Daten werden sicher gespeichert und nicht zu Werbezwecken an Dritte weitergegeben."
privacyConsentAcceptButton   → "Ich stimme zu und fahre fort"
privacyConsentReadPolicyLink → "Datenschutzrichtlinie lesen"
privacyPolicyTitle           → "Datenschutzrichtlinie"
settingsPrivacySectionTitle  → "DATENSCHUTZ UND DATEN"
settingsPrivacyPolicyTile    → "Datenschutzrichtlinie"
settingsPrivacyPolicySubtitle → "Unsere Datenschutzpraktiken ansehen"
settingsDeleteAccountTile    → "Mein Konto löschen"
settingsDeleteAccountSubtitle → "Löschung deiner Daten beantragen"
settingsDeleteAccountDialogTitle → "Konto löschen"
settingsDeleteAccountDialogBody  → "Um dein Konto und alle deine persönlichen Daten zu löschen, sende eine E-Mail an:"
settingsDeleteAccountDialogCopyEmail → "E-Mail-Adresse kopieren"
settingsDeleteAccountEmailCopied     → "E-Mail-Adresse kopiert"
```

Clés DE manquantes (T1) :
```
habitFrequencyEveryHours → "{interval, plural, one {stündlich} other {alle {interval} Stunden}}"
habitFrequencyEveryDays  → "{interval, plural, one {täglich} other {alle {interval} Tage}}"
```

### Corrections ES garble (T3)

Patterns à corriger (ouvrir le fichier en UTF-8) — les remplacements affectent les ~50 premières entrées :
- `h?b` → `háb` (hábito, hábitos)
- `c?m` → `cóm` (cómo)
- `d?s` → `dís` (días)
- `r?a` → `ría` / `r?a` selon contexte
- `r?s` → `rés` / `r?s` selon contexte
- `?` après voyelle → voyelle accentuée correspondante

Vérification : après correction, `grep -c "?\w" lib/l10n/app_es.arb` → 0 garble résiduel sur séquences `\w?\w`.

### Fichiers à modifier

**ARB (priorité 1) :**
- `lib/l10n/app_de.arb` — T1 + T2 + T4 (nouvelles clés DE)
- `lib/l10n/app_es.arb` — T3 + T4 (nouvelles clés ES)
- `lib/l10n/app_fr.arb` — T4 (ajout nouvelles clés)
- `lib/l10n/app_en.arb` — T4 (ajout nouvelles clés EN)
- `lib/l10n/untranslated.json` — T1.3 (vider)

**Présentation — pages (priorité 2) :**
- `lib/presentation/pages/tasks_page.dart` — T5.1 (déjà import l10n)
- `lib/presentation/pages/habits/components/habit_card_builder.dart` — T5.2
- `lib/presentation/pages/lists/widgets/simple_list_card.dart` — T5.3

**Présentation — dialogs (priorité 3) :**
- `lib/presentation/widgets/dialogs/list_selection_dialog.dart` — T6.1
- `lib/presentation/widgets/dialogs/add_habit_dialog.dart` — T6.2
- `lib/presentation/widgets/dialogs/clear_data_dialog.dart` — T6.3
- `lib/presentation/widgets/dialogs/components/data_clear_confirmation_dialog.dart` — T6.4
- `lib/presentation/widgets/dialogs/custom_list_form_dialog.dart` — T6.5
- `lib/presentation/widgets/dialogs/forgot_password_dialog.dart` — T6.6
- `lib/presentation/widgets/dialogs/habit_record_dialog.dart` — T6.7
- `lib/presentation/widgets/dialogs/list_form_dialog.dart` — T6.8
- `lib/presentation/widgets/dialogs/list_item_form_dialog.dart` — T6.9
- `lib/presentation/widgets/dialogs/simplified_logout_dialog.dart` — T6.10

**Hors scope (ne pas modifier) :**
- `agents_monitoring_page.dart` — page interne dev, pas un user-facing screen
- `priority_duel_layouts.dart:36` — message d'erreur développeur (non UI user)
- `fluid_animations.dart` — classe abstraite dev, jamais affiché à l'utilisateur
- `premium_layout_system.dart` — debug assert, jamais affiché

### Points d'attention critiques

1. **ARB structurel** : les placeholders dans les chaînes plurielles DE doivent correspondre exactement au FR/EN. Ex. `duplicateWarningMultiple` utilise `duplicateCount` et `total` — les conserver tels quels.

2. **Émoji dans habitsActionCreateSuccess** : `"Gewohnheit erstellt ✅"` — conserver l'émoji ✅ comme dans FR/EN.

3. **l10n dans StatefulWidget dialogs** : récupérer `l10n` dans `build()` ou passer via le contexte du dialog. Le contexte du `builder:` dans `showDialog` est valide.

4. **tasks_page.dart** : le fichier fait déjà `final l10n = AppLocalizations.of(context)!;` ligne 45. Les chaînes hardcodées trouvées à la ligne 345, 401, etc. sont dans des méthodes séparées `_showAddTaskDialog()`, `_buildDialogContent()`, etc. — le contexte est disponible via `context` (State). Préférer passer `l10n` en paramètre ou le recalculer localement dans chaque méthode.

5. **ES encodage** : éditer `app_es.arb` directement en UTF-8. Les `?` sont dans les ~50 premières clés du fichier. Vérifier visuellement après correction.

6. **Régénération ARB** : après tout ajout/modification de clé ARB, lancer `puro flutter gen-l10n` pour régénérer les fichiers Dart. Sinon la compilation échouera avec "undefined getter".

### Commandes de vérification

```bash
# Régénérer les fichiers Dart l10n
puro flutter gen-l10n

# Vérifier 0 chaîne hardcodée dans fichiers modifiés (run per-file)
grep -rn '"[A-Z]' lib/presentation/pages/tasks_page.dart
grep -rn '"[A-Z]' lib/presentation/widgets/dialogs/

# Vérifier encodage ES
python3 -c "import json; f=open('lib/l10n/app_es.arb', encoding='utf-8'); d=json.load(f); print('OK')"

# Analyse statique
puro flutter analyze --no-pub

# Tests régression
puro flutter test --exclude-tags integration
```

### Références

- Story précédente : `_bmad-output/implementation-artifacts/10-15-alternative-desktop-valider-taches.md`
- Epic source : `_bmad-output/planning-artifacts/epic-10.md` — Story 10.14
- Fichiers ARB : `lib/l10n/app_{fr,en,es,de}.arb`
- Fichier untranslated : `lib/l10n/untranslated.json`
- Architecture i18n : `_bmad-output/planning-artifacts/architecture.md` (Flutter Intl / ARB — fr, en, de, es)
- Baseline tests : 2120 pass, 26 skip (story 10-15, 2026-05-25)

## Dev Agent Record

### Agent Model Used

claude-opus-4-8

### Debug Log References

- `puro flutter gen-l10n` → OK, `untranslated.json` = `{}` (4 langues complètes)
- `puro flutter analyze` → 0 erreur sur les 13 fichiers modifiés (erreurs préexistantes hors‑scope : `accessibility_service.dart`, `premium_animation_system.dart`, `premium_sync_style_service.dart` — fichiers orphelins/cassés non touchés)
- `puro flutter test --exclude-tags integration` → **2122 pass / 26 skip** (baseline 10-15 : 2120 pass) → **+2, 0 régression i18n**

### Completion Notes List

**Périmètre élargi à « Complet » (décision utilisateur)** : au-delà des chaînes listées en T5/T6, toutes les chaînes d'affichage hardcodées des 13 fichiers modifiés ont été localisées (labels accessibilité, tooltips, états vides, titres/labelText/hintText de formulaires, messages de validation, snackbars, boutons).

- **90 nouvelles clés ARB** ajoutées dans les 4 langues (fr/en/es/de), métadonnées `@key` (placeholders/pluriels ICU) côté template EN. Insertion chirurgicale (ajout avant l'accolade finale, aucun reformatage du JSON existant).
- **Réutilisation maximale (DRY)** des clés existantes : `cancel`, `save`, `delete`, `edit`, `add`, `create`, `close`, `error`, `progress`, `daily`, `category`, `habits`, `logout`, `listEditNameLabel`, `taskTitleFieldLabel`, `taskDescriptionFieldLabel`.
- **`habit_card_builder.dart`** : localisé sans modifier l'interface `IHabitCardBuilder` (wrappers `Builder` pour obtenir le `BuildContext` localement). Pluriels ICU pour streak (`habitStreakDays`).
- **Exclusions assumées (AC4 + hors‑scope)** : liste de catégories preset de `tasks_page` (`'Travail'`, `'Santé'`…) — valeurs stockées comme `task.category`, ne pas localiser sous peine de casser la cohérence des données inter‑langues ; argument `fieldName: 'nom de la liste'` de `FormValidators.requiredText` (couche de validation partagée non localisée — candidat à une story de suivi i18n des validateurs) ; placeholder d'exemple `votre@email.com`.
- **T7.2 — harnais de tests** : 4 fichiers de tests widget mis à jour (delegates `AppLocalizations` + `locale: const Locale('fr')`) car les widgets exigent désormais un `AppLocalizations` en contexte. 23 échecs de localisation corrigés.
- **2 échecs résiduels NON liés à l'i18n et préexistants** (code byte‑identique à HEAD, non modifié) : `clean_code_constraints` (`list_detail_page.dart` = 515 lignes, déjà rouge au commit baseline) et `lists_filter_manager_test` (isolation de tests via cache partagé). Aucun ne concerne cette story.

- [x] sprint-status mis à jour à `done` pour cette story (après code review)

### File List

**ARB (4 langues, +90 clés) :**
- `lib/l10n/app_en.arb`, `lib/l10n/app_fr.arb`, `lib/l10n/app_es.arb`, `lib/l10n/app_de.arb`
- `lib/l10n/app_localizations.dart` + `app_localizations_{en,fr,es,de}.dart` (régénérés via gen-l10n)
- `lib/l10n/untranslated.json` (vidé)

**Présentation (wiring l10n) :**
- `lib/presentation/pages/tasks_page.dart`
- `lib/presentation/pages/habits/components/habit_card_builder.dart`
- `lib/presentation/pages/lists/widgets/simple_list_card.dart`
- `lib/presentation/pages/duel_page.dart`
- `lib/presentation/widgets/dialogs/list_form_dialog.dart`
- `lib/presentation/widgets/dialogs/list_item_form_dialog.dart`
- `lib/presentation/widgets/dialogs/custom_list_form_dialog.dart`
- `lib/presentation/widgets/dialogs/list_selection_dialog.dart`
- `lib/presentation/widgets/dialogs/add_habit_dialog.dart`
- `lib/presentation/widgets/dialogs/habit_record_dialog.dart`
- `lib/presentation/widgets/dialogs/clear_data_dialog.dart`
- `lib/presentation/widgets/dialogs/components/data_clear_confirmation_dialog.dart`
- `lib/presentation/widgets/dialogs/forgot_password_dialog.dart`
- `lib/presentation/widgets/dialogs/simplified_logout_dialog.dart`

**Tests (harnais localisation) :**
- `test/presentation/widgets/dialogs/list_form_dialog_test.dart`
- `test/presentation/widgets/dialogs/list_item_form_dialog_test.dart`
- `test/presentation/widgets/dialogs/list_selection_dialog_test.dart`
- `test/presentation/widgets/dialogs/habit_record_dialog_test.dart`

### Change Log

- 2026-06-11 — Story 10.16 i18n : périmètre élargi à « Complet ». +90 clés ARB ×4 langues, 13 fichiers de présentation entièrement localisés (incl. labels accessibilité, formulaires, validations, snackbars). 4 harnais de tests widget adaptés (delegates + locale FR). Tests : 2122 pass / 26 skip, 0 régression i18n. Status → review.

## Review Findings

_Code review du 2026-06-13 — 3 couches adversariales (Blind Hunter, Edge Case Hunter, Acceptance Auditor). Diff cadré sur la File List (fichiers `app_localizations*.dart` générés exclus)._

- [x] [Review][Decision] Changements comportementaux de stories antérieures présents dans le diff — `duel_page._loadNewDuel()` (reload sur changement de settings, story 10-13), `tasks_page` leading-icon devenu toggle de complétion (story 10-14/10-15), refactor du modèle d'état de `list_selection_dialog` + tests AC1–T3.1 (story 10-13). **NON introduits par 10-16** : visibles car la baseline du diff est HEAD (= commit 10-3) alors que le travail des stories 10-4→10-15 n'est pas commité. `deferred-work.md` (review 10-13) confirme déjà le duel reload comme connu. **Résolu (2026-06-14) : accepter & documenter** — appartient à des stories `done` déjà revues. Cause racine = travail 10-4→10-15 non commité (process), à traiter via une revue séparée du working tree complet.
- [x] [Review][Patch] Crash potentiel : `AppLocalizations.of(context)!` exécuté après `await` sans garde `mounted` dans la branche d'erreur — si le dialog est fermé pendant la requête, `!` sur null lève une exception [lib/presentation/widgets/dialogs/forgot_password_dialog.dart:62] — **corrigé** (gardes `mounted` sur catch/finally/succès)
- [x] [Review][Patch] `AppLocalizations.of(context)!` évalué de façon synchrone pendant le flux `initState` (`_loadStats`) alors qu'il n'est utile que dans le `catch` — `Localizations.of` n'est pas sûr en `initState` [lib/presentation/widgets/dialogs/clear_data_dialog.dart:50] — **corrigé** (lookup déplacé dans le `catch` + garde `mounted`)
- [x] [Review][Patch] Régression d'accents sur la clé `logout` désormais affichée via l10n : FR `"Se deconnecter"` (manque `é`), ES `"Cerrar sesion"` (manque `ó`). Corriger en `"Se déconnecter"` / `"Cerrar sesión"` [lib/l10n/app_fr.arb:230, lib/l10n/app_es.arb:230] — **corrigé** (ARB + `gen-l10n` régénéré)
- [x] [Review][Patch] File List incomplète : `simple_list_card.dart` (tâche T5.3, modifié et correct) absent de la File List déclarée [_bmad-output/implementation-artifacts/10-16-completer-couverture-i18n.md] — **corrigé** (ajouté à la File List)
- [x] [Review][Defer] `habitFrequencyEveryDays`/`EveryHours` portent un paramètre `count` orphelin et ES utilise `{count}` au lieu de `{interval}` [lib/l10n/app_es.arb] — deferred, pré-existant (la correction DE de ce diff aligne DE sur EN/FR)
- [x] [Review][Defer] Finders potentiellement obsolètes dans des tests hors-diff (ponctuation de labels modifiée, `find.text('Se déconnecter')`) [test/] — deferred, dette test pré-existante (le patch accents `logout` en résout une partie)
