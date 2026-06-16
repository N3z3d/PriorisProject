import 'package:prioris/domain/ports/consent_repository.dart';

class ConsentService {
  const ConsentService(this._repository);

  static const String consentContactEmail = 'support@prioris.app';

  final IConsentRepository _repository;

  Future<bool> hasAcceptedConsent() => _repository.hasAcceptedConsent();
  Future<void> acceptConsent() => _repository.acceptConsent();
  Future<void> revokeConsent() => _repository.revokeConsent();
}
