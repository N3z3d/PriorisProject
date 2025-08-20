# Claude Code Configuration - Prioris Project

## Permissions
- Autorisation complète pour ouvrir et modifier tous les fichiers dans Cursor h24 sans demander
- Permissions étendues pour les commandes Flutter, Dart, Git

## Notes importantes pour Claude
- Le projet est en cours de migration vers Supabase ✅ TERMINÉ
- Migration Supabase COMPLÈTE avec tests complets
- Priorité : stabilité du code avant ajout de features
- **OBLIGATOIRE : Coder en TDD (Test-Driven Development)**

## Instructions spéciales
- **TOUJOURS synchroniser avec l'IDE Cursor automatiquement**
- Ouvrir toutes les modifications dans Cursor automatiquement  
- Ne pas demander de permissions pour les éditions de fichiers
- Procéder directement aux corrections recommandées
- **Approche TDD obligatoire : Écrire les tests AVANT le code**

## Méthodologie TDD à suivre
1. **Red** : Écrire un test qui échoue
2. **Green** : Écrire le minimum de code pour faire passer le test
3. **Refactor** : Améliorer le code tout en gardant les tests verts
4. Répéter le cycle pour chaque fonctionnalité

## Status actuel
- ✅ Migration Supabase TERMINÉE (auth, repositories, sync)
- ✅ Tests complets créés (auth, repositories, integration)
- ✅ Erreurs de compilation corrigées (10 → 0)
- ✅ **Système d'orchestration TDD installé**
- ✅ **Sécurisation des clés API Supabase TERMINÉE**
- 🚀 Prêt pour nouvelles fonctionnalités en TDD

## 🔒 Configuration Sécurisée des Variables d'Environnement

### Système de Configuration Sécurisé
- ✅ **flutter_dotenv** installé et configuré
- ✅ Variables d'environnement externalisées
- ✅ Clés API Supabase sécurisées  
- ✅ Configuration multi-environnements (dev/prod)
- ✅ Validation automatique des variables critiques

### Fichiers de Configuration
```bash
.env.example         # Template avec valeurs factices (à commiter)
.env.development     # Configuration développement (peut être commitée)
.env.production      # Configuration production (JAMAIS commiter)  
.env                # Fichier actuel (ignoré par Git)
```

### Setup pour Nouveaux Développeurs
1. **Copier le template** :
   ```bash
   cp .env.example .env
   ```

2. **Configurer les vraies clés** :
   - Remplacer `SUPABASE_URL` par votre URL projet
   - Remplacer `SUPABASE_ANON_KEY` par votre clé anonyme

3. **Variables d'environnement disponibles** :
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   ENVIRONMENT=development
   DEBUG_MODE=true
   ```

### Architecture Sécurisée
- **AppConfig** : Classe centralisée pour toutes les variables d'environnement
- **Validation** : Vérification automatique des variables critiques au démarrage
- **Masquage** : Affichage masqué des clés sensibles dans les logs
- **Multi-environnements** : Support dev/prod avec configurations séparées

### Sécurité
- ✅ Plus de clés hardcodées dans le code source
- ✅ Fichiers .env exclus du contrôle de version
- ✅ Validation des variables au démarrage
- ✅ Logs sécurisés avec masquage des données sensibles

## 🎯 Système d'Orchestration Claude Code

### Agents Spécialisés Installés
- **tdd_orchestrator** : Coordinateur principal pour workflows TDD complexes
- **flutter_tester** : Spécialiste création de tests (unit, widget, integration)
- **dart_implementer** : Implémentation propre suivant les conventions projet
- **widget_builder** : Composants Flutter avec glassmorphisme et design premium
- **repository_manager** : Couche données Supabase avec patterns établis

### Activation Automatique
```bash
# Déclenche tdd_orchestrator
"Implement [feature] with TDD"
"Add [functionality] following TDD"

# Déclenche flutter_tester
"Write tests for [component]"
"Test [functionality]"

# Déclenche dart_implementer  
"Implement [business logic]"
"Create [service]"

# Déclenche widget_builder
"Create [widget] component"
"Build [UI element]"

# Déclenche repository_manager
"Add [entity] repository"
"Implement [data] persistence"
```

### Workflow TDD Automatisé
1. **RED** → flutter_tester crée test qui échoue
2. **GREEN** → dart_implementer/widget_builder implémente minimum
3. **REFACTOR** → amélioration code avec tests qui passent
4. **VALIDATE** → vérification qualité complète

### Commandes de Qualité
```bash
flutter test --coverage          # Tests avec couverture
dart analyze                     # Analyse statique  
dart format .                   # Formatage code
flutter packages pub run build_runner build  # Génération code
```

### Configuration
- Couverture de tests requise : >80%
- Zéro warning d'analyse
- Validation TDD obligatoire
- Vérifications accessibilité