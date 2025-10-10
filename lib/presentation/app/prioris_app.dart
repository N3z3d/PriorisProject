import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';
import 'package:prioris/domain/services/core/language_service.dart';
import 'package:prioris/domain/services/ui/responsive_service.dart';
import 'package:prioris/presentation/routes/app_routes.dart';
import 'package:prioris/presentation/pages/auth/auth_wrapper.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/animations/page_transitions.dart';
import 'package:prioris/l10n/app_localizations.dart';

/// Main application widget with theming, localization, and routing
class PriorisApp extends ConsumerWidget {
  const PriorisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Activer le listener d'authentification pour invalider les repository providers
    ref.watch(authChangeListenerProvider);

    final currentLocale = ref.watch(currentLocaleProvider);

    return MaterialApp(
      title: 'Prioris',
      theme: _buildAppTheme(),
      themeMode: ThemeMode.light, // Fixed to light theme for consistency
      home: const AuthWrapper(),
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
      
      // Internationalization
      locale: currentLocale,
      supportedLocales: LanguageService.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Responsive and cross-browser compatibility
      builder: (context, child) => _buildResponsiveWrapper(context, child),
    );
  }

  /// Build the application theme with custom page transitions
  ThemeData _buildAppTheme() {
    return AppTheme.lightTheme.copyWith(
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _CustomPageTransitionBuilder(),
          TargetPlatform.iOS: _CustomPageTransitionBuilder(),
          TargetPlatform.windows: _CustomPageTransitionBuilder(),
          TargetPlatform.macOS: _CustomPageTransitionBuilder(),
          TargetPlatform.linux: _CustomPageTransitionBuilder(),
        },
      ),
    );
  }

  /// Build responsive wrapper with adaptive UI adjustments
  Widget _buildResponsiveWrapper(BuildContext context, Widget? child) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final responsiveService = ResponsiveService();
    
    return MediaQuery(
      data: mediaQuery.copyWith(
        // Improve Safari and Firefox compatibility
        viewPadding: mediaQuery.viewPadding.copyWith(
          bottom: mediaQuery.viewPadding.bottom + 8,
        ),
        // Adaptive padding based on screen size
        padding: responsiveService.getAdaptivePadding(width),
        // Constrained text scaling for accessibility
        textScaler: TextScaler.linear(
          mediaQuery.textScaler.scale(1.0).clamp(0.8, 1.4)
        ),
      ),
      child: child!,
    );
  }
}

/// Custom page transition builder with slide and parallax effects
class _CustomPageTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Primary slide transition from right
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    final primaryTween = Tween(begin: begin, end: end);
    final primaryAnimation = animation.drive(
      primaryTween.chain(CurveTween(curve: PageTransitions.enterCurve)),
    );

    // Subtle parallax effect for exiting page
    const secondaryBegin = Offset.zero;
    const secondaryEnd = Offset(-0.2, 0.0);
    final secondaryTween = Tween(begin: secondaryBegin, end: secondaryEnd);
    final secondaryOffsetAnimation = secondaryAnimation.drive(
      secondaryTween.chain(CurveTween(curve: PageTransitions.exitCurve)),
    );

    return SlideTransition(
      position: secondaryOffsetAnimation,
      child: SlideTransition(
        position: primaryAnimation,
        child: FadeTransition(
          opacity: animation.drive(
            Tween(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: Curves.easeInOut),
            ),
          ),
          child: Material(
            child: DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(-5, 0),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}