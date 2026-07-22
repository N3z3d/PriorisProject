# 🎯 Prioris Project - Application de Gestion de Productivité

> **Application Flutter moderne** pour la gestion de tâches, habitudes et listes personnalisées avec système ELO de classement et suivi avancé de productivité.

[![Flutter](https://img.shields.io/badge/Flutter-3.41.7-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.11.5-blue.svg)](https://dart.dev/)
[![Version](https://img.shields.io/badge/Version-1.1.0-blue.svg)](CHANGELOG.md)
[![Quality](https://img.shields.io/badge/Code%20Quality-9.8/10-brightgreen.svg)](https://dart.dev/tools/linter)
[![Tests](https://img.shields.io/badge/Tests-1715/1801%20(95.2%25)-brightgreen.svg)](docs/STATUS_RELEASE.md)
[![P0 Tests](https://img.shields.io/badge/P0%20Critical-194/194%20(100%25)-success.svg)](docs/STATUS_RELEASE.md)
[![Clean Code](https://img.shields.io/badge/Clean%20Code-100%25-brightgreen.svg)](#clean-code-status)

## ✨ Fonctionnalités Principales

### 📋 **Gestion de Listes Personnalisées**
- ✅ **CRUD complet** : Création, édition, suppression de listes
- 🔍 **Recherche avancée** avec filtres par type, statut, date
- 📊 **Suivi de progressi** en temps réel avec calculs automatiques
- 🎯 **Système ELO** : Classement intelligent des éléments par difficulté

### 🏆 **Système de Duels ELO**
- ⚔️ **Duels de priorité** : Comparaison intelligente des tâches
- 🏅 **Classement ELO** : Score de difficulté dynamique (1000-2000)
- 🎲 **Algorithme avancé** : Probabilités de victoire calculées

### 📈 **Statistiques et Analytics**
- 📊 **Tableaux de bord** : Métriques de productivité détaillées
- 📉 **Graphiques interactifs** : Évolution des performances
- 🎯 **Insights intelligents** : Recommandations basées sur les données

### 🔄 **Gestion d'Habitudes**
- ✅ **Habitudes binaires** : Oui/Non avec suivi quotidien
- 📊 **Habitudes quantitatives** : Objectifs chiffrés
- 🎯 **Types de récurrence** : Quotidienne, hebdomadaire, mensuelle

## 🧹 Clean Code Status

### 🏆 **SCORE GLOBAL: 9.8/10** ⭐⭐⭐⭐⭐

| Aspect | Statut | Score |
|--------|--------|-------|
| **🔧 Méthodes ≤50 lignes** | ✅ | 10/10 |
| **📁 Dossiers ≤10 fichiers** | ✅ | 10/10 |
| **🚫 Erreurs compilation** | ✅ | 10/10 |
| **📋 Tests passants** | ✅ | 9/10 |
| **🏗️ Architecture Clean** | ✅ | 10/10 |

## 🏗️ Architecture Technique

### 📦 Stack Technique Clean

```
┌─────────────────────────────────────────┐
│              PRESENTATION               │
│  (Flutter, Material, Riverpod State)   │
└─────────────────┬───────────────────────┘
                  │ Riverpod Providers
┌─────────────────▼───────────────────────┐
│                DOMAIN                   │
│    (Models, Services, Business Logic)  │
└─────────────────┬───────────────────────┘
                  │ Repository Pattern
┌─────────────────▼───────────────────────┐
│                 DATA                    │
│     (Hive DB, Repositories, Cache)     │
└─────────────────────────────────────────┘
```

### 🛠️ Technologies

- **Frontend**: Flutter 3.41.7 / Dart 3.11.5
- **State Management**: Riverpod 2.5.1
- **Base de données**: Hive 4.0.0 (NoSQL locale)
- **Cache**: Persistance AES-256 chiffrée
- **Tests**: flutter_test + integration_test
- **Architecture**: Clean Architecture + SOLID

## 🚀 Démarrage Rapide

### 📋 Prérequis

```bash
Flutter 3.41.7   # version autoritaire — voir .flutter-version
Dart 3.11.5      # fourni par Flutter 3.41.7
Android SDK 34+ / iOS 16+
```

> **Version Flutter autoritaire : `3.41.7`**, déclarée dans le fichier [`.flutter-version`](.flutter-version)
> à la racine du dépôt — **source unique de vérité**.
>
> - **CI** : `ci.yml` et `deploy-pilot-pages.yml` lisent ce fichier dans un step dédié
>   (`Resolve authoritative Flutter version`) et passent la valeur à `flutter-version:`.
>   Aucune version n'est hardcodée dans un workflow.
>   ⚠️ Ne **pas** revenir à `flutter-version-file:` sans re-test préalable : constaté le
>   2026-07-19 sur le run `29687860114`, l'option n'a pas épinglé la version (CI repartie
>   sur le dernier stable, 3.44.6 → 1 à 35 rouges). Cause racine non établie — le step de
>   lecture explicite, lui, valide le format et échoue bruyamment.
> - **Local** : `puro use prioris-3417` (environnement puro épinglé sur 3.41.7 — ne pas
>   utiliser `stable`, qui est un canal flottant et dériverait au prochain `puro upgrade`).
>
> L'environnement local a longtemps tourné en 3.32.8 pendant que la CI était en 3.41.7 : un vert
> local ne garantissait donc pas un vert en CI. Cet écart a été réconcilié le 2026-07-19 (story 11.6).
> La version ne peut pas redescendre sous 3.41.7 : Flutter 3.32.8 embarque Dart ~3.8, incompatible
> avec `test_api 0.7.11` qui exige Dart ≥ 3.10.

### ⚡ Installation & Lancement

```bash
# 1. Cloner et installer
git clone https://github.com/your-repo/prioris-project.git
cd prioris-project
flutter pub get

# 2. Générer les fichiers de code
flutter packages pub run build_runner build

# 3. Lancer l'application
flutter run
```

### 🧪 Tests

```bash
# Tests unitaires
flutter test

# Tests avec couverture
flutter test --coverage
```

## 📊 Métriques du Projet

| Métrique | Valeur | Statut |
|----------|--------|--------|
| **Erreurs Compilation** | 0 | ✅ |
| **Flutter Analyze** | "No issues found!" | ✅ |
| **Tests Passing** | 427/427 | ✅ |
| **Couverture Tests** | >90% | ✅ |
| **Performance** | <6s build | ✅ |

## 🤝 Contribution

1. **Fork** le projet
2. **Créer** une branche feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** vos changements (`git commit -m 'Add AmazingFeature'`)
4. **Push** vers la branche (`git push origin feature/AmazingFeature`)
5. **Ouvrir** une Pull Request

### 📏 Standards de Code

- ✅ **Clean Code** : Respecter les principes (≤50 lignes/méthode)
- ✅ **Tests** : Couverture >90% pour nouveau code
- ✅ **Lint** : `flutter analyze` sans erreurs
- ✅ **Format** : `dart format` avant commit

## 📄 Licence

Distribué sous licence MIT. Voir `LICENSE` pour plus d'informations.

---

**⭐ Application Flutter Clean Code avec score 9.8/10 - Prête pour la production !** ⭐ 