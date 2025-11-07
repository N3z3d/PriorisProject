import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/pages/lists/utils/list_type_helpers.dart'
    as page_helpers;
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/dialogs/components/list_type_helpers.dart'
    as dialog_helpers;

void main() {
  group('ListTypeHelpers (pages)', () {
    test('exposes TODO metadata', () {
      expect(
        page_helpers.ListTypeHelpers.getIconForType(ListType.TODO),
        Icons.check_circle_outline,
      );
      expect(
        page_helpers.ListTypeHelpers.getColorForType(ListType.TODO),
        AppTheme.accentColor,
      );
      expect(
        page_helpers.ListTypeHelpers.getDescriptionForType(ListType.TODO),
        'T\u00E2ches quotidiennes',
      );
    });

    test('exposes IDEAS metadata', () {
      expect(
        page_helpers.ListTypeHelpers.getIconForType(ListType.IDEAS),
        Icons.lightbulb_outline,
      );
      expect(
        page_helpers.ListTypeHelpers.getColorForType(ListType.IDEAS),
        AppTheme.infoColor,
      );
      expect(
        page_helpers.ListTypeHelpers.getDescriptionForType(ListType.IDEAS),
        'Id\u00E9es et inspirations',
      );
    });
  });

  group('ListTypeHelpers (dialogs)', () {
    test('returns colors for TODO and IDEAS', () {
      expect(
        dialog_helpers.ListTypeHelpers.getColor(ListType.TODO),
        Colors.indigo,
      );
      expect(
        dialog_helpers.ListTypeHelpers.getColor(ListType.IDEAS),
        Colors.teal,
      );
    });
  });
}
