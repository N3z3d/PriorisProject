import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/services/text/text_normalization_service.dart';

class DuplicateDetectionResult {
  final List<String> duplicateTitles;
  final List<String> uniqueTitles;

  const DuplicateDetectionResult({
    required this.duplicateTitles,
    required this.uniqueTitles,
  });

  bool get hasDuplicates => duplicateTitles.isNotEmpty;
}

class DuplicateDetectionService {
  static const _normalizer = TextNormalizationService();

  const DuplicateDetectionService();

  DuplicateDetectionResult detect(
    List<ListItem> existing,
    List<String> incoming,
  ) {
    final existingNormalized = existing
        .map((item) => _normalizer.normalizeForSorting(item.title.trim()))
        .toSet();

    final duplicates = <String>[];
    final unique = <String>[];

    for (final title in incoming) {
      final normalized = _normalizer.normalizeForSorting(title.trim());
      if (existingNormalized.contains(normalized)) {
        duplicates.add(title);
      } else {
        unique.add(title);
        existingNormalized.add(normalized);
      }
    }

    return DuplicateDetectionResult(
      duplicateTitles: duplicates,
      uniqueTitles: unique,
    );
  }
}
