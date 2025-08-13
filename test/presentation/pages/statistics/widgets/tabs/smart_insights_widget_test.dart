import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/pages/statistics/widgets/smart/smart_insights_widget.dart';

void main() {
  group('SmartInsightsWidget', () {
    testWidgets('affiche les messages String', (tester) async {
      final insights = [
        'Votre productivité est 15% plus élevée le matin',
        'Les habitudes de "Bien-être" ont le meilleur taux de réussite (85%)',
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: SmartInsightsWidget(insights: insights),
        ),
      );
      expect(find.text(insights[0]), findsOneWidget);
      expect(find.text(insights[1]), findsOneWidget);
      expect(find.text('💡 Insights Intelligents'), findsOneWidget);
    });

    testWidgets('affiche les messages Map avec icône', (tester) async {
      final insights = [
        {'icon': '🎯', 'message': 'Votre productivité est excellente !'},
        {'icon': '🔥', 'message': 'Impressionnant ! Vous avez une série de 10 jours.'},
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: SmartInsightsWidget(insights: insights),
        ),
      );
      expect(find.text('🎯'), findsOneWidget);
      expect(find.text('🔥'), findsOneWidget);
      expect(find.text(insights[0]['message']!), findsOneWidget);
      expect(find.text(insights[1]['message']!), findsOneWidget);
    });

    testWidgets('supporte une liste vide sans crash', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SmartInsightsWidget(insights: const []),
        ),
      );
      expect(find.text('💡 Insights Intelligents'), findsOneWidget);
    });
  });
} 
