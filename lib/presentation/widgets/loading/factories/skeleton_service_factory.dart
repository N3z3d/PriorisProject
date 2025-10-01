import 'package:prioris/presentation/widgets/loading/interfaces/specialized_skeleton_interfaces.dart';
import 'package:prioris/presentation/widgets/loading/services/dashboard_skeleton_service.dart';
import 'package:prioris/presentation/widgets/loading/services/profile_skeleton_service.dart';
import 'package:prioris/presentation/widgets/loading/services/list_skeleton_service.dart';
import 'package:prioris/presentation/widgets/loading/services/detail_skeleton_service.dart';
import 'package:prioris/presentation/widgets/loading/services/settings_skeleton_service.dart';
import 'package:prioris/presentation/widgets/loading/services/navigation_skeleton_service.dart';
import 'package:prioris/presentation/widgets/loading/services/modal_skeleton_service.dart';
import 'package:prioris/presentation/widgets/loading/strategies/animation_strategies.dart';
import 'package:prioris/presentation/widgets/loading/builders/skeleton_builder.dart';

/// Skeleton service factory implementation following OCP and Abstract Factory pattern
/// Single Responsibility: Creates skeleton services without modification for new types
/// Open/Closed: New skeleton types can be added without modifying existing code
class SkeletonServiceFactory implements ISkeletonServiceFactory {
  static const String _dashboardKey = 'dashboard';
  static const String _profileKey = 'profile';
  static const String _listKey = 'list';
  static const String _detailKey = 'detail';
  static const String _settingsKey = 'settings';
  static const String _navigationKey = 'navigation';
  static const String _modalKey = 'modal';

  // Service creation methods following Factory Method pattern

  @override
  IDashboardSkeletonService createDashboardService() {
    return DashboardSkeletonService();
  }

  @override
  IProfileSkeletonService createProfileService() {
    return ProfileSkeletonService();
  }

  @override
  IListSkeletonService createListService() {
    return ListSkeletonService();
  }

  @override
  IDetailSkeletonService createDetailService() {
    return DetailSkeletonService();
  }

  @override
  ISettingsSkeletonService createSettingsService() {
    return SettingsSkeletonService();
  }

  @override
  INavigationSkeletonService createNavigationService() {
    return NavigationSkeletonService();
  }

  @override
  IModalSkeletonService createModalService() {
    return ModalSkeletonService();
  }

  @override
  ISkeletonAnimationStrategy createAnimationStrategy(String strategyId) {
    return SkeletonAnimationStrategyFactory.create(strategyId);
  }

  @override
  ISkeletonBuilder createBuilder() {
    return FluentSkeletonBuilder();
  }

  // Service locator methods for dynamic service creation

  /// Creates service by key - follows Factory Method pattern
  T? createServiceByKey<T>(String serviceKey) {
    switch (serviceKey) {
      case _dashboardKey:
        return createDashboardService() as T?;
      case _profileKey:
        return createProfileService() as T?;
      case _listKey:
        return createListService() as T?;
      case _detailKey:
        return createDetailService() as T?;
      case _settingsKey:
        return createSettingsService() as T?;
      case _navigationKey:
        return createNavigationService() as T?;
      case _modalKey:
        return createModalService() as T?;
      default:
        return null;
    }
  }

  /// Returns all supported service keys
  List<String> get supportedServiceKeys => [
    _dashboardKey,
    _profileKey,
    _listKey,
    _detailKey,
    _settingsKey,
    _navigationKey,
    _modalKey,
  ];

  /// Validates if a service key is supported
  bool isServiceKeySupported(String serviceKey) {
    return supportedServiceKeys.contains(serviceKey);
  }
}

/// Registry for skeleton types following Registry pattern
/// Single Responsibility: Maps skeleton types to service keys
/// Open/Closed: New mappings can be added without modifying core logic
class SkeletonTypeRegistry implements ISkeletonTypeRegistry {
  static final SkeletonTypeRegistry _instance = SkeletonTypeRegistry._internal();
  factory SkeletonTypeRegistry() => _instance;
  SkeletonTypeRegistry._internal();

  final Map<String, String> _typeToServiceMap = {};
  final Map<String, List<String>> _serviceToTypesMap = {};

  /// Initializes default type mappings
  void initializeDefaultMappings() {
    // Dashboard types
    _registerMapping('dashboard', 'dashboard');
    _registerMapping('dashboard_page', 'dashboard');
    _registerMapping('main_dashboard', 'dashboard');

    // Profile types
    _registerMapping('profile', 'profile');
    _registerMapping('profile_page', 'profile');
    _registerMapping('user_profile', 'profile');

    // List types
    _registerMapping('list', 'list');
    _registerMapping('list_page', 'list');
    _registerMapping('item_list', 'list');

    // Detail types
    _registerMapping('detail', 'detail');
    _registerMapping('detail_page', 'detail');
    _registerMapping('item_detail', 'detail');

    // Settings types
    _registerMapping('settings', 'settings');
    _registerMapping('settings_page', 'settings');
    _registerMapping('preferences', 'settings');

    // Navigation types
    _registerMapping('drawer', 'navigation');
    _registerMapping('navigation_drawer', 'navigation');
    _registerMapping('side_menu', 'navigation');

    // Modal types
    _registerMapping('sheet', 'modal');
    _registerMapping('bottom_sheet', 'modal');
    _registerMapping('modal', 'modal');
  }

  @override
  void registerSkeletonType(String type, String serviceKey) {
    _registerMapping(type, serviceKey);
  }

  @override
  String? getServiceKeyForType(String type) {
    return _typeToServiceMap[type];
  }

  @override
  List<String> getSupportedTypes() {
    return _typeToServiceMap.keys.toList();
  }

  @override
  bool isTypeSupported(String type) {
    return _typeToServiceMap.containsKey(type);
  }

  @override
  void unregisterSkeletonType(String type) {
    final serviceKey = _typeToServiceMap.remove(type);
    if (serviceKey != null) {
      _serviceToTypesMap[serviceKey]?.remove(type);
      if (_serviceToTypesMap[serviceKey]?.isEmpty == true) {
        _serviceToTypesMap.remove(serviceKey);
      }
    }
  }

  /// Gets all types supported by a service
  List<String> getTypesForService(String serviceKey) {
    return _serviceToTypesMap[serviceKey] ?? [];
  }

  /// Gets all registered service keys
  List<String> getRegisteredServiceKeys() {
    return _serviceToTypesMap.keys.toList();
  }

  // Private helper methods

  void _registerMapping(String type, String serviceKey) {
    _typeToServiceMap[type] = serviceKey;
    _serviceToTypesMap.putIfAbsent(serviceKey, () => []).add(type);
  }
}

/// Skeleton creation coordinator following Facade pattern
/// Single Responsibility: Coordinates skeleton creation across all services
/// Open/Closed: New skeleton types supported without modification
class SkeletonCreationCoordinator {
  final SkeletonServiceFactory _serviceFactory;
  final SkeletonTypeRegistry _typeRegistry;

  SkeletonCreationCoordinator({
    SkeletonServiceFactory? serviceFactory,
    SkeletonTypeRegistry? typeRegistry,
  }) : _serviceFactory = serviceFactory ?? SkeletonServiceFactory(),
       _typeRegistry = typeRegistry ?? SkeletonTypeRegistry() {
    _typeRegistry.initializeDefaultMappings();
  }

  /// Creates a skeleton by type following Factory Method pattern
  T? createServiceForType<T>(String skeletonType) {
    final serviceKey = _typeRegistry.getServiceKeyForType(skeletonType);
    if (serviceKey == null) {
      return null;
    }

    return _serviceFactory.createServiceByKey<T>(serviceKey);
  }

  /// Validates if a skeleton type is supported
  bool canHandleType(String skeletonType) {
    return _typeRegistry.isTypeSupported(skeletonType);
  }

  /// Gets all supported skeleton types
  List<String> getSupportedTypes() {
    return _typeRegistry.getSupportedTypes();
  }

  /// Registers a new skeleton type mapping
  void registerSkeletonType(String type, String serviceKey) {
    if (_serviceFactory.isServiceKeySupported(serviceKey)) {
      _typeRegistry.registerSkeletonType(type, serviceKey);
    } else {
      throw ArgumentError('Service key $serviceKey is not supported');
    }
  }

  /// Gets detailed mapping information for debugging
  Map<String, dynamic> getMappingInfo() {
    return {
      'supported_types': _typeRegistry.getSupportedTypes(),
      'service_keys': _typeRegistry.getRegisteredServiceKeys(),
      'total_mappings': _typeRegistry.getSupportedTypes().length,
    };
  }
}