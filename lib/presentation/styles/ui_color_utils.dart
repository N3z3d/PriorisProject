import 'package:flutter/material.dart';

/// Helper methods to derive tonal variations from any [Color] without relying
/// on [MaterialColor] or a global [ColorScheme]. Each widget can keep control
/// of its base color and generate lighter/darker variants on demand.
///
/// Lightness adjustments follow a simple mapping inspired by Material design
/// tones (50 → +0.40 lightness … 900 → −0.40 lightness) while clamping values
/// between 0 and 1 to avoid invalid colors.

/// Returns a lighter variant of [color].
Color lighten(Color color, [double amount = 0.1]) =>
    _shiftLightness(color, amount.abs());

/// Returns a darker variant of [color].
Color darken(Color color, [double amount = 0.1]) =>
    _shiftLightness(color, -amount.abs());

/// Generates a tone comparable to Material's shade scale (50-900).
Color tone(Color color, {required int level}) {
  final adjustment = _toneLightnessAdjustments[level] ?? 0.0;
  return _shiftLightness(color, adjustment);
}

const Map<int, double> _toneLightnessAdjustments = {
  50: 0.40,
  100: 0.30,
  200: 0.22,
  300: 0.14,
  400: 0.06,
  500: 0.0,
  600: -0.06,
  700: -0.14,
  800: -0.24,
  900: -0.34,
};

Color _shiftLightness(Color color, double delta) {
  final hsl = HSLColor.fromColor(color);
  final lightness = (hsl.lightness + delta).clamp(0.0, 1.0);
  return hsl.withLightness(lightness).toColor();
}
