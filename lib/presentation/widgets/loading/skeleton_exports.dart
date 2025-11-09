/// Export file for the SOLID skeleton system architecture
///
/// This file provides clean imports for all skeleton-related components
/// following the new modular, SOLID-principled design.
library skeleton_exports;

// Core interfaces
export 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';

// Base components
export 'package:prioris/presentation/widgets/loading/components/skeleton_blocks.dart';
export 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';

// Specialized skeleton systems
export 'package:prioris/presentation/widgets/loading/systems/card_skeleton_system.dart';
export 'package:prioris/presentation/widgets/loading/systems/list_skeleton_system.dart';
export 'package:prioris/presentation/widgets/loading/systems/form_skeleton_system.dart';
export 'package:prioris/presentation/widgets/loading/systems/grid_skeleton_system.dart';
export 'package:prioris/presentation/widgets/loading/systems/complex_layout_skeleton_system.dart';

// Main coordinator (excludes PremiumSkeletons to avoid conflict)
export 'package:prioris/presentation/widgets/loading/premium_skeleton_manager.dart'
    hide PremiumSkeletons;

// Backward-compatible entry point
export 'package:prioris/presentation/widgets/loading/premium_skeletons.dart';