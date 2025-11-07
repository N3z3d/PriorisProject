import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/styles/ui_color_utils.dart';

void main() {
  group('ui_color_utils', () {
    test('lighten produces a brighter color', () {
      final base = const Color(0xFF3366FF);
      final lighter = lighten(base, 0.2);

      expect(lighter.computeLuminance(), greaterThan(base.computeLuminance()));
    });

    test('darken produces a darker color', () {
      final base = const Color(0xFF3366FF);
      final darker = darken(base, 0.2);

      expect(darker.computeLuminance(), lessThan(base.computeLuminance()));
    });

    test('tone maps levels to bounded lightness adjustments', () {
      final base = Colors.red;
      final veryLight = tone(base, level: 50);
      final mid = tone(base, level: 500);
      final veryDark = tone(base, level: 900);

      expect(veryLight.computeLuminance(), greaterThan(mid.computeLuminance()));
      expect(veryDark.computeLuminance(), lessThan(mid.computeLuminance()));
    });
  });
}
