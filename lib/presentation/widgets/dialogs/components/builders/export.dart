/// Export centralisé pour tous les builders spécialisés de dialogs premium
///
/// Ce fichier exporte tous les services SOLID-compliant qui remplacent
/// la classe monolithique PremiumLogoutDialogUI originale.
///
/// SOLID COMPLIANCE:
/// - ISP: Interface segregation avec exports modulaires
/// - DIP: Abstraction des services de construction de dialogs
///
/// Refactoring: 669 lignes → 4 services spécialisés (<150 lignes chacun)

// Services spécialisés SOLID-compliant
export 'dialog_container_builder.dart';
export 'premium_header_builder.dart';
export 'action_buttons_builder.dart';
export 'content_section_builder.dart';