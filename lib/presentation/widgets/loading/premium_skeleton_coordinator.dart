import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';
import 'package:prioris/presentation/widgets/loading/systems/card_skeleton_system.dart';
import 'package:prioris/presentation/widgets/loading/systems/list_skeleton_system.dart';
import 'package:prioris/presentation/widgets/loading/systems/form_skeleton_system.dart';
import 'package:prioris/presentation/widgets/loading/systems/grid_skeleton_system.dart';
import 'package:prioris/presentation/widgets/loading/systems/complex_layout_skeleton_system.dart';

/// Premium skeleton coordinator - Main coordinator following SOLID principles
/// Single Responsibility: Coordinate skeleton system selection and creation
/// Open/Closed: Extensible for new skeleton systems without modification
/// Dependency Inversion: Depends on abstractions (ISkeletonSystem)
class PremiumSkeletonCoordinator implements ISkeletonSystemFactory {
  static final PremiumSkeletonCoordinator _instance = PremiumSkeletonCoordinator._internal();
  factory PremiumSkeletonCoordinator() => _instance;
  PremiumSkeletonCoordinator._internal() {
    _registerDefaultSystems();
  }

  final Map<String, ISkeletonSystem> _registeredSystems = {};
  final Map<String, String> _typeToSystemMap = {};

  @override
  List<String> get registeredSystems => _registeredSystems.keys.toList();

  /// Gets all available skeleton types across all systems
  List<String> get availableSkeletonTypes => _typeToSystemMap.keys.toList();

  @override
  void registerSystem(String systemId, ISkeletonSystem system) {
    _registeredSystems[systemId] = system;

    // Map supported types to this system
    for (final type in system.supportedTypes) {
      _typeToSystemMap[type] = systemId;
    }
  }

  @override
  ISkeletonSystem? createSystem(String systemId) {
    return _registeredSystems[systemId];
  }

  /// Creates a skeleton widget by type using the appropriate system
  Widget createSkeletonByType(
    String skeletonType, {
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    final system = _findSystemForType(skeletonType);
    if (system == null) {
      return _createFallbackSkeleton(width: width, height: height);
    }

    return system.createSkeleton(
      width: width,
      height: height,
      options: options,
    );
  }

  /// Creates a skeleton variant using the appropriate system
  Widget createSkeletonVariant(
    String systemId,
    String variant, {
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    final system = _registeredSystems[systemId];
    if (system is IVariantSkeletonSystem) {
      return system.createVariant(
        variant,
        width: width,
        height: height,
        options: options,
      );
    }

    return system?.createSkeleton(
      width: width,
      height: height,
      options: options,
    ) ?? _createFallbackSkeleton(width: width, height: height);
  }

  /// Creates an animated skeleton using the appropriate system
  Widget createAnimatedSkeleton(
    String systemId, {
    double? width,
    double? height,
    Duration? duration,
    AnimationController? controller,
    Map<String, dynamic>? options,
  }) {
    final system = _registeredSystems[systemId];
    if (system is IAnimatedSkeletonSystem) {
      return system.createAnimatedSkeleton(
        width: width,
        height: height,
        duration: duration,
        controller: controller,
        options: options,
      );
    }

    return system?.createSkeleton(
      width: width,
      height: height,
      options: options,
    ) ?? _createFallbackSkeleton(width: width, height: height);
  }

  /// Creates skeleton using smart type detection
  Widget createSmartSkeleton(
    String hint, {
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    final detectedType = _detectSkeletonType(hint);
    return createSkeletonByType(
      detectedType,
      width: width,
      height: height,
      options: options,
    );
  }

  /// Batch creates multiple skeletons for list scenarios
  List<Widget> createBatchSkeletons(
    String skeletonType, {
    required int count,
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    final system = _findSystemForType(skeletonType);
    if (system == null) {
      return List.generate(count, (index) =>
        _createFallbackSkeleton(width: width, height: height));
    }

    return List.generate(count, (index) {
      return system.createSkeleton(
        width: width,
        height: height,
        options: {
          ...options ?? {},
          'batch_index': index,
          'batch_count': count,
        },
      );
    });
  }

  /// Creates a skeleton with adaptive loading based on content
  Widget createAdaptiveSkeleton({
    required Widget child,
    required bool isLoading,
    String? skeletonType,
    Duration animationDuration = const Duration(milliseconds: 300),
    Map<String, dynamic>? options,
  }) {
    return _AdaptiveSkeletonWrapper(
      manager: this,
      child: child,
      isLoading: isLoading,
      skeletonType: skeletonType,
      animationDuration: animationDuration,
      options: options ?? {},
    );
  }

  /// Gets system information for debugging/monitoring
  Map<String, dynamic> getSystemInfo() {
    return {
      'registered_systems': _registeredSystems.length,
      'available_types': _typeToSystemMap.length,
      'systems': _registeredSystems.keys.toList(),
      'type_mappings': _typeToSystemMap,
    };
  }

  /// Validates if a skeleton type is supported
  bool isSkeletonTypeSupported(String skeletonType) {
    return _findSystemForType(skeletonType) != null;
  }

  /// Gets recommended skeleton type based on context
  String getRecommendedSkeletonType(BuildContext context, Widget widget) {
    // Smart recommendation based on widget type and context
    if (widget is Card) return 'task_card';
    if (widget is ListTile) return 'list_item';
    if (widget is GridView) return 'grid_view';
    if (widget.runtimeType.toString().contains('Form')) return 'form_field';

    return 'standard';
  }

  // Private methods

  void _registerDefaultSystems() {
    registerSystem('card_skeleton_system', CardSkeletonSystem());
    registerSystem('list_skeleton_system', ListSkeletonSystem());
    registerSystem('form_skeleton_system', FormSkeletonSystem());
    registerSystem('grid_skeleton_system', GridSkeletonSystem());
    registerSystem('complex_layout_skeleton_system', ComplexLayoutSkeletonSystem());
  }

  ISkeletonSystem? _findSystemForType(String skeletonType) {
    // Direct mapping
    if (_typeToSystemMap.containsKey(skeletonType)) {
      return _registeredSystems[_typeToSystemMap[skeletonType]];
    }

    // Fuzzy matching - find system that can handle this type
    for (final system in _registeredSystems.values) {
      if (system.canHandle(skeletonType)) {
        return system;
      }
    }

    return null;
  }

  String _detectSkeletonType(String hint) {
    final hintLower = hint.toLowerCase();

    // Card patterns
    if (hintLower.contains('card') || hintLower.contains('task') || hintLower.contains('habit')) {
      return 'task_card';
    }

    // List patterns
    if (hintLower.contains('list') || hintLower.contains('item') || hintLower.contains('tile')) {
      return 'list_item';
    }

    // Form patterns
    if (hintLower.contains('form') || hintLower.contains('input') || hintLower.contains('field')) {
      return 'form_field';
    }

    // Grid patterns
    if (hintLower.contains('grid') || hintLower.contains('dashboard') || hintLower.contains('stats')) {
      return 'grid_view';
    }

    // Page patterns
    if (hintLower.contains('page') || hintLower.contains('screen') || hintLower.contains('layout')) {
      return 'page_layout';
    }

    return 'standard';
  }

  Widget _createFallbackSkeleton({double? width, double? height}) {
    return Container(
      width: width,
      height: height ?? 50,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

/// Adaptive skeleton wrapper for seamless loading transitions
class _AdaptiveSkeletonWrapper extends StatefulWidget {
  final PremiumSkeletonManager manager;
  final Widget child;
  final bool isLoading;
  final String? skeletonType;
  final Duration animationDuration;
  final Map<String, dynamic> options;

  const _AdaptiveSkeletonWrapper({
    required this.manager,
    required this.child,
    required this.isLoading,
    this.skeletonType,
    required this.animationDuration,
    required this.options,
  });

  @override
  State<_AdaptiveSkeletonWrapper> createState() => _AdaptiveSkeletonWrapperState();
}

class _AdaptiveSkeletonWrapperState extends State<_AdaptiveSkeletonWrapper>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    if (!widget.isLoading) {
      _fadeController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_AdaptiveSkeletonWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading != widget.isLoading) {
      if (widget.isLoading) {
        _fadeController.reverse();
      } else {
        _fadeController.forward();
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Skeleton layer
        if (widget.isLoading) _buildSkeletonLayer(),

        // Content layer
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: widget.child,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSkeletonLayer() {
    final skeletonType = widget.skeletonType ??
        widget.manager.getRecommendedSkeletonType(context, widget.child);

    return widget.manager.createSkeletonByType(
      skeletonType,
      options: widget.options,
    );
  }
}

/// Extension methods for convenient skeleton creation
extension SkeletonManagerExtensions on PremiumSkeletonManager {
  /// Quick card skeleton creation
  Widget card({
    String variant = 'task',
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    return createSkeletonVariant(
      'card_skeleton_system',
      variant,
      width: width,
      height: height,
      options: options,
    );
  }

  /// Quick list skeleton creation
  Widget list({
    String variant = 'standard',
    int itemCount = 5,
    double? width,
    Map<String, dynamic>? options,
  }) {
    return createSkeletonVariant(
      'list_skeleton_system',
      variant,
      width: width,
      options: {
        'itemCount': itemCount,
        ...options ?? {},
      },
    );
  }

  /// Quick form skeleton creation
  Widget form({
    String variant = 'standard',
    int fieldCount = 4,
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    return createSkeletonVariant(
      'form_skeleton_system',
      variant,
      width: width,
      height: height,
      options: {
        'fieldCount': fieldCount,
        ...options ?? {},
      },
    );
  }

  /// Quick grid skeleton creation
  Widget grid({
    String variant = 'standard',
    int itemCount = 6,
    int crossAxisCount = 2,
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    return createSkeletonVariant(
      'grid_skeleton_system',
      variant,
      width: width,
      height: height,
      options: {
        'itemCount': itemCount,
        'crossAxisCount': crossAxisCount,
        ...options ?? {},
      },
    );
  }

  /// Quick page skeleton creation
  Widget page({
    String variant = 'standard',
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    return createSkeletonVariant(
      'complex_layout_skeleton_system',
      variant,
      width: width,
      height: height,
      options: options,
    );
  }
}

/// Helper class for easy access to the skeleton coordinator
/// Renamed to avoid conflict with the main PremiumSkeletons class
class SkeletonCoordinatorHelper {
  static final PremiumSkeletonCoordinator _coordinator = PremiumSkeletonCoordinator();

  /// Get the singleton coordinator instance
  static PremiumSkeletonCoordinator get coordinator => _coordinator;
}