import 'package:flutter/material.dart';
import 'package:prioris/presentation/pages/home_page.dart';
import 'package:prioris/presentation/pages/list_detail_page.dart';
import 'package:prioris/presentation/pages/list_detail_loader_page.dart';
import 'package:prioris/presentation/pages/agents_monitoring_page.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'dart:core';

/// Gestionnaire des routes de l'application
/// 
/// Définit toutes les routes disponibles et leur configuration
/// pour une navigation cohérente et maintenable.
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

  /// Générateur de routes dynamique – gère également les deep-links
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // 1) Route statique connue dans le tableau
    final staticBuilder = routes[settings.name];
    if (staticBuilder != null) {
      return MaterialPageRoute(builder: staticBuilder, settings: settings);
    }

    // 2) Deep-link vers /list-detail
    if (settings.name != null && settings.name!.startsWith(listDetail)) {
      // arguments via Navigator ou via query string
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

      if (list == null) {
        return _errorRoute('Liste non trouvée');
      }

      return MaterialPageRoute(
        builder: (context) => ListDetailPage(list: list!),
        settings: settings,
      );
    }

    // 3) Inconnue → erreur
    return _errorRoute('Route non trouvée');
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
