/// NAMING CONVENTIONS GUIDE
/// Prioris Project Coding Standards
///
/// This file defines and enforces consistent naming conventions
/// across the entire codebase to improve readability and maintainability.

/// ========== DART NAMING CONVENTIONS ==========

/// CLASS NAMES
/// Use UpperCamelCase (PascalCase)
/// Examples:
/// ✅ TaskManagementService
/// ✅ CustomListRepository
/// ✅ HabitTrackingContext
/// ❌ taskManagementService
/// ❌ custom_list_repository

/// VARIABLE AND METHOD NAMES
/// Use lowerCamelCase
/// Examples:
/// ✅ currentUser
/// ✅ isLoading
/// ✅ updateTaskPriority()
/// ❌ CurrentUser
/// ❌ update_task_priority()

/// CONSTANTS
/// Use lowerCamelCase for local constants, SCREAMING_SNAKE_CASE for global constants
/// Examples:
/// ✅ static const DEFAULT_TIMEOUT = Duration(seconds: 30);
/// ✅ const maxRetries = 3; (local)
/// ❌ static const defaultTimeout = Duration(seconds: 30);

/// PRIVATE MEMBERS
/// Use underscore prefix with lowerCamelCase
/// Examples:
/// ✅ _repositoryInstance
/// ✅ _initializeServices()
/// ❌ _RepositoryInstance
/// ❌ _initialize_services()

/// ENUMS
/// Use UpperCamelCase for enum name, lowerCamelCase for values
/// Examples:
/// ✅ enum TaskStatus { pending, inProgress, completed }
/// ❌ enum task_status { Pending, IN_PROGRESS, COMPLETED }

/// ========== PROJECT-SPECIFIC CONVENTIONS ==========

class NamingConventions {
  /// FILE NAMING
  static const Map<String, String> fileNaming = {
    'Entities': 'snake_case.dart (e.g., custom_list.dart)',
    'Services': 'snake_case_service.dart (e.g., task_management_service.dart)',
    'Controllers': 'snake_case_controller.dart (e.g., lists_controller.dart)',
    'Repositories': 'snake_case_repository.dart (e.g., habit_repository.dart)',
    'Widgets': 'snake_case_widget.dart (e.g., habit_card_widget.dart)',
    'Pages': 'snake_case_page.dart (e.g., home_page.dart)',
    'Dialogs': 'snake_case_dialog.dart (e.g., task_edit_dialog.dart)',
    'Providers': 'snake_case_providers.dart (e.g., auth_providers.dart)',
  };

  /// DIRECTORY NAMING
  static const Map<String, String> directoryNaming = {
    'All directories': 'snake_case (e.g., task_management, habit_tracking)',
    'Context directories': 'domain_name (e.g., task_management, list_organization)',
    'Feature directories': 'feature_name (e.g., authentication, statistics)',
  };

  /// METHOD NAMING PATTERNS
  static const Map<String, String> methodPatterns = {
    'Getters': 'get + EntityName (e.g., getTaskById, getAllHabits)',
    'Setters': 'set + PropertyName (e.g., setLoading, updateTaskStatus)',
    'Booleans': 'is/has/can/should + Condition (e.g., isLoading, hasData, canEdit)',
    'Actions': 'verb + Object (e.g., createTask, deleteList, updateHabit)',
    'Handlers': 'handle + Event (e.g., handleSubmit, handleError)',
    'Builders': 'build + ComponentName (e.g., buildTaskCard, buildHeader)',
    'Validators': 'validate + FieldName (e.g., validateEmail, validateRequired)',
  };

  /// EVENT NAMING
  static const Map<String, String> eventNaming = {
    'Domain Events': 'EntityName + PastTense (e.g., TaskCreated, HabitCompleted)',
    'UI Events': 'on + Action (e.g., onTap, onSubmit, onChanged)',
    'Lifecycle Events': 'verb + State (e.g., initState, dispose, didChangeDependencies)',
  };

  /// CONSTANT NAMING
  static const Map<String, String> constantNaming = {
    'Global Constants': 'SCREAMING_SNAKE_CASE (e.g., DEFAULT_TIMEOUT, MAX_RETRIES)',
    'Local Constants': 'lowerCamelCase (e.g., maxLength, defaultValue)',
    'Environment': 'ALL_CAPS (e.g., API_URL, DEBUG_MODE)',
    'Colors': 'descriptive names (e.g., primaryColor, successGreen)',
  };

  /// PROVIDER NAMING
  static const Map<String, String> providerNaming = {
    'State Providers': 'entityStateProvider (e.g., taskStateProvider)',
    'Notifier Providers': 'entityNotifierProvider (e.g., listsNotifierProvider)',
    'Service Providers': 'serviceNameProvider (e.g., authServiceProvider)',
    'Repository Providers': 'entityRepositoryProvider (e.g., taskRepositoryProvider)',
    'Controller Providers': 'entityControllerProvider (e.g., listsControllerProvider)',
  };

  /// INTERFACE NAMING
  static const Map<String, String> interfaceNaming = {
    'Interfaces': 'I + InterfaceName (e.g., ITaskRepository, IAuthService)',
    'Mixins': 'descriptive + Mixin (e.g., ValidationMixin, LoadingStateMixin)',
    'Abstract Classes': 'Abstract + ClassName or Base + ClassName',
    'Ports': 'I + DomainName + Port (e.g., ITaskManagementPort)',
  };

  /// BUSINESS DOMAIN NAMING
  static const Map<String, String> domainNaming = {
    'Aggregates': 'EntityName + Aggregate (e.g., TaskAggregate)',
    'Value Objects': 'descriptive names (e.g., Priority, EloScore, DateRange)',
    'Domain Services': 'DomainName + Service (e.g., TaskEloService)',
    'Specifications': 'EntityName + Specifications (e.g., TaskSpecifications)',
    'Events': 'EntityName + Action + Event (e.g., TaskCreatedEvent)',
  };

  /// TESTING NAMING
  static const Map<String, String> testNaming = {
    'Test Files': 'subject_test.dart (e.g., task_service_test.dart)',
    'Test Classes': 'SubjectTest (e.g., TaskServiceTest)',
    'Test Methods': 'should_result_when_condition (e.g., should_create_task_when_valid_data)',
    'Mock Classes': 'Mock + ClassName (e.g., MockTaskRepository)',
    'Test Data': 'TestData or Factory pattern (e.g., TaskTestData.valid())',
  };

  /// VALIDATION RULES
  static const List<String> validationRules = [
    'No abbreviations in public APIs (use full words)',
    'Boolean variables should start with is/has/can/should',
    'Collections should be plural (e.g., tasks, users, items)',
    'Avoid Hungarian notation',
    'Use intention-revealing names',
    'Be consistent within the same context',
    'Avoid mental mapping (clear, explicit names)',
    'Use searchable names for important concepts',
  ];

  /// ANTI-PATTERNS TO AVOID
  static const Map<String, String> antiPatterns = {
    'data': 'Too generic. Use specific names like userData, taskData',
    'info': 'Too vague. Use specific names like userInfo, taskInfo',
    'manager': 'Overused. Consider Service, Coordinator, Handler',
    'util/utils': 'Vague. Use specific names like DateHelper, ValidationHelper',
    'temp': 'Indicates poor naming. Use descriptive temporary names',
    'obj/object': 'Too generic. Use specific entity names',
    'flag': 'Use boolean intention names instead',
    'item': 'Too generic unless in collections context',
  };

  /// REFACTORING RECOMMENDATIONS
  static const Map<String, String> refactoringRecommendations = {
    'Long method names': 'Consider extracting to smaller, well-named methods',
    'Generic names': 'Make names more specific to their domain context',
    'Inconsistent naming': 'Standardize naming patterns within related classes',
    'Cryptic abbreviations': 'Expand to full, understandable words',
    'Misleading names': 'Rename to reflect actual behavior/purpose',
  };

  /// NAMING QUALITY METRICS
  static bool isGoodVariableName(String name) {
    return name.length >= 3 &&
           name.contains(RegExp(r'^[a-z][a-zA-Z0-9]*$')) &&
           !_containsAntiPatterns(name) &&
           _isIntentionRevealing(name);
  }

  static bool isGoodClassName(String name) {
    return name.length >= 3 &&
           name.contains(RegExp(r'^[A-Z][a-zA-Z0-9]*$')) &&
           !_containsAntiPatterns(name) &&
           _isIntentionRevealing(name);
  }

  static bool _containsAntiPatterns(String name) {
    const badPatterns = ['data', 'info', 'temp', 'obj', 'flag'];
    return badPatterns.any((pattern) => name.toLowerCase().contains(pattern));
  }

  static bool _isIntentionRevealing(String name) {
    // Simple heuristic: longer names are usually more intention-revealing
    return name.length > 4 || _isCommonGoodShortName(name);
  }

  static bool _isCommonGoodShortName(String name) {
    const goodShortNames = ['id', 'key', 'url', 'api', 'ui', 'cpu', 'ram'];
    return goodShortNames.contains(name.toLowerCase());
  }

  /// NAMING ANALYSIS REPORT
  static Map<String, dynamic> analyzeNaming(List<String> names) {
    int good = 0;
    int needsImprovement = 0;
    final suggestions = <String>[];

    for (final name in names) {
      if (isGoodVariableName(name) || isGoodClassName(name)) {
        good++;
      } else {
        needsImprovement++;
        suggestions.add('Consider improving: $name');
      }
    }

    return {
      'total': names.length,
      'good': good,
      'needsImprovement': needsImprovement,
      'score': names.isEmpty ? 0 : (good / names.length * 100).round(),
      'suggestions': suggestions,
    };
  }
}