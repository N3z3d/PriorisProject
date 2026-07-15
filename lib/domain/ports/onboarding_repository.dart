/// État d'onboarding d'un utilisateur, **lié au compte** (pas au device).
///
/// Value object pur (aucune dépendance infrastructure) : deux dates suffisent à
/// décider « déjà complété ? » ([completedAt]) et « dormant ? » ([lastSeenAt]).
class OnboardingState {
  /// Date de complétion de l'onboarding, `null` s'il n'a jamais été complété.
  final DateTime? completedAt;

  /// Date du dernier passage authentifié, `null` si jamais vu.
  /// Support de la règle de dormance (reproposer après une longue absence).
  final DateTime? lastSeenAt;

  const OnboardingState({this.completedAt, this.lastSeenAt});

  /// Vrai dès que l'onboarding a été complété au moins une fois.
  bool get hasCompleted => completedAt != null;
}

/// Port domaine pour la persistance de l'état d'onboarding, account-scoped.
///
/// Miroir de [IConsentRepository] : aucune dépendance infrastructure.
/// L'implémentation account-scoped vit dans `lib/data/repositories/supabase/`.
abstract class IOnboardingRepository {
  /// Charge l'état d'onboarding du compte courant.
  Future<OnboardingState> loadState();

  /// Marque l'onboarding comme terminé (pose `completedAt`, idempotent :
  /// ne réécrit pas une date de complétion déjà présente).
  Future<void> markCompleted();

  /// Enregistre « vu maintenant » ([lastSeenAt]) — support de la dormance.
  Future<void> touchLastSeen();
}
