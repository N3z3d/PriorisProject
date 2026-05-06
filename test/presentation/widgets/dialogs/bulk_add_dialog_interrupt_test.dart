import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/infrastructure/services/import_interrupt_service.dart';
import 'package:prioris/presentation/widgets/dialogs/bulk_add_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/localized_widget.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ImportInterruptService.instance.onComplete();
  });

  group('BulkAddDialog — interruption detection', () {
    testWidgets('import complet : état effacé de SharedPreferences',
        (tester) async {
      final completer = Completer<void>();

      await tester.pumpWidget(localizedApp(
        BulkAddDialog(
          onSubmit: (items, onProgress) {
            onProgress(1, 1);
            return completer.future;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Item');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ajouter'));
      await tester.pump();

      completer.complete();
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('import_interrupt_current_v1'), isNull);
      expect(prefs.getInt('import_interrupt_total_v1'), isNull);
    });

    testWidgets('import en cours : onProgress persiste dans SharedPreferences',
        (tester) async {
      late void Function(int, int) capturedProgress;
      final completer = Completer<void>();

      await tester.pumpWidget(localizedApp(
        BulkAddDialog(
          onSubmit: (items, onProgress) {
            capturedProgress = onProgress;
            return completer.future;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Item');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ajouter'));
      await tester.pump();

      capturedProgress(3, 10);
      await tester.pump(const Duration(milliseconds: 50));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('import_interrupt_current_v1'), equals(3));
      expect(prefs.getInt('import_interrupt_total_v1'), equals(10));

      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets(
        'annulation pendant import : état effacé (BulkAddCancelException)',
        (tester) async {
      await tester.pumpWidget(localizedApp(
        BulkAddDialog(
          onSubmit: (items, onProgress) async {
            onProgress(2, 5);
            throw BulkAddCancelException();
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Item');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ajouter'));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('import_interrupt_current_v1'), isNull);
    });

    testWidgets(
        'lifecycle paused : didChangeAppLifecycleState persiste independamment',
        (tester) async {
      late void Function(int, int) capturedProgress;
      final completer = Completer<void>();

      await tester.pumpWidget(localizedApp(
        BulkAddDialog(
          onSubmit: (items, onProgress) {
            capturedProgress = onProgress;
            return completer.future;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Item');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ajouter'));
      await tester.pump();

      // Etablit _processedCount=5, _totalCount=10 dans le state du dialog
      capturedProgress(5, 10);
      await tester.pump(const Duration(milliseconds: 50));

      // Efface les prefs pour isoler le chemin didChangeAppLifecycleState
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('import_interrupt_current_v1');
      await prefs.remove('import_interrupt_total_v1');

      // Simule paused -> doit declencher didChangeAppLifecycleState independamment
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(milliseconds: 50));

      expect(prefs.getInt('import_interrupt_current_v1'), equals(5));
      expect(prefs.getInt('import_interrupt_total_v1'), equals(10));

      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets(
        'lifecycle hidden : didChangeAppLifecycleState persiste (desktop/web)',
        (tester) async {
      late void Function(int, int) capturedProgress;
      final completer = Completer<void>();

      await tester.pumpWidget(localizedApp(
        BulkAddDialog(
          onSubmit: (items, onProgress) {
            capturedProgress = onProgress;
            return completer.future;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Item');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ajouter'));
      await tester.pump();

      capturedProgress(3, 8);
      await tester.pump(const Duration(milliseconds: 50));

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('import_interrupt_current_v1');
      await prefs.remove('import_interrupt_total_v1');

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      await tester.pump(const Duration(milliseconds: 50));

      expect(prefs.getInt('import_interrupt_current_v1'), equals(3));
      expect(prefs.getInt('import_interrupt_total_v1'), equals(8));

      completer.complete();
      await tester.pumpAndSettle();
    });
  });
}
