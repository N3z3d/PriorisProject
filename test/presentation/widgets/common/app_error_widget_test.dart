import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/core/exceptions/app_exception.dart';
import 'package:prioris/presentation/widgets/common/error/app_error_widget.dart';
import '../../../helpers/localized_widget.dart';

void main() {
  group('AppErrorWidget', () {
    testWidgets('affiche icône error_outline pour erreur générique',
        (tester) async {
      await tester.pumpWidget(
        localizedApp(
          const AppErrorWidget(
            title: 'Titre',
            message: 'Message',
          ),
        ),
      );
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsNothing);
    });

    testWidgets('affiche icône wifi_off pour erreur réseau', (tester) async {
      await tester.pumpWidget(
        localizedApp(
          const AppErrorWidget(
            title: 'Titre',
            message: 'Message',
            isNetworkError: true,
          ),
        ),
      );
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('affiche le bouton Réessayer si onRetry fourni',
        (tester) async {
      await tester.pumpWidget(
        localizedApp(
          AppErrorWidget(
            title: 'Titre',
            message: 'Message',
            onRetry: () {},
          ),
        ),
      );
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets("n'affiche pas de bouton si onRetry null", (tester) async {
      await tester.pumpWidget(
        localizedApp(
          const AppErrorWidget(
            title: 'Titre',
            message: 'Message',
          ),
        ),
      );
      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    testWidgets(
        'fromError : AppException.network → isNetworkError = true',
        (tester) async {
      await tester.pumpWidget(
        localizedApp(
          Builder(
            builder: (context) => AppErrorWidget.fromError(
              context: context,
              error: AppException.network(message: 'net error'),
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });

    testWidgets(
        'fromError : Exception générique → isNetworkError = false',
        (tester) async {
      await tester.pumpWidget(
        localizedApp(
          Builder(
            builder: (context) => AppErrorWidget.fromError(
              context: context,
              error: Exception('unknown'),
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}
