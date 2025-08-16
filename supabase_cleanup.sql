-- ===================================
-- SCRIPT DE NETTOYAGE COMPLET - PRIORIS
-- ===================================

-- ⚠️ ATTENTION: Ce script supprime TOUTES les données !
-- À exécuter uniquement pour remettre la base à zéro

-- Supprimer toutes les données des tables (dans l'ordre des dépendances)
DELETE FROM public.habit_completions;
DELETE FROM public.list_items;
DELETE FROM public.custom_lists;
DELETE FROM public.habits;
DELETE FROM public.profiles;

-- Optionnel: supprimer aussi les utilisateurs d'authentification
-- (Attention: ceci supprime définitivement les comptes utilisateurs)
-- DELETE FROM auth.users;

-- Réinitialiser les compteurs de séquence si nécessaire
-- (Les UUIDs n'ont pas de séquence, donc pas nécessaire ici)

-- Vérifier que tout est vide
SELECT 'profiles' as table_name, COUNT(*) as count FROM public.profiles
UNION ALL
SELECT 'custom_lists' as table_name, COUNT(*) as count FROM public.custom_lists
UNION ALL
SELECT 'list_items' as table_name, COUNT(*) as count FROM public.list_items
UNION ALL
SELECT 'habits' as table_name, COUNT(*) as count FROM public.habits
UNION ALL
SELECT 'habit_completions' as table_name, COUNT(*) as count FROM public.habit_completions
UNION ALL
SELECT 'auth.users' as table_name, COUNT(*) as count FROM auth.users;

-- Message de confirmation
SELECT 'Base de données nettoyée avec succès !' as message;