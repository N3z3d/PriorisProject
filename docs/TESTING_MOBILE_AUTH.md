# Procédure de test auth mobile — Prioris

## Rate limit Supabase

Supabase applique par défaut un rate limit sur l'envoi d'emails magic link / OTP :
- **3 à 4 emails / heure** (plan gratuit — limite par IP/projet selon configuration Supabase)
- Dépasser ce seuil → erreur Supabase "Email rate limit exceeded" (HTTP 429)

---

## Procédure de test mobile avec rate limit actif

### Option A — Email différent (recommandé)

Utiliser une adresse email différente de celle utilisée pour les tests précédents dans l'heure.
Gmail accepte les alias `+tag` : `yourname+test2@gmail.com` reçoit les emails.
Note : Supabase applique le rate limit par IP ou par projet selon la configuration — l'alias email
peut ne pas contourner la limite selon votre setup.

### Option B — Attendre 1 heure

Attendre la fin de la fenêtre de rate limit (60 min depuis le dernier envoi).

### Option C — Console Supabase (développement uniquement)

1. Ouvrir le dashboard Supabase du projet
2. Authentication → Users → sélectionner l'utilisateur cible
3. Copier le lien magic link depuis les logs, ou générer via "Send magic link"
4. Coller directement dans le navigateur mobile (bypasse l'envoi email)

---

## Cas de test auth callback à couvrir

| Scénario | URL simulée | Résultat attendu |
|----------|-------------|-----------------|
| Succès magic link (PKCE) | `https://app/?code=xxx&type=signup` | AuthWrapper → HomePage |
| Succès fragment route-like | `https://app/#sb-<project>-auth-token` | AppRoutes → AuthWrapper → HomePage |
| Lien expiré | Fragment `#sb-...` sans session valide | LoginPage + message "lien expiré" |
| Navigateur différent | Fragment sans code verifier PKCE en localStorage | LoginPage + message "session non établie" |
| Callback sans session | `?error=access_denied&error_description=...` | LoginPage + message d'erreur contextuel |

**Mécanisme** : `WebAuthCallbackStabilizer.consumeCallbackWithoutSession()` retourne `true`
→ `callbackWithoutSessionProvider` (autoDispose) expose `true` à `LoginPage.initState()`
→ snackbar / message contextuel affiché une seule fois.

---

## Vérification avec compte non-créateur

Avant la clôture de chaque Epic :

1. Se déconnecter du compte Thibaut (Settings → Déconnexion)
2. Se connecter avec un compte pilote externe (non créateur du projet Supabase)
3. Vérifier :
   - Affichage correct de l'interface (pas de données Thibaut visibles)
   - Flux RGPD : `ConsentGatePage` s'affiche si première connexion de ce compte
   - RLS Supabase : les données de l'autre utilisateur sont bien isolées
4. Tester les flux critiques sur le compte non-créateur :
   - Ajout d'un item en liste
   - Duel de priorisation (calcul Elo)
   - Vue Insights (données vides ou propres au compte)
   - Déconnexion propre

---

## Architecture auth (rappel)

Le flux auth callback est géré par `WebAuthCallbackStabilizer` avant le bootstrap UI :

```
SupabaseService.initialize()
  └─ stabilizeFromCurrentOrIncomingSessionIfNeeded()
       ├─ détecte URL callback (query ?code= ou fragment #sb-)
       ├─ échange PKCE si code verifier présent
       ├─ persiste session → localStorage (sb-<projectRef>-auth-token)
       ├─ sanitize URL → history.replaceState
       └─ si échec → _callbackWithoutSession = true

AppRoutes.generateRoute()
  └─ _isSupabaseCallbackRoute() → route vers AuthWrapper

AuthWrapper (home: dans MaterialApp)
  └─ authUIStateProvider + consentProvider → HomePage / LoginPage / ConsentGatePage
```

Fichiers clés :
- `lib/infrastructure/services/web_auth_callback_stabilizer.dart`
- `lib/infrastructure/services/supabase_service.dart`
- `lib/presentation/pages/auth/auth_wrapper.dart`
- `lib/presentation/routes/app_routes.dart`
