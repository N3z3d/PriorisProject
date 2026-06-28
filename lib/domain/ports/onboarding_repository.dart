/// Port domaine pour la persistance de l'état d'onboarding actif.
///
/// Miroir de [IConsentRepository] : aucune dépendance infrastructure.
/// L'implémentation vit dans `lib/data/repositories/`.
abstract class IOnboardingRepository {
  /// Vrai si l'utilisateur a déjà atteint (ou passé) le moment d'activation.
  Future<bool> hasCompletedOnboarding();

  /// Marque l'onboarding comme terminé (flag durable, idempotent).
  Future<void> markCompleted();
}
