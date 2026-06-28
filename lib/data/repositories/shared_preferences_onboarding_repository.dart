import 'package:prioris/domain/ports/onboarding_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Adapter SharedPreferences pour [IOnboardingRepository].
///
/// Calque exact de `SharedPreferencesConsentRepository` (stories 10.2 / 10.5).
class SharedPreferencesOnboardingRepository implements IOnboardingRepository {
  static const String _onboardingKey = 'onboarding_completed_v1';

  @override
  Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  @override
  Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }
}
