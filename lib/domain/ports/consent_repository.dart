abstract class IConsentRepository {
  Future<bool> hasAcceptedConsent();
  Future<void> acceptConsent();
  Future<void> revokeConsent();
}
