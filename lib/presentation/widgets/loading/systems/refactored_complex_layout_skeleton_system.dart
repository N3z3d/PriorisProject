import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';
import 'package:prioris/presentation/widgets/loading/systems/specialized/dashboard_skeleton_service.dart';
import 'package:prioris/presentation/widgets/loading/systems/specialized/page_skeleton_service.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';

/// Système de squelettes de layout complexes refactorisé respectant SOLID
///
/// SRP: Délègue chaque responsabilité à un service spécialisé
/// OCP: Extensible via l'ajout de nouveaux services
/// LSP: Compatible avec l'interface IVariantSkeletonSystem
/// ISP: Utilise des interfaces spécialisées pour chaque service
/// DIP: Dépend d'abstractions, pas d'implémentations concrètes
class RefactoredComplexLayoutSkeletonSystem implements IVariantSkeletonSystem, IAnimatedSkeletonSystem {
  final Map<String, String> _serviceRegistry = {};

  RefactoredComplexLayoutSkeletonSystem() {
    _initializeServices();
  }

  @override
  String get systemId => 'refactored_complex_layout_skeleton_system';

  @override
  List<String> get supportedTypes => [
    ...DashboardSkeletonService.supportedTypes,
    ...PageSkeletonService.supportedTypes,
    'navigation_drawer',
    'bottom_sheet',
  ];

  @override
  List<String> get availableVariants => [
    'standard',
    'compact',
    'detailed',
    'minimal',
  ];

  @override
  Duration get defaultAnimationDuration => const Duration(milliseconds: 1500);

  @override
  bool canHandle(String skeletonType) {
    return _findResponsibleService(skeletonType) != null;
  }

  @override
  Widget createSkeleton({
    double? width,
    double? height,
    String? variant,
    Duration? duration,
    AnimationController? controller,
    Map<String, dynamic>? options,
  }) {
    return createVariant(
      variant ?? 'standard',
      width: width,
      height: height,
      options: {
        ...options ?? {},
        'animation_duration': duration,
        'animation_controller': controller,
      },
    );
  }

  @override
  Widget createVariant(
    String variant, {
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    try {
      final skeletonType = options?['skeletonType'] ?? 'page_layout';
      final responsibleService = _findResponsibleService(skeletonType);

      if (responsibleService == null) {
        LoggerService.instance.warning(
          'Aucun service trouvé pour le type: $skeletonType, utilisation du fallback',
          context: 'RefactoredComplexLayoutSkeletonSystem',
        );
        return _createFallbackSkeleton(variant, options);
      }

      return _delegateToService(responsibleService, skeletonType, variant, options);
    } catch (e) {
      LoggerService.instance.error(
        'Erreur lors de la création du squelette variant: $variant',
        context: 'RefactoredComplexLayoutSkeletonSystem',
        error: e,
      );
      return _createErrorSkeleton();
    }
  }

  @override
  Widget createAnimated({
    required AnimationController controller,
    String variant = 'standard',
    Map<String, dynamic>? options,
  }) {
    final skeleton = createVariant(variant, options: options);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * controller.value),
          child: Opacity(
            opacity: 0.7 + (0.3 * controller.value),
            child: skeleton,
          ),
        );
      },
    );
  }

  /// Initialise le registre des services
  void _initializeServices() {
    // Enregistrer les types gérés par chaque service
    for (final type in DashboardSkeletonService.supportedTypes) {
      _serviceRegistry[type] = DashboardSkeletonService.serviceId;
    }

    for (final type in PageSkeletonService.supportedTypes) {
      _serviceRegistry[type] = PageSkeletonService.serviceId;
    }

    // Services spéciaux
    _serviceRegistry['navigation_drawer'] = 'navigation_service';
    _serviceRegistry['bottom_sheet'] = 'sheet_service';

    LoggerService.instance.info(
      'Services initialisés: ${_serviceRegistry.length} types supportés',
      context: 'RefactoredComplexLayoutSkeletonSystem',
    );
  }

  /// Trouve le service responsable d'un type de squelette
  String? _findResponsibleService(String skeletonType) {
    // Recherche directe
    if (_serviceRegistry.containsKey(skeletonType)) {
      return _serviceRegistry[skeletonType];
    }

    // Recherche par patterns
    if (DashboardSkeletonService.canHandle(skeletonType)) {
      return DashboardSkeletonService.serviceId;
    }

    if (PageSkeletonService.canHandle(skeletonType)) {
      return PageSkeletonService.serviceId;
    }

    // Patterns spéciaux
    if (skeletonType.contains('drawer') || skeletonType.contains('navigation')) {
      return 'navigation_service';
    }

    if (skeletonType.contains('sheet') || skeletonType.contains('modal')) {
      return 'sheet_service';
    }

    return null;
  }

  /// Délègue la création du squelette au service approprié
  Widget _delegateToService(
    String serviceName,
    String skeletonType,
    String variant,
    Map<String, dynamic>? options,
  ) {
    LoggerService.instance.info(
      'Délégation à $serviceName pour type: $skeletonType, variant: $variant',
      context: 'RefactoredComplexLayoutSkeletonSystem',
    );

    switch (serviceName) {
      case 'dashboard_skeleton_service':
        return DashboardSkeletonService.createDashboard(
          variant: variant,
          options: options,
        );

      case 'page_skeleton_service':
        return PageSkeletonService.createPage(
          pageType: skeletonType,
          variant: variant,
          options: options,
        );

      case 'navigation_service':
        return _createNavigationDrawer(variant, options);

      case 'sheet_service':
        return _createBottomSheet(variant, options);

      default:
        LoggerService.instance.warning(
          'Service non reconnu: $serviceName',
          context: 'RefactoredComplexLayoutSkeletonSystem',
        );
        return _createFallbackSkeleton(variant, options);
    }
  }

  /// Crée un drawer de navigation
  Widget _createNavigationDrawer(String variant, Map<String, dynamic>? options) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _createDrawerHeader(),
          ...List.generate(6, (index) => _createDrawerItem()),
        ],
      ),
    );
  }

  /// Crée une bottom sheet
  Widget _createBottomSheet(String variant, Map<String, dynamic>? options) {
    final height = options?['height'] ?? 300.0;

    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          _createSheetHandle(),
          const SizedBox(height: 16),
          _createSheetHeader(),
          const SizedBox(height: 16),
          Expanded(child: _createSheetContent()),
        ],
      ),
    );
  }

  /// Crée un squelette de fallback
  Widget _createFallbackSkeleton(String variant, Map<String, dynamic>? options) {
    LoggerService.instance.info(
      'Utilisation du squelette de fallback pour variant: $variant',
      context: 'RefactoredComplexLayoutSkeletonSystem',
    );

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(height: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Container(height: 200, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Container(height: 40, color: Colors.grey[300]),
        ],
      ),
    );
  }

  /// Crée un squelette d'erreur
  Widget _createErrorSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: Text('Erreur de génération du squelette'),
      ),
    );
  }

  // === COMPOSANTS DRAWER ===

  Widget _createDrawerHeader() {
    return Container(
      height: 150,
      color: Colors.grey[300],
      child: const Center(
        child: Text('Header'),
      ),
    );
  }

  Widget _createDrawerItem() {
    return ListTile(
      leading: Container(
        width: 24,
        height: 24,
        color: Colors.grey[300],
      ),
      title: Container(
        height: 16,
        color: Colors.grey[300],
      ),
    );
  }

  // === COMPOSANTS BOTTOM SHEET ===

  Widget _createSheetHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _createSheetHeader() {
    return Container(
      height: 24,
      color: Colors.grey[300],
    );
  }

  Widget _createSheetContent() {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 60,
          color: Colors.grey[300],
        ),
      ),
    );
  }

  /// Obtient des statistiques sur l'utilisation des services
  Map<String, dynamic> getUsageStats() {
    final serviceCount = <String, int>{};

    for (final service in _serviceRegistry.values) {
      serviceCount[service] = (serviceCount[service] ?? 0) + 1;
    }

    return {
      'totalTypes': _serviceRegistry.length,
      'serviceDistribution': serviceCount,
      'supportedVariants': availableVariants.length,
    };
  }

  /// Ajoute un nouveau type de squelette
  void registerSkeletonType(String skeletonType, String serviceName) {
    _serviceRegistry[skeletonType] = serviceName;

    LoggerService.instance.info(
      'Nouveau type enregistré: $skeletonType -> $serviceName',
      context: 'RefactoredComplexLayoutSkeletonSystem',
    );
  }

  /// Supprime un type de squelette
  void unregisterSkeletonType(String skeletonType) {
    _serviceRegistry.remove(skeletonType);

    LoggerService.instance.info(
      'Type supprimé: $skeletonType',
      context: 'RefactoredComplexLayoutSkeletonSystem',
    );
  }
}