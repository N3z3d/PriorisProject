import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lightweight builder that mirrors the "Red / Green / Refactor" cycle
/// used across the architecture regression tests. Each stage is optional
/// but executed in order when [build] is called.
class TDDTestBuilder {
  TDDTestBuilder(this.description);

  final String description;

  AsyncValueGetter<void>? _red;
  AsyncValueGetter<void>? _green;
  AsyncValueGetter<void>? _refactor;

  TDDTestBuilder red(AsyncValueGetter<void> body) {
    _red = body;
    return this;
  }

  TDDTestBuilder green(AsyncValueGetter<void> body) {
    _green = body;
    return this;
  }

  TDDTestBuilder refactor(AsyncValueGetter<void> body) {
    _refactor = body;
    return this;
  }

  void build() {
    test('TDD RED · $description', () async {
      if (_red != null) {
        await _red!();
      }
    });

    test('TDD GREEN · $description', () async {
      if (_green != null) {
        await _green!();
      }
    });

    test('TDD REFACTOR · $description', () async {
      if (_refactor != null) {
        await _refactor!();
      }
    });
  }
}
