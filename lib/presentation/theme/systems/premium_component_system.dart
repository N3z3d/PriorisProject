import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/interfaces/premium_ui_interfaces.dart';
import 'package:prioris/presentation/widgets/loading/premium_skeletons.dart';
import 'factories/export.dart';

/// Premium Component System - Coordinates component creation via specialized factories
/// Responsibility: Delegating component creation to specialized factories (SRP + Factory Pattern)
class PremiumComponentSystem implements IPremiumComponentSystem {
  PremiumComponentSystem(this._themeSystem);

  final IPremiumThemeSystem _themeSystem;
  late final PremiumButtonFactory _buttonFactory;
  late final PremiumCardFactory _cardFactory;
  late final PremiumListFactory _listFactory;
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    await _themeSystem.initialize();
    _initializeFactories();
    _isInitialized = true;
  }

  @override
  bool get isInitialized => _isInitialized;

  // ============ INITIALIZATION ============

  void _initializeFactories() {
    _buttonFactory = PremiumButtonFactory(_themeSystem);
    _cardFactory = PremiumCardFactory(_themeSystem);
    _listFactory = PremiumListFactory(_themeSystem);
  }

  // ============ BUTTON COMPONENTS ============

  @override
  Widget createButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    PremiumButtonStyle style = PremiumButtonStyle.primary,
    ButtonSize size = ButtonSize.medium,
    bool enableHaptics = true,
    bool enablePhysics = true,
    bool enableGlass = false,
  }) {
    _ensureInitialized();
    return _buttonFactory.createButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      style: style,
      size: size,
      enableHaptics: enableHaptics,
      enablePhysics: enablePhysics,
      enableGlass: enableGlass,
    );
  }

  @override
  Widget createFAB({
    required VoidCallback onPressed,
    required Widget child,
    bool enableHaptics = true,
    bool enablePhysics = true,
    bool enableGlass = true,
    Color? color,
  }) {
    _ensureInitialized();
    return _buttonFactory.createFAB(
      onPressed: onPressed,
      child: child,
      enableHaptics: enableHaptics,
      enablePhysics: enablePhysics,
      enableGlass: enableGlass,
      color: color,
    );
  }

  // ============ CARD COMPONENTS ============

  @override
  Widget createCard({
    required Widget child,
    VoidCallback? onTap,
    bool enableHaptics = true,
    bool enablePhysics = true,
    bool enableGlass = false,
    bool showLoading = false,
    SkeletonType skeletonType = SkeletonType.custom,
    EdgeInsets? padding,
    double? elevation,
  }) {
    _ensureInitialized();
    return _cardFactory.createCard(
      child: child,
      onTap: onTap,
      enableHaptics: enableHaptics,
      enablePhysics: enablePhysics,
      enableGlass: enableGlass,
      showLoading: showLoading,
      skeletonType: skeletonType,
      padding: padding,
      elevation: elevation,
    );
  }

  // ============ LIST COMPONENTS ============

  @override
  Widget createListItem({
    required Widget child,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    List<Widget>? swipeActions,
    bool enableHaptics = true,
    bool enablePhysics = true,
    bool showLoading = false,
  }) {
    _ensureInitialized();
    return _listFactory.createListItem(
      child: child,
      onTap: onTap,
      onLongPress: onLongPress,
      swipeActions: swipeActions,
      enableHaptics: enableHaptics,
      enablePhysics: enablePhysics,
      showLoading: showLoading,
    );
  }

  // ============ PRIVATE METHODS ============

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('PremiumComponentSystem must be initialized before use.');
    }
  }
}