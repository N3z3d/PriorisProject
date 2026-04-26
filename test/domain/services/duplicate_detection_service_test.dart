import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/services/duplicate_detection_service.dart';

void main() {
  const service = DuplicateDetectionService();
  final now = DateTime(2024, 1, 1);

  ListItem makeItem(String title) =>
      ListItem(id: title, title: title, listId: 'l1', createdAt: now);

  group('DuplicateDetectionService.detect', () {
    test('cas nominal — 1 doublon exact', () {
      final existing = [makeItem('Café')];
      final result = service.detect(existing, ['Café', 'Thé']);
      expect(result.duplicateTitles, ['Café']);
      expect(result.uniqueTitles, ['Thé']);
      expect(result.hasDuplicates, isTrue);
    });

    test('insensible à la casse', () {
      final existing = [makeItem('Café')];
      final result = service.detect(existing, ['café', 'Thé']);
      expect(result.duplicateTitles, ['café']);
      expect(result.uniqueTitles, ['Thé']);
      expect(result.hasDuplicates, isTrue);
    });

    test('insensible aux accents', () {
      final existing = [makeItem('Café')];
      final result = service.detect(existing, ['Cafe', 'Eau']);
      expect(result.duplicateTitles, ['Cafe']);
      expect(result.uniqueTitles, ['Eau']);
    });

    test('doublon intra-batch', () {
      final result = service.detect([], ['item', 'Item', 'autre']);
      expect(result.duplicateTitles, ['Item']);
      expect(result.uniqueTitles, ['item', 'autre']);
    });

    test('aucun doublon', () {
      final existing = [makeItem('Pomme')];
      final result = service.detect(existing, ['Poire', 'Cerise']);
      expect(result.duplicateTitles, isEmpty);
      expect(result.uniqueTitles, ['Poire', 'Cerise']);
      expect(result.hasDuplicates, isFalse);
    });

    test('tout doublon — uniqueTitles vide', () {
      final existing = [makeItem('A'), makeItem('B')];
      final result = service.detect(existing, ['A', 'B']);
      expect(result.uniqueTitles, isEmpty);
      expect(result.hasDuplicates, isTrue);
    });

    test('incoming vide', () {
      final existing = [makeItem('X')];
      final result = service.detect(existing, []);
      expect(result.duplicateTitles, isEmpty);
      expect(result.uniqueTitles, isEmpty);
      expect(result.hasDuplicates, isFalse);
    });

    test('existing vide — tous uniques', () {
      final result = service.detect([], ['A', 'B', 'C']);
      expect(result.duplicateTitles, isEmpty);
      expect(result.uniqueTitles, ['A', 'B', 'C']);
    });

    test('trim des espaces avant comparaison', () {
      final existing = [makeItem('Café')];
      final result = service.detect(existing, ['  café  ']);
      expect(result.duplicateTitles, ['  café  ']);
      expect(result.uniqueTitles, isEmpty);
    });
  });
}
