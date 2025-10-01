import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/interfaces/premium_ui_interfaces.dart';

/// Premium Layout System - Handles layout patterns and responsive design following SRP
/// Responsibility: All layout-related functionality and responsive breakpoints
class PremiumLayoutSystem implements IPremiumLayoutSystem {
  bool _isInitialized = false;

  // Responsive breakpoints
  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 1024;

  // Grid configuration
  static const int _defaultMobileColumns = 1;
  static const int _defaultTabletColumns = 2;
  static const int _defaultDesktopColumns = 3;

  // Spacing constants
  static const double _defaultSpacing = 16.0;
  static const double _compactSpacing = 8.0;
  static const double _comfortableSpacing = 24.0;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  @override
  bool get isInitialized => _isInitialized;

  // ============ RESPONSIVE BREAKPOINTS ============

  @override
  bool isMobile(BuildContext context) {
    _ensureInitialized();
    final width = MediaQuery.of(context).size.width;
    return width < _mobileBreakpoint;
  }

  @override
  bool isTablet(BuildContext context) {
    _ensureInitialized();
    final width = MediaQuery.of(context).size.width;
    return width >= _mobileBreakpoint && width < _tabletBreakpoint;
  }

  @override
  bool isDesktop(BuildContext context) {
    _ensureInitialized();
    final width = MediaQuery.of(context).size.width;
    return width >= _tabletBreakpoint;
  }

  // ============ LAYOUT BUILDERS ============

  @override
  Widget createResponsiveLayout({
    required BuildContext context,
    Widget? mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    _ensureInitialized();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (isMobile(context)) {
          return mobile ?? _createFallbackWidget(context, 'Mobile');
        } else if (isTablet(context)) {
          return tablet ?? mobile ?? _createFallbackWidget(context, 'Tablet');
        } else {
          return desktop ?? tablet ?? mobile ?? _createFallbackWidget(context, 'Desktop');
        }
      },
    );
  }

  @override
  Widget createAdaptiveContainer({
    required Widget child,
    required BuildContext context,
    EdgeInsets? padding,
    double? maxWidth,
  }) {
    _ensureInitialized();

    final adaptivePadding = padding ?? _getAdaptivePadding(context);
    final adaptiveMaxWidth = maxWidth ?? _getAdaptiveMaxWidth(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: adaptiveMaxWidth),
        child: Padding(
          padding: adaptivePadding,
          child: child,
        ),
      ),
    );
  }

  // ============ GRID SYSTEMS ============

  @override
  Widget createResponsiveGrid({
    required List<Widget> children,
    required BuildContext context,
    int? mobileColumns,
    int? tabletColumns,
    int? desktopColumns,
    double spacing = _defaultSpacing,
  }) {
    _ensureInitialized();

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _getColumnsForScreen(
          context,
          mobileColumns ?? _defaultMobileColumns,
          tabletColumns ?? _defaultTabletColumns,
          desktopColumns ?? _defaultDesktopColumns,
        );

        return _ResponsiveGrid(
          columns: columns,
          spacing: spacing,
          children: children,
        );
      },
    );
  }

  // ============ ADVANCED LAYOUT METHODS ============

  /// Creates a responsive sidebar layout
  Widget createSidebarLayout({
    required BuildContext context,
    required Widget sidebar,
    required Widget content,
    double sidebarWidth = 250,
    bool collapsibleSidebar = true,
  }) {
    _ensureInitialized();

    if (isMobile(context)) {
      return _MobileSidebarLayout(
        sidebar: sidebar,
        content: content,
        collapsible: collapsibleSidebar,
      );
    } else {
      return _DesktopSidebarLayout(
        sidebar: sidebar,
        content: content,
        sidebarWidth: sidebarWidth,
        collapsible: collapsibleSidebar && isTablet(context),
      );
    }
  }

  /// Creates adaptive spacing based on screen size
  EdgeInsets getAdaptiveSpacing(BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    _ensureInitialized();

    double spacing;
    if (isMobile(context)) {
      spacing = mobile ?? _compactSpacing;
    } else if (isTablet(context)) {
      spacing = tablet ?? _defaultSpacing;
    } else {
      spacing = desktop ?? _comfortableSpacing;
    }

    return EdgeInsets.all(spacing);
  }

  /// Creates responsive typography scaling
  double getAdaptiveTextScale(BuildContext context) {
    _ensureInitialized();

    if (isMobile(context)) {
      return 0.9;
    } else if (isTablet(context)) {
      return 1.0;
    } else {
      return 1.1;
    }
  }

  // ============ PRIVATE METHODS ============

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('PremiumLayoutSystem must be initialized before use.');
    }
  }

  Widget _createFallbackWidget(BuildContext context, String deviceType) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text('No layout provided for $deviceType'),
    );
  }

  EdgeInsets _getAdaptivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  double _getAdaptiveMaxWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity;
    } else if (isTablet(context)) {
      return 768;
    } else {
      return 1200;
    }
  }

  int _getColumnsForScreen(
    BuildContext context,
    int mobile,
    int tablet,
    int desktop,
  ) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return desktop;
    }
  }
}

// ============ INTERNAL LAYOUT WIDGETS ============

/// Internal responsive grid widget
class _ResponsiveGrid extends StatelessWidget {
  final int columns;
  final double spacing;
  final List<Widget> children;

  const _ResponsiveGrid({
    required this.columns,
    required this.spacing,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox();

    final rows = (children.length / columns).ceil();

    return Column(
      children: List.generate(rows, (rowIndex) {
        final startIndex = rowIndex * columns;
        final endIndex = (startIndex + columns).clamp(0, children.length);
        final rowChildren = children.sublist(startIndex, endIndex);

        return Padding(
          padding: EdgeInsets.only(bottom: rowIndex < rows - 1 ? spacing : 0),
          child: Row(
            children: List.generate(columns, (colIndex) {
              if (colIndex < rowChildren.length) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: colIndex < columns - 1 ? spacing : 0,
                    ),
                    child: rowChildren[colIndex],
                  ),
                );
              } else {
                return const Expanded(child: SizedBox());
              }
            }),
          ),
        );
      }),
    );
  }
}

/// Internal mobile sidebar layout
class _MobileSidebarLayout extends StatelessWidget {
  final Widget sidebar;
  final Widget content;
  final bool collapsible;

  const _MobileSidebarLayout({
    required this.sidebar,
    required this.content,
    required this.collapsible,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: collapsible ? Drawer(child: sidebar) : null,
      body: content,
    );
  }
}

/// Internal desktop sidebar layout
class _DesktopSidebarLayout extends StatefulWidget {
  final Widget sidebar;
  final Widget content;
  final double sidebarWidth;
  final bool collapsible;

  const _DesktopSidebarLayout({
    required this.sidebar,
    required this.content,
    required this.sidebarWidth,
    required this.collapsible,
  });

  @override
  State<_DesktopSidebarLayout> createState() => _DesktopSidebarLayoutState();
}

class _DesktopSidebarLayoutState extends State<_DesktopSidebarLayout> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final currentWidth = _isCollapsed ? 80.0 : widget.sidebarWidth;

    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: currentWidth,
          child: Column(
            children: [
              if (widget.collapsible)
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(_isCollapsed ? Icons.menu : Icons.menu_open),
                    onPressed: () => setState(() => _isCollapsed = !_isCollapsed),
                  ),
                ),
              Expanded(child: widget.sidebar),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: widget.content),
      ],
    );
  }
}