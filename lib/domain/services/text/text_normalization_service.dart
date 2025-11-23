/// Service de normalisation de texte pour le tri et la comparaison
///
/// **SRP** : Responsable uniquement de la normalisation de texte
/// **Stateless** : Aucun état, fonctions pures
class TextNormalizationService {
  const TextNormalizationService();

  /// Normalise une chaîne pour le tri alphabétique
  ///
  /// - Convertit en minuscules
  /// - Supprime les accents
  /// - Préserve les espaces et la ponctuation
  ///
  /// Exemples:
  /// - "Équateur" -> "equateur"
  /// - "Île de la Réunion" -> "ile de la reunion"
  /// - "CAFÉ" -> "cafe"
  String normalizeForSorting(String text) {
    return _removeAccents(text.toLowerCase());
  }

  /// Supprime les accents d'une chaîne
  ///
  /// Utilise la décomposition Unicode NFD pour séparer
  /// les caractères de base de leurs diacritiques
  String _removeAccents(String text) {
    // Décomposition NFD : sépare les caractères de base et les diacritiques
    // Par exemple : é -> e + ´
    final normalized = text
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('å', 'a')
        .replaceAll('æ', 'ae')
        .replaceAll('ç', 'c')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ì', 'i')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ñ', 'n')
        .replaceAll('ó', 'o')
        .replaceAll('ò', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ø', 'o')
        .replaceAll('œ', 'oe')
        .replaceAll('ú', 'u')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ý', 'y')
        .replaceAll('ÿ', 'y');

    return normalized;
  }

  /// Compare deux chaînes de manière insensible aux accents et à la casse
  ///
  /// Retourne:
  /// - < 0 si a vient avant b
  /// - 0 si a == b
  /// - > 0 si a vient après b
  int compareIgnoringAccents(String a, String b) {
    final normalizedA = normalizeForSorting(a);
    final normalizedB = normalizeForSorting(b);
    return normalizedA.compareTo(normalizedB);
  }
}
