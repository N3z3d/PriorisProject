import 'package:flutter/material.dart';
import 'package:prioris/presentation/pages/home_page.dart';
import 'package:prioris/presentation/pages/list_detail_page.dart';
import 'package:prioris/presentation/pages/list_detail_loader_page.dart';
import 'package:prioris/presentation/pages/agents_monitoring_page.dart';
import 'package:prioris/presentation/pages/auth/auth_wrapper.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';

/// Gestionnaire des routes de l'application
class AppRoutes {
  /// Noms de routes
  static const String home = '/';
  static const String listDetail = '/list-detail';
  static const String agentsMonitoring = '/agents-monitoring';

  /// Tableau centralisé des routes statiques (sans arguments)
  static final Map<String, WidgetBuilder> routes = {
    home: (context) => const HomePage(),
    agentsMonitoring: (context) => const AgentsMonitoringPage(),
  };

  /// Générateur de routes dynamique
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // 1) Route statique connue dans le tableau
    final staticBuilder = routes[settings.name];
    if (staticBuilder != null) {
      return MaterialPageRoute(builder: staticBuilder, settings: settings);
    }

    // 2) Deep-link vers /list-detail
    if (settings.name != null && settings.name!.startsWith(listDetail)) {
      // arguments via Navigator
      CustomList? list;
      if (settings.arguments is CustomList) {
        list = settings.arguments as CustomList;
      } else if (settings.arguments is Map) {
        list = (settings.arguments as Map)['list'] as CustomList?;
      }

      // Essayer de récupérer un id via query string (ex: /list-detail?id=123)
      if (list == null) {
        final uri = Uri.parse(settings.name!);
        final id = uri.queryParameters['id'];
        if (id != null) {
          return MaterialPageRoute(
            builder: (context) => ListDetailLoaderPage(listId: id),
            settings: settings,
          );
        }
      }

      // CORRECTION UX: Si pas d'ID, utiliser ListDetailLoaderPage avec null pour fallback automatique
      if (list == null) {
        LoggerService.instance.debug('Pas d\'ID de liste fourni, fallback vers première liste', context: 'AppRoutes');
        return MaterialPageRoute(
          builder: (context) => const ListDetailLoaderPage(listId: null),
          settings: settings,
        );
      }

      return MaterialPageRoute(
        builder: (context) => ListDetailPage(list: list!),
        settings: settings,
      );
    }

    // 3) Garde Supabase : fragments route-like (#sb, sb-, sb.) capturés par le
    // moteur Flutter avant que le stabilizer ait pu remplacer l'URL.
    if (_isSupabaseCallbackRoute(settings.name)) {
      return MaterialPageRoute(
        builder: (_) => const _AuthCallbackRedirectPage(),
        settings: settings,
      );
    }

    // 4) Route inconnue → erreur
    return _errorRoute('Route non trouvée');
  }

  static bool _isSupabaseCallbackRoute(String? name) {
    if (name == null) return false;
    final normalized = name.replaceAll('/', '').replaceAll('#', '');
    return normalized == 'sb' ||
        normalized.startsWith('sb-') ||
        normalized.startsWith('sb.');
  }
  
  /// Route d'erreur pour les routes non définies
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Erreur'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Navigation vers la page de détail d'une liste
  static void navigateToListDetail(BuildContext context, CustomList list) {
    Navigator.of(context).pushNamed(
      listDetail,
      arguments: {'list': list},
    );
  }
  
  /// Navigation vers la page d'accueil
  static void navigateToHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      home,
      (route) => false,
    );
  }
}

/// Page de redirection pour les fragments Supabase route-like (#sb, #sb-...).
///
/// Affiché quand le moteur Flutter a capturé l'URL de callback avant que le
/// stabilizer ait pu la nettoyer via history.replaceState. Redirige vers
/// [AuthWrapper] après un bref délai pour ne pas laisser l'utilisateur sur
/// une page vide ou "Route non trouvée".
class _AuthCallbackRedirectPage extends StatefulWidget {
  const _AuthCallbackRedirectPage();

  @override
  State<_AuthCallbackRedirectPage> createState() =>
      _AuthCallbackRedirectPageState();
}

class _AuthCallbackRedirectPageState extends State<_AuthCallbackRedirectPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), _redirectToAuthWrapper);
  }

  void _redirectToAuthWrapper() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthWrapper()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Redirection en cours…',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _redirectToAuthWrapper,
              child: const Text('Continuer maintenant'),
            ),
          ],
        ),
      ),
    );
  }
}