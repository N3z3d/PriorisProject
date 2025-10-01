/// Migration Services Export - SOLID-Compliant Migration Architecture
///
/// This export file provides access to the refactored migration system
/// that follows SOLID principles and Clean Code constraints.
///
/// Services Overview:
/// - ConflictResolver: Handles data conflicts during migration
/// - MigrationOrchestrator: Coordinates complex migration workflows
/// - MigrationValidator: Validates data integrity before/during migration
/// - ProgressTracker: Tracks and reports migration progress in real-time
/// - DataCleaner: Performs cleanup operations after successful migrations
///
/// All services are designed to be <200 lines and follow SOLID principles:
/// - SRP: Single responsibility for each service
/// - OCP: Extensible through strategy patterns
/// - LSP: Compatible interfaces across all services
/// - ISP: Focused interfaces for specific operations
/// - DIP: Dependency injection and abstraction-based design

export 'conflict_resolver.dart';
export 'migration_orchestrator.dart';
export 'migration_validator.dart';
export 'progress_tracker.dart';
export 'data_cleaner.dart';