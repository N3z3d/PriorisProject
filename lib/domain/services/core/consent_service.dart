import 'package:shared_preferences/shared_preferences.dart';

class ConsentService {
  static const String _consentKey = 'privacy_consent_v1';
  static const String _consentDateKey = 'privacy_consent_date_v1';
  static const String consentContactEmail = 'support@prioris.app';

  Future<bool> hasAcceptedConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_consentKey) ?? false;
  }

  Future<void> acceptConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, true);
    try {
      await prefs.setString(_consentDateKey, DateTime.now().toIso8601String());
    } catch (_) {
      // Flag persisted; date write failed — audit trail incomplete but consent valid
    }
  }

  Future<void> revokeConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_consentKey);
    await prefs.remove(_consentDateKey);
  }
}
