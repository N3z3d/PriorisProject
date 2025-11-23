import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/services/text/text_normalization_service.dart';

void main() {
  group('TextNormalizationService', () {
    late TextNormalizationService service;

    setUp(() {
      service = const TextNormalizationService();
    });

    group('normalizeForSorting', () {
      test('converts to lowercase', () {
        expect(service.normalizeForSorting('HELLO'), equals('hello'));
        expect(service.normalizeForSorting('WoRlD'), equals('world'));
      });

      test('removes French accents from e', () {
        expect(service.normalizeForSorting('été'), equals('ete'));
        expect(service.normalizeForSorting('être'), equals('etre'));
        expect(service.normalizeForSorting('élève'), equals('eleve'));
        expect(service.normalizeForSorting('hôtel'), equals('hotel'));
      });

      test('removes accents from i', () {
        expect(service.normalizeForSorting('île'), equals('ile'));
        expect(service.normalizeForSorting('naïve'), equals('naive'));
      });

      test('removes accents from a', () {
        expect(service.normalizeForSorting('à'), equals('a'));
        expect(service.normalizeForSorting('â'), equals('a'));
      });

      test('removes accents from u', () {
        expect(service.normalizeForSorting('où'), equals('ou'));
        expect(service.normalizeForSorting('sûr'), equals('sur'));
      });

      test('removes accents from o', () {
        expect(service.normalizeForSorting('côte'), equals('cote'));
      });

      test('removes accents from c', () {
        expect(service.normalizeForSorting('ça'), equals('ca'));
        expect(service.normalizeForSorting('français'), equals('francais'));
      });

      test('handles mixed case and accents', () {
        expect(service.normalizeForSorting('Élève'), equals('eleve'));
        expect(service.normalizeForSorting('CAFÉ'), equals('cafe'));
      });

      test('preserves non-accented characters', () {
        expect(service.normalizeForSorting('hello'), equals('hello'));
        expect(service.normalizeForSorting('world123'), equals('world123'));
      });
    });

    group('compareIgnoringAccents', () {
      test('sorts words with same letters but different accents as equal', () {
        expect(service.compareIgnoringAccents('été', 'ete'), equals(0));
        expect(service.compareIgnoringAccents('élève', 'eleve'), equals(0));
      });

      test('ignores case when comparing', () {
        expect(service.compareIgnoringAccents('HELLO', 'hello'), equals(0));
        expect(service.compareIgnoringAccents('World', 'WORLD'), equals(0));
      });

      test('sorts alphabetically when normalized strings differ', () {
        expect(service.compareIgnoringAccents('apple', 'banana'), lessThan(0));
        expect(service.compareIgnoringAccents('zebra', 'ant'), greaterThan(0));
      });

      test('handles real-world French names correctly', () {
        // These should all be considered equal to their non-accented versions
        expect(service.compareIgnoringAccents('René', 'Rene'), equals(0));
        expect(service.compareIgnoringAccents('François', 'Francois'), equals(0));
        expect(service.compareIgnoringAccents('Naïma', 'Naima'), equals(0));
      });

      test('sorts correctly with mixed accented and non-accented strings', () {
        final names = ['Émile', 'Francois', 'Étienne', 'Antoine'];
        names.sort(service.compareIgnoringAccents);

        expect(names, equals(['Antoine', 'Émile', 'Étienne', 'Francois']));
      });
    });

    group('edge cases', () {
      test('handles empty strings', () {
        expect(service.normalizeForSorting(''), equals(''));
        expect(service.compareIgnoringAccents('', ''), equals(0));
      });

      test('handles strings with only accents', () {
        expect(service.normalizeForSorting('é'), equals('e'));
        expect(service.normalizeForSorting('ç'), equals('c'));
      });

      test('handles strings with numbers', () {
        expect(service.normalizeForSorting('café123'), equals('cafe123'));
        expect(service.compareIgnoringAccents('abc123', 'abc123'), equals(0));
      });

      test('handles strings with special characters', () {
        expect(service.normalizeForSorting('hello-world'), equals('hello-world'));
        expect(service.normalizeForSorting('test_file.txt'), equals('test_file.txt'));
      });
    });
  });
}
