import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/services/persistence/adaptive_persistence_service.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';
import '../interfaces/lists_managers_interfaces.dart';

/// **Strategy Pattern** pour la gestion des différentes stratégies d'initialisation
///
/// **Single Responsibility Principle (SRP)** : Se concentre uniquement sur l'initialisation
/// **Open/Closed Principle (OCP)** : Extensible pour de nouvelles stratégies sans modification
/// **Dependency Inversion Principle (DIP)** : Dépend d'abstractions, pas d'implémentations
class ListsInitializationManager implements IListsInitializationManager {
  // === Dependencies (injected via constructor) ===
  final AdaptivePersistenceService? _adaptivePersistenceService;
  final CustomListRepository? _customListRepository;
  final ListItemRepository? _itemRepository;

  // === State tracking ===
  bool _isInitialized = false;
  String _initializationMode = 'none';
  DateTime? _initializationTime;
  Exception? _lastInitializationError;

  /// **Dependency Injection** - Constructor avec dépendances optionnelles
  ///
  /// Permet différentes stratégies d'initialisation selon les services disponibles
  ListsInitializationManager({
    AdaptivePersistenceService? adaptivePersistenceService,
    CustomListRepository? customListRepository,
    ListItemRepository? itemRepository,
  })  : _adaptivePersistenceService = adaptivePersistenceService,
        _customListRepository = customListRepository,
        _itemRepository = itemRepository;

  /// **Factory constructor** - Pour initialisation adaptive (stratégie recommandée)
  factory ListsInitializationManager.adaptive(
    AdaptivePersistenceService adaptivePersistenceService,
    CustomListRepository customListRepository,
    ListItemRepository itemRepository,
  ) {
    return ListsInitializationManager(
      adaptivePersistenceService: adaptivePersistenceService,
      customListRepository: customListRepository,
      itemRepository: itemRepository,
    );
  }

  /// **Factory constructor** - Pour initialisation legacy (compatibilité)
  factory ListsInitializationManager.legacy(
    CustomListRepository customListRepository,
    ListItemRepository itemRepository,
  ) {
    return ListsInitializationManager(
      customListRepository: customListRepository,
      itemRepository: itemRepository,
    );
  }

  @override
  Future<void> initializeAdaptive() async {
    if (_isInitialized) {
      LoggerService.instance.warning(
        'Tentative de réinitialisation - ignorée',
        context: 'ListsInitializationManager',
      );
      return;
    }

    if (_adaptivePersistenceService == null) {
      throw StateError(
        'AdaptivePersistenceService requis pour l\'initialisation adaptive',
      );
    }

    try {
      LoggerService.instance.info(
        'Début initialisation adaptive du système de listes',
        context: 'ListsInitializationManager',
      );

      await _validateAdaptiveServiceReady();
      await _performAdaptiveInitialization();
      _markAsInitialized('adaptive');

      LoggerService.instance.info(
        'Initialisation adaptive terminée avec succès',
        context: 'ListsInitializationManager',
      );
    } catch (e) {
      _handleInitializationError('adaptive', e);
      rethrow;
    }
  }

  @override
  Future<void> initializeLegacy() async {
    if (_isInitialized) {
      LoggerService.instance.warning(
        'Tentative de réinitialisation - ignorée',
        context: 'ListsInitializationManager',
      );
      return;
    }

    if (_customListRepository == null || _itemRepository == null) {
      throw StateError(
        'Repositories requis pour l\'initialisation legacy',
      );
    }

    try {
      LoggerService.instance.info(
        'Début initialisation legacy du système de listes',
        context: 'ListsInitializationManager',
      );

      await _validateLegacyRepositoriesReady();
      await _performLegacyInitialization();
      _markAsInitialized('legacy');

      LoggerService.instance.info(
        'Initialisation legacy terminée avec succès',
        context: 'ListsInitializationManager',
      );
    } catch (e) {
      _handleInitializationError('legacy', e);
      rethrow;
    }
  }

  @override
  Future<void> initializeAsync() async {
    if (_isInitialized) {
      LoggerService.instance.warning(
        'Tentative de réinitialisation - ignorée',
        context: 'ListsInitializationManager',
      );
      return;
    }

    try {
      LoggerService.instance.info(
        'Début initialisation asynchrone du système de listes',
        context: 'ListsInitializationManager',
      );

      // Strategy: Essayer adaptive d'abord, puis legacy en fallback
      if (_adaptivePersistenceService != null) {
        await initializeAdaptive();
      } else if (_customListRepository != null && _itemRepository != null) {
        await initializeLegacy();
      } else {
        throw StateError(
          'Aucun service d\'initialisation disponible',
        );
      }

      _initializationMode = 'async-${_initializationMode}';

      LoggerService.instance.info(
        'Initialisation asynchrone terminée: $_initializationMode',
        context: 'ListsInitializationManager',
      );
    } catch (e) {
      _handleInitializationError('async', e);
      rethrow;
    }
  }

  @override
  bool get isInitialized => _isInitialized;

  @override
  String get initializationMode => _initializationMode;

  /// Obtient le temps d'initialisation
  DateTime? get initializationTime => _initializationTime;

  /// Obtient la dernière erreur d'initialisation
  Exception? get lastInitializationError => _lastInitializationError;

  /// Réinitialise le manager (pour tests)
  void reset() {
    _isInitialized = false;
    _initializationMode = 'none';
    _initializationTime = null;
    _lastInitializationError = null;

    LoggerService.instance.debug(
      'Manager d\'initialisation réinitialisé',
      context: 'ListsInitializationManager',
    );
  }

  /// Obtient les informations de diagnostic
  Map<String, dynamic> getDiagnosticInfo() {
    return {
      'isInitialized': _isInitialized,
      'initializationMode': _initializationMode,
      'initializationTime': _initializationTime?.toIso8601String(),
      'hasAdaptiveService': _adaptivePersistenceService != null,
      'hasCustomListRepository': _customListRepository != null,
      'hasItemRepository': _itemRepository != null,
      'lastError': _lastInitializationError?.toString(),
    };
  }

  // === Private methods ===

  /// Valide que le service adaptatif est prêt
  Future<void> _validateAdaptiveServiceReady() async {
    // Vérifier que le service est accessible
    try {
      final mode = _adaptivePersistenceService!.currentMode;
      LoggerService.instance.debug(
        'Service adaptatif prêt en mode: $mode',
        context: 'ListsInitializationManager',
      );
    } catch (e) {
      throw StateError(
        'Service adaptatif non prêt: $e',
      );
    }
  }

  /// Valide que les repositories legacy sont prêts
  Future<void> _validateLegacyRepositoriesReady() async {
    // Test rapide d'accès aux repositories
    try {
      await _customListRepository!.getAllLists();
      await _itemRepository!.getAll();

      LoggerService.instance.debug(
        'Repositories legacy validés et prêts',
        context: 'ListsInitializationManager',
      );
    } catch (e) {
      throw StateError(
        'Repositories legacy non prêts: $e',
      );
    }
  }

  /// Effectue l'initialisation adaptive
  Future<void> _performAdaptiveInitialization() async {
    // Pré-charger une petite quantité de données pour valider la connectivité
    final testLists = await _adaptivePersistenceService!.getAllLists();

    LoggerService.instance.debug(
      'Test de connectivité adaptive réussi: ${testLists.length} listes',
      context: 'ListsInitializationManager',
    );
  }

  /// Effectue l'initialisation legacy
  Future<void> _performLegacyInitialization() async {
    // Validation basique des repositories
    final testLists = await _customListRepository!.getAllLists();
    final testItems = await _itemRepository!.getAll();

    LoggerService.instance.debug(
      'Test de connectivité legacy réussi: ${testLists.length} listes, ${testItems.length} éléments',
      context: 'ListsInitializationManager',
    );
  }

  /// Marque le manager comme initialisé
  void _markAsInitialized(String mode) {
    _isInitialized = true;
    _initializationMode = mode;
    _initializationTime = DateTime.now();
    _lastInitializationError = null;
  }

  /// Gère les erreurs d'initialisation
  void _handleInitializationError(String mode, Object error) {
    _isInitialized = false;
    _initializationMode = 'error-$mode';
    _lastInitializationError = error is Exception ? error : Exception(error.toString());

    LoggerService.instance.error(
      'Erreur lors de l\'initialisation $mode',
      context: 'ListsInitializationManager',
      error: error,
    );
  }

  /// **Template Method Pattern** - Stratégie d'initialisation automatique
  ///
  /// Choisit automatiquement la meilleure stratégie selon les services disponibles
  Future<void> initializeAuto() async {
    if (_isInitialized) return;

    LoggerService.instance.info(
      'Début initialisation automatique - détection de la meilleure stratégie',
      context: 'ListsInitializationManager',
    );

    // Stratégie 1: Adaptive (recommandée)
    if (_adaptivePersistenceService != null) {
      LoggerService.instance.debug(
        'Stratégie choisie: Adaptive (service adaptatif disponible)',
        context: 'ListsInitializationManager',
      );
      await initializeAdaptive();
      return;
    }

    // Stratégie 2: Legacy (fallback)
    if (_customListRepository != null && _itemRepository != null) {
      LoggerService.instance.debug(
        'Stratégie choisie: Legacy (repositories disponibles)',
        context: 'ListsInitializationManager',
      );
      await initializeLegacy();
      return;
    }

    // Aucune stratégie disponible
    throw StateError(
      'Aucune stratégie d\'initialisation disponible - '
      'AdaptivePersistenceService ou repositories requis',
    );
  }
}