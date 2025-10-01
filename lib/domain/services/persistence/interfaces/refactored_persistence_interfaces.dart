/// **REFACTORED PERSISTENCE INTERFACES** - Export consolidé
///
/// **LOT 3.1** : Interfaces segregées pour la décomposition SOLID
/// du monolithe unified_persistence_service.dart (923 lignes)
///
/// **Architecture** : ISP (Interface Segregation Principle) compliant
/// **Responsabilités séparées** selon le principe SRP

// === Interface segregées (ISP) ===
export 'local_persistence_interface.dart';
export 'cloud_persistence_interface.dart';
export 'sync_persistence_interface.dart';
export 'persistence_coordinator_interface.dart';

// === Interface legacy (sera dépréciée) ===
export 'unified_persistence_interface.dart';