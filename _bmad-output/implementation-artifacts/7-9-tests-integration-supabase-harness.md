# Story 7.9 : Faire tourner les tests d'integration Supabase en local

Status: backlog

## Story

En tant que developpeur,
je veux pouvoir executer les tests d'integration Supabase depuis ma machine locale,
afin de valider le CRUD habitudes contre le vrai Supabase sans deployer.

## Contexte

Le test `test/integration/repositories/supabase_habit_repository_integration_test.dart`
existe et couvre le CRUD complet. Il est bloque par deux problemes d'infrastructure :

1. **`test/flutter_test_config.dart` injecte une URL mock** pour tous les tests sous `test/`.
   Le test lit `AppConfig.instance.supabaseUrl` qui retourne `tests-prioris.supabase.co`
   (URL fictive) au lieu du vrai projet Supabase. Contournement partiel applique en 7.1
   (lecture directe du `.env`), mais `AuthService.signIn` logue encore l'URL mock car il
   lit `AppConfig` independamment.

2. **Compte de test inexistant dans le projet Supabase pilote.**
   Le compte `test_1776892399910_958@example.com` n'existe pas dans
   `vgowxrktjzgwrfivtvse.supabase.co`. Il faut creer un compte de test dans ce projet
   (Supabase Dashboard -> Authentication -> Users -> Invite user) et mettre a jour les
   credentials dans `test/manual/test_credentials.txt`.

## Acceptance Criteria

1. `flutter test test/integration/repositories/... --tags integration` passe en vert.
2. Le compte de test est cree dans le bon projet Supabase et documente.
3. La lecture des credentials de test est propre (pas d'URL mock injectee par flutter_test_config).

## Tasks

- [ ] Creer le compte de test dans Supabase Dashboard -> Authentication -> Users
- [ ] Mettre a jour `test/manual/test_credentials.txt` avec email/password
- [ ] Verifier que `AuthService.signIn` utilise l'URL initialisee par `Supabase.initialize`
      et non celle d'`AppConfig` (ou documenter que c'est juste un log, pas le vrai appel)
- [ ] Valider que le test passe en vert avec les bons credentials

## Note

AC3 de la story 7.1 est considere valide via la validation manuelle en production (l'utilisateur
a confirme que le CRUD fonctionne dans l'app deployee). Ce test est du "nice to have" pour
automatiser cette validation.
