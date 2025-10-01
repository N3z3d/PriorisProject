/// Factory for creating persistence strategies
/// Follows Factory pattern and integrates with DI container

import 'package:prioris/core/patterns/persistence_strategy.dart';
import 'package:prioris/core/patterns/concrete_persistence_strategies.dart';
import 'package:prioris/domain/services/persistence/adaptive_persistence_service.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';

/// Strategy creation configuration
enum StrategyType {
  local,
  adaptive,
  memory,
  readOnly,
}

/// Configuration for strategy creation
class StrategyConfig {
  final StrategyType type;
  final Map<String, dynamic> parameters;

  const StrategyConfig({
    required this.type,
    this.parameters = const {},
  });

  factory StrategyConfig.local({
    required CustomListRepository listRepository,
    required ListItemRepository itemRepository,
  }) {
    return StrategyConfig(
      type: StrategyType.local,
      parameters: {
        'listRepository': listRepository,
        'itemRepository': itemRepository,
      },
    );
  }

  factory StrategyConfig.adaptive({
    required AdaptivePersistenceService adaptiveService,
  }) {
    return StrategyConfig(
      type: StrategyType.adaptive,
      parameters: {
        'adaptiveService': adaptiveService,
      },
    );
  }

  factory StrategyConfig.memory() {
    return const StrategyConfig(
      type: StrategyType.memory,
    );
  }

  factory StrategyConfig.readOnly({
    required IPersistenceStrategy underlyingStrategy,
  }) {
    return StrategyConfig(
      type: StrategyType.readOnly,
      parameters: {
        'underlyingStrategy': underlyingStrategy,
      },
    );
  }
}

/// Factory for creating persistence strategies
/// Follows Factory pattern and provides centralized strategy creation
class PersistenceStrategyFactory {
  static final Map<StrategyType, IPersistenceStrategy Function(Map<String, dynamic>)>
      _strategyCreators = {
    StrategyType.local: _createLocalStrategy,
    StrategyType.adaptive: _createAdaptiveStrategy,
    StrategyType.memory: _createMemoryStrategy,
    StrategyType.readOnly: _createReadOnlyStrategy,
  };

  /// Creates a persistence strategy based on configuration
  static Future<IPersistenceStrategy> createStrategy(StrategyConfig config) async {
    final creator = _strategyCreators[config.type];
    if (creator == null) {
      throw ArgumentError('Unknown strategy type: ${config.type}');
    }

    LoggerService.instance.debug(
      'Creating persistence strategy: ${config.type}',
      context: 'PersistenceStrategyFactory',
    );

    final strategy = creator(config.parameters);
    await strategy.initialize();

    LoggerService.instance.info(
      'Created and initialized strategy: ${strategy.strategyName}',
      context: 'PersistenceStrategyFactory',
    );

    return strategy;
  }

  /// Creates multiple strategies and returns a context with the primary one
  static Future<PersistenceContext> createContext({
    required StrategyConfig primaryConfig,
    List<StrategyConfig>? fallbackConfigs,
  }) async {
    // Create primary strategy
    final primaryStrategy = await createStrategy(primaryConfig);
    final context = PersistenceContext(primaryStrategy);

    // Create and register fallback strategies
    if (fallbackConfigs != null) {
      for (final config in fallbackConfigs) {
        try {
          final fallbackStrategy = await createStrategy(config);
          context.registerStrategy(fallbackStrategy);
        } catch (e) {
          LoggerService.instance.warning(
            'Failed to create fallback strategy: ${config.type}',
            context: 'PersistenceStrategyFactory',
            error: e,
          );
        }
      }
    }

    LoggerService.instance.info(
      'Created persistence context with ${context.availableStrategies.length} strategies',
      context: 'PersistenceStrategyFactory',
    );

    return context;
  }

  /// Creates a strategy context for testing
  static Future<PersistenceContext> createTestContext() async {
    final config = StrategyConfig.memory();
    return await createContext(primaryConfig: config);
  }

  /// Creates a strategy context for development
  static Future<PersistenceContext> createDevelopmentContext({
    required CustomListRepository listRepository,
    required ListItemRepository itemRepository,
  }) async {
    final primaryConfig = StrategyConfig.local(
      listRepository: listRepository,
      itemRepository: itemRepository,
    );

    final fallbackConfigs = [
      StrategyConfig.memory(),
    ];

    return await createContext(
      primaryConfig: primaryConfig,
      fallbackConfigs: fallbackConfigs,
    );
  }

  /// Creates a strategy context for production
  static Future<PersistenceContext> createProductionContext({
    required AdaptivePersistenceService adaptiveService,
    required CustomListRepository localListRepository,
    required ListItemRepository localItemRepository,
  }) async {
    final primaryConfig = StrategyConfig.adaptive(
      adaptiveService: adaptiveService,
    );

    final fallbackConfigs = [
      StrategyConfig.local(
        listRepository: localListRepository,
        itemRepository: localItemRepository,
      ),
      StrategyConfig.memory(),
    ];

    return await createContext(
      primaryConfig: primaryConfig,
      fallbackConfigs: fallbackConfigs,
    );
  }

  /// Strategy creator methods

  static IPersistenceStrategy _createLocalStrategy(Map<String, dynamic> params) {
    final listRepository = params['listRepository'] as CustomListRepository?;
    final itemRepository = params['itemRepository'] as ListItemRepository?;

    if (listRepository == null || itemRepository == null) {
      throw ArgumentError('Local strategy requires listRepository and itemRepository');
    }

    return LocalPersistenceStrategy(
      listRepository: listRepository,
      itemRepository: itemRepository,
    );
  }

  static IPersistenceStrategy _createAdaptiveStrategy(Map<String, dynamic> params) {
    final adaptiveService = params['adaptiveService'] as AdaptivePersistenceService?;

    if (adaptiveService == null) {
      throw ArgumentError('Adaptive strategy requires adaptiveService');
    }

    return AdaptivePersistenceStrategy(
      adaptiveService: adaptiveService,
    );
  }

  static IPersistenceStrategy _createMemoryStrategy(Map<String, dynamic> params) {
    return InMemoryPersistenceStrategy();
  }

  static IPersistenceStrategy _createReadOnlyStrategy(Map<String, dynamic> params) {
    final underlyingStrategy = params['underlyingStrategy'] as IPersistenceStrategy?;

    if (underlyingStrategy == null) {
      throw ArgumentError('Read-only strategy requires underlyingStrategy');
    }

    return ReadOnlyPersistenceStrategy(
      underlyingStrategy: underlyingStrategy,
    );
  }

  /// Gets available strategy types
  static List<StrategyType> get availableTypes => _strategyCreators.keys.toList();

  /// Checks if a strategy type is supported
  static bool isStrategySupported(StrategyType type) {
    return _strategyCreators.containsKey(type);
  }
}

/// Strategy selection policy
/// Determines which strategy to use based on conditions
abstract class IStrategySelectionPolicy {
  Future<StrategyType> selectStrategy(Map<String, dynamic> context);
}

/// Smart strategy selection policy
/// Selects strategy based on authentication state and availability
class SmartStrategySelectionPolicy implements IStrategySelectionPolicy {
  @override
  Future<StrategyType> selectStrategy(Map<String, dynamic> context) async {
    final isAuthenticated = context['isAuthenticated'] as bool? ?? false;
    final isOnline = context['isOnline'] as bool? ?? true;
    final preferLocal = context['preferLocal'] as bool? ?? false;

    if (preferLocal) {
      return StrategyType.local;
    }

    if (isAuthenticated && isOnline) {
      return StrategyType.adaptive;
    }

    return StrategyType.local;
  }
}

/// Fallback strategy selection policy
/// Always uses local strategy as a safe fallback
class FallbackStrategySelectionPolicy implements IStrategySelectionPolicy {
  @override
  Future<StrategyType> selectStrategy(Map<String, dynamic> context) async {
    return StrategyType.local;
  }
}

/// Testing strategy selection policy
/// Always uses in-memory strategy for tests
class TestingStrategySelectionPolicy implements IStrategySelectionPolicy {
  @override
  Future<StrategyType> selectStrategy(Map<String, dynamic> context) async {
    return StrategyType.memory;
  }
}