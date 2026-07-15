import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/providers/onboarding_providers.dart';
import 'package:prioris/domain/ports/onboarding_repository.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/onboarding/controllers/onboarding_flow_controller.dart';
import 'package:prioris/presentation/pages/onboarding/onboarding_flow_page.dart';
import 'package:prioris/presentation/pages/onboarding/onboarding_gate.dart';

/// Pilote `shouldShowOnboarding` pour simuler une invalidation du compteur.
final _showFlagProvider = StateProvider<bool>((ref) => true);

/// Repository espion : compte les appels à `touchLastSeen` (AC2/T5) sans
/// toucher au réseau. `markCompleted` fait avancer l'état comme l'adapter réel.
class _SpyOnboardingRepository implements IOnboardingRepository {
  int touchLastSeenCalls = 0;
  OnboardingState _state = const OnboardingState();

  @override
  Future<OnboardingState> loadState() async => _state;

  @override
  Future<void> markCompleted() async {
    _state = OnboardingState(
      completedAt: _state.completedAt ?? DateTime.utc(2026),
      lastSeenAt: _state.lastSeenAt,
    );
  }

  @override
  Future<void> touchLastSeen() async {
    touchLastSeenCalls++;
  }
}

Widget _wrap(List<Override> overrides, {_SpyOnboardingRepository? repo}) {
  return ProviderScope(
    overrides: [
      onboardingRepositoryProvider
          .overrideWithValue(repo ?? _SpyOnboardingRepository()),
      ...overrides,
    ],
    child: MaterialApp(
      locale: const Locale('fr'),
      theme: ThemeData(splashFactory: NoSplash.splashFactory),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const OnboardingGate(),
    ),
  );
}

void main() {
  group('OnboardingGate', () {
    testWidgets('shouldShow=true → affiche OnboardingFlowPage', (tester) async {
      await tester.pumpWidget(_wrap([
        shouldShowOnboardingProvider.overrideWith((ref) async => true),
      ]));
      await tester.pump(); // résout le FutureProvider

      expect(find.byType(OnboardingFlowPage), findsOneWidget);
    });

    testWidgets('chargement → spinner', (tester) async {
      // Completer jamais complété : reste en loading sans timer pendant.
      final pending = Completer<bool>();
      await tester.pumpWidget(_wrap([
        shouldShowOnboardingProvider.overrideWith((ref) => pending.future),
      ]));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(OnboardingFlowPage), findsNothing);
    });

    testWidgets('shouldShow=false → onboarding non affiché', (tester) async {
      await tester.pumpWidget(_wrap([
        shouldShowOnboardingProvider.overrideWith((ref) async => false),
      ]));
      await tester.pump();

      expect(find.byType(OnboardingFlowPage), findsNothing);
    });

    testWidgets(
        'latch : reste sur OnboardingFlowPage quand shouldShow rebascule à false',
        (tester) async {
      // Régression du bug HIGH : le flux invalide les providers de tâches, ce
      // qui ferait passer shouldShow à false. Le gate doit rester monté.
      await tester.pumpWidget(_wrap([
        shouldShowOnboardingProvider
            .overrideWith((ref) async => ref.watch(_showFlagProvider)),
      ]));
      await tester.pump();
      expect(find.byType(OnboardingFlowPage), findsOneWidget);

      final container = ProviderScope.containerOf(
          tester.element(find.byType(OnboardingGate)));
      container.read(_showFlagProvider.notifier).state = false; // invalidation
      await tester.pump();
      await tester.pump();

      expect(find.byType(OnboardingFlowPage), findsOneWidget);
    });

    testWidgets('sortie : finished=true → bascule vers HomePage',
        (tester) async {
      await tester.pumpWidget(_wrap([
        shouldShowOnboardingProvider.overrideWith((ref) async => true),
      ]));
      await tester.pump();
      expect(find.byType(OnboardingFlowPage), findsOneWidget);

      final container = ProviderScope.containerOf(
          tester.element(find.byType(OnboardingGate)));
      await container
          .read(onboardingFlowControllerProvider.notifier)
          .completeOnboarding();
      await tester.pump();

      expect(find.byType(OnboardingFlowPage), findsNothing);
    });

    testWidgets(
        'T5 : touchLastSeen appelé exactement une fois en atteignant HomePage',
        (tester) async {
      final spy = _SpyOnboardingRepository();
      await tester.pumpWidget(_wrap(
        [shouldShowOnboardingProvider.overrideWith((ref) async => false)],
        repo: spy,
      ));
      await tester.pump();
      // Un rebuild supplémentaire ne doit pas ré-enregistrer la connexion.
      await tester.pump();

      expect(find.byType(OnboardingFlowPage), findsNothing);
      expect(spy.touchLastSeenCalls, 1);
    });

    testWidgets(
        'erreur de lecture → HomePage mais aucune écriture de last_seen_at',
        (tester) async {
      // Fail-open sans corruption : quand `loadState` échoue, l'état n'a pas été
      // lu ; toucher `last_seen_at` effacerait une dormance qu'on n'a pas pu
      // mesurer. Un seul échec transitoire ne doit pas défaire le re-accueil 90j.
      final spy = _SpyOnboardingRepository();
      await tester.pumpWidget(_wrap(
        [
          shouldShowOnboardingProvider
              .overrideWith((ref) async => throw Exception('backend injoignable')),
        ],
        repo: spy,
      ));
      await tester.pump();

      expect(find.byType(OnboardingFlowPage), findsNothing);
      expect(spy.touchLastSeenCalls, 0);
    });
  });
}
