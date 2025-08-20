import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/services/ui/cross_browser_compatibility_service.dart';
import 'package:prioris/domain/services/ui/responsive_service.dart';
import 'package:prioris/domain/services/core/language_service.dart';
import 'package:prioris/core/config/app_config.dart';
import 'package:prioris/infrastructure/services/supabase_service.dart';
import 'package:prioris/presentation/routes/app_routes.dart';
import 'package:prioris/presentation/pages/auth/auth_wrapper.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/animations/page_transitions.dart';
import 'package:prioris/presentation/services/debug/overflow_audit_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Hive pour le stockage local
  await Hive.initFlutter();
  
  // Enregistrer les adapters Hive
  Hive.registerAdapter(CustomListAdapter());
  Hive.registerAdapter(ListItemAdapter());
  Hive.registerAdapter(ListTypeAdapter());
  
  // Initialiser la configuration avec les variables d'environnement
  await AppConfig.initialize();
  
  // Initialiser Supabase avec la configuration sécurisée
  await SupabaseService.initialize();
  
  // Initialiser le service de langue
  final languageService = LanguageService();
  await languageService.initialize();
  
  // Appliquer les corrections de compatibilité cross-browser
  CrossBrowserCompatibilityService().applyBrowserSpecificFixes();
  
  // Activer l'audit des overflows en mode debug
  OverflowAuditService.enable();
  
  runApp(
    ProviderScope(
      overrides: [
        languageServiceProvider.overrideWithValue(languageService),
      ],
      child: const PriorisApp(),
    ),
  );
}

class PriorisApp extends ConsumerWidget {
  const PriorisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(currentLocaleProvider);
    
    return MaterialApp(
      title: 'Prioris',
      theme: AppTheme.lightTheme.copyWith(
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: _CustomPageTransitionBuilder(),
            TargetPlatform.iOS: _CustomPageTransitionBuilder(),
            TargetPlatform.windows: _CustomPageTransitionBuilder(),
            TargetPlatform.macOS: _CustomPageTransitionBuilder(),
            TargetPlatform.linux: _CustomPageTransitionBuilder(),
          },
        ),
      ),
      // Removed darkTheme and set themeMode to light
      themeMode: ThemeMode.light,
      home: const AuthWrapper(),
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
      
      // Configuration de l'internationalisation
      locale: currentLocale,
      supportedLocales: LanguageService.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Améliorations pour la compatibilité cross-browser et responsivité
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final width = mediaQuery.size.width;
        final responsiveService = ResponsiveService();
        
        return MediaQuery(
          data: mediaQuery.copyWith(
            // Améliorer la compatibilité avec Safari et Firefox
            viewPadding: mediaQuery.viewPadding.copyWith(
              bottom: mediaQuery.viewPadding.bottom + 8,
            ),
            // Padding adaptatif selon la taille d'écran
            padding: responsiveService.getAdaptivePadding(width), 
            textScaler: TextScaler.linear(mediaQuery.textScaler.scale(1.0).clamp(0.8, 1.4)),
          ),
          child: child!,
        );
      },
    );
  }
}

/// Builder personnalisé pour les transitions de page par défaut
class _CustomPageTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Transition slide depuis la droite avec effet parallaxe
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    final primaryTween = Tween(begin: begin, end: end);
    final primaryAnimation = animation.drive(
      primaryTween.chain(CurveTween(curve: PageTransitions.enterCurve)),
    );

    // Effet parallaxe subtil pour la page sortante
    const secondaryBegin = Offset.zero;
    const secondaryEnd = Offset(-0.2, 0.0);
    final secondaryTween = Tween(begin: secondaryBegin, end: secondaryEnd);
    final secondaryOffsetAnimation = secondaryAnimation.drive(
      secondaryTween.chain(CurveTween(curve: PageTransitions.exitCurve)),
    );

    // Combine slide et fade pour une transition fluide
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

