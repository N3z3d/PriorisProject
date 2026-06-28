/// Parse pur des tâches saisies à l'Acte 1 de l'onboarding.
///
/// Source **unique de vérité** du nombre de tâches : split sur les sauts de
/// ligne, trim, filtre des lignes vides, déduplication insensible à la casse.
/// Consommé à la fois par le compteur de l'UI ([OnboardingCaptureStep]) et par
/// le contrôleur ([OnboardingFlowController]) — aucune logique de comptage
/// dupliquée entre les deux couches (DRY du comportement).
class OnboardingTaskParser {
  const OnboardingTaskParser();

  /// Retourne les titres uniques (premier libellé conservé pour la casse).
  List<String> parse(String raw) {
    final seen = <String>{};
    final titles = <String>[];
    for (final line in raw.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (seen.add(trimmed.toLowerCase())) {
        titles.add(trimmed);
      }
    }
    return titles;
  }
}
